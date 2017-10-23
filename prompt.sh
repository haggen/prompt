# See https://github.com/haggen/prompt

# Accessible variables.
local _prompt_pwd _prompt_git _precmd_seconds

# Enable prompt substitution and add
# carriage return before the prompt.
setopt promptsubst promptcr

# The prompt.
PROMPT='%B$_prompt_pwd $_prompt_git%b'

# Update the directory section of prompt.
function update_prompt_pwd {
  # Get current working directory, replacing $HOME for ~.
  _prompt_pwd="${PWD/#$HOME/~}"

  # Shorten the path.
  if test "$_prompt_pwd" != "~"; then
    _prompt_pwd="${${${${(@j:/:M)${(@s:/:)_prompt_pwd}##.#?}:h}%/}//\%/%%}/${${_prompt_pwd:t}//\%/%%}"
  fi
}

# Update the Git section of prompt.
function update_prompt_git {

  # Tell if we're within a Git repository.
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then

    # Get current branch.
    local branch="${$(git symbolic-ref HEAD 2> /dev/null)#refs/heads/}"

    # Tell if we're in the middle of a rebase -i.
    if test -d $(git rev-parse --git-dir)/rebase-merge; then
      _prompt_git="%F{red}*%f "

    # Tell if the working copy is clean.
    elif test -n "$(git status --porcelain)"; then
      _prompt_git="%F{yellow}$branch±%f "

    # Otherwise change colors and append a cue.
    else
      local git_local="$(git rev-parse @)"
      local git_remote="$(git rev-parse '@{u}')"
      local git_base="$(git merge-base @ '@{u}')"

      if test "$git_local" = "$git_remote"; then
        _prompt_git="%F{white}$branch%f "
      elif test "$git_local" = "$git_base"; then
        _prompt_git="%F{cyan}$branch▼%f "
      elif test "$git_remote" = "$git_base"; then
        _prompt_git="%F{green}$branch▲%f "
      fi
    fi
  fi
}

# Hook to when the current working directory changes.
function chpwd {
  update_prompt_pwd
  update_prompt_git
}

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

# Update prompt variables once at initialization.
update_prompt_pwd
update_prompt_git
