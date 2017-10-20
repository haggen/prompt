# See https://github.com/haggen/prompt

function update_prompt {
  local _pwd="${PWD/#$HOME/~}"
  local _git

  # Shorten current working directory.
  if test "$_pwd" != "~"; then
    _pwd="${${${${(@j:/:M)${(@s:/:)_pwd}##.#?}:h}%/}//\%/%%}/${${_pwd:t}//\%/%%}"
  fi

  # Tell if we're within a Git repository.
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then

    # Tell if there's uncommited changes.
    if test -n "$(git status --porcelain)"; then
      _git="%F{red}*%f "
    else
      local git_local="$(git rev-parse @)"
      local git_remote="$(git rev-parse '@{u}')"
      local git_base="$(git merge-base @ '@{u}')"

      if test "$git_local" = "$git_remote"; then
        _git=
      elif test "$git_local" = "$git_base"; then
        _git="%F{cyan}↓%f "
      elif test "$git_remote" = "$git_base"; then
        _git="%F{cyan}↑%f "
      fi
    fi
  fi

  # Set prompt.
  PROMPT="%B$_pwd $_git%b"
}

# Hook to just before a command is executed.
function preexec {
  precmd_seconds=$SECONDS
}

# Hook to just before a new prompt is displayed.
function precmd {
  if test -z "$precmd_seconds"; then
    return
  fi

  # Calculate elapsed seconds since last command was executed.
  elapsed_seconds=$(( $SECONDS - $precmd_seconds ))

  local hours minutes seconds remainder

  # Print elapsed time since last command.
  if (( elapsed_seconds >= 3600 )); then
    hours=$(( elapsed_seconds / 3600 ))
    remainder=$(( elapsed_seconds % 3600 ))
    minutes=$(( remainder / 60 ))
    seconds=$(( remainder % 60 ))
    print -P "%Belapsed time ${hours}h${minutes}m${seconds}s%b"
  elif (( elapsed_seconds >= 60 )); then
    minutes=$(( elapsed_seconds / 60 ))
    seconds=$(( elapsed_seconds % 60 ))
    print -P "%Belapsed time ${minutes}m${seconds}s%b"
  elif (( elapsed_seconds >= 1 )); then
    print -P "%Belapsed time ${elapsed_seconds}s%b"
  fi

  # Clear marked seconds. Next time it executes, unless a
  # new command has been input it'll skip this calculation.
  precmd_seconds=

  # Update prompt.
  update_prompt
}

update_prompt
