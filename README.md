```
vagrant up
```
手動安裝nginx
```
cd /data


cp nginx-1.20.1.tar.gz  /usr/local/src
cd  /usr/local/src
tar zxvf nginx-1.20.1.tar.gz
cd nginx-1.20.1
apt-get update
apt install gcc
apt-get install libpcre3 libpcre3-dev
apt-get install zlib1g-dev
apt install pcre-devel
./configure --prefix=/usr/local/nginx
apt-get install build-essential
make && make install
```

啟動
```
cd /usr/local/nginx
```
看到如下四個目錄

conf 配置文件
html 網頁文件
logs 日誌文件
sbin 進程文件

```
./sbin/nginx
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] still could not bind()
```
不能綁定80端口

```
root@vagrant:/usr/local/nginx# netstat -antp
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      24377/nginx: master
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      562/systemd-resolve
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1924/sshd: /usr/sbi
tcp        0      0 10.0.2.15:22            10.0.2.2:61465          ESTABLISHED 12847/sshd: vagrant
tcp6       0      0 :::111                  :::*                    LISTEN      1/init
tcp6       0      0 :::22                   :::*                    LISTEN      1924/sshd: /usr/sbi

```



### nginx 信號

```
https://www.nginx.com/resources/wiki/start/topics/tutorials/commandline/
```

#### 查看nginx 運行狀態

```
# ps aux|grep nginx
```

可見

主進程文件與子進程文件
```
root        1569  0.0  0.0   4596   388 ?        Ss   05:57   0:00 nginx: master process ./nginx
nobody      1570  0.0  0.2   5280  2772 ?        S    05:57   0:00 nginx: worker process
root        1575  0.0  0.0   8900   736 pts/0    S+   05:58   0:00 grep --color=auto nginx

```

#### 傳入信號量關閉主進程

快速關閉
```
# kill -INT 1569
```

優雅關閉, 等請求結束後再關
worker 沒工作就把你關了
```
# kill -QUIT 1569
```

改變配置文件, 平滑的重讀配置文件

 *重新載入配置文件, 開啟新的worker process 讀取配置文件, 關閉舊的worker process* 
```
# kill -HUP 1569
```

切割文件


*linux中 是用disc上的inode來存放檔案 就算把原檔案改名 並複製一份 他會追及改完名後的檔案 並不會存到舊檔案(名)*
```
# tail -10 logs/access.log
```


1.改名
```
# mv access.log access.log.1009
```

2.新增一個文件讓他指向
```
# touch access.log
```

3.使用USR1 請linux重新指向新的inode 避免他又寫到access.log.1009了
```
# kill -USR1 1580
```

### 如果不想老是查看進程號


/usr/local/nginx下
```
# cat logs/nginx.pid
```

這個可以連用

```
# kill -INT `cat logs/nginx.pid`
```