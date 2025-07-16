# Unbound Helm Chart

Note: this was originally copied from
[`ryantiger658/unbound-helm-chart`](https://github.com/ryantiger658/unbound-helm-chart.git) and updated to support modern Unbound.

## What is Unbound
Why are you asking me? Google it!

[According to Google:](https://www.nlnetlabs.nl/projects/unbound/about/)
> Unbound is a validating, recursive, caching DNS resolver. It is designed to be fast and lean and incorporates modern features based on open standards. Late 2019, Unbound has been rigorously audited, which means that the code base is more resilient than ever.

## How do I use it 
I like many nerds run a PiHole on my home network to block ads across the network. PiHole works by denying queries to known add urls, and forwarding valid queries to an upstream resolver such as 1.1.1.1 or Google's 8.8.8.8. 

By running Unbound I am able to set my Unbound deployment as the upstream for my PiHole. This allows me to resolve all queries internally based off of authoratitive sources. Meaning even more security... and even less ISP tracking. 

![seemscrazy](https://media.giphy.com/media/9hEcsoYAJb3kA/giphy.gif)

(You're not wrong)

## How to Use This Repo and the Chart Repo

Chart Repo URL:  https://sarumont.github.io/homelab/

Chart Name: unbound

## To Install
```
helm repo add unbound https://sarumont.github.io/homelab
helm install -n <namespace> deploymentname unbound/unbound
```
