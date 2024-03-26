{ lib
, stdenv

, imx-gpu-viv
, imx-gpu-g2d

, makeWrapper
}:
{ nativeBuildInputs ? []
, buildInputs ? []
, outputs ? [ "out" ]
, postInstall ? ""
, meta ? {}
, ...
} @ attrs: with {
	args = attrs // {
		inherit
			nativeBuildInputs
			buildInputs
			outputs
			postInstall
			meta
		;
	};
}; let
	runtimeDependencies = [ imx-gpu-viv imx-gpu-g2d ];
	runtimeLibraryPath = lib.makeLibraryPath runtimeDependencies;

	postInstallWrap = ''
		for bin in $(find "$out" -executable -type f); do
			if patchelf --print-interpreter "$bin" &> /dev/null; then
				wrapProgram "$bin" \
					--prefix LD_LIBRARY_PATH : "${runtimeLibraryPath}"
			fi
		done
	'';
in stdenv.mkDerivation (args // {
	nativeBuildInputs = args.nativeBuildInputs ++ [ makeWrapper ];
	buildInputs = args.buildInputs ++ runtimeDependencies;

	postInstall = args.postInstall + postInstallWrap;
})
