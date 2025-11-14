{...}: {
  programs.steam = {
    enable = true;
  };

  hardware.graphics.enable32Bit = true;
  localNetworkGameTransfers.openFirewall = true;
}
