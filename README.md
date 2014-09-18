### Custom Nagios Plugins

Over time I built several nagios plugins for my use (or modified existing ones). I keep them here.

* **check_minidlnastatus** - checks the status of the minidlna server outputing perfdata for the number of video, audio and image files
* **check_twitterfollowers.sh** - outputs the number of twitter followers for a given username, good for graphing. Doesn't require API access, it uses curl on the public user profile page. It might be usefull to set `        normal_check_interval           60                    ; check hourly` when defining this service
* **check_zpools.sh** - Slightly modified version of [ this one ](https://github.com/alpha01/SysAdmin-Scripts/tree/master/nagios-plugins) with perfdata

For now minidlna and twitter plugins have no warning capabilities built in but it should be trivial to add them if anybody needs them, I use them simply for graphing.
