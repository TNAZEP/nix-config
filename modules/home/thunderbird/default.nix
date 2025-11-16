{ username, ... }:
{
  programs.thunderbird = {
    enable = false;

    profiles."${username}" = {
      isDefault = true;
    };
  };
}
