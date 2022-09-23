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

  home.packages = with pkgs; [
    ripgrep-all
    tree
    tdesktop
    libxml2
    htop
    whois
    units
    git
    xclip
    traceroute
    jq
    #vim_configurable # _configurable is the one with X support (for clipboard)
    ungoogled-chromium
    p7zip
    #spotify
    nyxt
    quickemu
    cloc
    bat
    exa
    fd
  ];

  home.file.".config/ripgreprc" = {
    source = ./dotfiles/ripgreprc;
  };

  programs.bash = {
    enable = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    initExtra = builtins.readFile ./dotfiles/bashrc;
    shellAliases = {
      ll = "ls -l";
      la = "ls -A";
      lla = "ls -la";
      ".." = "cd ..";
      gits = "git s";
      nixos-rebuild = "nixos-rebuild --flake . --use-remote-sudo";
    };
    shellOptions = [
      "histappend"
      "checkwinsize"
      "globstar"
    ];
  };

  programs.lesspipe.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.firefox = {
    enable = true;
    profiles = {
      "ken" = {
        id = 0;
        isDefault = true;
        extraConfig = ""; # TODO: user.js goes here
        userChrome = ""; # TODO: userChrome.css goes here
        userContent = ""; # TODO: userContent.css goes here
        settings = {
          "browser.urlbar.clickSelectsAll" = true;
          "browser.urlbar.doubleClickSelectsAll" = false;
          "browser.tabs.tabMinWidth" = 0;
          "general.autoScroll" = true;
          # Restore tabs automatically
          "browser.startup.page" = 3;
          # Don't warn about closing tabs
          "browser.tabs.warnOnClose" = false;
          # Don't cycle tabs in MRU order
          "browser.ctrlTab.recentlyUsedOrder" = false;
          # Allow DRMed content
          "media.eme.enabled" = true;
          # Disable Pocket
          # Note: Still has to be manually removed from the homepage
          # See about:preferences#home
          "extensions.pocket.enabled" = false;
          #Don't offer to save passwords
          "signon.rememberSignons" = false;
        };
      };
    };
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      amp2html
      darkreader
      vimium
      bitwarden
      ublock-origin
      #https-everywhere
      #stylus
      #reddit-enhancement-suite
      #plasma-integration
      #peertubeify
      #old-reddit-redirect
      #link-cleaner
      #google-search-link-fix
      #anchors-reveal
      #facebook-container
      #want: history-autodelete
      #want: dontbugme
      #want: Disable Ctrl-Q and Cmd-Q
    ];
  };

  programs.git = {
    enable = true;
    userName = "Ken Klatt";
    userEmail = "ken@kla.tt"; # TODO: Make this conditional for work email
    aliases = {
      s = "status";
      sw = "switch";
      d = "diff";
      ds = "diff --staged";
      # diff with the active branch's upstream
      du = ''
        !f() { \
          git diff `git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)"`; \
        }; f
      '';
      b = "branch";
      ba = "branch -a";
      br = "branch -r";
      # Shows branches in recently-committed-to order
      brecent = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
      # Used with vim like this: vim $(git conflicts) to open all conflicted files
      conflicts = "diff --name-only --diff-filter=U";
      # Stage just the whitespace changes
      addwhitespace = "! git add -A && git diff --cached -w | git apply --cached -R";
      # Used to 'cd `git root`' quickly
      root = "rev-parse --show-toplevel";
      fix = "commit --amend --no-edit";
      upstream = ''
        !f() { \
          echo `git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)"`; \
        }; f
      '';
      merge-base = "merge-base"; # This is here for tab completion to find the command. It's part of the plumbing.
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      lga = "lg --all"; # Include commits from all branches
      lightweight-tags = ''
        !f() { \
          git for-each-ref refs/tags/ --format '%(objecttype) %(refname:short)' | while read ty name; do [ $ty = commit ] && echo $name; done \
        }; f
      '';
      annotated-tags = ''
        !f() { \
          git for-each-ref refs/tags/ --format '%(objecttype) %(refname:short)' | while read ty name; do [ $ty = tag ] && echo $name; done \
        }; f
      '';
      remote-tags = "ls-remote --tags origin";
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
        ff = "only";
      };
      merge = {
        ff = false;
      };
      core = {
        # -+F: Configure the pager git uses for diffs to not exit automatically on short
        # content so that I stop closing my terminal trying to scroll down with ctrl-d.
        # -j.5: When searching have less put the result in the middle of the screen, not the top.
        pager = "less -+F -j.5";
        #pager = vim -R +AnsiEsc -
        #pager=  vim-pager
      };
      clean = {
        requireForce = false;
      };
      fetch = {
        prune = true;
      };
      push = {
        default = "current";
        followTags = true;
        atomic = true;
      };
      commit = {
        # Show the diff when editing the commit message
        verbose = true;
      };
      log = {
        follow = true;
      };
      diff = {
        noprefix = true;
      };
    };
    ignores = [
      "*.swp"
      "*~"
      ".idea/*"
    ];
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    newSession = true;
    baseIndex = 1;
    clock24 = false;
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    plugins = with pkgs; [
        {
            plugin = tmuxPlugins.resurrect;
            extraConfig = "set -g @resurrect-strategy-vim 'session'";
        }
        {
            plugin = tmuxPlugins.fingers;
        }
    ];
    extraConfig = ''
	# This config is generated by Home-Manager. Don't update it here.

        # disable sound bell
        set -g bell-action none
        # disable visual bell
        set -g visual-bell off

	# Set a second tmux prefix of ctrl-a
	# Never mind, that breaks ctrl-a navigating to the beginning of the command line
	#set-option -g prefix2 C-a

	# Make new panes to open in the current directory
	# Thanks to https://gist.github.com/william8th/faf23d311fc842be698a1d80737d9631
	bind c new-window -c "#{pane_current_path}"
	bind '"' split-window -c "#{pane_current_path}"
	bind % split-window -h -c "#{pane_current_path}"

	# Enable color in some terminals that can't figure it out on their own. (Gnome's)
	set -g default-terminal "screen-256color"

	# Renumber windows when one is killed
	set-option -g renumber-windows on

	# Better vim-like bindings for copy-paste functionality
	bind-key -T copy-mode-vi 'v' send -X begin-selection
	bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel

	# Better vim-like bindings for moving between panes in a window
	bind h select-pane -L;
	bind j select-pane -D;
	bind k select-pane -U;
	bind l select-pane -R;

	# Jump back to last prompt (if your prompt has 🍌 in it)
	#bind -T copy-mode-vi n send-keys -X search-forward "🍌" and bind -T copy-mode-vi p send-keys -X search-backward "🍌"
	bind-key -n M-U copy-mode\;\
		   send-keys -X start-of-line\;\
		   send-keys -X search-backward "🍌 "
	bind-key U copy-mode\;\
		   send-keys -X start-of-line\;\
		   send-keys -X search-backward "🍌 "
	
	# Sync the system clipboard with tmux's clipboard
	bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

	set -g mouse on

        # Shift the active window with < and >. -d focuses the window being moved.
        bind-key -r < swap-window -t -1 -d
        bind-key -r > swap-window -t +1 -d

    '';
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      surround
      vim-nix
      Improved-AnsiEsc
    ];
    extraConfig = builtins.readFile ./dotfiles/vimrc;
  };

}

