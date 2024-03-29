### Custom Nagios Plugins

Over time I built several nagios plugins for my use (or modified existing ones). I keep them here.

* **check_calibreserver.sh** - checks the status of the calibre ebooks server (fast, using the API) and returns for graphing the number of books, authors and series
* **check_copsserver.sh** - basically the same as check_calibreserver but queries a [COPS](http://blog.slucas.fr/en/oss/calibre-opds-php-server) installation instead of a running calibre server.
* **check_isdcttemp.sh** - check temperature of Intel PCIe SSDs using isdcttemp tool
* **check_minidlnastatus** - checks the status of the minidlna server outputing perfdata for the number of video, audio and image files
* **check_nvmecli.sh** - check temperature of nvme disks using nvme-cli
* **check_sshwltemp.sh** - checks the temperature of a remote Tomato router that supports it
* **check_sshpftemp.sh** - checks the temperature of a remote pfSense router that supports it
* **check_twitterfollowers.sh** - outputs the number of twitter followers for a given username, good for graphing. Doesn't require API access, it uses curl on the public user profile page. It might be usefull to set  
`        normal_check_interval           60                    ; check hourly` when defining this service
* **check_zerofolder.sh** - Checks a folder for non-zero files (I have scripts outputing only errors to a log folder - when a file is not zero it means an error appeared
* **check_zpools.sh** - Checks the status of (all) zpools of a zfs system. Slightly modified version of [ this one ](https://github.com/alpha01/SysAdmin-Scripts/tree/master/nagios-plugins) with perfdata

For now calibreserver, minidlna and twitter plugins have no warning capabilities built in but it should be trivial to add them if anybody needs them, I use them simply for graphing.

sudo settings for the `nagios` user

    nagios ALL=(root) NOPASSWD:/usr/sbin/hddtemp, /usr/bin/isdct, /usr/sbin/nvme smart-log*
