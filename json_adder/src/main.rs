use chrono::{NaiveDateTime, Utc};
use mongodb::{bson, Collection};
use serde_json::Value;
use std::fs;
mod models;
mod setup_db;

const DATA_DIRECTORY: &str = "../../api.freifunk.net/data/history/";

#[tokio::main]

async fn main() -> mongodb::error::Result<()> {
    let snapshot_collection: Collection<models::Community> = setup_db::get_collection().await;

    for file in fs::read_dir(DATA_DIRECTORY).unwrap() {
        // File path for sample json file, change this later
        let file_path: std::path::PathBuf = file.unwrap().path();

        // Convert JSON to string, then to value, then to bson
        let contents: String = fs::read_to_string(file_path.clone()).expect("couldn't read file");
        let value: Value = serde_json::from_str(&contents).expect("couldn't parse json");

        // Construct bson datetime function
        // -> bson::DateTime
        fn filepath_to_bson_date(file_path: std::path::PathBuf) -> bson::DateTime {

            let file_name = file_path.file_name()
            .expect("could not read filename after reading data directory")
            .to_str().expect("could not convert filename to &str");

            fn filename_to_padded_datestring(file_name: &str) -> String {

                let mut truncated_filename = file_name
                .get(..11)
                .expect("could not truncate filename")
                .to_string();
    
                // Add zeroes to the date string for minutes and seconds
                truncated_filename.push_str("0000");
                truncated_filename
            }

            let fmt: &str = "%Y%m%d-%H%M%S";
            let padded_datestring = filename_to_padded_datestring(file_name);
            let chrono_dt: chrono::DateTime<Utc> =
                NaiveDateTime::parse_from_str(&padded_datestring, fmt)
                    .expect("failed to parse naive datetime from json value")
                    .and_utc();
            // Convert to bson datetime, copied
            // from https://docs.rs/bson/latest/bson/struct.DateTime.html
            let bson_dt: bson::DateTime = chrono_dt.into();
            bson::DateTime::from_chrono(chrono_dt);
            bson_dt
        }

        

        let mut communities_in_snapshot: Vec<models::Community> = Vec::new();
        let bson_time = filepath_to_bson_date(file_path);

        for (community_label, community_info) in value.as_object().unwrap() {
            // let mtime = &community_info["mtime"].to_string();
            let community = models::Community {
                metadata: community_label.to_string(),
                timestamp: bson_time,
                content: community_info.clone(),
            };

            communities_in_snapshot.push(community);
        }

        // print!("{:?}",communities_in_snapshot);

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
