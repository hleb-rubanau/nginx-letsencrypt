#!/bin/bash

function say() {
    echo "[$(date +%F-%T)] $*" >&2
}   

function die() {
    say "ERROR: $*"
    exit 1;
}

# useful for small utilities
function print_and_exit() {
    echo $*
    exit;
}

function report_vars() {
    for varname in $* ; do
        say "$varname=${!varname}"
    done
}

function check_file_params() {
    result="$(find $* 2>/dev/null || true)"
    [ ! -z "$result" ]
}

function require_var() {
    varname=$1
    if [ -z "${!varname}" ]; then
        die "Please define $varname"
    fi  
}

function require_vars() {
    MISSING_VARS=""
    for varname in $* ; do
        if [ -z "${!varname}" ]; then
            MISSING_VARS="$MISSING_VARS $varname"
        fi
    done
    if [ ! -z "$MISSING_VARS" ]; then
        die "Following variables are missing:$MISSING_VARS"
    fi
}

function letsencrypt_failed_recently() {
    [ -e $LETSENCRYPT_FAILURE_LOG_FILE ] && check_file_params $LETSENCRYPT_FAILURE_LOG_FILE -mmin -${LETSENCRYPT_FAILURE_GRACE_PERIOD}
}

function no_concurrent_cert_update() {
    ! check_file_params $CERTS_UPDATER_LOG -mmin -5
}
