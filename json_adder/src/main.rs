use mongodb::{
    bson::doc,
    options::{ClientOptions, ServerApi, ServerApiVersion},
    Client,
};
#[tokio::main]
async fn main() -> mongodb::error::Result<()> {
    let uri: &str = "mongodb://ADMIN:PASSWORD@localhost:27017";

    let mut client_options = ClientOptions::parse_async(uri).await?;

    // Set the server_api field of the client_options object to Stable API version 1
    let server_api = ServerApi::builder().version(ServerApiVersion::V1).build();
    client_options.server_api = Some(server_api);

    // Create a new client and connect to the server
    let client: Client = Client::with_options(client_options)?;

    let database = client.database("communities");
    let collection = database.collection("hourlySnapshot");

    // Send a ping to confirm a successful connection
    client
        .database("communities")
        .run_command(doc! { "ping": 1 }, None)
        .await?;

    println!("Pinged your deployment. You successfully connected to MongoDB!");

    let doc = doc! {
        "title": "Mistress America", "type": "movsssie"
    };
    let result = collection.insert_one(doc, None).await?;

    println!("{:#?}", result);

    Ok(())
}
