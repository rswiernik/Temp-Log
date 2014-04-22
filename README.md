Temp-Log
===

** This project is a work in progress, network features and scrapping are still being worked on!

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
