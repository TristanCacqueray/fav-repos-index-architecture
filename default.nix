{ elk-port ? 9200 }:
let
  # pin the upstream nixpkgs
  nixpkgsSrc = (import (fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/8d0340aee5caac3807c58ad7fa4ebdbbdd9134d6.tar.gz";
    sha256 = "0r00azbz64fz8yylm8x37imnrsm5cdzshd5ma8gwfwjyw166n3r1";
  }));
  # use the nixpkgs source of gRPC-haskell to ensure the libgrpc build correctly
  nixpkgsGrpcSrc = (import ../../awakesecurity/gRPC-haskell/nixpkgs.nix);
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

    # our code is added to the set
    fri-backend = self.callCabal2nix "fri-backend" ./. { };
  };

  # setup the haskell package set using the gRPC-haskell overlay
  grpc-overlay = (import ../../awakesecurity/gRPC-haskell/release.nix).overlay;
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
      http.port: ${toString elk-port}
    '';
  };
  startElk = pkgs.writeTextFile {
    name = "startElk.sh";
    executable = true;
    text = ''
      export ES_HOME=/tmp/es-home
      mkdir -p $ES_HOME/logs $ES_HOME/data
             E        ${pkgs.rsync}/bin/rsync -a ${elk}/config/ $ES_HOME/config/
      ln -sf ${elk}/modules $ES_HOME/modules 2> /dev/null
      find $ES_HOME -type f | xargs chmod 0600
      find $ES_HOME -type d | xargs chmod 0700
      cat ${elkConf} > $ES_HOME/config/elasticsearch.yml
      exec ${elk}/bin/elasticsearch
    '';
  };
  elk = pkgsNonFree.elasticsearch7;

  # Protobuf
  renderSchema = pkgs.writeTextFile {
    name = "renderSchema.sh";
    executable = true;
    text = ''
      ${hsPkgs.proto3-suite}/bin/compile-proto-file --proto protos/fri.proto --out src/
      ${python-grpc}/bin/python -m grpc_tools.protoc -Iprotos --python_out=python/ --grpc_python_out=python/ fri.proto
    '';
  };

in {
  # Helper to manage the db
  db = { start = startElk; };

  renderSchema = renderSchema;

  # Backend
  backend = hsPkgs.fri-backend;

  # Dev environment
  shell = hsPkgs.shellFor {
    packages = p: [ p.fri-backend ];
    buildInputs =
      [ hsPkgs.hlint hsPkgs.cabal-install hsPkgs.haskell-language-server ];
    propagatedBuildInputs = [ pkgs.strace elk python-grpc ];
  };
}
