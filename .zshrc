# ---------------------------------------------------------
# 1. ENVIRONMENT & PATHS (Must be first)
# ---------------------------------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"

# Load Homebrew paths if not already present (Mac specific)
#if [[ -f /opt/homebrew/bin/brew ]]; then
#  eval "$(/opt/homebrew/bin/brew shellenv)"
#fi

# ---------------------------------------------------------
# 2. COMPLETION INITIALIZATION
# ---------------------------------------------------------
# Initialize completions AFTER paths are set so it finds Brew completions
autoload -Uz compinit
compinit -i  # The -i flag ignores insecure directories (common on Mac)

# ---------------------------------------------------------
# 3. ANTIDOTE PLUGIN MANAGER
# ---------------------------------------------------------
local antidote_path="${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh"

if [[ -f $antidote_path ]]; then
  source "$antidote_path"
  zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
  
  # Regenerate if .txt is newer than .zsh
  if [[ ! -f "${zsh_plugins}.zsh" || "${zsh_plugins}.txt" -nt "${zsh_plugins}.zsh" ]]; then
    antidote bundle < "${zsh_plugins}.txt" >| "${zsh_plugins}.zsh"
  fi
  source "${zsh_plugins}.zsh"
fi

# ---------------------------------------------------------
# 4. CUSTOM CONFIG & TOOLS
# ---------------------------------------------------------
zstyle ':omz:plugins:nvm' lazy yes

# Load personal files
for file in ~/.{path,functions,exports,extra,aliases}; do
  [[ -r "$file" ]] && source "$file"
done

# Nix & Terminal Integrations
[[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]] && . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
[[ $TERM_PROGRAM != "WarpTerminal" && -e "${HOME}/.iterm2_shell_integration.zsh" ]] && source "${HOME}/.iterm2_shell_integration.zsh"

# zsh-history-substring-search configuration
bindkey '^[[A' history-substring-search-up # or '\eOA'
bindkey '^[[B' history-substring-search-down # or '\eOB'
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

 # "If a completion is performed with the cursor within a word, and a
  # full completion is inserted, the cursor is moved to the end of the
  # word."
  # https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-4
setopt always_to_end

 # "If a command is issued that can’t be executed as a normal command,
  # and the command is the name of a directory, perform the cd command
  # to that directory."
  # https://zsh.sourceforge.io/Doc/Release/Options.html#Changing-Directories
  #
  # That is, enter a path to cd to i
setopt auto_cd

 # "If unset, the cursor is set to the end of the word if completion is
  # started. Otherwise it stays there and completion is done from both
  # ends."
  # https://zsh.sourceforge.io/Doc/Release/Options.html#Completion-4
setopt complete_in_word

  # "If the internal history needs to be trimmed to add the current
  # command line, setting this option will cause the oldest history
  # event that has a duplicate to be lost before losing a unique event
  # from the list."
  # https://zsh.sourceforge.io/Doc/Release/Options.html#History
setopt hist_expire_dups_first

  # "When searching for history entries in the line editor, do not
  # display duplicates of a line previously found, even if the
  # duplicates are not contiguous."
  # https://zsh.sourceforge.io/Doc/Release/Options.html#History
setopt hist_find_no_dups


  # "Remove command lines from the history list when the first character
  # on the line is a space, or when one of the expanded aliases contains
  # a leading space. Only normal aliases (not global or suffix aliases)
  # have this behaviour. Note that the command lingers in the internal
  # history until the next command is entered before it vanishes,
  # allowing you to briefly reuse or edit the line. If you want to make
  # it vanish right away without entering another command, type a space
  # and press return."
  # https://zsh.sourceforge.io/Doc/Release/Options.html#History
setopt hist_ignore_space

  # "Turns on interactive comments; comments begin with a #."
  # https://zsh.sourceforge.io/Intro/intro_16.html
  #
  # That is, enable comments in the terminal. Nice when copying and
  # pasting from documentation/tutorials, and disable part of
  # a command pulled up from history.
setopt interactivecomments  


# ---------------------------------------------------------
# 5. THEME (Must be last)
# ---------------------------------------------------------
eval "$(starship init zsh)"



# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/dragon/.lmstudio/bin"
# End of LM Studio CLI section

