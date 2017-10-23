# See https://github.com/haggen/prompt

# Hook to just before a command is executed.
function preexec {
  _precmd_seconds=$SECONDS
}

# Hook to just before a new prompt is displayed
# after a command has been executed.
function precmd {
  if test -z "$_precmd_seconds"; then
    return
  fi

  # Calculate elapsed seconds since last command was executed.
  elapsed_seconds=$(( $SECONDS - $_precmd_seconds ))

  local h m s r

  # Print elapsed time since last command.
  if (( elapsed_seconds >= 3600 )); then
    h=$(( elapsed_seconds / 3600 ))
    r=$(( elapsed_seconds % 3600 ))
    m=$(( r / 60 ))
    s=$(( r % 60 ))
    print -P "%Belapsed time ${h}h${m}m${s}s%b"
  elif (( elapsed_seconds >= 60 )); then
    m=$(( elapsed_seconds / 60 ))
    s=$(( elapsed_seconds % 60 ))
    print -P "%Belapsed time ${m}m${s}s%b"
  elif (( elapsed_seconds >= 1 )); then
    print -P "%Belapsed time ${elapsed_seconds}s%b"
  fi

  # Clear marked seconds. Next time it executes, unless a
  # new command has been input it'll skip this calculation.
  _precmd_seconds=
}

# Get the directory section of prompt.
function _prompt_pwd {
  # Get current working directory, replacing $HOME for ~.
  local pwd="${PWD/#$HOME/~}"

  # Shorten the path.
  if test "$pwd" != "~"; then
    print "${${${${(@j:/:M)${(@s:/:)pwd}##.#?}:h}%/}//\%/%%}/${${pwd:t}//\%/%%}"
  else
    print "$pwd"
  fi
}

# Get the Git section of prompt.
function _prompt_git {
  local branch local_head remote_head base_head

  # Bail if we are outside a Git repository.
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return
  fi

  # Get active branch.
  branch="${$(git symbolic-ref HEAD 2> /dev/null)#refs/heads/}"

  # Change colors and append status cue.
  if test -d $(git rev-parse --git-dir)/rebase-merge; then
    print "%F{red}*%f "
  elif test -n "$(git status --porcelain)"; then
    print "%F{yellow}$branch±%f "
  else
    local_head="$(git rev-parse @)"
    remote_head="$(git rev-parse '@{u}')"
    base_head="$(git merge-base @ '@{u}')"

    if test "$local_head" = "$remote_head"; then
      print "%F{white}$branch%f "
    elif test "$local_head" = "$base_head"; then
      print "%F{cyan}$branch▼%f "
    elif test "$remote_head" = "$base_head"; then
      print "%F{green}$branch▲%f "
    fi
  fi
}

# Enable prompt substitution and add
# carriage return before the prompt.
setopt promptsubst promptcr

# The prompt.
PROMPT='%B$(_prompt_pwd) $(_prompt_git)%b'
