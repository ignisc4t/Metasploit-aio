#!/usr/bin/env bash
#
# Metasploit For Android - Termux
# set colors
dfl='\033[0m'
red='\033[1;31m'
grn='\033[1;32m'
ylo='\033[1;33m'
cyn='\033[1;36m'
gry='\033[0;30m'

set -e
export PREFIX=/data/data/com.termux/files/usr
export TMPDIR=$PREFIX/tmp

# first step of flight-to-the-moon, lol
clear
echo
echo -e "$red[!]$dfl beginning dump of physical memory..."
echo
sleep 2.5
echo -e "$grn lol...$ylo :D"
echo -e "$ylo I wonder, how much people that remember this one..."
echo
sleep 1.5
echo -e "$cyn Not a fancy scripts, just installing Metasploit to your\nandroid Termux environment. Nothing big, for real..."

FOLD_COLUMNS=70
if [[ $COLUMNS =~ ([[:digit:]]) ]] && ((COLUMNS < FOLD_COLUMNS)); then
	FOLD_COLUMNS=$COLUMNS
fi

echo
echo -e "$red[!]$ylo PLEASE READ THIS BEFORE YOU PROCEED!$dfl"
sleep 1
{
	echo
	echo -e "$red[!] Disclaimer :$grn Use this scripts at your own risk, this scripts doesn't guarrantee if Metasploit will working on your Termux environment!! It will download Metasploit source and tried to install on your android device. If you're had a doubt or installing some scripts then never use it, leave this script immediately by choose 'no' at the start of this script."
	echo
	echo -e "Files will be downloaded from the original repository of Metasploit https://github.com/rapid7/metasploit-framework. Then it will begin the installation procedure on your device."
	echo
	echo -e "Please, be aware. Don't ask neither Metasploit (rapid7) nor Termux developer for assistance, Termux$red 'IS NOT'$grn officially supported by Metasploit. You're on your own."
	echo
	echo -e "FYI: Metasploit also available on Termux unstable-repo, just in case if you wondering. Refer to termux wiki for installation guide. ;)"
	echo
	echo -e "$red     You've been warned!!$grn"
	echo
	echo -e "The original metasploit installer scripts provided in Termux unstable-packages repository at Github:"
	echo -e "https://github.com/termux/unstable-packages/tree/master/packages/metasploit. all credits belong to Rapid7 and  Termux Apps Developer for making this possible."
	echo
	echo -e "Supported architecture:"
	echo -e "[arm*] [aarch64] [i686] [x86_64]$dfl"
echo
} | fold -s -w "$FOLD_COLUMNS"

while true; do
	echo -e "$ylo Please, enter your answer below, then press enter.$cyn"
    read -p "[!] Do you want to install it ? [y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo -e "$ylo Please answer$grn yes$dfl or$red no$dfl";;
    esac
done

# MSFVER = Metasploit Version
echo -e "$red[!]$grn Enter Metasploit version (e.g. 6.0.0): $dfl"
read MSFVER
echo -e "$grn[OK]$ylo Metasploit-$MSFVER.tar.gz$grn will be installed$dfl"
echo
sleep 1
echo -e "$red[!]$grn Checking user .....$dfl"
echo
sleep 1.5
# Checking root session
if [ "$(id -u)" = "0" ]; then
	echo -e "$red[!] Hey, pssstt... No root for this one, my friend :)$dfl"
	exit 1
	else
	echo -e "$grn[OK]$ylo Let's go..."
fi
echo
sleep 1.5

echo -e "$ylo[!] Please, just wait for these process,\nkeep calm and enjoy your coffee.\nDon't do unnecessary stuff while installing Metasploit.$red Keep Calm.$dfl"
echo
sleep 1
echo -e "$cyn[*] Updating and Upgrading Termux packages...$dfl"
apt update && apt upgrade -y
apt install busybox -y
apt install apr apr-util autoconf bison clang coreutils curl findutils git libffi libgmp libiconv libpcap libsqlite libtool libxml2 libxslt make ncurses ncurses ncurses-utils openssl pkg-config postgresql readline resolv-conf ruby tar termux-elf-cleaner termux-tools unzip wget zip zlib -y
sleep 1
echo -e "$cyn[*] Downloading Metasploit-Framework...$dfl"
mkdir -p "$TMPDIR"
rm -f "$TMPDIR/metasploit-$MSFVER.tar.gz"
curl -L "https://github.com/rapid7/metasploit-framework/archive/$MSFVER.tar.gz" -o "$TMPDIR/metasploit-$MSFVER.tar.gz"
echo -e "$grn[OK]$ylo files downloaded at $TMPDIR.$dfl"
sleep 1

echo -e "$cyn[*] Removing previous version Metasploit Framework...$dfl"
rm -rf "$PREFIX"/opt/metasploit-framework
sleep 1

