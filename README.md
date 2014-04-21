Temp-Log
===

** This project is a work in progress, network features and scrapping are still being worked on! **

Temperature monitoring in perl using lm-sensors. This perl script scraps the output of the 'sensors' portion of lm-sensors. When run as the client, the script gathers core temperature data, means them, and sends the data to a master node. By default, when run as the client the program will send info to localhost. In the designed use-case, the server portion of Temps is run on the master node and each client whoes temperature is being monitored is then reported to the master. When run as the master node, the program should be run in the background awaiting outer node information.

Uasge as Client:
---
```
~$ ./temps.pl -m <master node>
			[-v | --verbose]
			[-d | --debug]
                    
```

Uasge as Server:
---
```
~$ ./temps.pl -s &
			[-m <master node>]
			[-v | --verbose]
			[-d | --debug]
                    
```
