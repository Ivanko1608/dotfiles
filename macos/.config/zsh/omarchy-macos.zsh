# Omarchy-style shell tools on macOS. Sourced from ~/.zshrc (ohmyzsh package),
# after Oh My Zsh. zoxide is set up in ~/.zshrc itself.

# fzf: Ctrl+T files, Ctrl+R history. (Alt+C cd is shadowed by AeroSpace's
# Super+C close; use zoxide's `z`/`zi` instead.)
if (( $+commands[fzf] )); then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  source <(fzf --zsh)
fi

# eza for listings.
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first --icons=auto'
  alias ll='eza -lh --group-directories-first --icons=auto --git'
  alias la='eza -lah --group-directories-first --icons=auto --git'
  alias lt='eza --tree --level=2 --icons=auto'
fi

# bat: ANSI theme follows Ghostty's palette, so it tracks theme-set.
if (( $+commands[bat] )); then
  export BAT_THEME=ansi
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT='-c'
fi

# ripgrep / fd need no setup; `rg` and `fd` are on PATH via Homebrew.

# Word movement: Option+arrows belong to AeroSpace and Alt+f to fullscreen,
# so Ctrl+Left/Right move by word (disable the Mission Control "Move
# left/right a space" shortcuts so macOS doesn't eat them). Alt+b still works.
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# starship, recolored by theme-set via a generated config.
if (( $+commands[starship] )); then
  if [[ -r ~/.local/state/omarchy-macos/theme/starship.toml ]]; then
    export STARSHIP_CONFIG=~/.local/state/omarchy-macos/theme/starship.toml
  else
    export STARSHIP_CONFIG=~/.config/omarchy-macos/starship-base.toml
  fi
  eval "$(starship init zsh)"
fi
