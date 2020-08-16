## Metasploit-aio
The lonely bash script wrapper to installing Metasploit-Framework-Dev into android termux environment.

## Ideas
I need something simple to make the magic happen over my phone, so here's the result; a single bash script to rule all the other commands inside.

## Info
Before we begin to make the magic happen:
The original project of metasploit-framework, built in Ruby by Rapid7 is on their repository :</br>
https://github.com/rapid7/metasploit-framework</br>
new release can be found at:
https://github.com/rapid7/metasploit-framework/releases
or the installer :
https://metasploit.com/

Termux Apps is an Android terminal and Linux environment, it support bunch of packages that you can found on normal Linux distribution.
Apps can be download on termux website:
https://termux.com
Termux package repository :
https://github.com/termux/termux-packages

The original scripts is on termux unstable packages repository :
```
https://github.com/termux/unstable-packages/tree/master/packages/metasploit
```
Head to their website / repository for more info about the programs and tools.

## How To
Be sure to check the release page of Metasploit, and look for the new release you want to choose,
the script need the release number version, you need to input it manually.
This script is very easy to use, you just need to download the script and run it from your termux terminal.
Nothing fancy, just a little colorful and a bit longer waiting time to finish.
Tested on android 7.1 aarch64, use at your own risk if you want to test it on android <7.0.
supported architecture :</br>
[arm*] [aarch64] [i686] [x86_64]
Without further ado, let's begin the procedure:

It is better to put the files on your `home dir` </br>
Clone the repository / download the installer :
```
cd $HOME
git clone https://github.com/enigm4s/Metasploit-aio.git
cd Metasploit-aio
chmod +x metasploit-aio.sh
./metasploit-aio
```
follow the instruction in the script.

or
```
cd $HOME
curl -LO https://raw.githubusercontent.com/enigm4s/Metasploit-aio/master/metasploit-aio.sh
chmod +x metasploit-aio.sh
./metasploit-aio.sh
```
follow the instruction in the script.
Don't forget, you need to specifically input the metasploit version (e.g. 6.0.0)

## Contributing
any pull request are welcome, I do realize my script is not perfect. any suggestion for better script will be accepted.

## Misc
This script will install some dependencies required by Termux and Metasploit to run properly.
all the files installed can be found on:
```
$PREFIX/opt/metasploit-framework
$HOME/./msf4
$PREFIX/opt/metasploit-framework/vendor/bundle
$PREFIX/var/lib/postgresql
```

## Things Doesn't work:
- Rubocop didn't work here (unsolved mysteries)
- still finding...

- eNigma (@enigm4s)
