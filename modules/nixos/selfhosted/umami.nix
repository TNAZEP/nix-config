{
  lib,
  config,
  ...
}: {
  opnix.secrets.umami = lib.mkDefault {
    opPath = "op://Selfhosted/umami/APP_SECRET";
    owner = "umami";
    group = "umami";
    mode = "0400";
  };

  services = {
    umami = {
      enable = true;
      settings = {
        APP_SECRET_FILE = config.opnix.secrets.umami.path;
        PORT = 4645;
      };
      createPostgresqlDatabase = true;
    };

    nginx = {
      enable = lib.mkForce true;
      virtualHosts = {
        "umami.tux.rs" = {
          forceSSL = true;
          useACMEHost = "tux.rs";
          locations = {
            "/" = {
              proxyPass = "http://localhost:${toString config.services.umami.settings.PORT}";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
