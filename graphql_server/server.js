const express = require('express');
const graphqlHTTP = require('express-graphql').graphqlHTTP;
const { graphql, buildSchema } = require('graphql');
const { MongoClient } = require('mongodb');

// don't steal my password please
const password = encodeURIComponent("w6x)Kf9z:Y!j.+k");

const context = () => MongoClient.connect('mongodb+srv://pierremarshall:${password}@freifunktest.zsfzlav.mongodb.net/').then(client => client.db('freifunktest'));

// Construct a schema, using GraphQL schema language
// this buildschema stuff can be replaced at some point
// but for now
const schema = buildSchema(`
  type Query {
    community: [Community]
  }
  type Community {
    metadata: String,
    timestamp: String,
    _id: String
 }
`);

// Provide resolver functions for your schema fields
const resolvers = {
	hello: (args, context) => context().then(db => db.collection('hourly_snapshot').find().toArray())
};

// This is the server bit
const app = express();

app.use('/api', graphqlHTTP({
	schema,
	rootValue: resolvers,
	context,
	graphiql: true
}));

app.listen(4000);

console.log(`Server ready at http://localhost:4000/api`);
