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
				legacyPackages = import ./pkgs { inherit (pkgs) callPackage; };

				overlayAttrs = config.legacyPackages;

				_module.args.pkgs = import inputs.nixpkgs {
					inherit system;
					overlays = [ self.overlays.default ];
					config.allowUnfree = true;
				};
			};
		};
}
