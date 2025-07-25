{ config, pkgs, modulesPath, ... }:
{
  # これを追加
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];
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
    torsocks # Tor SOCKS proxy
  ];

  # Enable Docker daemon (rootful). For rootless, use virtualisation.docker.rootless.enable
  virtualisation.docker.enable = true;

  # Enable Tor daemon so that torsocks (or curl via SOCKS5) works out of the box
  services.tor = {
    enable = true;          # start tor.service at boot
    client.enable = true;   # provide local SOCKS proxy on 9050
  };

  # Automatically log in as alice on the console
  services.getty.autologinUser = "alice";

  # Copy the host workspace into Alice's home at boot instead of bind-mounting
  systemd.tmpfiles.rules = [
    # Ensure the target directory exists with correct ownership
    "d /home/alice/workspace 0755 alice users - -"
  ];

  
  # 1) まず QEMU に「/workspace を共有してね」と伝える
  virtualisation.sharedDirectories = {
    workspace = {                 # ←名前は自由。後で device= に使う
      source = "/workspace";      # ホスト側の絶対パス
      target = "/workspace";      # ゲスト内で見える場所
      # readOnly = true;          # 読み取り専用にしたいなら付ける
    };
  };

  # 2) ゲストがブート時に /workspace をマウントする
  fileSystems."/workspace" = {
    device  = "workspace";        # ① で付けた名前
    fsType  = "9p";
    options = "trans=virtio,version=9p2000.L,rw,cache=mmap";
    neededForBoot = true;         # ブート後に手動で mount するなら false
  };

  # すでに用意していた “/workspace をコピーする” サービスは不要になるので
  # 有効にしていた場合は無効化しておく
  systemd.services.copy-workspace.enable = false;

  # Change directory to /workspace on login
  environment.loginShellInit = "cd /workspace";

  system.stateVersion = "24.05";
}
