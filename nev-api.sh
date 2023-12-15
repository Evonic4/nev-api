#!/bin/bash
#nev-api

ver="0.1"
API_FOLDER="/usr/share/nev-api/"
HOOK_FILE="${API_FOLDER}/hook.sh"
LOG_FILE="${API_FOLDER}/log.txt"
PORT=$(sed -n 1"p" $API_FOLDER"settings.conf" | tr -d '\r')
echo "$(date '+%Y-%m-%d %H:%M:%S')  |  Start nev-api ver "$ver >> "${LOG_FILE}"


commands(){
    echo "$(date '+%Y-%m-%d %H:%M:%S')  |  Request : ${REQUEST}" >> "${LOG_FILE}"
    source "${HOOK_FILE}"
}

reply(){
    echo "${1}" > "${API_FOLDER}/temp"
}

continue(){
    REQUEST=$(echo ${REQUEST} | sed 's/^\///;   s/[^/]*\(\/.*\)/\1/')
}

error(){
    reply "404 Error | API Not Found"
}

listening(){
    printf "Listening on port ${PORT}"
    while true;do
        cat "${API_FOLDER}/temp" | nc -ln ${PORT} -q 1 > >(
       	while read line;do
            line=$(echo "${line}" | tr -d '[\r\n]')
            if echo "${line}" | grep -qE '^GET /' ;then
                REQUEST=$(echo "${line}" | cut -d ' ' -f2)
            elif [ "x${line}" = x ];then
                commands
            fi
            done
        )
    done
    rm -f "${API_FOLDER}/temp"
}

mkfifo "${API_FOLDER}/temp"
listening