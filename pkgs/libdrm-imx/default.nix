{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, meson
, ninja
, docutils
, libpthreadstubs
, libpciaccess
}:
stdenv.mkDerivation rec {
  pname = "libdrm-imx";
	version = "lf-6.6.3-1.0.0";

	src = fetchFromGitHub {
		owner = "nxp-imx";
		repo = "libdrm-imx";
		rev = version;
		hash = "sha256-nVwzcdXziSqAilrLKxgfqP349IYrrnv977DipHLO9ek=";
	};

  outputs = [ "out" "dev" "bin" ];

	depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [ meson ninja docutils ];
  buildInputs = [ libpthreadstubs libpciaccess ];

  mesonFlags = [
    "-Dinstall-test-programs=true"
    "-Dcairo-tests=disabled"
    "-Dvalgrind=disabled"
    (lib.mesonEnable "omap" stdenv.hostPlatform.isLinux)
  ] ++ lib.optionals stdenv.hostPlatform.isAarch [
    "-Dtegra=enabled"
  ] ++ lib.optionals (!stdenv.hostPlatform.isLinux) [
    "-Detnaviv=disabled"
  ];

  meta = with lib; {
    homepage = "https://github.com/nxp-imx/libdrm-imx";
    description = "i.MX DRM Direct Rendering Manager";
    license = licenses.mit;
    platforms = lib.subtractLists platforms.darwin platforms.unix;
    maintainers = with maintainers; [ kamillaova ];
  };
}
