#!/usr/bin/env bash
# [@]ignisc4t (enigm4)
###=============================================###
## Android Termux Metasploit-AIO Installer v1.1-rev
###=============================================###

## Color set - Make it a little colorful
B=$(tput bold)
U=$(tput smul)
Ut=$(tput rmul)
tblk="$(tput bold)$(tput setaf 0)"
tred="$(tput bold)$(tput setaf 1)"
tgrn="$(tput bold)$(tput setaf 2)"
tylo="$(tput bold)$(tput setaf 3)"
tblu="$(tput bold)$(tput setaf 4)"
tmgt="$(tput bold)$(tput setaf 5)"
tcyn="$(tput bold)$(tput setaf 6)"
twht="$(tput bold)$(tput setaf 7)"
bdr=$(echo ${tmgt}"[=]"${tylo})

## Function block-start here
###=============================================###

## setting Installer
set -e
export PREFIX=/data/data/com.termux/files/usr
export TMPDIR=$PREFIX/tmp

## Getting user sessions id
function useraio() {
    echo -e "${tylo}[?]${tcyn} Checking user..."
    if [ "$(id -u)" = "0" ] ; then
        echo -e "${tred}[!] You're not allowed to run this on root."
        exit 1
    elif [ "$(id -u)" != "0" ] ; then
        echo -e "${tylo}[√]${tcyn} Checking user done."
    fi
}

## Getting android version
function aosver() {
    echo -e "${tylo}[√] $(uname -m)${tcyn} detected"
    echo -e "${tylo}[?]${tcyn} Checking android version..."
    aos=$(getprop ro.build.version.release)
}

## Folding message
FOLD_COLUMNS=70
if [[ $COLUMNS =~ ([[:digit:]]) ]] && ((COLUMNS < FOLD_COLUMNS)); then
        FOLD_COLUMNS=$COLUMNS
fi

## Main Function
###=============================================###

## Updating Termux packages
function aptoops() {
    echo -e "${tylo}[*]${tcyn} Updating required dependencies..."
    apt update -y && apt upgrade -y &> /dev/null
    apt install busybox -y
    apt install apr apr-util autoconf bison clang coreutils curl findutils git libffi libgmp libiconv libpcap libsqlite libtool libxml2 libxslt make ncurses ncurses ncurses-utils openssl pkg-config postgresql readline resolv-conf ruby tar termux-elf-cleaner termux-tools unzip wget zip zlib -y
    echo -e "${tylo}[*]${tcyn} Updating dependecies done."
}

## Downloading Metasploit
function msffver() {
    echo -e "${tred}[!]${tylo} Please, enter Msf version manually,\n    put ${tred}release number only${tylo} in the prompt below."
    echo -e "$tred[!]${tylo} Enter Metasploit version (e.g. 5.0.98 or 6.0.0): "
    read MSFVER
    echo -e "${tylo}[OK]${tred} Metasploit-$MSFVER.tar.gz${tcyn} will be installed."
    if [ -f $TMPDIR/metasploit-$MSFVER.tar.gz ] ; then
        echo -e "${tylo}[√]${tcyn} Found metasploit-$MSFVER.tar.gz, proceed with installing..."
    else
        echo -e "${tylo}[*]${tcyn} Downloading Metasploit-Framework-$MSFVER-dev..."
        mkdir -p "$TMPDIR"
        rm -rf "$TMPDIR"/metasploit-*
        msffcurl;
        curl -L "https://github.com/rapid7/metasploit-framework/archive/$MSFVER.tar.gz" -o "$TMPDIR/metasploit-$MSFVER.tar.gz"
        msffdown;
    fi
}

## Checking Metasploit download
function msffdown() {
    if [ -f $TMPDIR/metasploit-$MSFVER.tar.gz ] ; then
        echo -e "${tylo}[OK]${tcyn} metasploit-$MSFVER.tar.gz downloaded at $TMPDIR"
    else
        echo -e "${tred}[X] Downloading metasploit-$MSFVER.tar.gz failed.\n    ${tylo}Please make sure you enter the right ${U}RELEASE NUMBER${Ut}"
        msffver;
    fi
}

