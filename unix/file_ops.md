Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal
$ cd 'Python for DE 2026'

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026 (main)
$ ls
 SQL_2026/  'corey schafer'/   unix/

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026 (main)
$ cd unix

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ touch file.txt

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ ls
file.txt  ls.md

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ cd ..

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026 (main)
$ cd unix

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ rm file.txt

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ l
bash: l: command not found

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ ls
ls.md

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ cp ls.md file1.txt

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ ls
file1.txt  ls.md

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ mv file1.txt ls_copy.md

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ ls
ls.md  ls_copy.md

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ cat ls.md

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ tail -f logfile.txt
tail: cannot open 'logfile.txt' for reading: No such file or directory
tail: no files remaining

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ less file.txt
file.txt: No such file or directory

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ touch file_ops.txt

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ rm file_ops.txt

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ touch file_ops.md

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ rm ls, ls_copy
rm: cannot remove 'ls,': No such file or directory
rm: cannot remove 'ls_copy': No such file or directory

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$ rm ls.md ls_copy.md

Dell@DESKTOP-560GTFG MINGW64 /e/SQL+DA+Personal/Python for DE 2026/unix (main)
$
