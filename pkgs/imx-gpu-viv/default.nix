{ lib
, stdenv
, fetchurl

, libdrm
, wayland

, autoPatchelfHook

, backend ? "wayland"
, isMX8 ? true
, hasGbm ? isMX8
, imxSoc ? "IMX_SOC_NOT_SET"
, enableDemos ? false
, enableVulkan ? isMX8
, enableOpenCL ? true
}:
stdenv.mkDerivation rec {
	pname = "imx-gpu-viv";
	version = "6.4.3.p4.2";

	src = fetchurl {
		url = "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/${pname}-${version}-aarch64.bin";
		hash = "sha256-UpIcC1lSnxWYCE6ZHtoYYxAHVPKKd0S6lYFY3/gHSzs=";
	};

	unpackCmd = "sh $curSrc --auto-accept"; # https://www.nxp.com/docs/en/disclaimer/LA_OPT_NXP_SW.html

	nativeBuildInputs = [ autoPatchelfHook ];
	buildInputs = [ stdenv.cc.cc.lib libdrm wayland ];

	outputs = [ "out" "dev" "bin" ]
		++ lib.optional enableDemos "demos"
		++ lib.optional enableOpenCL "icd";

	env = rec {
		LIBVULKAN_VERSION_MAJOR = "1";
		LIBVULKAN_VERSION       = "${LIBVULKAN_VERSION_MAJOR}.2.1";
		LIBVULKAN_API_VERSION   = "${LIBVULKAN_VERSION_MAJOR}.2.182";
	};

	# TODO: Implement all things from Yocto BSP (by Variscite?)
	installPhase = ''
		mkdir -p $out/lib $dev/{include,lib/pkgconfig} $bin/bin

		cp -Pv gpu-core/usr/lib/*.so* $out/lib
		cp -rv gpu-core/usr/include/* $dev/include
		cp -rv gpu-tools/gmem-info/usr/bin/* $bin/bin
	'' + lib.optionalString enableDemos ''
		mkdir $demos
		cp -rv gpu-demos/opt/viv_samples/* $demos
	'' + ''
		rm -rfv $dev/include/vulkan

		# Install SOC-specific drivers
		if [ -d gpu-core/usr/lib/${imxSoc} ]; then
			cp -rv gpu-core/usr/lib/${imxSoc}/* $out/lib
		fi
	'' + lib.optionalString hasGbm ''
		cp -v gpu-core/usr/lib/pkgconfig/gbm.pc $dev/lib/pkgconfig/gbm.pc
	'' + ''
		cp -v gpu-core/usr/lib/pkgconfig/glesv1_cm.pc $dev/lib/pkgconfig/glesv1_cm.pc
		cp -v gpu-core/usr/lib/pkgconfig/glesv2.pc    $dev/lib/pkgconfig/glesv2.pc
		cp -v gpu-core/usr/lib/pkgconfig/vg.pc        $dev/lib/pkgconfig/vg.pc
	'' + lib.optionalString (backend == "wayland") ''
		cp -v gpu-core/usr/lib/pkgconfig/egl_wayland.pc $dev/lib/pkgconfig/egl.pc
		cp -rv gpu-core/usr/lib/wayland/* $out/lib
	'' + lib.optionalString enableOpenCL ''
		mkdir -p $icd/etc/OpenCL/vendors
		cp -v gpu-core/etc/Vivante.icd $icd/etc/OpenCL/vendorsVivante.icd
	'' + lib.optionalString (!enableOpenCL) ''
		rm -rfv $demos/cl11
	'' + lib.optionalString enableVulkan ''
		mkdir -p $out/share/vulkan/icd.d

		# Rename the vulkan implementation library which is wrapped by the vulkan-loader
		# library of the same name
		VK_MAJOR=$LIBVULKAN_VERSION_MAJOR
		VK_FULL=$LIBVULKAN_VERSION
		mv -v $out/lib/libvulkan.so.$VK_FULL $out/lib/libvulkan_VSI.so.$VK_FULL
		patchelf --set-soname libvulkan_VSI.so.$VK_MAJOR $out/lib//libvulkan_VSI.so.$VK_FULL
		rm $out/lib/libvulkan.so.$VK_MAJOR $out/lib/libvulkan.so
		ln -s libvulkan_VSI.so.$VK_FULL $out/lib/libvulkan_VSI.so.$VK_MAJOR
		ln -s libvulkan_VSI.so.$VK_FULL $out/lib/libvulkan_VSI.so

		cp -v ${./imx_icd.json} $out/share/vulkan/icd.d/imx_icd.json

		substituteInPlace $out/share/vulkan/icd.d/imx_icd.json \
			--replace %libdir% $out/lib \
			--replace %api_version% $LIBVULKAN_API_VERSION
	'';

	passthru.settings = {
		inherit
			backend
			isMX8
			hasGbm
			imxSoc
			enableDemos
			enableVulkan
			enableOpenCL
		;
	};

	meta = with lib; {
		description = "GPU driver and apps for i.MX";
		homepage = "https://github.com/Freescale/meta-freescale";
		license = licenses.unfree; # LA_OPT_NXP_Software_License
		platforms = [ "aarch64-linux" ]; # TODO: aarch32 support?
		maintainers = with maintainers; [ kamillaova ];
	};
}