## Checking the existence Msf archive on the web
function msffcurl() {
    if wget --spider "https://github.com/rapid7/metasploit-framework/archive/$MSFVER.tar.gz" 2> /dev/null; then
        echo -e "${tylo}[OK]${tcyn} Metasploit-$MSFVER.tar.gz available."
    else
        echo -e "${tred}[X] Metasploit-$MSFVER.tar.gz Version not found, ${tylo}try again with different version"
        msffver;
    fi
}

## Installing Metasploit
function msffinst() {
    echo -e "${tylo}[*]${tcyn} Removing previous version Metasploit Framework..."
    rm -rf "$PREFIX"/opt/metasploit-framework
    echo -e "${tylo}[*]${tcyn} Extracting new version of Metasploit Framework..."
    mkdir -p "$PREFIX"/opt/metasploit-framework
    tar zxf "$TMPDIR/metasploit-$MSFVER.tar.gz" --strip-components=1 \
            -C "$PREFIX"/opt/metasploit-framework
}

## Installing Rubygems
function msffruby() {
    if [ "$(gem list -i rubygems-update 2>/dev/null)" = "false" ]; then
        echo -e "${tylo}[*]${tcyn} Installing 'rubygems-update' if necessary..."
        gem install --no-document --verbose rubygems-update
        echo -e "${tylo}[*]${tcyn} Installing 'bundler:1.7.3'..."
        gem install --no-document --verbose  bundler:1.7.3
    fi
}

## Building Metasploit
function msffbuildg() {
    echo -e "${tylo}[*]${tcyn} Installing Metasploit-Framework dependencies..."
    echo -e "${tred}[!]${tcyn} (it'll be a long time wait, you better do something with your time)."
    cd "$PREFIX"/opt/metasploit-framework
    gem install --no-document --verbose bundler
    bundle config build.nokogiri --use-system-libraries
    bundle install --deployment --jobs=2 --verbose
}

## Installing fix for Msf and Ruby
function msffixer() {
    echo -e "${tylo}[*]${tcyn} Running fixes..."
    sed -i "s@/etc/resolv.conf@$PREFIX/etc/resolv.conf@g" "$PREFIX"/opt/metasploit-framework/lib/net/dns/resolver.rb
    find "$PREFIX"/opt/metasploit-framework -type f -executable -print0 | xargs -0 -r termux-fix-shebang
    find "$PREFIX"/lib/ruby/gems -type f -iname \*.so -print0 | xargs -0 -r termux-elf-cleaner
}

## Setting Postgresql
function msffpgsql() {
    echo -e "${tylo}[*]${tcyn} Setting MSF database..."
    mkdir -p "$PREFIX"/opt/metasploit-framework/config
    sleep 0.5
    {
    echo ' production:'
    echo '  adapter: postgresql'
    echo '  database: msf_database'
    echo '  username: msf'
    echo '  password:'
    echo '  host: 127.0.0.1'
    echo '  port: 5432'
    echo '  pool: 75'
    echo '  timeout: 5'
    } >> "$PREFIX"/opt/metasploit-framework/config/database.yml
    sleep 0.5

    echo -e "${tylo}[*]${tcyn} Setting Postgresql database..."
    if [ -d $PREFIX/var/lib/postgresql ] ; then
        pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent
    else
        mkdir -p "$PREFIX"/var/lib/postgresql
        if [ -f $PREFIX/var/lib/postgresql/postmaster.pid ] ; then
            pg_ctl -D "$PREFIX"/var/lib/postgresql stop --silent
        elif [ -f $PREFIX/tmp/.s.PGSQL.* ] ; then
            pg_ctl -D "$PREFIX"/var/lib/postgresql stop --silent
        else
            if ! pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent; then
                initdb "$PREFIX"/var/lib/postgresql
                pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent
            fi
            if [ -z "$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='msf'")" ]; then
                createuser msf
            fi
            if [ -z "$(psql -l | grep msf_database)" ]; then
                createdb msf_database
            fi
        fi
    fi
}

