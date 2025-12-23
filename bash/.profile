# ~/.profile: executed by Bourne-compatible login shells.

# ------------------------------------------
# 1. PATH & Environment Variables
# ------------------------------------------

# Rust & uv Env
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
elif [ -f "$HOME/.local/bin/env" ]; then
    . "$HOME/.local/bin/env"
fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# D-Bus / Secret Service Setup (WSL/Headless)
# PAMで正しく起動していれば DBUS_SESSION_BUS_ADDRESS は自動設定されるが、
# 念のため XDG_RUNTIME_DIR 配下のバスを確認して補完する
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    _uid=$(id -u)
    if [ -S "/run/user/$_uid/bus" ]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$_uid/bus"
    fi
    unset _uid
fi

# ------------------------------------------
# 2. Bash specific
# ------------------------------------------
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n 2> /dev/null || true

# Ensure local bin env is sourced
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
