{ lib
, fetchFromGitHub
, rustPlatform
, clang
, libclang
, llvm
, m4
, pkg-config
, expat
, fontconfig
, libX11
, libXft
, libXinerama
}:

# The dmenu-rs package has extensive plugin support. However, this derivation
# only builds the package with the default set of plugins. If you'd like to
# further customize dmenu-rs you can build it from the source.
# See: https://github.com/Shizcow/dmenu-rs#plugins
rustPlatform.buildRustPackage rec {
  pname = "dmenu-rs";
  version = "5.5.1";

  src = fetchFromGitHub {
    owner = "Shizcow";
    repo = pname;
    rev = version;
    sha256 = "sha256-WpDqBjIZ5ESnoRtWZmvm+gNTLKqxL4IibRVCj0yRIFM=";
  };

  nativeBuildInputs = [
    clang
    libclang
    llvm
    m4
    pkg-config
  ];

  buildInputs = [
    expat
    fontconfig
    libX11
    libXft
    libXinerama
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  #cargoRoot = "src";

  # As suggested in the nixpkgs manual section on building rust packages, the
  # derivation's Cargo.lock file is copied into the source.
  postPatch = ''
    export cargoRoot="src"
    cp ${./Cargo.lock} src/Cargo.lock
  '';

  preConfigure = ''
    sed -i "s@PREFIX = /usr/local@PREFIX = $out@g" config.mk
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    make install
  '';

  # TODO Try harder to get make test working in checkPhase.
  # Running make test invokes X11 and yields a cannot open display error.
  doCheck = false;
  checkPhase = ''
    make test
  '';

  RUST_BACKTRACE = "full";
  LIBCLANG_PATH = "${libclang.lib}/lib";

  meta = with lib; {
    description = "A pixel perfect port of dmenu, rewritten in Rust with extensive plugin support";
    homepage = "https://github.com/Shizcow/dmenu-rs";
    license = with licenses; [ gpl3Only ];
    maintainers = with maintainers; [ benjaminedwardwebb ];
    platforms = platforms.linux; # TODO
  };
}
