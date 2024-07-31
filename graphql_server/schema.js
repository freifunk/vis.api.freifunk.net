const { buildSchema } = require('graphql');

const SDLschema = `

type Query {
  communities(metadata: String): [Community!]!
  latest_nodes_per_community(metadata: String): [Community!]!
  grouped_nodes_timeseries: [NodesTimeseries!]!
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
  _id: Date
  sumNodes: Int
}

type Date {
  date: DateParts
}

type DateParts {
  year: Int
  month: Int
  day: Int
  hour: Int
}

`;

module.exports = buildSchema(SDLschema)