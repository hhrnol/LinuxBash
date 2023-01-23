#!/bin/bash
touch /var/log/backupfiles.log
sourcedir=$1
destdir=$2
croncmd="/opt/script/backup.sh $sourcedir $destdir>> /var/log/backupfiles.log 2>&1"
cronjob="*/2 * * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" || : ; echo "$cronjob" ) | crontab -
for file in $(find $sourcedir -printf "%P\n") ; do
 if [ -a $destdir/$file ] ; then
  if [ $sourcedir/$file -nt $destdir/$file ]; then
	cp -r $sourcedir/$file $destdir/$file
	echo "$(date) Newer file detected, copying $file from $sourcedir to $destdir " >> /var/log/backupfiles.log
    else
	echo "$(date) File $file exists, skipping from $sourcedir to $destdir" >> /var/log/backupfiles.log
   fi
  else
	echo "$(date) $file is being copied from $sourcedir to $destdir" >> /var/log/backupfiles.log
	cp -r $sourcedir/$file $destdir/$file
 fi
done
for file in $(find $destdir -printf "%P\n") ; do
 if  [ ! -e $sourcedir/$file ] ; then
    rm  $destdir/$file
    echo "$(date) $file no longer exists in the $sourcedir and will be deleted from $destdir"   >> /var/log/backupfiles.log
 fi
done
