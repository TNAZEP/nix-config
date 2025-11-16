{ config, lib, pkgs, ... }:
let
  inherit (lib) concatStringsSep mapAttrsToList mkIf mkOption types;
  secretList = mapAttrsToList (
    name: value: {
      inherit name;
      opPath = value.opPath;
      path = value.path;
      owner = value.owner;
      group = value.group;
      mode = value.mode;
    }
  ) config.opnix.secrets;

  syncScript = pkgs.writeShellScript "opnix-sync" ''
    set -euo pipefail

    ${concatStringsSep "\n" (mapAttrsToList (_: secret: ''
      echo "Fetching ${secret.opPath} into ${secret.path}" >&2
      install -d -m 0750 -o ${secret.owner} -g ${secret.group} "$(dirname "${secret.path}")"
      tmpfile=$(mktemp)
      if ! ${pkgs._1password-cli}/bin/op read "${secret.opPath}" > "$tmpfile"; then
        echo "Failed to read secret ${secret.opPath}. Ensure the 1Password CLI is signed in." >&2
        rm -f "$tmpfile"
        exit 1
      fi
      install -m ${secret.mode} -o ${secret.owner} -g ${secret.group} "$tmpfile" "${secret.path}"
      rm -f "$tmpfile"
    '') config.opnix.secrets)}
  '';

in {
  options.opnix.secrets = mkOption {
    description = "Secrets managed via 1Password using opnix.";
    default = {};
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        opPath = mkOption {
          description = ''1Password item path (op://Vault/Item/Field).'';
          type = types.str;
        };

        path = mkOption {
          description = "Destination file for the secret.";
          type = types.str;
          default = "/run/opnix/${name}";
        };

        owner = mkOption {
          description = "User that should own the secret file.";
          type = types.str;
          default = "root";
        };

        group = mkOption {
          description = "Group that should own the secret file.";
          type = types.str;
          default = "root";
        };

        mode = mkOption {
          description = "File mode for the secret.";
          type = types.str;
          default = "0400";
        };
      };
    }));
  };

  config = mkIf (secretList != []) {
    environment.systemPackages = [ pkgs._1password-cli ];

    systemd.services.opnix-sync = {
      description = "Sync 1Password secrets with opnix";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = syncScript;
        TimeoutStartSec = 300;
      };
    };
  };
}
