{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ and Docker access for the user.
    createHome = false; # Home dir provided by bind mount
    initialPassword = "test";
  };

  environment.systemPackages = with pkgs; [
    cowsay
    lolcat
    docker # Docker client if needed outside of the service
  ];

  # Enable Docker daemon (rootful). For rootless, use virtualisation.docker.rootless.enable
  virtualisation.docker.enable = true;

  # Bind-mount the host workspace directory as Alice's home
  fileSystems."/home/alice" = {
    device = "/workspace";
    fsType = "none"; # bind mount
    options = [ "bind" "x-systemd.requires-mounts-for=/workspace" ];
    neededForBoot = true; # mount early
  };

  system.stateVersion = "24.05";
}
