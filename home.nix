{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "ken";
  home.homeDirectory = "/home/ken";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  programs.git = {
    enable = true;
    userName = "Ken Klatt";
    userEmail = "ken@kla.tt";
    aliases = {
      s = "status";
      sw = "switch";
      d = "diff";
      ds = "diff --staged";
      b = "branch";
      ba = "branch -a";
      br = "branch -r";
      brecent = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
      conflicts = "diff --name-only --diff-filter=U";
      addwhitespace = "! git add -A && git diff --cached -w | git apply --cached -R";
      new = "log origin/master@{1}..origin/master@{0}";
      root = "rev-parse --show-toplevel";
      fix = "commit --amend --no-edit";
    };
    delta = {
      enable = false;
      options = {
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "decorations";
        whitespace-error-style = "22 reverse";
      };
    };
    extraConfig = {
      pull = {
        rebase = true;
      };
      merge = {
        ff = false;
      };
    };
    ignores = [
      "*.swp"
      "*~"
      ".idea/*"
    ];
  };

}

