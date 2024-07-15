const { buildSchema } = require('graphql');

module.exports = buildSchema(`
type Query {
  communities(metadata: String): [Community!]!
}

type Community {
  metadata: String!
  timestamp: String
  _id: String
  content: Content
}

type Content {
  state: State
}

type State {
  nodes: Int
}


`);