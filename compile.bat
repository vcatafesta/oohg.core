@echo off
rem
rem $Id: compile.bat,v 1.9 2006-01-23 00:44:00 guerra000 Exp $
rem
cls

Rem Set Paths 

IF "%HG_BCC%"==""  SET HG_BCC=c:\borland\bcc55
IF "%HG_ROOT%"=="" SET HG_ROOT=c:\oohg
IF "%HG_HRB%"==""  SET HG_HRB=c:\harbour

if exist %1.exe del %1.exe

Rem Debug Compile

for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/d" GOTO DEBUG_COMP
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/D" GOTO DEBUG_COMP

%HG_HRB%\bin\harbour %1.prg -n -i%HG_HRB%\include;%HG_ROOT%\include; %2 %3

GOTO C_COMP

:DEBUG_COMP

ECHO OPTIONS NORUNATSTARTUP > INIT.CLD

%HG_HRB%\bin\harbour %1.prg -n -b -i%HG_HRB%\include;%HG_ROOT%\include; %2 %3

:C_COMP

%HG_BCC%\bin\bcc32 -c -O2 -tW -M -I%HG_HRB%\include;%HG_BCC%\include; -L%HG_BCC%\lib; %1.c

if exist %1.rc %HG_BCC%\bin\brc32 -r %1.rc

echo c0w32.obj + > b32.bc
echo %1.obj, + >> b32.bc
echo %1.exe, + >> b32.bc
echo %1.map, + >> b32.bc
echo %HG_ROOT%\lib\oohg.lib + >> b32.bc

Rem *** Compiler libraries ***
for %%a in (rtl vm gtwin lang codepage macro rdd dbfntx dbfcdx dbffpt common debug pp) do echo %HG_HRB%\lib\%%a.lib + >> b32.bc

Rem *** Compiler-dependant libraries ***
if exist %HG_HRB%\lib\dbfdbt.lib  echo %HG_HRB%\lib\dbfdbt.lib + >> b32.bc
if exist %HG_HRB%\lib\hbsix.lib   echo %HG_HRB%\lib\hbsix.lib + >> b32.bc
if exist %HG_HRB%\lib\tip.lib     echo %HG_HRB%\lib\tip.lib + >> b32.bc
if exist %HG_HRB%\lib\ct.lib      echo %HG_HRB%\lib\ct.lib + >> b32.bc
if exist %HG_HRB%\lib\hsx.lib     echo %HG_HRB%\lib\hsx.lib + >> b32.bc
if exist %HG_HRB%\lib\pcrepos.lib echo %HG_HRB%\lib\pcrepos.lib + >> b32.bc

Rem *** Additional libraries ***
if exist %HG_HRB%\lib\libct.lib   echo %HG_HRB%\lib\libct.lib + >> b32.bc
if exist %HG_HRB%\lib\libmisc.lib echo %HG_HRB%\lib\libmisc.lib + >> b32.bc
if exist %HG_HRB%\lib\hbole.lib   echo %HG_HRB%\lib\hbole.lib + >> b32.bc
if exist %HG_HRB%\lib\dll.lib     echo %HG_HRB%\lib\dll.lib + >> b32.bc

Rem *** "Related" libraries ***
if exist %HG_HRB%\lib\hbprinter.lib  echo %HG_HRB%\lib\hbprinter.lib + >> b32.bc
if exist %HG_ROOT%\lib\hbprinter.lib echo %HG_ROOT%\lib\hbprinter.lib + >> b32.bc
if exist %HG_HRB%\lib\socket.lib     echo %HG_HRB%\lib\socket.lib + >> b32.bc
if exist %HG_ROOT%\lib\socket.lib    echo %HG_ROOT%\lib\socket.lib + >> b32.bc
if exist %HG_HRB%\lib\miniprint.lib  echo %HG_HRB%\lib\miniprint.lib + >> b32.bc
if exist %HG_ROOT%\lib\miniprint.lib echo %HG_ROOT%\lib\miniprint.lib + >> b32.bc

Rem *** ODBC Libraries Link ***
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/o" echo %HG_HRB%\lib\hbodbc.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/o" echo %HG_HRB%\lib\odbc32.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/O" echo %HG_HRB%\lib\hbodbc.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/O" echo %HG_HRB%\lib\odbc32.lib + >> b32.bc

Rem *** ZIP Libraries Linking ***
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/z" echo %HG_HRB%\lib\zlib1.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/z" echo %HG_HRB%\lib\ziparchive.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/Z" echo %HG_HRB%\lib\zlib1.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/Z" echo %HG_HRB%\lib\ziparchive.lib + >> b32.bc

Rem *** ADS Libraries Linking ***
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/a" echo %HG_HRB%\lib\rddads.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/a" echo %HG_HRB%\lib\ace32.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/A" echo %HG_HRB%\lib\rddads.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/A" echo %HG_HRB%\lib\ace32.lib + >> b32.bc

Rem *** MySql Libraries Linking ***
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/m" echo %HG_HRB%\lib\mysql.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/m" echo %HG_HRB%\lib\libmysql.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/M" echo %HG_HRB%\lib\mysql.lib + >> b32.bc
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/M" echo %HG_HRB%\lib\libmysql.lib + >> b32.bc

echo cw32.lib + >> b32.bc
echo import32.lib, >> b32.bc

if exist %1.res echo %1.res + >> b32.bc
if exist %HG_ROOT%\resources\hbprinter.res echo %HG_ROOT%\resources\hbprinter.res + >> b32.bc
if exist %HG_ROOT%\resources\miniprint.res echo %HG_ROOT%\resources\miniprint.res + >> b32.bc
if exist %HG_ROOT%\resources\oohg.res      echo %HG_ROOT%\resources\oohg.res + >> b32.bc

Rem Debug Link

for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/d" GOTO DEBUG_LINK
for %%a in ( %2 %3 %4 %5 %6 %7 %8 ) do if "%%a"=="/D" GOTO DEBUG_LINK

%HG_BCC%\bin\ilink32 -Gn -Tpe -aa -L%HG_BCC%\lib; @b32.bc

GOTO CLEANUP

:DEBUG_LINK

%HG_BCC%\bin\ilink32 -Gn -Tpe -ap -L%HG_BCC%\lib; @b32.bc

:CLEANUP

del *.tds
del %1.c
del %1.map
del %1.obj
del b32.bc
if exist %1.res del %1.res
%1
