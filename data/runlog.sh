#!/bin/bash
#echo `date -d yesterday +%Y%m%d` #另種寫法

#echo $(date -d yesterday +%Y%m%d)

LOGPATH=/usr/local/nginx/logs/z.com.access.log
BASEPATH=/data

#$(date -d yesterday +%Y%m%d) #年月日

bak=$BASEPATH/$(date -d yesterday +%Y%m%d%H%M).z.com.access.log #年月日時分 測試用 可以馬上看到效果
#echo $bak

mv $LOGPATH $bak
touch $LOGPATH

kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`


