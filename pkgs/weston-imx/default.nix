{ lib
, stdenv
, fetchpatch2
, fetchFromGitHub
, pkg-config
, meson, ninja, python3
, wayland-scanner
, wayland, wayland-protocols-imx
, cairo, libGL, libdrm-imx, mesa
, libevdev, libinput
, libxkbcommon, seatd
, xcbutilcursor
, imx-gpu-viv
, imx-gpu-g2d

, demoSupport ? true
, hdrSupport ? true, libdisplay-info
, jpegSupport ? true, libjpeg
, lcmsSupport ? true, lcms2
, pangoSupport ? true, pango
, pipewireSupport ? false, pipewire
, remotingSupport ? false, gst_all_1
#, vncSupport ? true, aml, neatvnc, pam
, rdpSupport ? true, freerdp
, vaapiSupport ? false, libva
, webpSupport ? true, libwebp
, xwaylandSupport ? true, xwayland, libXcursor
}:
stdenv.mkDerivation rec {
	pname = "weston-imx";
	version = "10.0.0";

	src = fetchFromGitHub {
		owner = "nxp-imx";
		repo = "weston-imx";
		rev = version;
		hash = "sha256-AxppkUZBJx9C964HjJKJzMRfQsxX8WREXfZvx//hOjo=";
	};

#	patches = [
#		# ci, backend-vnc: update to Neat VNC 0.7.0
#		# part of https://gitlab.freedesktop.org/wayland/weston/-/merge_requests/1051
#		(fetchpatch2 {
#			url = "https://gitlab.freedesktop.org/wayland/weston/-/commit/8895b15f3dfc555a869e310ff6e16ff5dced1336.patch";
#			hash = "sha256-PGAmQhzG8gZcYRaZwhKPlgzfbILIXGAHLSd9dCHAP1A=";
#			excludes = [ ".gitlab-ci.yml" ];
#		})
#	];

	depsBuildBuild = [ pkg-config ];
	nativeBuildInputs = [ meson ninja python3 wayland-scanner ];
	buildInputs = [
		wayland wayland-protocols-imx
		cairo /*libGL*/ libdrm-imx /*mesa*/
		libevdev libinput
		seatd libxkbcommon
		imx-gpu-viv
		imx-gpu-g2d
	] ++ lib.optional hdrSupport libdisplay-info
		++ lib.optional jpegSupport libjpeg
		++ lib.optional lcmsSupport lcms2
		++ lib.optional pangoSupport pango
		++ lib.optional pipewireSupport pipewire
		++ lib.optional rdpSupport freerdp
		++ lib.optionals remotingSupport [ gst_all_1.gstreamer gst_all_1.gst-plugins-base ]
		++ lib.optional vaapiSupport libva
#		++ lib.optionals vncSupport [ aml neatvnc pam ]
		++ lib.optional webpSupport libwebp
		++ lib.optionals xwaylandSupport [ libXcursor xcbutilcursor xwayland ];

	mesonFlags = [
#		(lib.mesonBool "backend-wayland" false)
#		(lib.mesonBool "renderer-gl" false)
		(lib.mesonBool "test-junit-xml" false)
		(lib.mesonBool "backend-drm-screencast-vaapi" vaapiSupport)
		(lib.mesonBool "backend-pipewire" pipewireSupport)
		(lib.mesonBool "backend-rdp" rdpSupport)
#		(lib.mesonBool "backend-vnc" vncSupport)
		(lib.mesonBool "color-management-lcms" lcmsSupport)
		(lib.mesonBool "demo-clients" demoSupport)
		(lib.mesonBool "image-jpeg" jpegSupport)
		(lib.mesonBool "image-webp" webpSupport)
		(lib.mesonBool "pipewire" pipewireSupport)
		(lib.mesonBool "remoting" remotingSupport)
		(lib.mesonOption "simple-clients" "")
		(lib.mesonBool "xwayland" xwaylandSupport)
	] ++ lib.optionals xwaylandSupport [
		(lib.mesonOption "xwayland-path" (lib.getExe xwayland))
	];

	passthru.providedSessions = [ "weston" ];

	meta = with lib; {
		description = "i.MX Graphics Wayland Compositor";
		homepage = "https://github.com/nxp-imx/weston-imx";
		license = licenses.mit; # Expat version
		platforms = platforms.linux;
		mainProgram = "weston";
	};
}
