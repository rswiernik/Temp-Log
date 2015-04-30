Temp-Log
===

**This branch is deticated to the python rewrite of this software. As development continues, the perl version will be moved to a depricated branch. At this time, it is safe to assume that the software in this branch does not function and should not be used.**

Temperature monitoring in perl using lm-sensors. This perl script scraps the output of the 'sensors' portion of lm-sensors. In the designed use-case, the server portion of Temps is run on the master node and each client whoes temperature is being monitored is then reported to the master. 

Uasge as Client:
---
When run as the client, the script gathers core temperature data, means them, and sends the data to a master node. By default, when run as the client the program will send info to localhost. 
```
~$ ./temps.pl -m <master node>
			[-v | --version]
			[-d | --debug]
                    
```

Uasge as Server:
---
When run as the master node, the program should be run in the background awaiting outer node information.
```
~$ ./temps.pl -s &
			[-v | --version]
			[-d | --debug]
                    
```
