{
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  opnix.secrets.nextcloud_password = lib.mkDefault {
    opPath = "op://Selfhosted/nextcloud/admin_password";
    owner = "nextcloud";
    group = "nextcloud";
    mode = "0400";
  };

  services = {
    nginx = {
      enable = lib.mkForce true;
      virtualHosts = {
        "cloud.tux.rs" = {
          forceSSL = true;
          useACMEHost = "tux.rs";
        };
      };
    };

    nextcloud = {
      enable = true;
      hostName = "cloud.tux.rs";
      package = pkgs.nextcloud32;
      database.createLocally = true;
      configureRedis = true;
      maxUploadSize = "16G";
      https = true;

      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit mail spreed;
      };

      config = {
        dbtype = "sqlite";
        adminuser = "${username}";
        adminpassFile = config.opnix.secrets.nextcloud_password.path;
      };

      settings = {
        overwriteProtocol = "https";
        default_phone_region = "IN";
      };
    };
  };

  environment.systemPackages = with pkgs; [nextcloud31];
}
