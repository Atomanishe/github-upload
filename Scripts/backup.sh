#!/bin/bash
log_file="/$HOME/backup.log"  # --- Name Log file
exec 1>>$log_file

cd ~

dir_ba="backup"                      # --- Name Backup Dir
if [ -d /$HOME/$dir_ba ]
then
echo " The directory $dir_ba already exists"
else
echo " The directory $dir_ba already created"
mkdir /$HOME/$dir_ba
fi

dir_re="resource"                    # --- Name Resource Dir
if [ -d /$HOME/$dir_re ]
then
echo " The directory $dir_re already exists"
else
echo " The directory $dir_re already created"
mkdir /$HOME/$dir_re
fi

date=`date '+b_%Y%m%d_%H:%M:%S'`

echo "Name backup file is = /$HOME/$dir_re/$date"

touch /$HOME/$dir_re/$date & sudo chmod 660 /$HOME/$dir_re/$date

lscpu  >> /$HOME/$dir_re/$date      # --- What will we put in file

zip -r -9 /$HOME/$dir_ba/$date.zip /$HOME/$dir_re/$date

echo "Name ZIP-ed backup file is = /$HOME/$dir_ba/$date.zip"
echo "This is my first script, it was very hard at first, but when I figured it >
echo "with best regards"
echo "Shchemer Andrey, earth, Belarus, minsk"
echo "all rights reserved 2022"
