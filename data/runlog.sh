#!/bin/bash
#echo `date -d yesterday +%Y%m%d` #另種寫法

#echo $(date -d yesterday +%Y%m%d)

LOGPATH=/usr/local/nginx/logs/z.com.access.log
BASEPATH=/data/$(date -d yesterday +%Y%m)

#$(date -d yesterday +%Y%m%d) #年月日

#echo $bak

mkdir -p $BASEPATH
bak=$BASEPATH/$(date -d yesterday +%d%H%M).z.com.access.log #年月日時分 測試用 可以馬上看到效果


mv $LOGPATH $bak
touch $LOGPATH

kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`


