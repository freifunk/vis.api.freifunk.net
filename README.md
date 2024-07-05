# Visualisation of Freifunk API data

A pipeline to load data from the Freifunk API JSONs and create a GraphQL interface. Inspired by [Andi Bräu's talk at the GPN16](https://media.ccc.de/v/gpn16-7659-die_freifunk_api).
Currently being worked on as a Google Summer of Code project.

Todo:
- [X] Triage old issues
- [X] Set up MongoDB
- [X] Start writing a MongoDB script to add JSON objects in a time series
- [X] Set up GraphQL server
- [X] Get some data through the pipeline from end to end

Next steps:
- [ ] Make the GraphQL Schema fit the JSON Schema for the database file
