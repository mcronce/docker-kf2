function require_config() {
    # Generate INI files
    if [[ ! -f "${HOME}/kf2server/KFGame/Config/PCServer-KFGame.ini" ]]; then
        "${HOME}/kf2server/Binaries/Win64/KFGameSteamServer.bin.x86_64" kf-bioticslab?difficulty=0?adminpassword=secret?gamepassword=secret -port=7777 &
        for i in {0..20}; do
            if [[ -f "${HOME}/kf2server/KFGame/Config/PCServer-KFGame.ini" ]]; then
                break;
            fi;
            sleep 1;
        done;
        kfpid=$(pgrep -f port=7777)
        kill $kfpid
    fi
}

function load_config() {
    ## Load defaults if nothing has been set

    # Default to survival
    [[ -z "$KF_GAME_MODE" ]] && export KF_GAME_MODE=Survival
    if [[ "$KF_GAME_MODE" == 'VersusSurvival' ]]; then
        KF_GAME_MODE='VersusSurvival?maxplayers=12';
    fi;

    # find /path/to/volume -name '*KF-*kfm' | xargs -n 1 basename -s .kfm\n"
    [[ -z "$KF_MAP" ]] && export KF_MAP=KF-BioticsLab

    # 0 - normal, 1 - hard, 2 - suicidal, 3 - hell on earth
    [[ -z "$KF_DIFFICULTY" ]] && export KF_DIFFICULTY=0

    # Used for web console and in-game logins
    [[ -z "$KF_ADMIN_PASS" ]] && export KF_ADMIN_PASS=secret

    # Setting this creates a private server
    [[ -z "$KF_GAME_PASS" ]] && export KF_GAME_PASS=''

    # 0 - 4 waves, 1 - 7 waves, 2 - 10 waves, default 1
    [[ -z "$KF_GAME_LENGTH" ]] && export KF_GAME_LENGTH=1

    # Name that appears in the server browser
    [[ -z "$KF_SERVER_NAME" ]] && export KF_SERVER_NAME=KF2 Server

    # true or false, default false
    [[ -z "$KF_ENABLE_WEB" ]] && export KF_ENABLE_WEB=false

    # default to 7777
    [[ -z "$KF_PORT" ]] && export KF_PORT=7777

    # default to $(($KF_PORT + 19238))
    #    (19238 = 27015 - 7777)
    [[ -z "$KF_QUERY_PORT" ]] && export KF_QUERY_PORT="$(($KF_PORT + 19238))"

    # default to 8080
    [[ -z "$KF_WEBADMIN_PORT" ]] && export KF_WEBADMIN_PORT=8080


    ## Now we edit the config files to set the config
    sed -i "s/^GameLength=.*/GameLength=$KF_GAME_LENGTH\r/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFGame.ini"
    sed -i "s/^ServerName=.*/ServerName=$KF_SERVER_NAME\r/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFGame.ini"
    sed -i "s/^bEnabled=.*/bEnabled=$KF_ENABLE_WEB\r/" "${HOME}/kf2server/KFGame/Config/KFWeb.ini"
    [[ "${KF_DISABLE_TAKEOVER}" == 'true' ]] && sed -i 's/^bUsedForTakeover=.*/bUsedForTakeover=FALSE'"\r"'/' "${HOME}/kf2server/KFGame/Config/LinuxServer-KFGame.ini"
}

function launch() {
    export WINEDEBUG=fixme-all
    local cmd

    cmd="${HOME}/kf2server/Binaries/Win64/KFGameSteamServer.bin.x86_64 "
    cmd+="$KF_MAP?Game=KFGameContent.KFGameInfo_$KF_GAME_MODE"
    cmd+="?Difficulty=$KF_DIFFICULTY"
    cmd+="?AdminPassword=$KF_ADMIN_PASS"
    [[ -z "$KF_GAME_PASS" ]] || cmd+="?GamePassword=$KF_GAME_PASS"
    cmd+=" -Port=$KF_PORT"
    cmd+=" -WebAdminPort=$KF_WEBADMIN_PORT"
    cmd+=" -QueryPort=$KF_QUERY_PORT"

    echo "Running command: $cmd" > $0-cmd.log
    exec $cmd
}