## Installing MSF fixer >= 7.0
function msffconsfix7() {
    echo -e "${tblk}[*] Installing another fix..."
    rm -rf $PREFIX/bin/{msfconsole,msfd,msfrpc,msfrpcd,msfvenom} > /dev/null 2>&1 || true

    {
    echo ' #!/data/data/com.termux/files/usr/bin/sh'
    echo ' '
    echo ' SCRIPT_NAME=$(basename "$0")'
    echo ' METASPLOIT_PATH="/data/data/com.termux/files/usr/opt/metasploit-framework"'
    echo ' '
    echo ' # Fix ruby bigdecimal extensions linking error.'
    echo ' case "$(uname -m)" in'
    echo '         aarch64)'
    echo '                 export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.7.0/aarch64-linux-android/bigdecimal.so"'
    echo '                 ;;'
    echo '         arm*)'
    echo '                 export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.7.0/arm-linux-androideabi/bigdecimal.so"'
    echo '                 ;;'
    echo '         i686)'
    echo '                 export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.7.0/i686-linux-android/bigdecimal.so"'
    echo '                 ;;'
    echo '         x86_64)'
    echo '                 export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.7.0/x86_64-linux-android/bigdecimal.so"'
    echo '                 ;;'
    echo '         *)'
    echo '                 ;;'
    echo ' esac'
    echo ' '
    echo ' case "$SCRIPT_NAME" in'
    echo '         msfconsole|msfd|msfrpc|msfrpcd|msfvenom)'
    echo '                 exec ruby "$METASPLOIT_PATH/$SCRIPT_NAME" "$@"'
    echo '                 ;;'
    echo '         *)'
    echo '                 echo "[!] Unknown Metasploit command '$SCRIPT_NAME'."'
    echo '                 exit 1'
    echo '                 ;;'
    echo ' esac'
    } >> "$PREFIX"/bin/msfconsole

    for i in msfd msfrpc msfrpcd msfvenom; do
        ln -sfr "$PREFIX"/bin/msfconsole "$PREFIX"/bin/$i
    done
    chmod +777 "$PREFIX"/bin/{msfconsole,msfd,msfrpc,msfrpcd,msfvenom} > /dev/null 2>&1
    echo -e "${tylo}[OK]${tcyn} Fix bigdecimal.so for${tylo} $(uname -m)${tcyn} device success !!!"
    echo
}

## Installing MSF fixer =< 6.0
function msffconsfix6() {
    echo -e "${tblk}[*] Installing another fix..."
    rm -rf $PREFIX/bin/{msfconsole,msfd,msfrpc,msfrpcd,msfvenom} > /dev/null 2>&1 || true

    {
    echo ' #!/data/data/com.termux/files/usr/bin/sh'
    echo ' '
    echo ' SCRIPT_NAME=$(basename "$0")'
    echo ' METASPLOIT_PATH="/data/data/com.termux/files/usr/opt/metasploit-framework"'
    echo ' '
    echo ' # Fix ruby bigdecimal extensions linking error.'
    echo ' case "$(uname -m)" in'
    echo '         aarch64)'
    echo '                 export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.6.0/aarch64-linux-android/bigdecimal.so"'
    echo '                 ;;'
    echo '         arm*)'
    echo '                 export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.6.0/arm-linux-androideabi/bigdecimal.so"'
    echo '                 ;;'
    echo '         i686)'
    echo '                 export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.6.0/i686-linux-android/bigdecimal.so"'
    echo '                 ;;'
    echo '         x86_64)'
    echo '                 export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.6.0/x86_64-linux-android/bigdecimal.so"'
    echo '                 ;;'
    echo '         *)'
    echo '                 ;;'
    echo ' esac'
    echo ' '
    echo ' case "$SCRIPT_NAME" in'
    echo '         msfconsole|msfd|msfrpc|msfrpcd|msfvenom)'
    echo '                 exec ruby "$METASPLOIT_PATH/$SCRIPT_NAME" "$@"'
    echo '                 ;;'
    echo '         *)'
    echo '                 echo "[!] Unknown Metasploit command '$SCRIPT_NAME'."'
    echo '                 exit 1'
    echo '                 ;;'
    echo ' esac'
    } >> "$PREFIX"/bin/msfconsole

    for i in msfd msfrpc msfrpcd msfvenom; do
        ln -sfr "$PREFIX"/bin/msfconsole "$PREFIX"/bin/$i
    done
    chmod +777 "$PREFIX"/bin/{msfconsole,msfd,msfrpc,msfrpcd,msfvenom} > /dev/null 2>&1
    echo -e "${tylo}[OK]${tcyn} Fix bigdecimal.so for${tylo} $(uname -m)${tcyn} device success !!!"
    echo
}

