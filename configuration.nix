{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./imports/steam.nix
    ];

  hardware.bluetooth.enable = true;

  # Suspend-then-hibernate
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };
  systemd.sleep.extraConfig = "HibernateDelaySec=2h";

  services.emacs.enable = true;

  networking.hostName = "framework";
  networking.networkmanager.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true; # Allow unfree software

  # Map CapsLock to Esc on single press and Ctrl on when used with multiple keys.
  services.interception-tools = {
    enable = true;
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  # Framework-specific workarounds
  boot.kernelPackages = pkgs.linuxPackages_6_0; # Need a modern kernel for X11 to start
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ]; # https://community.frame.work/t/12th-gen-not-sending-xf86monbrightnessup-down/20605
  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    #"/swap".options = [ "noatime" ]; # Throws an error. Maybe isn't needed.
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1"; # TODO: Can this be moved into my home-manager configuration (beside programs.firefox) somehow?
  };

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = false;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver.xkbOptions = "caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ken = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      thunderbird
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search nixpkgs#wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    tmux
    git
    tealdeer
    ripgrep-all
    fd
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

