{
  config,
  pkgs,
  username,
  email,
  ...
}: {
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users.${username} = {
      hashedPasswordFile = config.opnix.secrets.tux-password.path;
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel" "storage"];
      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL+OzPUe2ECPC929DqpkM39tl/vdNAXfsRnmrGfR+X3D ${email}''
      ];
    };
  };
}
