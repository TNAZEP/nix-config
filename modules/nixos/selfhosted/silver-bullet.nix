{
  lib,
  config,
  ...
}: {
  opnix.secrets.silver_bullet = lib.mkDefault {
    opPath = "op://Selfhosted/silver-bullet/env";
    owner = "silverbullet";
    group = "silverbullet";
    mode = "0400";
  };

  services = {
    silverbullet = {
      enable = true;
      listenPort = 9876;
      envFile = config.opnix.secrets.silver_bullet.path;
    };

    nginx = {
      enable = lib.mkForce true;
      virtualHosts = {
        "notes.tux.rs" = {
          forceSSL = true;
          useACMEHost = "tux.rs";
          locations = {
            "/" = {
              proxyPass = "http://localhost:9876";
            };
          };
        };
      };
    };
  };
}
