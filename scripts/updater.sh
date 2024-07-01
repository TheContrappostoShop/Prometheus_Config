#!/usr/bin/env bash

usage() {
    cat << EOM
Usage: $1 component-name [target-release]
EOM
}

is_user_root ()
{
    [ "${EUID:=$(id -u)}" -eq 0 ]
}

 yes_or_no() {
     local prompt="$1"
     while true; do
         read -p "$prompt (y/n) " -r
         case "$REPLY" in
         y | Y)
             echo true
             return 0
             ;;
         n | N)
             echo false
             return 0
             ;;
         *)
             echo "Invalid response. Please try again." >&2
             ;;
         esac
     done
 }


get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

get_github_releases() {
    curl --silent "https://api.github.com/repos/$1/releases" | 
        grep '"tag_name":' | 
        sed -E 's/.*"([^"]+)".*/\1/'
}

get_github_releases_from_component() {
    COMPONENT="$1"
    
    case "$COMPONENT" in
    "odyssey")
        echo "$(get_github_releases "TheContrappostoShop/Odyssey")" ;;
    "orion")
        echo "$(get_github_releases "TheContrappostoShop/Orion")" ;;
    *)
        echo "Invalid component, cannot list releases" >&2
        exit 1 ;;
    esac
}

update_odyssey() {
    RELEASE="$1"

    if [ "$RELEASE" == "latest" ]; then
        ODYSSEY_URL="https://github.com/TheContrappostoShop/Odyssey/releases/latest/download/odyssey_armv7.tar.gz"
    else
        ODYSSEY_URL="https://github.com/TheContrappostoShop/Odyssey/releases/download/$RELEASE/odyssey_armv7.tar.gz"
    fi

    systemctl stop odyssey

    cd "/home/$SUDO_USER"

    wget "${ODYSSEY_URL}" -O - | tar -C odyssey/ -xz

    # Remove example yaml to avoid confusion
    rm -rf odyssey/example.yaml

    systemctl start odyssey

    cd -
}

update_orion() {
    RELEASE="$1"

    if [ "$RELEASE" == "latest" ]; then
        ORION_URL="https://github.com/TheContrappostoShop/Orion/releases/latest/download/orion_armv7.tar.gz"
    else
        ORION_URL="https://github.com/TheContrappostoShop/Orion/releases/download/$RELEASE/orion_armv7.tar.gz"
    fi

    systemctl stop orion

    cd "/home/$SUDO_USER"

    wget "${ORION_URL}" -O - | tar -C orion/ -xz

    systemctl start orion

    cd -
}

update_nanodlp() {
    exit 1
}


COMPONENT="$1"

if [[ -z "$2" ]]; then
    RELEASE="latest"
else
    RELEASE="$2"
fi

if [[ "$RELEASE" == "-l" || "$RELEASE" == "--list" ]]; then
    get_github_releases_from_component $COMPONENT
    exit 0
fi

if [[ -z "$COMPONENT" ]]; then
    usage
    exit 1
fi


if ! is_user_root; then
    echo "This script must be run with `sudo`"
    exit 1
fi

echo "Requested to update component=$COMPONENT to release=$RELEASE"
if ! $(yes_or_no "Would you like to continue?"); then
    exit 0
fi

case "$COMPONENT" in
"odyssey")
    update_odyssey $RELEASE ;;
"orion")
    update_orion $RELEASE ;;
"nanodlp")
    update_nanodlp $RELEASE ;;
*)
    echo "Invalid component" >&2
    exit 1 ;;
esac


    
