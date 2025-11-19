{
  pkgs,
  ...
}:
{
  ################################
  # Steam & general gaming tools
  ################################

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    # General gaming tools
    mangohud
    gamescope
    goverlay
    lutris
    wine
    winetricks
    protontricks
    protonup
    protonup-qt

    # Emulators / launchers
    faugus-launcher
    dolphin-emu
  ];

  ################################
  # Controller rules
  ################################

  services.udev.packages = [ pkgs.game-devices-udev-rules ];

  hardware.graphics.enable32Bit = true;
}
