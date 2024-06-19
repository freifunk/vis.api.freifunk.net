use bson::{doc, Document};
use futures::TryStreamExt;
#[allow(unused_imports)]
#[allow(dead_code)]
use mongodb::{
    bson,
    options::{
        ClientOptions, CreateCollectionOptions, ServerApi, ServerApiVersion, TimeseriesGranularity,
        TimeseriesOptions,
    },
    Client, Collection,
};
use std::error::Error;
use tokio;

#[tokio::main]

async fn main() -> Result<Collection<Document>, Error> {
    // boilerplate connection code
    let uri: &str = "mongodb://ADMIN:PASSWORD@localhost:27017";
    let mut client_options = ClientOptions::parse_async(uri).await?;

    // Set the server_api field of the client_options object to Stable API version 1
    let server_api = ServerApi::builder().version(ServerApiVersion::V1).build();
    client_options.server_api = Some(server_api);

    // Create a new client and connect to the server
    let client: Client = Client::with_options(client_options)?;

    let db_list: Vec<String> = client.list_database_names(doc! {}, None).await?;
    println!("List databases: {:?}", db_list);
    let db = client.database("communities");
    
    // List collections in the database
    let coll_list: Vec<String> = db.list_collection_names(doc! {}).await?;
    println!("List collections in database: {:?}", coll_list);

    // If the collection doesn't exist, create it
    if coll_list.iter().any(|e| e != "hourly_snapshot") {
        let ts_opts = TimeseriesOptions::builder()
            .time_field("timestamp".to_string())
            .meta_field(Some("label".to_string()))
            .granularity(Some(TimeseriesGranularity::Hours))
            .build();
        let coll_opts = CreateCollectionOptions::builder()
            .timeseries(ts_opts)
            .build();
        db.create_collection("hourly_snapshot", coll_opts).await?;
    };

    // Return the collection
    let snapshot_collection: Collection<Document> = db.collection("hourly_snapshot");
    return snapshot_collection
}
