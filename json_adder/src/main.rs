#[allow(unused_imports)]
#[allow(dead_code)]
use bson::Document;
use chrono::{NaiveDateTime, Utc};
use core::fmt;
use mongodb::{
    bson,
    options::{ClientOptions, ServerApi, ServerApiVersion},
    Client,
};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::fs;

#[tokio::main]

async fn main() -> mongodb::error::Result<()> {
    // Is it possible to wrap up some of this boilerplate connection code?
    let uri: &str = "mongodb://ADMIN:PASSWORD@localhost:27017";
    let mut client_options = ClientOptions::parse_async(uri).await?;

    // Set the server_api field of the client_options object to Stable API version 1
    let server_api = ServerApi::builder().version(ServerApiVersion::V1).build();
    client_options.server_api = Some(server_api);

    // Create a new client and connect to the server
    let client: Client = Client::with_options(client_options)?;

    // Connect to the database and the snapshot collection document
    let database = client.database("communities");
    let snapshot_collection = database.collection("hourly_snapshot");

    for file in fs::read_dir("../../api.freifunk.net/data/history/").unwrap() {
        // File path for sample json file, change this later
        let file_path = file.unwrap().path();

        // Convert JSON to string, then to value, then to bson
        let contents: String = fs::read_to_string(file_path).expect("couldn't read file");
        let value: Value = serde_json::from_str(&contents).expect("couldn't parse json");

        #[derive(Serialize, Deserialize, Debug)]
        struct Community {
            label: String,
            timestamp: bson::DateTime,
            content: Value,
        }

        // Construct bson datetime function
        fn mtime_to_bson(mtime: &str) -> bson::DateTime {
            // mtime is surrounded by quotes, and when passed into parse_from_str, it is
            // cut down to the format described in fmt
            let fmt = "%Y-%m-%d %H:%M:%S";
            let chrono_dt: chrono::DateTime<Utc> =
                NaiveDateTime::parse_from_str(&mtime[1..20], fmt)
                    .expect("failed to parse naive datetime from json value")
                    .and_utc();
            // Convert to bson datetime, copied
            // from https://docs.rs/bson/latest/bson/struct.DateTime.html
            let bson_dt: bson::DateTime = chrono_dt.into();
            bson::DateTime::from_chrono(chrono_dt);
            bson_dt
        }

        let mut communities_in_snapshot: Vec<Community> = Vec::new();
        for (community_label, community_info) in value.as_object().unwrap() {
            let mtime = &community_info["mtime"].to_string();
            let bson_time = mtime_to_bson(mtime);

            let community = Community {
                label: community_label.to_string(),
                timestamp: bson_time,
                content: community_info.clone(),
            };

            communities_in_snapshot.push(community);
        }

        // Insert lots of documents in one go
        let insert_many_result = snapshot_collection
            .insert_many(communities_in_snapshot, None)
            .await?;
        println!("Inserted documents with _ids:");
        for (_key, value) in &insert_many_result.inserted_ids {
            println!("{}", value);
        }
    }

    Ok(())
}
