const { buildSchema } = require('graphql');

const SDLschema = `

type Query {
  communities(metadata: String): [Community!]!
  latest_nodes_per_community(metadata: String): [Community!]!
  grouped_nodes_timeseries: [NodesTimeseries!]!
  routing_protocols: [RoutingTimeseries]
}

type Community {
  metadata: String
  timestamp: String
  _id: ID
  # This adds a nodes field for latest_communities
  # there is a better way of doing this with interfaces
  nodes: Int
}

type NodesTimeseries {
  date: String!
  avgNodes: Int
}

type RoutingTimeseries {
  _id: String!
  routingList: [Routers]
}

# This is needed for mapping
type Routers {
    routingTech: String
    seen: Int
}


`;

module.exports = buildSchema(SDLschema)