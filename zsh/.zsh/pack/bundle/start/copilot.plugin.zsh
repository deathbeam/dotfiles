function copilot {
  if [ -z "$1" ]; then
    echo -e -n "\033[0;31m"
    echo "Usage: copilot <shell|git|gh> <query>"
    return 1
  fi

  query_type=$1
  shift

  if [ -z "$1" ]; then
    echo -e -n "\033[0;31m"
    echo "Usage: copilot <shell|git|gh> <query>"
    return 1
  fi

  keyword=Suggestion:

  command=$(echo "" | gh copilot suggest -t $query_type "$@" 2>/dev/null | grep $keyword -A2 | grep -v $keyword)
  if [ -z "$command" ]; then
    echo -e -n "\033[0;31m"
      echo "Error: no suggestion found."
      return 1
  fi

  trimmed_command=$(echo $command | xargs)
  print -z $trimmed_command
}

alias '??'='copilot shell'
alias 'git?'='copilot git'
alias 'gh?'='copilot gh'
