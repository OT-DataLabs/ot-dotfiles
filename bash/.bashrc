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

fastfetch_responsive() {
    # Obtenemos el ancho actual de la terminal en columnas
    local width=$(tput cols)

    # Si la terminal tiene menos de 80 columnas (es pequeña)
    if [ "$width" -lt 80 ]; then
        fastfetch -c ~/.config/fastfetch/small.jsonc
    # Si la terminal tiene entre 80 y 110 columnas (mediana)
    elif [ "$width" -lt 110 ]; then
        fastfetch -c ~/.config/fastfetch/medium.jsonc
    # Si la terminal es grande
    else
        fastfetch -c ~/.config/fastfetch/config.jsonc
    fi
}

# Alias para que al escribir 'fastfetch' o usarlo en el inicio, se ejecute la función
alias fastfetch='fastfetch_responsive'
