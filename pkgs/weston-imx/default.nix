{ lib
, mkImxDerivation
, fetchpatch2
, fetchFromGitHub
, pkg-config
, meson, ninja, python3
, wayland-scanner
, wayland, wayland-protocols-imx
, libevdev, libinput
, libxkbcommon, xcbutilcursor
, seatd, cairo, libdrm-imx

, demoSupport ? false
, hdrSupport ? false, libdisplay-info
, jpegSupport ? false, libjpeg
, lcmsSupport ? false, lcms2
, pangoSupport ? true, pango
, pipewireSupport ? false, pipewire
, remotingSupport ? false, gst_all_1
, vncSupport ? false, aml, neatvnc, pam
, rdpSupport ? true, freerdp
, vaapiSupport ? false, libva
, webpSupport ? false, libwebp
, xwaylandSupport ? false, xwayland, libXcursor
}:
mkImxDerivation rec {
	pname = "weston-imx";
	version = "lf-6.6.3-1.0.0";

	src = fetchFromGitHub {
		owner = "nxp-imx";
		repo = "weston-imx";
		rev = version;
		hash = "sha256-SjioGPHZe8q5sNjfWPiTwxGhtTn2qYq1+CbEhXrlRzw=";
	};

	patches = [
		# tests: Add an option to disable building tests
		# part of https://gitlab.freedesktop.org/wayland/weston/-/merge_requests/555
		(fetchpatch2 {
			url = "https://gitlab.freedesktop.org/wayland/weston/-/commit/4d3051c765c246c7328502d2a84f5600a189ee71.patch";
			hash = "sha256-sO4e4Xl+I81a9OoJSakETQ7I4x3E7FBK0H74TKjA7Fg=";
		})
		# ci, backend-vnc: update to Neat VNC 0.7.0
		# part of https://gitlab.freedesktop.org/wayland/weston/-/merge_requests/1051
		(fetchpatch2 {
			url = "https://gitlab.freedesktop.org/wayland/weston/-/commit/8895b15f3dfc555a869e310ff6e16ff5dced1336.patch";
			hash = "sha256-k8zOU6nROZ7e+v8jbWb194e9/NXFlGMV1+XTxLMXKbA=";
			excludes = [ ".gitlab-ci*" ];
		})
	];

	depsBuildBuild = [ pkg-config ];
	nativeBuildInputs = [ meson ninja python3 wayland-scanner ];
	buildInputs = [
		wayland wayland-protocols-imx
		libevdev libinput
		seatd libxkbcommon
		cairo libdrm-imx
	] ++ lib.optional hdrSupport libdisplay-info
		++ lib.optional jpegSupport libjpeg
		++ lib.optional lcmsSupport lcms2
		++ lib.optional pangoSupport pango
		++ lib.optional pipewireSupport pipewire
		++ lib.optional rdpSupport freerdp
		++ lib.optionals remotingSupport [ gst_all_1.gstreamer gst_all_1.gst-plugins-base ]
		++ lib.optional vaapiSupport libva
		++ lib.optionals vncSupport [ aml neatvnc pam ]
		++ lib.optional webpSupport libwebp
		++ lib.optionals xwaylandSupport [ libXcursor xcbutilcursor xwayland ];

	doCheck = false; # whatever

	mesonFlags = [
		(lib.mesonBool "tests" doCheck)
		(lib.mesonOption "simple-clients" "")
		(lib.mesonBool "test-junit-xml" false)
		(lib.mesonBool "backend-drm-screencast-vaapi" vaapiSupport)
		(lib.mesonBool "backend-pipewire" pipewireSupport)
		(lib.mesonBool "backend-rdp" rdpSupport)
		(lib.mesonBool "backend-vnc" vncSupport)
		(lib.mesonBool "color-management-lcms" lcmsSupport)
		(lib.mesonBool "demo-clients" demoSupport)
		(lib.mesonBool "image-jpeg" jpegSupport)
		(lib.mesonBool "image-webp" webpSupport)
		(lib.mesonBool "pipewire" pipewireSupport)
		(lib.mesonBool "remoting" remotingSupport)
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
