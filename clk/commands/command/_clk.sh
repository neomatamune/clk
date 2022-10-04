#!/bin/bash -eu

clk_confirm () {
    local prompt="$1"
    local res
    read -p "${prompt} " res
    if echo "${res}" | grep -iq '^\(y\|yes\)$'
    then
        return 0
    else
        return 1
    fi
}

clk_name_to_env () {
    local name="$1"
    echo "CLK___$(echo "${name}"|sed -r 's/^-+//g'|sed 's/-/_/g'|tr '[:lower:]' '[:upper:]')"
}

clk_value ( ) {
    local name="$1"
    local variable="$(clk_name_to_env "${name}")"
    local variable_call="\${${variable}}"
    echo "$(eval "echo \"${variable_call}\"")"
}

clk_extension ( ) {
    local value="$1"
    echo "${value}"|sed -r 's|^(.+)\.([^.]+)$|\2|'
}

clk_without_extension ( ) {
    local value="$1"
    echo "${value}"|sed -r 's|^(.+)\.([^.]+)$|\1|'
}

clk_is_null ( ) {
    local name="$1"
    test "$(clk_value "${name}")" == ""
}

clk_is_true ( ) {
    local name="$1"
    test "$(clk_value "${name}")" = "True"
}

clk_import ( ) {
    local dep="$1"
    source "$(dirname "${0}")/lib/${dep}"
}

clk_list_to_choice () {
    echo "[$(sed -r 's-(.+)- "\1"-'| paste -s - -d,)]"
}

clk_abort () {
	local message="${1:-Aborting}"
	local code="${2:-1}"
	clk log -l error "${message}"
	exit "${code}"
}

clk_help_handler () {
	if [ $# -gt 0 ] && [ "$1" == "--help" ]
	then
		clk_usage
		exit 0
	fi
    if [ "${CLK__LOG_LEVEL}" = "debug" ] \
           || [ "${CLK__LOG_LEVEL}" = "develop" ] \
           || [ "${CLK__DEBUG}" = "True" ] \
           || [ "${CLK__DEVELOP}" = "True" ]
    then
        set -x
    fi
}

_log () {
	clk log "$@"
}

_info () {
	_log -l info "$@"
}

clk_in_project () {
	pushd "${CLK__PROJECT}" > /dev/null
}

clk_end_in_project () {
	popd > /dev/null
}

clk_wait_for_line () {
	local line="$1"
	line="$(echo "${line}"|sed 's/\//\\\//g')"
	exec sed -n "/${line}/q"
}

clk_wait_for_line_tee () {
	local line="$1"
	line="$(echo "${line}"|sed 's/\//\\\//g')"
	exec sed "/${line}/q"
}

clk_pid_exists () {
	local pid="$1"
	ps -p "${1}" > /dev/null 2>&1
}