## Function block-end here
###=============================================###
## Pre Message I
clear;
echo "${tgrn}
                                                        
         ##   #                    #     #        #   #   #   
         ##  ##     #              #       #     # #  #  # #  
         ##  ##  #  ##  #   # ###  #  #  # ##    # #  # #   # 
         # ## # ### #   ## #  #  # # # # # #     ###  # #   # 
         # ## # #   #  # # ## #  # # # # # #    #   # #  # #  
         ### ##  ## ##  ## #  ###  #  #  # ##   #  ## #   #   
                              #                               
                              ##
                                                    ${tred}v1.0
                                                    ${tylo}[@]eNigm4
"

## Pre Message II
echo "
${bdr}           ${tred}[!]${tylo}PLEASE READ THIS BEFORE YOU PROCEED!${tred}[!]          ${bdr}
${bdr}                                                               ${bdr}
${bdr} ${tred}[!] Disclaimer : ${tylo}${U}Use this scripts at ${tred}'YOUR OWN RISK'${Ut}          ${bdr}
${bdr}                                                               ${bdr}
${bdr} This scripts doesn't guarrantee if Metasploit will working    ${bdr}
${bdr} on your Termux environment!! It will download Metasploit      ${bdr}
${bdr} source and tried to install on your android device. If you're ${bdr}
${bdr} had a doubt or installing some scripts then never use it,     ${bdr}
${bdr} leave this script immediately by choose 'No' at the beginning ${bdr}
${bdr} of this script.                                               ${bdr}
${bdr}                                                               ${bdr}
${bdr} Files will be downloaded from the original repository of      ${bdr}
${bdr} Metasploit ${tcyn}https://github.com/rapid7/metasploit-framework.${tylo}    ${bdr}
${bdr} ${tylo}Then it will begin the installation procedure on your device  ${bdr}
${bdr}                                                               ${bdr}
${bdr} Please, Don't ask neither Metasploit (Rapid7) nor Termux deve ${bdr}
${bdr} -eloper for assistance, Termux ${tred}'IS NOT'${tylo} officially supported  ${bdr}
${bdr} by Metasploit. You're on your own.                            ${bdr}
${bdr}                                                               ${bdr}
${bdr} FYI: Metasploit also available on Termux unstable-repo, just  ${bdr}
${bdr} in case if you wondering. Refer to termux wiki for installing ${bdr}
${bdr} guide. ;)                                                     ${bdr}
${bdr} ${tred}                     You've been warned!!${tylo}                     ${bdr}
${bdr} The original metasploit installer scripts provided in Termux  ${bdr}
${bdr} unstable-packages repository at Github:                       ${bdr}
${bdr} ${tcyn}github.com/termux/unstable-packages/tree/master/packages/meta ${tylo}${bdr}
${bdr} ${tcyn}sploit. ${tylo}Credits belong to Rapid7 and Termux Apps Developer    ${bdr}
${bdr} for making this possible.                                     ${bdr}
${bdr}                                                               ${bdr}
${bdr}                                             ${tgrn}Metasploit-AIO${tylo}    ${bdr}
${bdr}                                                     ${tgrn}eNigm4${tylo}    ${bdr}
"

###=============================================###
### Main Program Start here
###=============================================###
## Starting point
while true; do
    echo -e "${tylo}Press 'Y' to install, 'N' to exit, then press enter.${tcyn}"
    read -p "[!] Do you want to install it ? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* )
            echo -e "${tcyn}    see you again...\n"
            exit 1;;
        * ) echo -e "${tylo}    Please answer${tgrn} yes${tylo} or${tred} no";;
    esac
done

## Call user checking
useraio;

