{ elk-port ? 9200 }:
let
  nixpkgsSrc = (import (fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/8d0340aee5caac3807c58ad7fa4ebdbbdd9134d6.tar.gz";
    sha256 = "0r00azbz64fz8yylm8x37imnrsm5cdzshd5ma8gwfwjyw166n3r1";
  }));
  pkgs = nixpkgsSrc { };

in let
  fri = rec {
    # Debug
    debug = pkgs.mkShell {
      inputsFrom = [ ];
      buildInputs = [ pkgs.strace ];
    };
  };
in fri
