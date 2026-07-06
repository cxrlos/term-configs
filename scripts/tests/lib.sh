#!/usr/bin/env bash
# Minimal Bash 3.2 assertion helpers for term-configs script tests.

_tests_pass=0
_tests_fail=0

assert_eq() { # msg want got
    if [[ "$2" == "$3" ]]; then
        _tests_pass=$((_tests_pass + 1))
        printf '  ok  %s\n' "$1"
    else
        _tests_fail=$((_tests_fail + 1))
        printf '  FAIL %s\n       want: %s\n       got:  %s\n' "$1" "$2" "$3"
    fi
}

assert_contains() { # msg needle haystack
    case "$3" in
        *"$2"*) assert_eq "$1" match match ;;
        *)      assert_eq "$1" "contains:$2" "$3" ;;
    esac
}

tests_summary() {
    printf '\n  %d passed, %d failed\n' "$_tests_pass" "$_tests_fail"
    [[ "$_tests_fail" -eq 0 ]]
}
