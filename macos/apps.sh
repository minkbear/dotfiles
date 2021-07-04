#/bin/bash
clear && rm -rf ~/macapps && mkdir ~/macapps > /dev/null && cd ~/macapps

###############################
#    Print script header      #
###############################
echo $"

 ███╗   ███╗ █████╗  ██████╗ █████╗ ██████╗ ██████╗ ███████╗
 ████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝
 ██╔████╔██║███████║██║     ███████║██████╔╝██████╔╝███████╗
 ██║╚██╔╝██║██╔══██║██║     ██╔══██║██╔═══╝ ██╔═══╝ ╚════██║
 ██║ ╚═╝ ██║██║  ██║╚██████╗██║  ██║██║     ██║     ███████║╔═════════╗
 ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═ .link ═╝\n"


###############################
#    Define worker functions  #
###############################
versionChecker() {
	local v1=$1; local v2=$2;
	while [ `echo $v1 | egrep -c [^0123456789.]` -gt 0 ]; do
		char=`echo $v1 | sed 's/.*\([^0123456789.]\).*/\1/'`; char_dec=`echo -n "$char" | od -b | head -1 | awk {'print $2'}`; v1=`echo $v1 | sed "s/$char/.$char_dec/g"`; done
	while [ `echo $v2 | egrep -c [^0123456789.]` -gt 0 ]; do
		char=`echo $v2 | sed 's/.*\([^0123456789.]\).*/\1/'`; char_dec=`echo -n "$char" | od -b | head -1 | awk {'print $2'}`; v2=`echo $v2 | sed "s/$char/.$char_dec/g"`; done
	v1=`echo $v1 | sed 's/\.\./.0/g'`; v2=`echo $v2 | sed 's/\.\./.0/g'`;
	checkVersion "$v1" "$v2"
}

checkVersion() {
	[ "$1" == "$2" ] && return 1
	v1f=`echo $1 | cut -d "." -f -1`;v1b=`echo $1 | cut -d "." -f 2-`;v2f=`echo $2 | cut -d "." -f -1`;v2b=`echo $2 | cut -d "." -f 2-`;
	if [[ "$v1f" != "$1" ]] || [[ "$v2f" != "$2" ]]; then [[ "$v1f" -gt "$v2f" ]] && return 1; [[ "$v1f" -lt "$v2f" ]] && return 0;
		[[ "$v1f" == "$1" ]] || [[ -z "$v1b" ]] && v1b=0; [[ "$v2f" == "$2" ]] || [[ -z "$v2b" ]] && v2b=0; checkVersion "$v1b" "$v2b"; return $?
	else [ "$1" -gt "$2" ] && return 1 || return 0; fi
}

