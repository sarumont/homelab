Helm chart for Logitech Media Server.

## Ports

These ports are exposed by a MetalLB service to be discoverable in your network.

|Protocol|Port|Purpose|
|--|--|--|
|UDP|3478|Port used for STUN.|
|UDP|5514|Port used for remote syslog capture|
|TCP|8080|Port used for device and application communication|
|TCP|8443|Port used for application GUI/API as seen in a web browser|
|TCP|8880|Port used for HTTP portal redirection|
|TCP|8843|Port used for HTTPS portal redirection|
|TCP|6789|Port used for UniFi mobile speed test|
|TCP|27117|Port used for local-bound database communication|
|UDP|5656-5699|Ports used by AP-EDU broadcasting|
|UDP|10001|Port used for device discovery|
|UDP|1900|Port used for "Make application discoverable on L2 network" in the UniFi Network settings|
