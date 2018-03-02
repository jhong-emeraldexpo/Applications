
forfiles /p "." /s /m "*.*" /d -4 /c "cmd /c dir @path"
forfiles /p "C:\Windows\Temp" /s /m "*.*" /d -6 /c "cmd /c dir @path"
Rem forfiles /p "C:\Windows\Temp" /s /m "*.*" /d -6 /c "cmd /c del @path" >> deletedfiles.txt
Rem Delete files
