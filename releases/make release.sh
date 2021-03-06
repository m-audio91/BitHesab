#! /usr/bin/bash
# first compile for every target for both cli and gui projects and then run this scipt to get the zip file.
# note: this script uses relative paths. so it is necessary to open the Terminal in the same folder as this script.

name="bithesab"
namec="BitHesab"
ver="1.3.0"
archive="$name""_v$ver""_cross_platform"
hashfile="./$ver/$archive.hash.txt"
lin32bin="$name-i386-linux"
lin64bin="$name-x86_64-linux"
lin64qt5bin="$name-x86_64-linux-qt5"
winbin="$name-i386-win32.exe"
macosbin="$name-x86_64-darwin"
arm7bin="$name-arm-linux"
qt5note="qt5 runtime dependency note.txt"
macosnote="macos unidentified developer note.txt"

echo start
rm -r ./$ver
mkdir ./$ver
touch $hashfile
echo $archive >> $hashfile
echo SHA256 valuse calculated using sha256sum utility in default mode >> $hashfile
echo "" >> $hashfile

#gui
echo gui >> $hashfile
if [ -f "../gui/$lin32bin" ]; then 
  mkdir -p ./$ver/gui/linux32/icon
  cp ../gui/$lin32bin ./$ver/gui/linux32/$name
  cp ../gui/extra/icon/*.png ./$ver/gui/linux32/icon
  sha256sum ./$ver/gui/linux32/$name >> $hashfile
fi
if [ -f "../gui/$lin64bin" ]; then 
  mkdir -p ./$ver/gui/linux64/icon
  cp ../gui/$lin64bin ./$ver/gui/linux64/$name
  cp ../gui/extra/icon/*.png ./$ver/gui/linux64/icon
  sha256sum ./$ver/gui/linux64/$name >> $hashfile
fi
if [ -f "../gui/$lin64qt5bin" ]; then 
  mkdir -p ./$ver/gui/linux64-qt5/icon
  cp ../gui/$lin64qt5bin ./$ver/gui/linux64-qt5/$name
  cp ../gui/extra/icon/*.png ./$ver/gui/linux64-qt5/icon
  cp "./$qt5note" "./$ver/gui/linux64-qt5/$qt5note" 
  sha256sum ./$ver/gui/linux64-qt5/$name >> $hashfile
fi
if [ -f "../gui/$winbin" ]; then 
  mkdir -p ./$ver/gui/windows
  cp ../gui/$winbin ./$ver/gui/windows/$namec.exe
  sha256sum ./$ver/gui/windows/$namec.exe >> $hashfile
fi
if [ -f "../gui/$macosbin" ]; then 
  mkdir -p ./$ver/gui/macos
  cp -r ../gui/$macosbin.app ./$ver/gui/macos/$namec.app
  cp ../gui/$macosbin ./$ver/gui/macos/$namec.app/Contents/MacOS/$namec
  cp "./$macosnote" "./$ver/gui/macos/$macosnote"
  sha256sum ./$ver/gui/macos/$namec.app/Contents/MacOS/$namec >> $hashfile
fi
if [ -f "../gui/$arm7bin" ]; then 
  mkdir -p ./$ver/gui/arm7/icon
  cp ../gui/$arm7bin ./$ver/gui/arm7/$name
  cp ../gui/extra/icon/*.png ./$ver/gui/arm7/icon
  sha256sum ./$ver/gui/arm7/$name >> $hashfile
fi

#cli
echo "" >> $hashfile
echo cli >> $hashfile
if [ -f "../cli/$lin32bin" ]; then 
  mkdir -p ./$ver/cli/linux32
  cp ../cli/$lin32bin ./$ver/cli/linux32/$name
  sha256sum ./$ver/cli/linux32/$name >> $hashfile
fi
if [ -f "../cli/$lin64bin" ]; then 
  mkdir -p ./$ver/cli/linux64
  cp ../cli/$lin64bin ./$ver/cli/linux64/$name
  sha256sum ./$ver/cli/linux64/$name >> $hashfile
fi
if [ -f "../cli/$winbin" ]; then 
  mkdir -p ./$ver/cli/windows
  cp ../cli/$winbin ./$ver/cli/windows/$namec.exe
  sha256sum ./$ver/cli/windows/$namec.exe >> $hashfile
fi
if [ -f "../cli/$macosbin" ]; then 
  mkdir -p ./$ver/cli/macos
  cp ../cli/$macosbin ./$ver/cli/macos/$namec
  sha256sum ./$ver/cli/macos/$namec >> $hashfile
fi
if [ -f "../cli/$arm7bin" ]; then 
  mkdir -p ./$ver/cli/arm7
  cp ../cli/$arm7bin ./$ver/cli/arm7/$name
  sha256sum ./$ver/cli/arm7/$name >> $hashfile
fi

#final output
cd ./$ver
zip -r ./$archive.zip ./cli ./gui
rm -r ./cli ./gui

echo done

