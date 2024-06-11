use bson::Document;
use mongodb::{
    bson,
    options::{ClientOptions, ServerApi, ServerApiVersion},
    Client,
};
// use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::fs;

#[tokio::main]

async fn main() -> mongodb::error::Result<()> {
    let uri: &str = "mongodb://ADMIN:PASSWORD@localhost:27017";
    let mut client_options = ClientOptions::parse_async(uri).await?;

    // Set the server_api field of the client_options object to Stable API version 1
    let server_api = ServerApi::builder().version(ServerApiVersion::V1).build();
    client_options.server_api = Some(server_api);

    // Create a new client and connect to the server
    let client: Client = Client::with_options(client_options)?;

    // Connect to the database and the snapshot collection document
    let database = client.database("communities");
    let snapshot_collection = database.collection("hourlySnapshot");

    println!("Pinged your deployment. You successfully connected to MongoDB!");

    // File path for the json, change this later
    let file_path: &str =
        "../../api.freifunk.net/data/history/20240129-10.01.02-ffSummarizedDir.json";

    // Convert JSON to string, then to value, then to bson
    let contents: String = fs::read_to_string(file_path).expect("couldn't read file");
    let value: Value = serde_json::from_str(&contents).expect("couldn't parse json");
    let bson_doc: Document = bson::to_bson(&value)
        .expect("couldn't convert value to bson")
        .as_document()
        .unwrap()
        .clone();

    // Insert this the bson into the collection
    let result = snapshot_collection.insert_one(bson_doc, None).await?;

    println!("Inserted a document with _id: {}", result.inserted_id);

    Ok(())
}
