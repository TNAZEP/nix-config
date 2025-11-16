{
  pkgs,
  lib,
  config,
  ...
}: {
  opnix.secrets.searx_secret_key = lib.mkDefault {
    opPath = "op://Selfhosted/searx/secret_key";
    owner = "searx";
    group = "searx";
    mode = "0400";
  };

  services = {
    searx = {
      enable = true;
      package = pkgs.searxng;
      environmentFile = config.opnix.secrets.searx_secret_key.path;
      settings = {
        general = {
          instance_name = "SearXNG";
        };
        server = {
          bind_address = "0.0.0.0";
          port = 3415;
          base_url = "https://sx.tux.rs";
          secret_key = "@secret_key@";
        };
        search = {
          autocomplete = "google";
        };
      };
    };

    nginx = {
      enable = lib.mkForce true;
      virtualHosts = {
        "sx.tux.rs" = {
          forceSSL = true;
          useACMEHost = "tux.rs";
          locations = {
            "/" = {
              proxyPass = "http://localhost:3415";
            };
          };
        };
      };
    };
  };
}
