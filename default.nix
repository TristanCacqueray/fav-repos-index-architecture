{ elk-port ? 9200 }:
let
  nixpkgsSrc = (import (fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/8d0340aee5caac3807c58ad7fa4ebdbbdd9134d6.tar.gz";
    sha256 = "0r00azbz64fz8yylm8x37imnrsm5cdzshd5ma8gwfwjyw166n3r1";
  }));
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
    fri-backend = self.callCabal2nix "fri-backend" ./backend/. { };
  };

  # TODO: push grpc to the next change
  grpc = (import ../../awakesecurity/gRPC-haskell/release.nix).linuxPkgs;
  hsPkgs = grpc.haskellPackages.extend (haskellExtension);

in let
  fri = rec {
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

    db = { start = startElk; };

    # Backend
    backend = hsPkgs.fri-backend;

    # Debug
    devel = hsPkgs.shellFor {
      packages = p: [ p.fri-backend ];
      buildInputs = [
        elk
        pkgs.strace
        hsPkgs.hlint
        hsPkgs.cabal-install
        hsPkgs.haskell-language-server
      ];
    };
  };
in fri
