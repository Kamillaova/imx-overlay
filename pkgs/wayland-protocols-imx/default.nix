{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, meson
, ninja
, wayland-scanner
, python3
, wayland
}:
stdenv.mkDerivation rec {
	pname = "wayland-protocols-imx";
	version = "lf-6.6.3-1.0.0";

	src = fetchFromGitHub {
		owner = "nxp-imx";
		repo = "wayland-protocols-imx";
		rev = version;
		hash = "sha256-MogY2FikGLe30y+FenDPYv0NOHVHhAoCDLFfmoVXsjU=";
	};

	postPatch = lib.optionalString doCheck ''
		patchShebangs tests/
	'';

	depsBuildBuild = [ pkg-config ];
	nativeBuildInputs = [ meson ninja wayland-scanner ];
	nativeCheckInputs = [ wayland python3 ];

	doCheck = stdenv.buildPlatform.linker == "bfd" && wayland.withLibraries; # TODO

	mesonFlags = [ (lib.mesonBool "tests" doCheck) ];

	meta = with lib; {
		description = "i.MX Wayland Protocols";
		homepage = "https://github.com/nxp-imx/wayland-protocols-imx";
		license = licenses.mit; # Expat version
		platforms = platforms.linux;
	};

#	passthru = { inherit version; };
}
