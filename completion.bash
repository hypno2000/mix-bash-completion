# ! /usr/bin/env bash
#
# bash completion for Elixir's build tool, Mix
#
# Prerequisites:
#
#   *) Elixir is installed
#   *) Elixir is in your PATH
#
# Installation:
#
#   *) Copy this file and .tasks.exs to ~/.mix-completion.bash
#   *) Append this line to your .bashrc:
#       source ~/.mix-completion.bash
#   *) Run the above command for the changes to take place immediately

cache_file="$HOME/.mix-completion-task-list"

# clear the cache
rm -rf "$cache_file"

exists(){
  if [ "$2" != in ]; then
    echo "Incorrect usage."
    echo "Correct usage: exists {key} in {array}"
    return
  fi   
  eval '[ ${'$3'[$1]+muahaha} ]'  
}

__mix()
{
    local cwd current previous more_previous exs tasks separator task_list superoption i j

    COMPREPLY=()

    current="${COMP_WORDS[COMP_CWORD]}"
    previous="${COMP_WORDS[COMP_CWORD - 1]}"
    more_previous="${COMP_WORDS[COMP_CWORD - 2]}"

    __mix_get_tasks "$cache_file"

    case "${previous}" in
        mix)
            __mix_complete_tasks
            ;;
        archive)
            __mix_complete_custom "${previous}"
            ;;
            -i)
                __mix_complete_directories
                ;;
            -o)
                __mix_complete_files
                ;;
        clean)
            __mix_complete_wordlist "--all"
            ;;
        cmd)
            __mix_complete_commands
            ;;
        compile)
            __mix_complete_wordlist"--list"
            ;;
        # dependenices cannot be completed as of now
        deps.clean)
            __mix_complete_custom "${previous}"
            ;;
        deps.compile)
            __mix_complete_wordlist "--quiet"
            ;;
        deps.get)
            __mix_complete_custom "${previous}"
            ;;
        deps.unlock)
            __mix_complete_wordlist "--all"
            ;;
        deps.update)
            __mix_complete_custom "${previous}"
            ;;
        do)
            __mix_complete_tasks
            ;;
        escriptize)
            __mix_complete_custom "${previous}"
            ;;
        local.install)
            __mix_complete_wordlist"--force"
            ;;
        local.rebar)
            __mix_complete_files
            ;;
        local.uninstall)
            __mix_complete_tasks
            ;;
        # i.e. `mix help help ` does not complete against tasks
        help)
            if [[ ! ${more_previous} == "help" ]] ; then __mix_complete_tasks; fi
            ;;
        new)
            __mix_complete_custom "${previous}"
            ;;
        run)
            __mix_complete_custom "${previous}"
            ;;
        test)
            __mix_complete_custom "${previous}"
            ;;
            --cover)
                __mix_complete_directories
                ;;
        *)
            __mix_get_superoption

            # `mix do [task]..., ` completes against tasks
            if [[ ("${COMP_WORDS[1]}" == "do" && "${previous:(-1)}" == ",") ]] ; then
                __mix_complete_tasks
            # `mix [task] [option] ` completes for task instead of option
            elif [[ ! -z "$superoption" && ! "$superoption" == "${current}" ]] ; then
                __mix_complete_custom "$superoption"
            fi

            return 0;;
    esac

    return 0
}

__mix_get_superoption()
{
    # retrive the last superoption, i.e. the latest option that is not a suboption
    for (( i=${#COMP_WORDS[@]} - 1; i >= 0; i-- ))
    do
        for (( j=${#tasks[@]} - 1; j >= 0; j-- ))
        do
            if [[ "${COMP_WORDS[i]}" == "${tasks[j]}"  ]] ; then
                superoption="${tasks[j]}"
                break 2
            fi
        done
    done
}

__mix_get_tasks()
{
    # create a file if it doesn't exist
    if [ ! -f "$1" ] ; then
        touch "$1"
    fi

    dir="$(pwd)"
    task_list="$(grep "$dir" "$1" | cut -d '=' -f 2)"

    # create dir tasks cach if it doesn't exists
    if [ "$task_list" == "" ]; then
        task_list="$(mix help | grep "^mix" | cut -d " " -f 2 | tr "\n" " ")"
        echo "$dir=$task_list" >> "$1"
    fi
}

__mix_complete_commands()
{
    COMPREPLY=($(compgen -c -- ${current}))
}

# used to complete for tasks with multiple options
__mix_complete_custom()
{
    case $1 in
        archive)
            __mix_complete_wordlist "--no-compile"
            ;;
        deps.clean)
            __mix_complete_wordlist "--all --unlock";
            ;;
        deps.get)
            __mix_complete_wordlist "--no-compile --no-deps-check --quiet"
            ;;
        deps.update)
            __mix_complete_wordlist "-- all --no-compile --no-deps-check --quiet"
            ;;
        escriptize)
            __mix_complete_wordlist "--force --no-compile"
            ;;
        new)
            __mix_complete_multi "--bare --module --umbrella"
            ;;
        run)
            __mix_complete_multi "--eval --require --parallel-require --no-halt --no-compile --no-start"
            ;;
        test)
            __mix_complete_multi "--trace --max-cases --cover --force --no-compile --no-start --no-color"
            ;;
        *)
            ;;
    esac

}
__mix_complete_directories()
{
    COMPREPLY=($(compgen -d -- ${current}))
}
__mix_complete_files()
{
    COMPREPLY=($(compgen -f -- ${current}))
}

# complete against oprions or files
__mix_complete_multi()
{
    if [[ ${current} == --* ]] ; then
        COMPREPLY=($(compgen -W "${1}" -- ${current}))
    else
        __mix_complete_files
    fi
}

__mix_complete_tasks()
{
    COMPREPLY=($(compgen -W "${task_list}" -- ${current}))
}

__mix_complete_wordlist()
{
    if [[ ${current} == --* ]] ; then
        COMPREPLY=($(compgen -W "${1}" -- ${current}))
    fi
}

complete -F __mix mix
