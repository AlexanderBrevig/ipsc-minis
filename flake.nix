{
  description = "ipsc-minis — scaled 3D-printable targets for dry-fire practice";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        render = pkgs.writeShellApplication {
          name = "render";
          runtimeInputs = [ pkgs.openscad pkgs.xvfb-run ];
          text = ''exec ./render.sh "$@"'';
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.openscad render ];
        };

        # nix run .#render [-- 4 5 6]   (run from the repo root)
        apps.render = {
          type = "app";
          program = "${render}/bin/render";
        };
        apps.default = self.apps.${system}.render;
      });
}
