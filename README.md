# Visualisation of Freifunk API data

A growing collection of R scripts to extract data from the Freifunk API JSONs and draw interesting diagrams. Inspired by [Andi Bräu's talk at the GPN16](https://media.ccc.de/v/gpn16-7659-die_freifunk_api) and [Freifunk's GSoC ideas](https://wiki.freifunk.net/Ideas#Freifunk_API_visualisation_framework).

Future goals: see [issues](https://github.com/freifunk/vis.api.freifunk.net/issues).

## Time series 

![](FF_nodes_per_community.png)

Uses a 240th fraction of the [historical JSONs](https://api.freifunk.net/data/history/).

## Word cloud of community descriptions

![](FF_description_cloud.png)

## Word cloud of services run by Freifunk communities

![](FF_service_cloud.png)

Presented terms appear at lest twice in the [current JSON](https://api.freifunk.net/data/ffSummarizedDir.json).
