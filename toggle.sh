# /brc/toggle.sh

__check_dev_env() {
    local current_dir
    current_dir=$(pwd -P 2>/dev/null || echo "$PWD")
    local projects_dir="$HOME/projects" 
    local dev_script="/brc/.rc"
    local is_dev_dir=0

    if git rev-parse --is-inside-work-tree &>/dev/null || [[ "$current_dir" == "$projects_dir"* ]]; then
        is_dev_dir=1
    elif [[ -f "./.devuse" ]] || git rev-parse --show-toplevel &>/dev/null; then
        is_dev_dir=1
    else
        local check_path="$current_dir"
        while [[ "$check_path" != "/" ]]; do
            if [[ -f "$check_path/.devuse" ]]; then
                is_dev_dir=1
                break
            fi
            check_path=$(dirname "$check_path")
        done
    fi

    if [[ "$is_dev_dir" -eq 1 ]]; then
        if [[ "$DEV_ENV_SOURCED" != "1" ]]; then
            if [[ -f "$dev_script" ]]; then
                source "$dev_script"
                export DEV_ENV_SOURCED=1
                echo -e "\e[1;36m┌───󱔗 \e[1;32mDEVELOPMENT INSTANCE INITIALIZED\e[1;36m ├───────────────────────┐\e[0m"
            fi
        fi
    else
        if [[ "$DEV_ENV_SOURCED" == "1" ]]; then
            if [[ -n "${DEV_ALIASES[*]}" ]]; then
                for al in "${DEV_ALIASES[@]}"; do
                    unalias "$al" 2>/dev/null
                done
                unset DEV_ALIASES
            fi

            if [[ -n "$OLD_PS1" ]]; then
                export PS1="$OLD_PS1"
                unset OLD_PS1
            fi

            unset IN_DEV_ENV
            export DEV_ENV_SOURCED=0
            echo -e "\e[1;36m└───󰨞 \e[1;33mDEV INSTANCE TERMINATED; RESTORING CMD.EXE\e[1;36m ├─────────────┘\e[0m"
        fi
    fi
}
