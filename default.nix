{ elk-port ? 9242, elk-home ? "/tmp/es-home" }:
let
  # pin the upstream nixpkgs
  nixpkgsSrc = (import (fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/8d0340aee5caac3807c58ad7fa4ebdbbdd9134d6.tar.gz";
    sha256 = "0r00azbz64fz8yylm8x37imnrsm5cdzshd5ma8gwfwjyw166n3r1";
  }));
  # import gRPC-haskell derivations and overlay to ensure the libgrpc build correctly
  grpcHaskellRepo = fetchTarball {
    url =
      "https://github.com/awakesecurity/gRPC-haskell/archive/78bcc540af43f32a4411c9142f629dd928b911d6.tar.gz";
    sha256 = "1mvq06crjazczq3vwbcnj8nq2kqn44p9cnljcybzpfqw4ha0kg19";
  };
  nixpkgsGrpcSrc = (import "${grpcHaskellRepo}/nixpkgs.nix");
  # setup the actual package set
  pkgs = nixpkgsSrc { };
  pkgsNonFree = nixpkgsSrc { config.allowUnfree = true; };

  # update haskell packages set with newer dependencies and our code
  haskellExtension = self: super: {
    # relude>1 feature exposed module
    relude = pkgs.haskell.lib.overrideCabal super.relude {
      version = "1.0.0.1";
      sha256 = "0cw9a1gfvias4hr36ywdizhysnzbzxy20fb3jwmqmgjy40lzxp2g";
    };
    # bloodhound needs a new release, use current master for now
    bloodhound = pkgs.haskell.lib.overrideCabal super.bloodhound {
      src = pkgs.fetchFromGitHub {
        owner = "bitemyapp";
        repo = "bloodhound";
        rev = "4775ebb759fe1b7cb5f880e4a41044b2363d98af";
        sha256 = "00wzaj4slvdxanm0krbc6mfn96mi5c6hhd3sywd3gq5m2ff59ggn";
      };
      broken = false;
    };

    caching-reverse-proxy = self.callCabal2nix "caching-reverse-proxy"
      ../../../softwarefactory-project.io/software-factory/caching-reverse-proxy/.
      { };

    # our code is added to the set
    fri-backend = self.callCabal2nix "fri-backend" ./. { };
  };

  # setup the haskell package set using the gRPC-haskell overlay
  grpc-overlay = (import "${grpcHaskellRepo}/release.nix").overlay;
  pkgs-grpc = nixpkgsGrpcSrc {
    overlays = [ grpc-overlay ];
    config = { allowBroken = true; };
  };
  hsPkgs = pkgs-grpc.haskellPackages.extend (haskellExtension);

  # a python venv with grpc tools
  python-grpc = pkgs.python39.withPackages (ps: [ ps.grpcio ps.grpcio-tools ]);

  # DB
  elkConf = pkgs.writeTextFile {
    name = "elasticsearch.yml";
    text = ''
      cluster.name: fri-elk
      http.port: ${toString elk-port}
      discovery.type: single-node
      network.host: 0.0.0.0
    '';
  };
  elkStart = pkgs.writeScriptBin "elk-start" ''
    # todo: only set max_map_count when necessary
    ${pkgs.sudo}/bin/sudo sysctl -w vm.max_map_count=262144
    set -ex
    export ES_HOME=${elk-home}
    mkdir -p $ES_HOME/logs $ES_HOME/data
    ${pkgs.rsync}/bin/rsync -a ${elk}/config/ $ES_HOME/config/
    ln -sf ${elk}/modules/ $ES_HOME/
    find $ES_HOME -type f | xargs chmod 0600
    find $ES_HOME -type d | xargs chmod 0700
    cat ${elkConf} > $ES_HOME/config/elasticsearch.yml
    exec ${elk}/bin/elasticsearch -p $ES_HOME/pid
  '';
  elkStop = pkgs.writeScriptBin "elk-stop" "kill $(cat /tmp/es-home/pid)";
  elkDestroy = pkgs.writeScriptBin "elk-destroy" ''
    set -x
    [ -f ${elk-home}/pid ] && (${elkStop}/bin/elkstop; sleep 5)
    rm -Rf ${elk-home}/
  '';

  elk = pkgsNonFree.elasticsearch7;

  # Protobuf
  grpc-web = pkgs.stdenv.mkDerivation rec {
    pname = "grpc-web";
    version = "1.2.1";
    src = pkgs.fetchurl {
      url =
        "https://github.com/grpc/grpc-web/releases/download/1.2.1/protoc-gen-grpc-web-1.2.1-linux-x86_64";
      sha256 = "15y5k71f1nm1zg9misxs5b7yk0n1g32hwsc3ip9khbchnxfn5qbc";
    };
    propagatedBuildInputs = [ pkgs.protobuf ];
    unpackPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/protoc-gen-grpc-web
    '';
    dontStrip = true;
    dontInstall = true;
  };
  renameScript = ../../change-metrics/monocle/codegen/rename_bs_module.py;
  protobufCodegen = pkgs.writeScriptBin "protobuf-codegen" ''
    set -x
    echo "# Haskell bindings"
    ${hsPkgs.proto3-suite}/bin/compile-proto-file --includeDir protos/ --proto fri/messages.proto --out src/
    ${hsPkgs.proto3-suite}/bin/compile-proto-file --includeDir protos/ --proto fri/services.proto --out src/
    ${pkgs.ormolu}/bin/ormolu -i src/Fri/Messages.hs
    ${pkgs.ormolu}/bin/ormolu -i src/Fri/Services.hs
    echo "# Python bindings"
    ${python-grpc}/bin/python -m grpc_tools.protoc -Iprotos --python_out=python/ --grpc_python_out=python/ fri/messages.proto fri/services.proto
    echo "# Javascript bindings using ${grpc-web}"
    ${pkgs.protobuf}/bin/protoc -I=protos fri/messages.proto fri/services.proto --js_out=import_style=commonjs:javascript/src/ --grpc-web_out=import_style=commonjs,mode=grpcwebtext:javascript/src/
    echo "# ReScript bindings"
    ${pkgs.ocamlPackages.ocaml-protoc}/bin/ocaml-protoc -bs -ml_out javascript/src/messages/ protos/fri/messages.proto
    ${pkgs.python3}/bin/python ${renameScript} ./javascript/src/messages/
    echo Done.
  '';

  # user interface
  node = pkgs.nodePackages.pnpm;

  # proxy
  envoy = pkgs.envoy;
  envoyConf = pkgs.writeTextFile {
    name = "envoy.yaml";
    text = builtins.readFile ./conf/envoy.yaml;
  };
  envoyStart =
    pkgs.writeScriptBin "envoy-start" "${envoy}/bin/envoy -c ${envoyConf}";

  apiStart = pkgs.writeScriptBin "api-start"
    "${hsPkgs.fri-backend}/bin/fri-api --elk-url localhost:8080 --port 8042";

  githubCacheStart = pkgs.writeScriptBin "gh-cache-start"
    "${hsPkgs.caching-reverse-proxy}/bin/caching-reverse-proxy --path /srv/api.github.com --port 8043 --dest-host api.github.com --dest-port 443";

  friStart = pkgs.writeScriptBin "fri-start" ''
    echo "TODO: start processes in tmux panes or gnome-shell tabs"
    echo "[+] Starting the database..."
    echo ${elkStart}
    echo "[+] Start the api..."
  '';

in {
  # Backend
  backend = hsPkgs.fri-backend;

  # Dev environment
  shell = hsPkgs.shellFor {
    packages = p: [ p.fri-backend ];
    buildInputs = [
      hsPkgs.hlint
      hsPkgs.cabal-install
      hsPkgs.ghcid
      hsPkgs.haskell-language-server
    ];
    propagatedBuildInputs = [
      pkgs.strace
      pkgs.esbuild
      pkgs.ocamlPackages.ocaml-protoc
      elk
      envoy
      python-grpc
      grpc-web
      node
      elkStart
      elkStop
      elkDestroy
      githubCacheStart
      protobufCodegen
      envoyStart
      friStart
    ];
  };
}
