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
