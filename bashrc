# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

black='\e[0;30m'
Black='\e[1;30m'
red='\e[0;31m'
Red='\e[1;31m'
green='\e[0;32m'
Green='\033[1;32m'
yellow='\e[0;33m'
Yellow='\[\e[1;33m\]'
blue='\e[0;34m'
Blue='\e[1;34m'
cyan='\e[0;36m'
Cyan='\e[1;36m'
white='\e[0;37m'
White='\e[1;37m'
nocolor='\[\e[0m\]' #no color

# don't put duplicate lines in the history. See bash(1) for more options
#export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    #alias vdir='ls --color=auto --format=long'
fi

# some more ls aliases
alias ll='ls -lh'
alias la='ls -Ah'
#alias l='ls -CF'

#alias svn-b="svn-buildpackage -us -uc -rfakeroot --svn-ignore-new --svn-lintian"
#alias svn-br="svn-b --svn-dont-purge --svn-reuse --svn-lintian"
#alias svn-bt="svn-buildpackage --svn-tag -rfakeroot"
#alias svn-e="svn-buildpackage --svn-export --svn-ignore-new --svn-dont-clean"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" -a -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [ -f /usr/lib/git-core/git-rev-parse ]; then
	gitrevparse=/usr/lib/git-core/git-rev-parse
	gitsymbolicref=/usr/lib/git-core/git-symbolic-ref
	gitnamerev=/usr/lib/git-core/git-name-rev
else
	gitrevparse=git-rev-parse
	gitsymbolicref=git-symbolic-ref
	gitnamerev=git-name-rev
fi

# git VCS information into the prompt
__vcs_dir() {
   local vcs base_dir sub_dir ref
   sub_dir() {
     local sub_dir
     sub_dir=$(readlink -f "${PWD}")
     sub_dir=${sub_dir#$1}
     echo ${sub_dir#/}
   }
   git_dir() {
     base_dir=$($gitrevparse --show-cdup 2>/dev/null) || return 1
	 if [ -z "$base_dir" ]; then base_dir="."; fi
     base_dir=$(readlink -f "$base_dir")
     sub_dir=$($gitrevparse --show-prefix)
     sub_dir=${sub_dir%/}
     ref=$($gitsymbolicref -q HEAD || $gitnamerev --name-only HEAD 2>/dev/null)
     ref=${ref#refs/heads/}
     vcs="git"
   }
   svn_dir() {
     [ -d ".svn" ] || return 1
     base_dir="."
     while [ -d "$base_dir/../.svn" ]; do base_dir="$base_dir/.."; done
     base_dir=$(readlink -f "$base_dir")
     sub_dir=$(sub_dir "${base_dir}")
     ref=$(svn info "$base_dir" | awk '/^URL/ { sub(".*/","",$0); r=$0 } /^Revision/ { sub("[^0-9]*","",$0); print r":"$0 }')
     vcs="svn"
   }

   git_dir || svn_dir

   [ "$vcs" ] && echo -e "($vcs)${base_dir/$HOME/~}:${sub_dir}[$ref]" \
   || echo "${PWD/$HOME/~}"
 }
 
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:$(__vcs_dir)\[\033[00m\]\$ '

# set a fancy prompt (non-color, unless we know we "want" color)
#case "$TERM" in
#xterm-color)
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#    ;;
#*)
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#    ;;
#esac


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    ;;
*)
    ;;
esac

# Define your own aliases here ...
#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# fire-up SSH agent if necessary
#if [ -z "$SSH_AGENT_PID" ]; then
#    printf "No ssh-agent detected. Starting one for you: "
#    eval `ssh-agent -s` 
#fi

# fire-up GPG agent if necessary
#if [ -z "$GPG_AGENT_INFO" ]; then
#    printf "No gpg-agent detected. Starting one for you.\n"
#    eval "$(gpg-agent --daemon)"
#fi

# user bin path
export PATH=$PATH:$HOME/bin
export GIT_EDITOR="vim"
export EDITOR="vim"
export VISUAL="gvim -f"

# use orig language
#export LC_ALL=C
#export LANG=C

# get FSL config loaded
if [ -f /etc/fsl/fsl.sh ]; then . /etc/fsl/fsl.sh; fi

# knock on paranoids door (yarik)
knock() 
{ 
 
  ( pn=${2:-10101} 
  dur=${3:-3} 
  echo telnet $1 $pn 
  telnet $1 $pn &> /dev/null & 
  sleep $dur 
  kill %% &> /dev/null )& 
} 

# search mail and display results
sm()
{
  mairix $1
  mutt -f ~/private/mail/mfolder
}

# look into the calendar
[ -e /tmp/gcalcli_agenda.txt ] && tail -n +2 /tmp/gcalcli_agenda.txt  | head -n -1

alias xlock='xlock -mode blank'
alias procincoming='reprepro -v -b ~/public_html/archive processincoming Default'
# ease git
alias gk='gitk --all&'
alias gfo='git fetch origin'
alias gpull='git pull origin master'
alias gpush='git push origin master'
alias ipy='ipython -pylab'
alias chrome='chromium-browser --enable-plugins'
#alias vimmvpa='PYLINTRC=$HOME/Desktop/host/mvpa2/PyMVPA/doc/misc/pylintrc vim'
#alias gvimmvpa='PYLINTRC=$HOME/Desktop/host/mvpa2/PyMVPA/doc/misc/pylintrc gvim'

alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias gitk='gitk --all'
alias lth='ls -lth'
alias ipy='ipython --pylab'
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
. /etc/afni/afni.sh
export FREESURFER_HOME=/apps/freesurfer-5.3
export PATH=/apps/afni-openmp:$PATH:$FREESURFER_HOME/bin:$HOME/bin:/$HOME/mvpa_linux_bkup/the_code
export PYTHONPATH=$HOME/mvpa_linux_bkup/the_code:$HOME/mvpa_linux_bkup/mvpa2/PyMVPA:$HOME/repos/reprclust:$PYTHONPATH:$HOME/virtenv:$HOME/repos/tensorflow:.
#$HOME/mvpa_linux_bkup/music/subjects/bregman:$HOME/lib/python:.
source $FREESURFER_HOME/FreeSurferEnv.sh
export SUBJECTS_DIR=$HOME/mvpa_linux_bkup/raiders_dartmouth/fsrecon
export AFNI_GLOBAL_SESSION=/apps/afni-openmp-20150526


. /home/swaroop/repos/torch/install/bin/torch-activate
alias matlab='/apps/matlab/Matlab_R2014b/bin/matlab'
