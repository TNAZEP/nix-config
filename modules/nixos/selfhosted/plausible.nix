{
  config,
  lib,
  ...
}: {
  opnix.secrets.plausible_key = lib.mkDefault {
    opPath = "op://Selfhosted/plausible/secret_key_base";
    owner = "plausible";
    group = "plausible";
    mode = "0400";
  };

  services = {
    plausible = {
      enable = true;

      server = {
        baseUrl = "https://plausible.tux.rs";
        port = 2100;
        disableRegistration = true;
        secretKeybaseFile = config.opnix.secrets.plausible_key.path;
      };

      database.postgres = {
        dbname = "plausible";
        socket = "/run/postgresql";
      };
    };

    nginx = {
      enable = lib.mkForce true;
      virtualHosts = {
        "plausible.tux.rs" = {
          forceSSL = true;
          useACMEHost = "tux.rs";
          locations = {
            "/" = {
              proxyPass = "http://localhost:2100";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
