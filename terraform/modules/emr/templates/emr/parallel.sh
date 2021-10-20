#!/bin/bash

parallelize() {

    declare -a pids
    declare -a commands
    declare -i index=0

    while read -r command; do
        stderr Executing \'"$command"\'
        $command &
        commands[$index]=$command
        pids[$index]=$!
        ((index++))
    done

    declare -a return_codes

    for i in $(seq 0 $((${#pids[@]} - 1))); do
        local pid=${pids[$i]}
        local command=${commands[$i]}
        stderr waiting for \""$command"\", pid: \"$pid\".
        wait $pid
        local rc=$?
        if [[ $rc != 0 ]]; then
            stderr Command failed: \""$command"\", return code: \"$rc\".
        fi
        return_codes[$i]=$rc
    done

    local bit=1
    local compound_rc=0
    for i in $(seq 0 $((${#return_codes[@]} - 1))); do
        if [[ ${return_codes[$i]} != 0 ]]; then
            ((compound_rc |= bit))
        fi
        ((bit*=2))
    done

    if [[ $compound_rc != 0 ]]; then
        exit "$compound_rc"
    fi
}

stderr() {
    echo "$@" >&2
}