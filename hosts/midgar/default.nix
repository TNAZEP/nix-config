{
  inputs,
  username,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default

    (import ./disko.nix { device = "/dev/nvme0n1"; })
    ./hardware.nix

    ../common
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/desktop
    ../../modules/nixos/desktop/awesome
    ../../modules/nixos/desktop/hyprland
    ../../modules/nixos/virtualisation
    ../../modules/nixos/gaming.nix
  ];

  nixpkgs.overlays = lib.mkAfter [
    (final: prev: {
      onetbb = prev.onetbb.overrideAttrs (old: {
        # Disable the super-slow/hanging test suite
        doCheck = false;
      });
    })
  ];

  hardware.nvidia-container-toolkit.enable = true;
  tux.services.openssh.enable = true;
  nixpkgs.config.cudaSupport = true;

  opnix.secrets = {
    hyperbolic_api_key = {
      opPath = "op://AI Keys/hyperbolic/api_key";
      owner = "${username}";
      group = "${username}";
      mode = "0400";
    };

    gemini_api_key = {
      opPath = "op://AI Keys/gemini/api_key";
      owner = "${username}";
      group = "${username}";
      mode = "0400";
    };

    open_router_api_key = {
      opPath = "op://AI Keys/open-router/token";
      owner = "${username}";
      group = "${username}";
      mode = "0400";
    };
  };

  networking = {
    hostName = "midgar";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        22
        3000
        6666
        8081
      ];

      # Facilitate firewall punching
      allowedUDPPorts = [
        41641
        4242
      ];

      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    plymouth = {
      enable = true;
      theme = "spinner-monochrome";
      themePackages = [
        (pkgs.plymouth-spinner-monochrome.override { inherit (config.boot.plymouth) logo; })
      ];
    };

    kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "vt.global_cursor_default=0"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;

    kernelPackages = pkgs.linuxPackages_zen;
    supportedFilesystems = [ "ntfs" ];

    initrd.systemd = {
      enable = lib.mkForce true;

      services.wipe-my-fs = {
        wantedBy = [ "initrd.target" ];
        after = [ "initrd-root-device.target" ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir /btrfs_tmp
          mount /dev/disk/by-partlabel/disk-primary-root /btrfs_tmp

          if [[ -e /btrfs_tmp/root ]]; then
              mkdir -p /btrfs_tmp/old_roots
              timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
              mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          delete_subvolume_recursively() {
              IFS=$'\n'
              for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                  delete_subvolume_recursively "/btrfs_tmp/$i"
              done
              btrfs subvolume delete "$1"
          }

          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
              delete_subvolume_recursively "$i"
          done

          btrfs subvolume create /btrfs_tmp/root
          umount /btrfs_tmp
        '';
      };
    };

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };

  hardware = {
    graphics.enable32Bit = true;
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  systemd = {
    enableEmergencyMode = false;

    user = {
      services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };

  programs = {
    ssh.startAgent = true;
    xfconf.enable = true;
    file-roller.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
    };
    nm-applet.enable = true;
    noisetorch.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "tnazep" ];
    };
  };

  services = {
    fwupd.enable = true;
    fstrim.enable = true;
    resolved.enable = true;
    flatpak.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    logind = {
      settings.Login = {
        HandlePowerKey = "suspend";
        HanldeLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
      };
    };

    xrdp = {
      enable = true;
      openFirewall = true;
      defaultWindowManager = "awesome";
      audio.enable = true;
    };

    syncthing = {
      enable = true;
      user = "tnazep";
      dataDir = "/home/tnazep/";
      openDefaultPorts = true;
    };

    libinput.touchpad.naturalScrolling = true;
    libinput.mouse.accelProfile = "flat";

    gvfs.enable = true;
    tumbler.enable = true;
    # @FIX gnome gcr agent conflicts with programs.ssh.startAgent;
    # gnome.gnome-keyring.enable = true;
    tailscale = {
      enable = true;
      extraUpFlags = [ "--login-server https://hs.tux.rs" ];
    };
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
  };

  fonts.packages = with pkgs.nerd-fonts; [
    fira-code
    jetbrains-mono
    bigblue-terminal
  ];

  programs.fuse.userAllowOther = true;
  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/tailscale"
      "/var/lib/nixos"
      "/var/lib/docker"
      "/var/lib/waydroid"
      "/var/lib/iwd"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      # "/etc/machine-id"
      "/etc/ly/save.ini"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  home-manager.users.${username} = {
    imports = [
      ./home.nix
    ];
  };

  users = {
    users.${username} = {
      password = "banan123";
      hashedPasswordFile = lib.mkForce null;
    };
  };

  system.stateVersion = "24.11";
}
