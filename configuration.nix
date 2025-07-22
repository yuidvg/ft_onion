{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.alice = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ and Docker access for the user.
    createHome = true; # Home dir provided by bind mount
    initialPassword = "test";
  };

  environment.systemPackages = with pkgs; [
    cowsay
    lolcat
    docker # Docker client if needed outside of the service
  ];

  # Enable Docker daemon (rootful). For rootless, use virtualisation.docker.rootless.enable
  virtualisation.docker.enable = true;

  # Copy the host workspace into Alice's home at boot instead of bind-mounting
  systemd.tmpfiles.rules = [
    # Ensure the target directory exists with correct ownership
    "d /home/alice/workspace 0755 alice users - -"
  ];

  systemd.services.copy-workspace = {
    description = "Copy /workspace to /home/alice/workspace on boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "alice";
      Group = "users";
      ExecStart = ''${pkgs.bash}/bin/bash -euc '
        src="";
        if [ -d /workspace ]; then
          src=/workspace
        elif [ -d /tmp/ft_onion ]; then
          src=/tmp/ft_onion
        else
          echo "No workspace source directory found; skipping copy." >&2
          exit 0
        fi
        exec ${pkgs.rsync}/bin/rsync -a --delete "$src/" /home/alice/workspace/
      '
      '';
    };
    # Skip unit entirely if neither path exists at boot
    conditionPathExists = [ "/workspace" "/tmp/ft_onion" ];
  };

  system.stateVersion = "24.05";
}
