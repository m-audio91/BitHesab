# BitHesab
![Image of BitHesab](https://github.com/m-audio91/BitHesab/raw/master/GUI/extra/icon/80.png)  
v1.2.0 GUI
v1.0.2 CLI

Free video bitrate/file size calculator. available in both CLI and GUI versions.

Copyright (C) 2017 Mohammadreza Bahrami, m.audio91 [AT] gmail.com  
  
### compilation guide:  
1. clone this repository plus [CommonUtils](https://github.com/m-audio91/CommonUtils) repository.
2. update your Free Pascal and Lazarus to at least the version mentioned in [latest BitHesab release](https://github.com/m-audio91/BitHesab/releases) description. use [fpcupdeluxe](https://github.com/newpascal/fpcupdeluxe) if you have problem updating.
3. open the project (bithesabgui.lpi or bithesab.lpi) in Lazarus and go to `project > project options > compiler options > paths > Other unit files` to add *CommonUtils* folder to your unit search paths.
4. compile and run.
5. issues? please report [here](https://github.com/m-audio91/BitHesab/issues)