{
  description = "LuaJIT development shell with LLS autocompletion";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    lua = pkgs.luajit.withPackages (ps: [ps.argparse ps.luaposix]);
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        lua
      ];

      shellHook = ''
        ARGPARSER_PATH="${pkgs.luajitPackages.argparse}/share/lua/5.1"

        # Create a local .luarc.json that points LLS to the Nix store path
        cat <<EOF > .luarc.json
        {
            "runtime": {
                "version": "LuaJIT"
            },
            "workspace": {
                "library": [
                    "$ARGPARSER_PATH"
                ],
                "checkThirdParty": false
            }
        }
        EOF

        echo "🚀 devShell activated! .luarc.json updated with Nix store paths."
      '';
    };
  };
}
