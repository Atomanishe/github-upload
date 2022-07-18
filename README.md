# Full Site deployment

This repo includes scripts which allow you:
- Register sites
- Install wordpress site and all dependencies
- Install and configure mysql
- Install php
- Install wordpress
- Install apache

## To use this script you need root permission
```
su -
```

## Install site with all dependensies and configure it
```
sh script.sh -phpVersion 7.4 -siteName wp.com -dbname wp_database -dbuser wp_user -dbpass wp_pass
```

## Add record to host file
example: 192.168.10.15 wp.com

## Install parts of site
1) Install web server
``` 
sh ./apache.sh
```

2) Install php
```
sh ./php.sh
```

3) Install wordpress
```
sh ./wordpress.sh -site wp.com
```

4) Register created site
```
sh ./regsite.sh -site wp.com
```

5) Initialize database and create user
```
/bin/bash ./mysql.sh -dbname wp_database -dbuser wp_user -dbpass wp_pass
```
