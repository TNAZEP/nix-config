{
  pkgs,
  ...
}:
{
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [ steam-run ];
  };

  hardware.graphics.enable32Bit = true;
}
