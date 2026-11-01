#!/usr/bin/env bash

set -u 

# Thresholds 

DISK_WARN=80
DISK_KO=90

# Helper : Output 

output_helper() {

    printf '%-5s %-8s %s\n' "$1" "$2" "$3" 

}

# Disk check 

DISK_PATH="/"

disk_check() {

    local usage
    usage=$(df --output=pcent "$DISK_PATH" | tail -n 1 | tr -dc '0-9')

    if [ "$usage" -ge "$DISK_KO"]; then 
        output_helper FAIL disk "$DISK_PATH is ${usage}% full"
        return 2
    elif [ "$usage" -ge "$DISK_WARN" ]; then 
        output_helper WARN disk "$DISK_PATH is ${usage}% full"
        return 1
    else 
        output_helper OK disk "$DISK_PATH is ${usage}% full"
        return 0
    fi
}

main(){

    disk_check
    exit $?

}

main "$@"