{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;

    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [
        "~/Wallpapers/kiyomizu.jpg"
      ];

      wallpaper = [
        ", ~/Wallpapers/kiyomizu.jpg"
      ];
    };
  };

  home.packages = with pkgs; [ hyprpaper ];
}