appStatus() {
  if [ ! -d "/Applications/$1" ]; then echo "uninstalled"; else
    if [[ $5 == "build" ]]; then BUNDLE="CFBundleVersion"; else BUNDLE="CFBundleShortVersionString"; fi
    INSTALLED=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "/Applications/$1/Contents/Info.plist"`
      if [ $4 == "dmg" ]; then COMPARETO=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "/Volumes/$2/$1/Contents/Info.plist"`;
      elif [[ $4 == "zip" || $4 == "tar" || $4 == "tbz2" ]]; then COMPARETO=`/usr/libexec/plistbuddy -c Print:$BUNDLE: "$3$1/Contents/Info.plist"`; fi
    checkVersion "$INSTALLED" "$COMPARETO"; UPDATED=$?;
    if [[ $UPDATED == 1 ]]; then echo "updated"; else echo "outdated"; fi; fi
}
installApp() {
  echo $'\360\237\214\200  - ['$2'] Downloading app...'
  if [ $1 == "dmg" ]; then curl -s -L -o "$2.dmg" $4; yes | hdiutil mount -nobrowse "$2.dmg" -mountpoint "/Volumes/$2" > /dev/null;
    if [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "/Volumes/$2/$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "$2" "" "dmg" "$7") == "uninstalled" ]]; then cp -R "/Volumes/$2/$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    hdiutil unmount "/Volumes/$2" > /dev/null && rm "$2.dmg"
  elif [ $1 == "zip" ]; then curl -s -L -o "$2.zip" $4; unzip -qq "$2.zip";
    if [[ $(appStatus "$3" "" "$5" "zip" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$5$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "zip" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi;
    rm -rf "$2.zip" && rm -rf "$5" && rm -rf "$3"
  elif [ $1 == "tbz2" ]; then curl -s -L -o "$2.tbz2" $4; tar -xvjfv "$2.tbz2";
    if [[ $(appStatus "$3" "" "$5" "tbz2" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "tbz2" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$5$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "tbz2" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "tbz2" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi;
    rm -rf "$2.tbz2" && rm -rf "$5" && rm -rf "$3"
  elif [ $1 == "tar" ]; then curl -s -L -o "$2.tar.bz2" $4; tar -zxf "$2.tar.bz2" > /dev/null;
    if [[ $(appStatus "$3" "" "$5" "tar" "$7") == "updated" ]]; then echo $'\342\235\214  - ['$2'] Skipped because it was already up to date!\n';
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "outdated" && $6 != "noupdate" ]]; then ditto "$3" "/Applications/$3"; echo $'\360\237\214\216  - ['$2'] Successfully updated!\n';
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "outdated" && $6 == "noupdate" ]]; then echo $'\342\235\214  - ['$2'] This app cant be updated!\n'
    elif [[ $(appStatus "$3" "" "$5" "tar" "$7") == "uninstalled" ]]; then mv "$5$3" /Applications; echo $'\360\237\221\215  - ['$2'] Succesfully installed!\n'; fi
    rm -rf "$2.tar.bz2" && rm -rf "$3"; fi
}

###############################
#    Install selected apps    #
###############################
installApp "dmg" "Firefox Dev." "Firefox Developer Edition.app" "https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=osx&lang=de" "" "" ""
installApp "dmg" "Chrome" "Google Chrome.app" "https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg" "" "" ""
installApp "dmg" "Dropbox" "Dropbox.app" "https://www.dropbox.com/download?plat=mac" "" "" ""
installApp "zip" "GitHub" "GitHub Desktop.app" "https://desktop.githubusercontent.com/releases/2.9.0-4806a6dc/GitHubDesktop-arm64.zip" "" "" ""
installApp "zip" "Visual Studio Code" "Visual Studio Code.app" "https://az764295.vo.msecnd.net/stable/2b9aebd5354a3629c3aba0a5f5df49f43d6689f8/VSCode-darwin-arm64.zip" "" "" ""
installApp "dmg" "Docker" "Docker.app" "https://desktop.docker.com/mac/stable/arm64/Docker.dmg" "" "" ""
installApp "zip" "Postman" "Postman.app" "https://dl.pstmn.io/download/latest/osx" "" "" ""
installApp "zip" "iTerm2" "iTerm.app" "https://iterm2.com/downloads/stable/latest" "" "" ""
installApp "dmg" "Skype" "Skype.app" "https://go.skype.com/mac.download" "" "" ""
installApp "dmg" "Discord" "Discord.app" "https://discord.com/api/download?platform=osx" "" "" ""
installApp "dmg" "JetBrains Toolbox" "JetBrains Toolbox.app" "https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.20.8804-arm64.dmg" "" "" ""
installApp "zip" "Cloudya" "Cloudya.app" "https://cdn.cloudya.com/Cloudya-1.2.1-mac.zip" "" "" ""
installApp "zip" "Tower" "Tower.app" "https://fournova-app-updates.s3.amazonaws.com/apps/tower3-mac/279-36c8e109/Tower-6.5-279.zip" "" "" ""
installApp "dmg" "AnyDesk" "AnyDesk.app" "https://download.anydesk.com/anydesk.dmg" "" "" ""
installApp "dmg" "BabelEdit" "BabelEdit.app" "https://www.codeandweb.com/download/babeledit/2.8.0/BabelEdit-2.8.0.dmg" "" "" ""
installApp "dmg" "Tunnelblick" "Tunnelblick.app" "https://tunnelblick.net/release/Latest_Tunnelblick_Stable.dmg" "" "" ""
installApp "dmg" "Sonos" "Sonos.app" "https://update-software.sonos.com/software/mac/mdcr/SonosDesktopController1312.dmg" "" "" ""
installApp "dmg" "TeamViewer" "TeamViewer.app" "https://dl.teamviewer.com/download/version_15x/TeamViewer.dmg" "" "" ""
installApp "dmg" "Little Snitch" "Little Snitch.app" "https://www.obdev.at/downloads/littlesnitch/LittleSnitch-5.2.2.dmg" "" "" ""
installApp "dmg" "TermHere" "TermHere.app" "https://dl.hbang.ws/macos/TermHere%201.2.1.dmg" "" "" ""
installApp "tbz2" "ImageOptim" "ImageOptim.app" "https://imageoptim.com/ImageOptim.tbz2" "" "" ""

###############################
#    Print script footer      #
###############################
echo $'--------------------------------------------------------------------------------'
echo $'\360\237\222\254  - Thank you for using macapps.link!! Liked it? Recommend us to your friends!'
echo $'\360\237\222\260  - The time is gold. Have I saved you a lot? :) - https://macapps.link/donate'
echo $'--------------------------------------------------------------------------------\n'
rm -rf ~/macapps