echo -e "$cyn[*] Extracting new version of Metasploit Framework...$dfl"
mkdir -p "$PREFIX"/opt/metasploit-framework
tar zxf "$TMPDIR/metasploit-$MSFVER.tar.gz" --strip-components=1 \
	-C "$PREFIX"/opt/metasploit-framework
sleep 1

echo -e "$cyn[*] Installing 'rubygems-update' if necessary...$dfl"
if [ "$(gem list -i rubygems-update 2>/dev/null)" = "false" ]; then
	gem install --no-document --verbose rubygems-update
fi
sleep 1

echo -e "$cyn[*] Installing 'bundler:1.7.3'...$dfl"
gem install --no-document --verbose  bundler:1.7.3
sleep 1

echo -e "$cyn[*] Installing Metasploit-Framework dependencies..."
echo -e "$red[!]$cyn (it'll be a long time wait, you better do something with your time)$dfl"
cd "$PREFIX"/opt/metasploit-framework
gem install --no-document --verbose bundler
bundle config.nokogiri --use-system-libraries
bundle install --deployment --jobs=2 --verbose
sleep 1

echo -e "$cyn[*] Running fixes...$dfl"
sed -i "s@/etc/resolv.conf@$PREFIX/etc/resolv.conf@g" "$PREFIX"/opt/metasploit-framework/lib/net/dns/resolver.rb
find "$PREFIX"/opt/metasploit-framework -type f -executable -print0 | xargs -0 -r termux-fix-shebang
find "$PREFIX"/lib/ruby/gems -type f -iname \*.so -print0 | xargs -0 -r termux-elf-cleaner
sleep 1

echo -e "$cyn[*] Setting Postgresql database...$dfl"
mkdir -p "$PREFIX"/opt/metasploit-framework/config
echo
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

mkdir -p "$PREFIX"/var/lib/postgresql
pg_ctl -D "$PREFIX"/var/lib/postgresql stop
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

sleep1
rm -rf $PREFIX/bin/{msfconsole,msfd,msfrpc,msfrpcd,msfvenom} > /dev/null 2>&1 || true
echo -e "$grn[%]$cyn Installing fix...$dfl"
echo
##########
# Tried this one, and the other one below there
# I'm not sure which one worked best. lol, me nub :D
# Fix ruby bigdecimal extensions linking error.
while true; do
	case "$(uname -m)" in
        aarch64)
                export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.7.0/aarch64-linux-android/bigdecimal.so"
                echo -e "$grn[OK]$ylo Fix bigdecimal.so for aarch64 done.$dfl"
                break
                ;;
        arm*)
                export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.7.0/arm-linux-androideabi/bigdecimal.so"
                echo -e "$grn[OK]$ylo Fix bigdecimal.so for arm* done.$dfl"
                break
                ;;
        i686)
                export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.7.0/i686-linux-android/bigdecimal.so"
                echo -e "$grn[OK]$ylo Fix bigdecimal.so for i686 done.$dfl"
                break
                ;;
        x86_64)
                export LD_PRELOAD="$LD_PRELOAD:/data/data/com.termux/files/usr/lib/ruby/2.7.0/x86_64-linux-android/bigdecimal.so"
                echo -e "$grn[OK]$ylo Fix bigdecimal.so for x86_64 done.$dfl"
                break
                ;;
        *)
                echo -e "$red[!]$cyn failed to fix bigdecimal.so\nNo architecture detected.$dfl"
                break
                ;;
	esac
done
echo
sleep 1

echo -e "$gry[*] Installing (another) fix..."
echo
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

echo -e "$grn[OK]$ylo Fix success !!!$dfl"
##########

for i in msfd msfrpc msfrpcd msfvenom; do
    ln -sfr "$PREFIX"/bin/msfconsole "$PREFIX"/bin/$i
done
chmod +777 "$PREFIX"/bin/{msfconsole,msfd,msfrpc,msfrpcd,msfvenom} > /dev/null 2>&1
sleep 1

echo
echo -e "$grn[OK]$ylo Metasploit Framework installation finished.$dfl"
echo -e "$grn[√]$ylo Enjoy the beast in your phone!"
echo
echo -e "$ylo Metasploit directory :"
echo -e "$cyn	$PREFIX/opt/metasploit-framework"
echo -e "$cyn	$HOME/.msf4"
echo
echo -e "$ylo Postgresql directory :"
echo -e "$cyn	$PREFIX/var/lib/postgresql"
echo
echo -e "$ylo Starting and stopping postgresql database:"
echo -e "$cyn	pg_ctl -D $PREFIX/var/lib/postgresql start"
echo -e "$cyn	pg_ctl -D $PREFIX/var/lib/postgresql stop"
echo
echo -e "$ylo Running command :"
echo -e "$cyn	msfconsole"
echo -e "$cyn	msfconsole --help"
echo
echo -e "$cyn[+] Don't forget to check the new Metasploit\nrelease for bug fix!"
echo

exit 0
