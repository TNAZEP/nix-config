{
  config,
  lib,
  ...
}: {
  opnix.secrets = {
    "cs2_secrets/SRCDS_TOKEN" = lib.mkDefault {
      opPath = "op://Game Servers/cs2/SRCDS_TOKEN";
      owner = "root";
      group = "root";
      mode = "0400";
    };

    "cs2_secrets/CS2_RCONPW" = lib.mkDefault {
      opPath = "op://Game Servers/cs2/CS2_RCONPW";
      owner = "root";
      group = "root";
      mode = "0400";
    };

    "cs2_secrets/CS2_PW" = lib.mkDefault {
      opPath = "op://Game Servers/cs2/CS2_PW";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  virtualisation.oci-containers.containers.cs2-server = {
    image = "joedwards32/cs2";
    environmentFiles = [
      config.opnix.secrets."cs2_secrets/SRCDS_TOKEN".path
      config.opnix.secrets."cs2_secrets/CS2_RCONPW".path
      config.opnix.secrets."cs2_secrets/CS2_PW".path
    ];

    environment = {
      # Server configuration
      STEAMAPPVALIDATE = "0";
      CS2_SERVERNAME = "tux's CS-2 Server";
      CS2_CHEATS = "0";
      CS2_PORT = "27015";
      CS2_SERVER_HIBERNATE = "1";
      CS2_RCON_PORT = "";
      CS2_LAN = "0";
      CS2_MAXPLAYERS = "10";
      CS2_ADDITIONAL_ARGS = "";
      CS2_CFG_URL = "";
      # Game modes
      CS2_GAMEALIAS = "competitive";
      CS2_GAMETYPE = "0";
      CS2_GAMEMODE = "1";
      CS2_MAPGROUP = "mg_active";
      CS2_STARTMAP = "de_mirage";
      # Workshop Maps
      CS2_HOST_WORKSHOP_COLLECTION = "";
      CS2_HOST_WORKSHOP_MAP = "";
      # Bots
      CS2_BOT_DIFFICULTY = "3";
      CS2_BOT_QUOTA = "";
      CS2_BOT_QUOTA_MODE = "";
      # TV
      TV_AUTORECORD = "0";
      TV_ENABLE = "0";
      TV_PORT = "27020";
      TV_PW = "changeme";
      TV_RELAY_PW = "changeme";
      TV_MAXRATE = "0";
      TV_DELAY = "0";
      # Logs
      CS2_LOG = "on";
      CS2_LOG_MONEY = "0";
      CS2_LOG_DETAIL = "0";
      CS2_LOG_ITEMS = "0";
    };
    volumes = [
      "cs2:/home/steam/cs2-dedicated"
    ];
    ports = [
      "27015:27015/tcp"
      "27015:27015/udp"
      "27020:27020/udp"
    ];
    extraOptions = [
      "--interactive"
    ];
  };
}
