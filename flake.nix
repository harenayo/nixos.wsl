{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { nixpkgs, nixos-wsl, ... }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-wsl.nixosModules.wsl
          (
            { config, ... }:
            {
              config = {
                wsl.enable = true;
                system.stateVersion = config.system.nixos.release;
                programs.bash.loginShellInit = "nixos-wsl-welcome";
              };
            }
          )
        ];
      };
    };
}
