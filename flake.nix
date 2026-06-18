{
  description = "LuaJIT development shell with LLS autocompletion";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    lua = pkgs.luajit.withPackages (ps: [ps.argparse ps.luaposix ps.penlight]);
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        lua
      ];
    };
  };
}
