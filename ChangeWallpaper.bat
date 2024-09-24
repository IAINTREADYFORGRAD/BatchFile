
rem echo off

setlocal enabledelayedexpansion

set CurrPath=%~dp0

rem if OriginalWallpaper is in the folder, use OriginalWallpaper; otherwise use minion as wallpaper
for %%a in (%CurrPath%\*) do (
  if %%~na EQU OriginalWallpaper (
    set OriginalImage=%%a
    goto UseOriginal
  ) 
)

goto UseMinion

:UseOriginal
  set Cach=%userprofile%\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles
  
  rem cached imaged is named _____ (fixed, not vary from image, time being stored, etc) 
  rem get that name given by system and delete the cached image
  for %%a in (%Cach%\*) do (
    set NewName=%%~na%%~xa
    del %%a
  )
  
  rem rename OriginalImage w/ the system created name
  ren %OriginalImage% %NewName%
  
  rem copy OriginalImage (now is renamed as _____) to cach
  rem and delete it from the current path
  for %%a in (%CurrPath%\*) do (
    if %%~na NEQ minion (
      if %%~na NEQ ChangeWallpaper (
        copy %%a %Cach%
        del %%a
      )
    )
  )

  for %%a in (%Cach%\*) do (
    set Image=%%a
  )

  goto ChangeAction

:UseMinion
  set Image=%CurrPath%minion.jpg
  if not exist %Image% (
    echo image does not exist in %CurrPath%
    goto: EOF
  )

  set OriginalImage=%userprofile%\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles\*
  copy %OriginalImage% %CurrPath%

  for %%a in (%CurrPath%/*) do (
    if %%~na NEQ minion (
      if %%~na NEQ ChangeWallpaper (
        ren %%a OriginalWallpaper%%~xa
        rem %a==%~a (the whole path and file name)
        rem but the ren command somehow does not rename the whole path and file name as the 2nd aurg 
        rem instead rename the file name only
      )
    )
  )


:ChangeAction
  rem /f: to force overwriting if wallpaper is already set
  rem /v: specifies the name of the registry value to be added or modified
  rem reg add: command to add a new registry entry or modify an existing one
  rem "": if the wallpaper path contains spaces you must enclose it in quotes 
  reg add "HKCU\Control Panel\Desktop" /v wallpaper /d %Image% /f 

  rem execute the function, UpdatePerUserSystemParameters, which is in lib, user32.dll
  rem the lib, user32.dll, would be loaded into memory by RUNDLL32.EXE
  %SystemRoot%\System32\RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters

  rem shutdown -r
