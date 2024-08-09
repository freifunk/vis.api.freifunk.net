use crate::models;
use bson::doc;
use mongodb::{
    bson,
    options::{
        ClientOptions, CreateCollectionOptions, ServerApi, ServerApiVersion, TimeseriesGranularity,
        TimeseriesOptions,
    },
    Client, Collection,
};

pub async fn get_collection() -> Collection<models::Community> {
    // boilerplate connection code
    // local database
    const URI: &str = "mongodb://ADMIN:PASSWORD@localhost:27017";
    // remote database
    // const URI: &str = "mongodb+srv://${user}:${password}@freifunktest.zsfzlav.mongodb.net/";

    let mut client_options = ClientOptions::parse_async(URI).await.unwrap();

    // Set the server_api field of the client_options object to Stable API version 1
    let server_api = ServerApi::builder().version(ServerApiVersion::V1).build();
    client_options.server_api = Some(server_api);

    // Create a new client and connect to the server
    let client: Client = Client::with_options(client_options).unwrap();

    let db_list: Vec<String> = client.list_database_names(doc! {}, None).await.unwrap();
    println!("List databases: {:?}", db_list);
    let db = client.database("communities");

    // List collections in the database
    let coll_list: Vec<String> = db.list_collection_names(doc! {}).await.unwrap();
    println!("List collections in database: {:?}", coll_list);

    // If the collection doesn't exist, create it
    if coll_list.iter().any(|e: &String| e == "hourly_snapshot") {
        println!("hourly_snapshot exists, move on");
    } else {
        println!("hourly_snapshot collection not found, creating it");
        let ts_opts = TimeseriesOptions::builder()
            .time_field("timestamp".to_string())
            .meta_field(Some("metadata".to_string()))
            .granularity(Some(TimeseriesGranularity::Hours))
            .build();
        let coll_opts = CreateCollectionOptions::builder()
            .timeseries(ts_opts)
            .build();
        db.create_collection("hourly_snapshot", coll_opts)
            .await
            .unwrap();
    };

    // Return the collection
    let snapshot_collection: Collection<models::Community> = db.collection("hourly_snapshot");
    return snapshot_collection;
}
