const express = require('express');
const graphqlHTTP = require('express-graphql').graphqlHTTP;
const graphql = require('graphql');
const { MongoClient } = require('mongodb');

const context = () => MongoClient.connect('mongodb+srv://databaseReader:freifunkfreifunk@freifunktest.zsfzlav.mongodb.net/').then(client => client.db('communities'));

const schema = require('./schema.js');

const resolvers = {
  communities: async (args, context) => {
    console.log(args);
    const db = await context();
    return db.collection('hourly_snapshot').find(args).limit(5).toArray();
  },
  latest_nodes_per_community: async (args, context) => {
    const db = await context();
    // define query pipeline to pass on to MongoDB
    let pipeline = [{ $sort: { timestamp: 1 } }, { $group: { _id: "$metadata", timestamp: { $first: "$timestamp" }, nodes: { $first: "$content.state.nodes" } } }];
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

const path = require('path')
app.use('/static', express.static(path.join(__dirname, '../visualisations')))

const port = 4000;
app.listen(port, () => {
  console.log(`Server listening on port ${port}`)
});