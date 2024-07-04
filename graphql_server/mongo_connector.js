const express = require('express');
const graphqlHTTP = require('express-graphql');
const { buildSchema } = require('graphql');
const { MongoClient } = require('mongodb');

// don't steal my password please
const password = encodeURIComponent("w6x)Kf9z:Y!j.+k");

const context = () => MongoClient.connect('mongodb+srv://pierremarshall:${password}@freifunktest.zsfzlav.mongodb.net/?retryWrites=true&w=majority&appName=freifunktest', { useNewUrlParser: true }).then(client => client.db('database_name'));

