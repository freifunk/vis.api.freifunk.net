const express = require('express');
const graphqlHTTP = require('express-graphql').graphqlHTTP;
const graphql = require('graphql');
const { MongoClient } = require('mongodb');

const context = () => MongoClient.connect('mongodb+srv://databaseReader:freifunkfreifunk@freifunktest.zsfzlav.mongodb.net/?retryWrites=true&w=majority&appName=freifunktest').then(client => client.db('communities'));

const schema = require('./schema.js');

// resolver for top five weimarnetz results
const resolvers = {
  communities: async (args, context) => {
    console.log(args);
    const db = await context();
    return db.collection('hourly_snapshot').find(args).limit(5).toArray();
  },
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
