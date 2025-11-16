{
  lib,
  config,
  ...
}: {
  opnix.secrets.wakapi_salt = lib.mkDefault {
    opPath = "op://Selfhosted/wakapi/password_salt";
    owner = "wakapi";
    group = "wakapi";
    mode = "0400";
  };

  services = {
    wakapi = {
      enable = true;
      passwordSaltFile = config.opnix.secrets.wakapi_salt.path;
      database.createLocally = true;
      settings = {
        app.avatar_url_template = "https://www.gravatar.com/avatar/{email_hash}.png";

        server = {
          port = 15999;
          public_url = "https://wakapi.tux.rs";
        };

        db = {
          dialect = "postgres";
          host = "/run/postgresql";
          port = 5432;
          name = "wakapi";
          user = "wakapi";
        };

        security = {
          allow_signup = false;
          disable_frontpage = true;
        };
      };
    };

    nginx = {
      enable = lib.mkForce true;
      virtualHosts = {
        "wakapi.tux.rs" = {
          forceSSL = true;
          useACMEHost = "tux.rs";
          locations = {
            "/" = {
              proxyPass = "http://localhost:15999";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
