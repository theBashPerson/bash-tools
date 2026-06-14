#!/bin/bash

echo -e "\e[1;36m󱔗 installing it or something.. oops i accidentally wiped your drive sorry bro \e[0m"


sudo mkdir -p /brc


echo "adding the binaries. its unsafe and i dont give a fuck."
sudo cp -r * /brc/
sudo cp .rc /brc/ 2>/dev/null || true

echo "-> executing internal uptools sequence..."
sudo chmod +x /brc/*


if ! grep -q "THE MULTITOOL MOD" ~/.bashrc; then
    echo "adding the like module checker thingy"
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

echo -e "\e[1;32m✔ done. do NOT ask for more shells. 'source ~/.bashrc'!\e[0m"
