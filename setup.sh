#!/bin/bash
# setup.sh — interactive installer / updater for bash-tools
command -v fzf &>/dev/null || { echo -e "\e[1;31m󰅚 fzf required. pacman -S fzf\e[0m"; exit 1; }

INSTALL_DIR="/brc"
BASHRC="$HOME/.bashrc"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── helpers ────────────────────────────────────────────────────────────────────
_header() {
    echo -e "\e[1;36m"
    echo "  ██████╗  █████╗ ███████╗██╗  ██╗    ████████╗ ██████╗  ██████╗ ██╗     ███████╗"
    echo "  ██╔══██╗██╔══██╗██╔════╝██║  ██║       ██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝"
    echo "  ██████╔╝███████║███████╗███████║       ██║   ██║   ██║██║   ██║██║     ███████╗"
    echo "  ██╔══██╗██╔══██║╚════██║██╔══██║       ██║   ██║   ██║██║   ██║██║     ╚════██║"
    echo "  ██████╔╝██║  ██║███████║██║  ██║       ██║   ╚██████╔╝╚██████╔╝███████╗███████║"
    echo "  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝"
    echo -e "\e[0m"
    echo -e "  \e[1;35m󱔗  lazy mode activated — bash-tools installer v2.0.0\e[0m\n"
}

_ok()   { echo -e "  \e[1;32m󰄬 $*\e[0m"; }
_err()  { echo -e "  \e[1;31m󰅚 $*\e[0m"; }
_info() { echo -e "  \e[1;36m󰋖 $*\e[0m"; }
_warn() { echo -e "  \e[1;33m  $*\e[0m"; }

_header

# ── action picker ──────────────────────────────────────────────────────────────
action=$(printf \
    'install — full fresh install\nupdate — pull latest + re-install\nuninstall — rip it all out\ncheck deps — see what is missing\nquit' | \
    fzf --prompt="  what do: " \
        --height=12 \
        --layout=reverse \
        --border \
        --header="  bash-tools setup")

[[ -z "$action" || "$action" == "quit" ]] && { _warn "bailing out"; exit 0; }

# ── dep check ─────────────────────────────────────────────────────────────────
_check_deps() {
    local hard_deps=(bash fzf git)
    local soft_deps=(wl-copy xclip xsel unrar 7z)
    echo ""
    _info "checking hard dependencies..."
    local missing_hard=()
    for d in "${hard_deps[@]}"; do
        if command -v "$d" &>/dev/null; then
            _ok "$d found"
        else
            _err "$d MISSING"
            missing_hard+=("$d")
        fi
    done

    echo ""
    _info "checking optional dependencies..."
    for d in "${soft_deps[@]}"; do
        if command -v "$d" &>/dev/null; then
            _ok "$d found"
        else
            _warn "$d not found (optional)"
        fi
    done

    if [[ ${#missing_hard[@]} -gt 0 ]]; then
        echo ""
        read -rp "$(echo -e "\e[1;33m  install missing hard deps via pacman? (y/n): \e[0m")" yn
        if [[ "$yn" == "y" ]]; then
            sudo pacman -S --needed --noconfirm "${missing_hard[@]}"
        fi
    fi
}

# ── install ───────────────────────────────────────────────────────────────────
_install() {
    echo ""
    _info "creating $INSTALL_DIR ..."
    sudo mkdir -p "$INSTALL_DIR"

    _info "copying tools..."
    local excluded=("PKGBUILD" "install.sh" "setup.sh" "README.md" "uptools")
    for f in "$SCRIPT_DIR"/*; do
        bn=$(basename "$f")
        skip=0
        for ex in "${excluded[@]}"; do [[ "$bn" == "$ex" ]] && skip=1 && break; done
        [[ "$skip" -eq 1 ]] && continue
        [[ -f "$f" ]] && sudo install -Dm 755 "$f" "$INSTALL_DIR/$bn" && _ok "installed $bn"
    done

    # dot files — 644
    for dotfile in .rc .devuse; do
        [[ -f "$SCRIPT_DIR/$dotfile" ]] && \
            sudo install -Dm 644 "$SCRIPT_DIR/$dotfile" "$INSTALL_DIR/$dotfile" && \
            _ok "installed $dotfile"
    done

    # toggle.sh — 644 (sourced not exec'd)
    [[ -f "$SCRIPT_DIR/toggle.sh" ]] && \
        sudo install -Dm 644 "$SCRIPT_DIR/toggle.sh" "$INSTALL_DIR/toggle.sh" && \
        _ok "installed toggle.sh"

    # bashrc hook
    if ! grep -q "THE MULTITOOL MOD" "$BASHRC" 2>/dev/null; then
        _info "injecting bashrc hook..."
        cat >> "$BASHRC" << 'EOF'

# THE MULTITOOL MOD
if [[ -f /brc/toggle.sh ]]; then
    source /brc/toggle.sh
    if [[ ";$PROMPT_COMMAND;" != *";__check_dev_env;"* ]]; then
        export PROMPT_COMMAND="__check_dev_env;$PROMPT_COMMAND"
    fi
fi
if [[ -d /brc ]]; then
    export PATH="$PATH:/brc"
fi
EOF
        _ok "bashrc hook injected"
    else
        _warn "bashrc hook already present — skipping"
    fi

    echo ""
    _ok "done! run: source ~/.bashrc"
}

# ── update ────────────────────────────────────────────────────────────────────
_update() {
    _info "pulling latest from git..."
    git -C "$SCRIPT_DIR" pull && _ok "repo updated"
    _install
}

# ── uninstall ─────────────────────────────────────────────────────────────────
_uninstall() {
    echo ""
    read -rp "$(echo -e "\e[1;31m  this will delete /brc and remove the bashrc hook. type 'YES' to confirm: \e[0m")" yn
    [[ "$yn" != "YES" ]] && { _warn "cancelled"; return; }

    sudo rm -rf /brc
    _ok "deleted /brc"

    # strip bashrc hook
    if [[ -f "$BASHRC" ]]; then
        sed -i '/# THE MULTITOOL MOD/,/^fi$/d' "$BASHRC"
        _ok "bashrc hook removed"
    fi

    _warn "uninstalled. you are now slower."
}

# ── dispatch ──────────────────────────────────────────────────────────────────
case "$action" in
    install*) _check_deps; _install ;;
    update*)  _check_deps; _update  ;;
    uninstall*) _uninstall ;;
    "check deps"*) _check_deps ;;
esac

echo ""
echo -e "\e[1;36m└─────────────────────────────────────────────────────────────┘\e[0m"
