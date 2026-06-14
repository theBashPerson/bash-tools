#!/bin/bash

echo -e "\e[1;36m󱔗 INITIALIZING BASH-HACKS MANUAL INSTALLATION...\e[0m"

# create the target directory layout
sudo mkdir -p /brc

# copy everything over safely
echo "-> transferring multitool binaries to /brc..."
sudo cp -r * /brc/
sudo cp .rc /brc/ 2>/dev/null || true

# fix the global script permissions instantly
echo "-> executing internal uptools sequence..."
sudo chmod +x /brc/*

# inject setup code to .bashrc if it isn't already there
if ! grep -q "THE MULTITOOL MOD" ~/.bashrc; then
    echo "-> appending modular shell hooks to ~/.bashrc..."
    cat << 'EOF' >> ~/.bashrc

# THE MULTITOOL MOD
# dev environment hook
if [[ -f /brc/toggle.sh ]]; then
    source /brc/toggle.sh
    if [[ ";$PROMPT_COMMAND;" != *";__check_dev_env;"* ]]; then
        export PROMPT_COMMAND="__check_dev_env;$PROMPT_COMMAND"
    fi
fi
# the unofficial fabric port
# expose custom multitool scripts universally
if [[ -d /brc ]]; then
    export PATH="$PATH:/brc"
fi
EOF
fi

echo -e "\e[1;32m✔ INSTALLATION COMPLETE. reload your terminal with 'source ~/.bashrc'!\e[0m"
