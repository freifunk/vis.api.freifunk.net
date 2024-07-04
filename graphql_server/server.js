const express = require('express');
const graphqlHTTP = require('express-graphql').graphqlHTTP;
const { graphql, buildSchema } = require('graphql');

// Construct a schema, using GraphQL schema language
// this buildschema stuff can be replaced at some point
// but for now
const schema = buildSchema(`
  type Query {
    hello: String
  }
`);

// Provide resolver functions for your schema fields
const resolvers = {
  hello: () => 'Hello world!'
};

// This is the server bit
const app = express();

app.use('/api', graphqlHTTP({
	schema,
	rootValue: resolvers,
	graphiql: true
}));

app.listen(4000);

console.log(`Server ready at http://localhost:4000/api`);
