## Completion configuration
autoload -U compinit
compinit

# complete path when aliased command
setopt complete_aliases

# language configuration
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# auto time after REPORTTIME sec
export REPORTTIME=1

# auto menu complete
setopt auto_menu

# auto change directory
setopt auto_cd

# use brace
setopt brace_ccl

# auto directory pushd that you can get dirs list by cd -[tab]
setopt auto_pushd

# compacked complete list display
setopt list_packed

# no beep sound when complete list displayed
setopt nolistbeep

# no no match found
setopt nonomatch

# emacs like keybind (e.x. Ctrl-a, Ctrl-e)
bindkey -e

# multi redirect (e.x. echo "hello" > hoge1.txt > hoge2.txt)
setopt multios

# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

## export original variable
export DOTFILES=$HOME/dotfiles

## Command history configuration
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_ignore_dups  # ignore duplication command history list
setopt hist_ignore_space # ignore when commands starts with space
setopt share_history     # share command history data

# nodebrew
if [ -f $DOTFILES/pkg/nodebrew/nodebrew ]; then
  export NODEBREW_ROOT=$DOTFILES/pkg/nodebrew
  export PATH=$NODEBREW_ROOT/current/bin:$PATH
  nodebrew use v7
  . <(npm completion)
  alias npmls="npm ls --depth 0"

  # always add path of $DOTFILES/node_modules/.bin before
  export PATH=$DOTFILES/node_modules/.bin:$PATH

  # always add path of current repo
  export PATH=./node_modules/.bin:$PATH
fi

# rbenv
if [ -d "$DOTFILES/pkg/rbenv/bin" ]; then
  export CONFIGURE_OPTS="--disable-install-doc"
  export RBENV_ROOT=$DOTFILES/pkg/rbenv
  export PATH=$RBENV_ROOT/bin:$PATH
  eval "$(rbenv init -)"
  rbenv global 2.4.0
fi

# gobrew
if [ -d "$DOTFILES/pkg/go" ]; then
  # export path
  source $DOTFILES/pkg/go/.gopath
  export GOROOT=$DOTFILES/pkg/go/current
  export PATH=$GOROOT/bin:$PATH
  echo "GOPATH: $GOPATH"
fi

# export
[ -d "$DOTFILES/local/tmux" ] && export PATH=$DOTFILES/local/tmux/bin:$PATH
[ -d "$DOTFILES/pkg/nghttp2" ] && export PATH=$DOTFILES/pkg/nghttp2/src:$PATH
[ -d "$DOTFILES/pkg/icdiff" ] && export PATH=$DOTFILES/pkg/icdiff:$PATH && alias diff=icdiff
[ -d "$DOTFILES/pkg/peco" ] && export PATH=$DOTFILES/pkg/peco:$PATH
[ -d "$DOTFILES/pkg/websocketd" ] && export PATH=$DOTFILES/pkg/websocketd:$PATH
[ -d "$DOTFILES/pkg/weighttp" ] && export PATH=$DOTFILES/pkg/weighttp/build/default:$PATH
[ -d "$DOTFILES/bin" ] && export PATH=$DOTFILES/bin:$PATH

# include
if [ `uname` = "Darwin" ]; then
  [ -f $DOTFILES/zsh/mac.zsh ] && source $DOTFILES/zsh/mac.zsh
elif [ `uname` = "Linux" ]; then
  [ -f $DOTFILES/zsh/ubuntu.zsh ] && source $DOTFILES/zsh/ubuntu.zsh
fi

[ -f $DOTFILES/zsh/common.zsh ] && source $DOTFILES/zsh/common.zsh
[ -f $DOTFILES/zsh/peco.zsh ] && source $DOTFILES/zsh/peco.zsh
[ -f $DOTFILES/zsh/showbranch.zsh ] && source $DOTFILES/zsh/showbranch.zsh
[ -f $DOTFILES/zsh/rails_alias.zsh ] && source $DOTFILES/zsh/rails_alias.zsh
[ -f $DOTFILES/zsh/http_status_codes.zsh ] && source $DOTFILES/zsh/http_status_codes.zsh

# reload .zprofile
[ -f $HOME/.zprofile ] && source $HOME/.zprofile

# default Shell(zsh) => tmux => zsh
if [ $SHLVL = 1 ]; then
  echo -n "attach?(y/n/x): " && read attach
  echo $attach

  if [ $attach = "x" ]; then
    return
  fi

  # reattach-to-user-namespace when mac
  if [ `uname` = "Darwin" ]; then
    tmux_config=$(cat $HOME/.tmux.conf <(echo 'set-option -g default-command "reattach-to-user-namespace -l $SHELL"'))

    # try attache tmux when connect via ssh
    if [ $attach = "y" ] && [ "${SSH_CONNECTION-}" != "" ]; then
      tmux a -d || tmux -f <(echo "$tmux_config")
    else
      tmux -f <(echo "$tmux_config")
    fi
  else
    # try attache tmux when connect via ssh
    if [ $attach = "y" ] && [ "${SSH_CONNECTION-}" != "" ]; then
      tmux a -d || tmux
    else
      tmux
    fi
  fi
fi
