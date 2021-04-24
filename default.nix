{ elk-port ? 9200 }:
let
  nixpkgsSrc = (import (fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/8d0340aee5caac3807c58ad7fa4ebdbbdd9134d6.tar.gz";
    sha256 = "0r00azbz64fz8yylm8x37imnrsm5cdzshd5ma8gwfwjyw166n3r1";
  }));
  pkgs = nixpkgsSrc { };
  pkgsNonFree = nixpkgsSrc { config.allowUnfree = true; };

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
        ${pkgs.rsync}/bin/rsync -a ${elk}/config/ $ES_HOME/config/
        ln -sf ${elk}/modules $ES_HOME/modules 2> /dev/null
        find $ES_HOME -type f | xargs chmod 0600
        find $ES_HOME -type d | xargs chmod 0700
        cat ${elkConf} > $ES_HOME/config/elasticsearch.yml
        exec ${elk}/bin/elasticsearch
      '';
    };
    elk = pkgsNonFree.elasticsearch7;

    # Debug
    debug = pkgs.mkShell {
      inputsFrom = [ elk ];
      buildInputs = [ pkgs.strace ];
    };
  };
in fri
