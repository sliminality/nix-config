{ lib, stdenv, pkgs }:

stdenv.mkDerivation rec {
  pname = "n";
  version = "9.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "tj";
    repo = "n";
    rev = "v${version}";
    sha256 = "sha256-q4wz8xgK3WsMZ4FgdUHMUVbfqmwS6xB/6N/RFYYI12Y=";
  };

  # Needed to skip the default build phase, which tries to call `make`.
  buildPhase = "true";

  installPhase = ''
    mkdir -p $out
    PREFIX=$out make install
  '';

  meta = {
    description = "Node version management";
    homepage = "https://github.com/tj/n";
    platforms = [ "aarch64-darwin" ];
    license = lib.licenses.mit;
    maintainers = [];
  };
}
