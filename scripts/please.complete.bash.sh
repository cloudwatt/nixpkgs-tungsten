GET_ATTRS=./scripts/get-attrs.nix

_get_attrs()
{
    nix-instantiate --strict --eval --expr "(import $GET_ATTRS {}).all" | tr -d "[]\""
}

_get_tests()
{
    nix-instantiate --strict --eval --expr "(import $GET_ATTRS {}).tests" | tr -d "[]\""
}

_please_completions()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ "${#COMP_WORDS[@]}" = "2" ]; then
        COMPREPLY=($(compgen -W "build completions list run-vm run-test uninstall install shell init doctor" "${COMP_WORDS[1]}"))
        return
    fi

    # Without nix-instantiate we cannot retrieve any
    # suggestions
    if ! type nix-instantiate >/dev/null 2>&1; then
        return
    fi

    case "$prev" in
        uninstall|install|build|shell)
            COMPREPLY=($(compgen -W "$(_get_attrs)" "$cur"))
            ;;
        run-vm|run-test)
            COMPREPLY=($(compgen -W "$(_get_tests)" "$cur"))
            ;;
    esac
}

complete -F _please_completions ./please
