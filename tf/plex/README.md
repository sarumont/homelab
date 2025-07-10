# Plex Terraform Module

Basic deploy of the Truecharts Plex Helm chart.

## Internal vs. external traffic

The additional `NodePort` service this module defines is to allow you to differentiate between `local` and `remote` traffic inside of Plex.

When installed, you will want to:

1. get the IP(s) of your `flannel` interfaces. In my `k3s` cluster, mine start at `10.42.0.0` and increment the 3rd octet by 1 for every node (i.e. `10.42.1.0`)
2. get the IP of the node Plex gets deployed to
3. use the NodePort IP for your ingress from the WAN (`remote`)
4. add the LB node IPs to _Settings -> Network -> LAN Networks_ in your Plex server config (`local`)

This should allow you to differentiate traffic and properly cap WAN traffic