## Call android os version
## Get and build Msf according to Android specification
aosver;
case "$aos" in
    7|7.0|7.1.2|8|8.0|8.1|9|9.0)
        echo -e "${tylo}[√]${tcyn} Your system running on Android ${tylo}${aos}${tcyn},\n    Gathering required dependencies..." ; sleep 0.25
        aptoops;
        printf %b "${tblu}[×××××>                                            ]${twht}[ 10%]\n" ; sleep 0.25
        msffver;
        printf %b "${tblu}[××××××××××××>                                     ]${twht}[ 25%]\n" ; sleep 0.25
        msffinst;
        printf %b "${tblu}[×××××××××××××××××>                                ]${twht}[ 35%]\n" ; sleep 0.25
        msffruby;
        printf %b "${tblu}[×××××××××××××××××××××××××>                        ]${twht}[ 50%]\n" ; sleep 0.25
        msffbuildg;
        printf %b "${tblu}[×××××××××××××××××××××××××××××××××>                ]${twht}[ 70%]\n" ; sleep 0.25
        msffixer;
        printf %b "${tblu}[××××××××××××××××××××××××××××××××××××××××>         ]${twht}[ 85%]\n" ; sleep 0.25
        msffconsfix7;
        printf %b "${tblu}[×××××××××××××××××××××××××××××××××××××××××××××××>  ]${twht}[ 95%]\n" ; sleep 0.25
        msffpgsql;
        printf %b "${tblu}[××××××××××××××××××××××××××××××××××××××××××××××××××]${twht}[100%]\n" ; sleep 0.25
        ;;
    5|5.0|5.1|6|6.0|6.0.1)
        echo -e "${tylo}[√]${tcyn} Your system running on Android ${tylo}${aos}${tcyn},\n    Gathering required dependencies..." ; sleep 0.25
        aptoops;
        printf %b "${tblu}[×××××>                                            ]${twht}[ 10%]\n" ; sleep 0.25
        msffver;
        printf %b "${tblu}[××××××××××××>                                     ]${twht}[ 25%]\n" ; sleep 0.25
        msffinst;
        printf %b "${tblu}[×××××××××××××××××>                                ]${twht}[ 35%]\n" ; sleep 0.25
        msffruby;
        printf %b "${tblu}[×××××××××××××××××××××××××>                        ]${twht}[ 50%]\n" ; sleep 0.25
        msffbuildg;
        printf %b "${tblu}[×××××××××××××××××××××××××××××××××>                ]${twht}[ 70%]\n" ; sleep 0.25
        msffixer;
        printf %b "${tblu}[××××××××××××××××××××××××××××××××××××××××>         ]${twht}[ 85%]\n" ; sleep 0.25
        msffconsfix6;
        printf %b "${tblu}[×××××××××××××××××××××××××××××××××××××××××××××××>  ]${twht}[ 95%]\n" ; sleep 0.25
        msffpgsql;
        printf %b "${tblu}[××××××××××××××××××××××××××××××××××××××××××××××××××]${twht}[100%]\n" ; sleep 0.25
        ;;
esac

###=============================================###
### Main Program End Here
###=============================================###
## Post Message

echo -e "${tgrn}[OK]${tcyn} Metasploit Framework ${tylo}${MSFVER}-dev${tcyn} installation finished"
echo -e "${tgrn}[√]${tcyn} Enjoy the beast in your phone!"
echo
echo -e "${tylo} - Metasploit directory :"
echo -e "${tcyn}   $PREFIX/opt/metasploit-framework"
echo -e "${tcyn}   $HOME/.msf4"
echo
echo -e "${tylo} - Postgresql directory :"
echo -e "${tcyn}   $PREFIX/var/lib/postgresql"
echo
echo -e "${tylo} - Starting and stopping postgresql database:"
echo -e "${tcyn}   pg_ctl -D $PREFIX/var/lib/postgresql start"
echo -e "${tcyn}   pg_ctl -D $PREFIX/var/lib/postgresql stop"
echo
echo -e "${tylo} - Running command :"
echo -e "${tcyn}   msfconsole"
echo -e "${tcyn}   msfconsole --help"
echo
echo -e "${tcyn}[+] Don't forget to check the new Metasploit\n    release for bug fix!"
echo

exit 0
