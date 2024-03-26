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
    homepage = "https://gitlab.freedesktop.org/mesa/drm";
    downloadPage = "https://dri.freedesktop.org/libdrm/";
    description = "Direct Rendering Manager library and headers";
    longDescription = ''
      A userspace library for accessing the DRM (Direct Rendering Manager) on
      Linux, BSD and other operating systems that support the ioctl interface.
      The library provides wrapper functions for the ioctls to avoid exposing
      the kernel interface directly, and for chipsets with drm memory manager,
      support for tracking relocations and buffers.
      New functionality in the kernel DRM drivers typically requires a new
      libdrm, but a new libdrm will always work with an older kernel.

      libdrm is a low-level library, typically used by graphics drivers such as
      the Mesa drivers, the X drivers, libva and similar projects.
    '';
    license = licenses.mit;
    platforms = lib.subtractLists platforms.darwin platforms.unix;
  };
}
