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

## 配置虛擬主機

### 配置文件說明

*conf/redis.conf*

```
worker_processes 1; //有一個工作的子進程 配置太大無意義 因為要爭奪CPU 資源

events {
    // 一般是配置 nginx 進程與連接的特性
    // 如一個worker允ㄒ以幾個連接
    worker_connections 1024; // 一個進程最大允許1024個連接
}

http{ // 配置http服務的主要段

    server{ // 虛擬主機段
        location { // 定位, 把特殊的路徑或文件再次定位, 如image目錄單獨處理, php 單獨處理

        }

    }

    // 範例: 基於ip, 如果沒配置 就往下跑
    server{
        listen 80;
        server_name 192.168.10.33; // ifconfig出現的ip

        location / {
            root html/ip; // 此處為/usr/local/nginx/html/ip (需事先創文件夾)
            index index.html; // 此處為/usr/local/nginx/html/ip/index.html (需事先創文件)
        }
    }


    // 範例: 基於域名的跳轉
    server{
        listen 80;// 監聽80端口
        server_name z.com; //監聽server_name域名 須到 C\windows\System32\drivers\etc\hosts 裡面加

        location / {
            root z.com; // 此處為/usr/local/nginx/z.com (需事先創文件夾)
            index index.html; // 此處為/usr/local/nginx/z.com/index.html (需事先創文件)
        }
    }

    // 範例: 基於端口
    server{
        listen 2022;// 監聽2022端口
        server_name z.com; //監聽server_name域名 須到 C\windows\System32\drivers\etc\hosts 裡面加

        location / {
            root /var/www/html; // 此處為/var/www/html (需事先創文件夾)
            index index.html; // 此處為/var/www/html/index.html (需事先創文件)
        }
    }

}

```

## nginx 日誌管理

觀察nginx 的server段 可以看到如下訊息:
#access_log logs/host.access.log main;

說明該server 他的訪問日誌文件是 logs/host.access.log
使用main 格式
除了main格式 你也可以自訂一其他格式

main格式是什麼?

```
 #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
 #                  '$status $body_bytes_sent "$http_referer" '
 #                  '"$http_user_agent" "$http_x_forwarded_for"';
 
 ```
 main  格式是我們定義好一種日誌的格式 並起個名字 便於引用
 以上面的例子 main類型的日誌 記錄了remote_addr...http_x_forwarded_for
 等選項
 
Nginx 允許針對不同的server做不同的log(有的web server 並不支持)

如果沒配置 系統默認就是main 格式 而且放在access.log下

例如:
在server z.com 下加入log


 server {
        listen       80;
        server_name  z.com;
        location / {
            root z.com;
            index index.html;
        }
        access_log logs/z.com.access.log main; # 加這行
    }

勿忘把main 的註解打開
測試配置文件
```
/usr/local/nginx/sbin/nginx -t
```
成功後重load nginx

```
/usr/local/nginx/sbin/nginx -s reload

```

#定時任務完成日誌切割

根據日期生成文件名: 使用date命令
 
當前日期
```
#date
```

昨天日期
```
#date -d yesterday
```


修改當前日期
```
#date -s "2021-12-29 23:35:30"
```

寫入
```
#clock -w
```

取出格式化日期
```
#date -d yesterday +%Y
```
得
2021

```
#date -d yesterday +%y
```
得
21

取出YYYY_mm_dd

```
# date -d yesterday +%Y_%m_%d

```

得
2021_12_29


