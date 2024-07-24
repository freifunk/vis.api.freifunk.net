const { buildSchema } = require('graphql');

const SDLschema = `

type Query {
  communities(metadata: String): [Community!]!
  latest_nodes_per_community(metadata: String): [Community!]!
  timeseries_nodes_per_community(metadata: String): [Community!]!
}

type Community {
  metadata: String
  timestamp: String
  _id: ID
  # This adds a nodes field for latest_communities
  # there is a better way of doing this with interfaces
  nodes: Int
}

`;

module.exports = buildSchema(SDLschema)