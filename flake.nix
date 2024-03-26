{
	description = "Flake for i.MX software";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
		flake-parts.url = "github:hercules-ci/flake-parts";
		flake-compat.url = "github:edolstra/flake-compat";
	};

	outputs = inputs @ { self, flake-parts, ... }: 
		flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
				flake-parts.flakeModules.easyOverlay
			];
		
			systems = [ "aarch64-linux" ]; # TODO: i.MX 6 support?

			perSystem = { system, config, pkgs, ... }: rec {
				packages = rec {
					imx-gpu-viv = pkgs.callPackage ./pkgs/imx-gpu-viv {};
					imx-gpu-g2d = pkgs.callPackage ./pkgs/imx-gpu-g2d {};

					libdrm-imx = pkgs.callPackage ./pkgs/libdrm-imx {};
					wayland-protocols-imx = pkgs.callPackage ./pkgs/wayland-protocols-imx {};

					weston-imx = pkgs.callPackage ./pkgs/weston-imx {};
				};

				overlayAttrs = config.packages;

				_module.args.pkgs = import inputs.nixpkgs {
					inherit system;
					overlays = [ self.overlays.default ];
					config.allowUnfree = true;
				};
			};
		};
}
