# Freifunk Project: Comprehensive Development Guide

## Table of Contents
1. [Introduction](#1-introduction)
2. [Project Setup](#2-project-setup)
3. [Database Connection](#3-database-connection)
4. [Query Development](#4-query-development)
5. [GraphQL Integration](#5-graphql-integration)
6. [Frontend Development](#6-frontend-development)
7. [Visualization Creation](#7-visualization-creation)
8. [Best Practices and Tips](#8-best-practices-and-tips)

## 1. Introduction

Welcome to the Freifunk Project! This guide will walk you through the process of contributing to our project, from connecting to the database to creating visualizations. Our project uses MongoDB for data storage, GraphQL for API queries, and D3.js for data visualization.

## 2. Project Setup

Before you begin, ensure you have the following prerequisites:
- Node.js and npm installed
- Access to the project repository
- MongoDB installed locally (optional, but recommended for development)

Clone the repository and install dependencies:

```bash
git clone https://github.com/your-org/freifunk-project.git
cd freifunk-project
npm install
```

## 3. Database Connection

### 3.1 Connecting to the Database

You have several options for connecting to the database:

#### Option 1: Using MongoDB Shell (mongosh)

```bash
mongosh mongodb+srv://databaseReader:freifunkfreifunk@freifunktest.zsfzlav.mongodb.net/
```

After connecting, switch to the 'communities' database:

```
use communities
```

#### Option 2: Using MongoDB Compass

For a more user-friendly interface, use MongoDB Compass with the same connection string:

```
mongodb+srv://databaseReader:freifunkfreifunk@freifunktest.zsfzlav.mongodb.net/
```

#### Option 3: Local MongoDB Instance

For development purposes, we recommend running MongoDB locally. Install MongoDB Community Edition and create a local database named 'communities'.

### 3.2 Important Notes

- The connection string provided is temporary and will change when the project moves to production.
- Always use environment variables for sensitive information like connection strings in a production setting.

## 4. Query Development

### 4.1 Creating MongoDB Aggregation Queries

1. Familiarize yourself with MongoDB's aggregation framework. Refer to the [official MongoDB Aggregation Pipeline documentation](https://docs.mongodb.com/manual/core/aggregation-pipeline/).

2. Develop and test your queries in the MongoDB shell or Compass before integration:

   ```javascript
   db.hourly_snapshot.aggregate([<YOUR_QUERY_HERE>])
   ```

### 4.2 Adding Your Query to the Project

1. Create a new file in the `graphql_server/mongodb_queries/` directory.
2. Name your file descriptively, e.g., `new_feature_query.js`.
3. Structure your query file as follows:

   ```javascript
   const query = [
     // Your aggregation pipeline stages here
   ];

   module.exports = query;
   ```

4. For reference, check the existing `latest_nodes_per_community.js` file.

## 5. GraphQL Integration

### 5.1 Adding a Resolver

1. Open `graphql_server/server.js`.
2. Locate the `resolvers` object.
3. Add a new resolver for your query:

   ```javascript
   resolvers: {
     Query: {
       // ... existing resolvers
       new_feature_query: async (args, context) => {
         const db = await context();
         const pipeline = require('./mongodb_queries/new_feature_query.js');
         return db.collection('hourly_snapshot').aggregate(pipeline).toArray();
       }
     }
   }
   ```

### 5.2 Updating the GraphQL Schema

1. Open `graphql_server/schema.js`.
2. If your query returns a new type of data, define a new type in the schema.
3. Add your query to the schema:

   ```graphql
   type Query {
     # ... existing queries
     new_feature_query: [NewFeatureType!]!
   }

   type NewFeatureType {
     # Define the structure of your query result
     field1: String!
     field2: Int!
     # ... other fields
   }
   ```

4. Refer to the [GraphQL documentation](https://graphql.org/learn/schema/) for more information on schema definition.

## 6. Frontend Development

### 6.1 Adding the Query to the Webpage

1. Open `visualisations/index.html`.
2. Add your new GraphQL query:

   ```javascript
   const query_new_feature = JSON.stringify({ 
     query: "{ new_feature_query { field1 field2 } }" 
   });
   ```

### 6.2 Adding a Graph Element

Add an HTML element for your new graph:

```html
<h2>New Feature Graph</h2>
<figure>
    <svg id="new_feature_graph_container" width="640" height="480"></svg>
    <figcaption>Description of your new feature graph</figcaption>
</figure>
```

## 7. Visualization Creation

### 7.1 Creating the Graph

1. Create a new file in `visualisations/graphs/`, e.g., `new_feature_graph.js`.
2. Implement your graph using D3.js. Here's a basic structure:

   ```javascript
   import * as d3 from "https://cdn.jsdelivr.net/npm/d3@7/+esm";

   export async function createNewFeatureGraph(query) {
     // Fetch data
     const response = await fetch('/graphql', {
       method: 'POST',
       headers: { 'Content-Type': 'application/json' },
       body: query
     });
     const result = await response.json();
     const data = result.data.new_feature_query;

     // Create SVG
     const svg = d3.create("svg")
       .attr("viewBox", [0, 0, width, height]);

     // Implement your D3.js visualization here

     return svg;
   }
   ```

3. Refer to `graph1.js` for an example of D3.js implementation.

### 7.2 Adding the Graph to the Page

In `visualisations/index.html`, import and call your graph creation function:

```javascript
import { createNewFeatureGraph } from './graphs/new_feature_graph.js';

createNewFeatureGraph(query_new_feature).then(
    (graph) => {
        new_feature_graph_container.replaceWith(graph.node());
        console.log("New feature graph appended to DOM");
    }
);
```

## 8. Best Practices and Tips

- Always test your queries thoroughly before integration.
- Use meaningful names for your files, queries, and graph functions.
- Comment your code, especially complex D3.js visualizations.
- Optimize your MongoDB queries for performance.
- Consider responsive design for your visualizations.
- Regularly update this documentation as the project evolves.

We're always open to suggestions for improving this process. If you have ideas for streamlining or enhancing any part of the development workflow, please share them with the team!