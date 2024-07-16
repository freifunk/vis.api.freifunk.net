const { buildSchema } = require('graphql');

const SDLschema = `

type Query {
  communities(metadata: String): [Community!]!
  latest_communities(metadata: String): [Community!]!
}

type Community {
  metadata: String
  timestamp: String
  _id: ID
  content: Content
}

type Content {
  state: State
}

type State {
  nodes: Int
}

`;

module.exports = buildSchema(SDLschema)