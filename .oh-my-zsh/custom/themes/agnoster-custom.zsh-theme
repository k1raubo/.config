# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster-custom - based on agnoster's Theme (https://gist.github.com/3712874)
# Customized: neutral black background + blue accent (Catppuccin Blue #89b4fa)
#
# INSTALLATION:
# 1. Copy this file to: ~/.oh-my-zsh/custom/themes/agnoster-custom.zsh-theme
# 2. In ~/.zshrc set: ZSH_THEME="agnoster-custom"
# 3. Requires a Powerline-patched / Nerd Font

### Segment drawing

CURRENT_BG='NONE'

CURRENT_FG='#cdd6f4'
CURRENT_DEFAULT_FG='#cdd6f4'

### Color palette (hex) - matches rofi / alacritty / nvim theme

: ${AGNOSTER_DIR_FG:='#161616'}
: ${AGNOSTER_DIR_BG:='#89b4fa'}      # Catppuccin Blue - main accent

: ${AGNOSTER_CONTEXT_FG:='#cdd6f4'}
: ${AGNOSTER_CONTEXT_BG:='#262626'}  # neutral dark gray

: ${AGNOSTER_GIT_CLEAN_FG:='#161616'}
: ${AGNOSTER_GIT_CLEAN_BG:='#a6e3a1'} # Catppuccin Green
: ${AGNOSTER_GIT_DIRTY_FG:='#161616'}
: ${AGNOSTER_GIT_DIRTY_BG:='#f9e2af'} # Catppuccin Yellow

: ${AGNOSTER_BZR_CLEAN_FG:='#161616'}
: ${AGNOSTER_BZR_CLEAN_BG:='#a6e3a1'}
: ${AGNOSTER_BZR_DIRTY_FG:='#161616'}
: ${AGNOSTER_BZR_DIRTY_BG:='#f9e2af'}

: ${AGNOSTER_HG_NEWFILE_FG:='#161616'}
: ${AGNOSTER_HG_NEWFILE_BG:='#f38ba8'} # Catppuccin Red
: ${AGNOSTER_HG_CHANGED_FG:='#161616'}
: ${AGNOSTER_HG_CHANGED_BG:='#f9e2af'}
: ${AGNOSTER_HG_CLEAN_FG:='#161616'}
: ${AGNOSTER_HG_CLEAN_BG:='#a6e3a1'}

: ${AGNOSTER_VENV_FG:='#161616'}
: ${AGNOSTER_VENV_BG:='#89b4fa'}

: ${AGNOSTER_AWS_PROD_FG:='#f9e2af'}
: ${AGNOSTER_AWS_PROD_BG:='#f38ba8'}
: ${AGNOSTER_AWS_FG:='#161616'}
: ${AGNOSTER_AWS_BG:='#a6e3a1'}

: ${AGNOSTER_STATUS_RETVAL_FG:='#f38ba8'}   # Red
: ${AGNOSTER_STATUS_ROOT_FG:='#f9e2af'}     # Yellow
: ${AGNOSTER_STATUS_JOB_FG:='#89b4fa'}      # Blue
: ${AGNOSTER_STATUS_FG:='#cdd6f4'}
: ${AGNOSTER_STATUS_BG:='#262626'}

: ${AGNOSTER_STATUS_RETVAL_NUMERIC:=false}
: ${AGNOSTER_GIT_INLINE:=false}
: ${AGNOSTER_GIT_BRANCH_STATUS:=true}

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0'
}

prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

git_toplevel() {
	local repo_root=$(git rev-parse --show-toplevel)
	if [[ $repo_root = '' ]]; then
		repo_root=$(git rev-parse --git-dir)
		if [[ $repo_root = '.' ]]; then
			repo_root=$PWD
		fi
	fi
	echo -n $repo_root
}

### Prompt components

prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment "$AGNOSTER_CONTEXT_BG" "$AGNOSTER_CONTEXT_FG" "%(!.%{%F{$AGNOSTER_STATUS_ROOT_FG}%}.)%n@%m"
  fi
}

prompt_git_relative() {
  local repo_root=$(git_toplevel)
  local path_in_repo=$(pwd | sed "s/^$(echo "$repo_root" | sed 's:/:\\/:g;s/\$/\\$/g')//;s:^/::;s:/$::;")
  if [[ $path_in_repo != '' ]]; then
    prompt_segment "$AGNOSTER_DIR_BG" "$AGNOSTER_DIR_FG" "$path_in_repo"
  fi;
}

prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'
  }
  local ref dirty mode repo_path

   if [[ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(command git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref="◈ $(command git describe --exact-match --tags HEAD 2> /dev/null)" || \
    ref="➦ $(command git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment "$AGNOSTER_GIT_DIRTY_BG" "$AGNOSTER_GIT_DIRTY_FG"
    else
      prompt_segment "$AGNOSTER_GIT_CLEAN_BG" "$AGNOSTER_GIT_CLEAN_FG"
    fi

    if [[ $AGNOSTER_GIT_BRANCH_STATUS == 'true' ]]; then
      local ahead behind
      ahead=$(command git log --oneline @{upstream}.. 2>/dev/null)
      behind=$(command git log --oneline ..@{upstream} 2>/dev/null)
      if [[ -n "$ahead" ]] && [[ -n "$behind" ]]; then
        PL_BRANCH_CHAR=$'\u21c5'
      elif [[ -n "$ahead" ]]; then
        PL_BRANCH_CHAR=$'\u21b1'
      elif [[ -n "$behind" ]]; then
        PL_BRANCH_CHAR=$'\u21b0'
      fi
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
    [[ $AGNOSTER_GIT_INLINE == 'true' ]] && prompt_git_relative
  fi
}

prompt_bzr() {
  (( $+commands[bzr] )) || return

  local dir="$PWD"
  while [[ ! -d "$dir/.bzr" ]]; do
    [[ "$dir" = "/" ]] && return
    dir="${dir:h}"
  done

  local bzr_status status_mod status_all revision
  if bzr_status=$(command bzr status 2>&1); then
    status_mod=$(echo -n "$bzr_status" | head -n1 | grep "modified" | wc -m)
    status_all=$(echo -n "$bzr_status" | head -n1 | wc -m)
    revision=${$(command bzr log -r-1 --log-format line | cut -d: -f1):gs/%/%%}
    if [[ $status_mod -gt 0 ]] ; then
      prompt_segment "$AGNOSTER_BZR_DIRTY_BG" "$AGNOSTER_BZR_DIRTY_FG" "bzr@$revision ✚"
    else
      if [[ $status_all -gt 0 ]] ; then
        prompt_segment "$AGNOSTER_BZR_DIRTY_BG" "$AGNOSTER_BZR_DIRTY_FG" "bzr@$revision"
      else
        prompt_segment "$AGNOSTER_BZR_CLEAN_BG" "$AGNOSTER_BZR_CLEAN_FG" "bzr@$revision"
      fi
    fi
  fi
}

prompt_hg() {
  (( $+commands[hg] )) || return
  local rev st branch
  if $(command hg id >/dev/null 2>&1); then
    if $(command hg prompt >/dev/null 2>&1); then
      if [[ $(command hg prompt "{status|unknown}") = "?" ]]; then
        prompt_segment "$AGNOSTER_HG_NEWFILE_BG" "$AGNOSTER_HG_NEWFILE_FG"
        st='±'
      elif [[ -n $(command hg prompt "{status|modified}") ]]; then
        prompt_segment "$AGNOSTER_HG_CHANGED_BG" "$AGNOSTER_HG_CHANGED_FG"
        st='±'
      else
        prompt_segment "$AGNOSTER_HG_CLEAN_BG" "$AGNOSTER_HG_CLEAN_FG"
      fi
      echo -n ${$(command hg prompt "☿ {rev}@{branch}"):gs/%/%%} $st
    else
      st=""
      rev=$(command hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(command hg id -b 2>/dev/null)
      if command hg st | command grep -q "^\?"; then
        prompt_segment "$AGNOSTER_HG_NEWFILE_BG" "$AGNOSTER_HG_NEWFILE_FG"
        st='±'
      elif command hg st | command grep -q "^[MA]"; then
        prompt_segment "$AGNOSTER_HG_CHANGED_BG" "$AGNOSTER_HG_CHANGED_FG"
        st='±'
      else
        prompt_segment "$AGNOSTER_HG_CLEAN_BG" "$AGNOSTER_HG_CLEAN_FG"
      fi
      echo -n "☿ ${rev:gs/%/%%}@${branch:gs/%/%%}" $st
    fi
  fi
}

prompt_dir() {
  if [[ $AGNOSTER_GIT_INLINE == 'true' ]] && $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    prompt_segment "$AGNOSTER_DIR_BG" "$AGNOSTER_DIR_FG" "$(git_toplevel | sed "s:^$HOME:~:")"
  else
    prompt_segment "$AGNOSTER_DIR_BG" "$AGNOSTER_DIR_FG" '%~'
  fi
}

prompt_virtualenv() {
  if [ -n "$CONDA_DEFAULT_ENV" ]; then
    prompt_segment "$AGNOSTER_VENV_BG" "$AGNOSTER_VENV_FG" "🐍 $CONDA_DEFAULT_ENV"
  fi
  if [[ -n "$VIRTUAL_ENV" && -n "$VIRTUAL_ENV_DISABLE_PROMPT" ]]; then
    prompt_segment "$AGNOSTER_VENV_BG" "$AGNOSTER_VENV_FG" "(${VIRTUAL_ENV:t:gs/%/%%})"
  fi
}

prompt_status() {
  local -a symbols

  if [[ $AGNOSTER_STATUS_RETVAL_NUMERIC == 'true' ]]; then
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$AGNOSTER_STATUS_RETVAL_FG}%}$RETVAL"
  else
    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{$AGNOSTER_STATUS_RETVAL_FG}%}✘"
  fi
  [[ $UID -eq 0 ]] && symbols+="%{%F{$AGNOSTER_STATUS_ROOT_FG}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$AGNOSTER_STATUS_JOB_FG}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment "$AGNOSTER_STATUS_BG" "$AGNOSTER_STATUS_FG" "$symbols"
}

prompt_aws() {
  [[ -z "$AWS_PROFILE" || "$SHOW_AWS_PROMPT" = false ]] && return
  case "$AWS_PROFILE" in
    *-prod|*production*) prompt_segment "$AGNOSTER_AWS_PROD_BG" "$AGNOSTER_AWS_PROD_FG"  "AWS: ${AWS_PROFILE:gs/%/%%}" ;;
    *) prompt_segment "$AGNOSTER_AWS_BG" "$AGNOSTER_AWS_FG" "AWS: ${AWS_PROFILE:gs/%/%%}" ;;
  esac
}

prompt_terraform() {
  local terraform_info=$(tf_prompt_info)
  [[ -z "$terraform_info" ]] && return
  prompt_segment magenta yellow "TF: $terraform_info"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_aws
  prompt_terraform
  prompt_context
  prompt_dir
  prompt_git
  prompt_bzr
  prompt_hg
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
