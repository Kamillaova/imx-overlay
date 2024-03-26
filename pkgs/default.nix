{ callPackage }: {
	imx-gpu-viv = callPackage ./imx-gpu-viv {};
	imx-gpu-g2d = callPackage ./imx-gpu-g2d {};

	libdrm-imx = callPackage ./libdrm-imx {};
	wayland-protocols-imx = callPackage ./wayland-protocols-imx {};

	weston-imx = callPackage ./weston-imx {};
} // import ./build-support { inherit callPackage; }
