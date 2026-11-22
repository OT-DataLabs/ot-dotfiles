#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH=$PATH:/home/oscar/.local/bin
eval "$(oh-my-posh init bash --config "$HOME/.config/ohmyposh/cobalt2.omp.json")"


fastfetch() {
    local width=$(tput cols)

    if [ "$width" -lt 65 ]; then
        # 'command' le dice a Zsh que ejecute el binario real, no la función (evita un bucle infinito)
        command fastfetch -c ~/.config/fastfetch/small.jsonc
    elif [ "$width" -lt 110 ]; then
        command fastfetch -c ~/.config/fastfetch/medium.jsonc
    else
        command fastfetch -c ~/.config/fastfetch/config.jsonc
    fi
}


alias emu8086="wine ~/.wine/drive_c/EMU8086/emu8086.exe &>/dev/null &"
