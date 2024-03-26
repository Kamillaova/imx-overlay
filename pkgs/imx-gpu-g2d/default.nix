{ lib
, stdenv
, fetchurl

, imx-gpu-viv

, autoPatchelfHook
}:
stdenv.mkDerivation rec {
  pname = "imx-gpu-g2d";
  version = "6.4.3.p4.2";

	src = fetchurl {
		url = "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/${pname}-${version}-aarch64.bin";
		hash = "sha256-/1Dd/uLZiXmKKrqE75EU4B+NhnKTiR3Aqs+rFkDL+KM=";
	};

	unpackCmd = "sh $curSrc --auto-accept"; # https://www.nxp.com/docs/en/disclaimer/LA_OPT_NXP_SW.html

	nativeBuildInputs = [ autoPatchelfHook ];
	buildInputs = [ imx-gpu-viv ];

	outputs = [ "out" "dev" ];

	installPhase = ''
		mkdir -p $out/lib $dev/include

		cp -rv g2d/usr/lib/*.so* $out/lib
		cp -Prv g2d/usr/include/* $dev/include
	'';

  meta = with lib; {
    description = "G2D library using i.MX GPU";
    homepage = "https://github.com/Freescale/meta-freescale";
    license = licenses.unfree; # LA_OPT_NXP_Software_License
    platforms = [ "aarch64-linux" ]; # TODO: aarch32 support?
  };
}
