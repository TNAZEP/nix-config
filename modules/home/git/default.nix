{
  email,
  username,
  ...
}:
{
  programs.git = {
    enable = true;
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = false;
    };
    settings = {
      user = {
        name = "${username}";
        email = "${email}";
      };
      init.defaultBranch = "main";
      commit.gpgSign = false;
      gpg.format = "ssh";
    };
  };
}
