const express = require('express');
const graphqlHTTP = require('express-graphql').graphqlHTTP;
const graphql = require('graphql');
const { MongoClient } = require('mongodb');

const context = () => MongoClient.connect('mongodb://ADMIN:PASSWORD@localhost:27017').then(client => client.db('communities'));

const schema = require('./schema.js');

const resolvers = {
  communities: async (args, context) => {
    console.log(args);
    const db = await context();
    return db.collection('hourly_snapshot').find(args).limit(5).toArray();
  },
  latest_nodes_per_community: async (args, context) => {
    const db = await context();
    const pipeline = require('./mongodb_queries/latest_nodes_per_community.js');
    return db.collection('hourly_snapshot').aggregate(pipeline).toArray();
  },
  grouped_nodes_timeseries: async (args, context) => {
    const db = await context();
    const pipeline = require('./mongodb_queries/grouped_nodes_timeseries.js');
    return db.collection('hourly_snapshot').aggregate(pipeline).toArray();
  },
};

// This is the server bit
const app = express();

app.use('/api',
  function (req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    res.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS, HEAD");
    next();
  }, graphqlHTTP({
    schema,
    rootValue: resolvers,
    context,
    graphiql: true
  }));
// return 204 code for favicon
app.use('/favicon.ico', (req, res) => res.status(204));

const path = require('path');
app.use('/static', express.static(path.join(__dirname, '../visualisations')));

const port = 4000;
app.listen(port, () => {
  console.log(`GraphiQL running at http://localhost:${port}/api`),
  console.log(`Test visualisation page running at http://localhost:${port}/static`)
});
