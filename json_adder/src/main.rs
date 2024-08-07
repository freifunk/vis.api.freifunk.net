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
    let mut inserted_object_count: u64 = 0u64;
    let mut inserted_file_count: u64 = 0u64;

    for file in fs::read_dir(DATA_DIRECTORY).unwrap() {
        // File path for sample json file, change this later
        let file_path: std::path::PathBuf = file.unwrap().path();

        // Convert JSON to string, then to value, then to bson
        let contents: String = fs::read_to_string(file_path.clone()).expect("couldn't read file");
        let value: Value = serde_json::from_str(&contents).expect("couldn't parse json");

        // Construct bson datetime function
        // -> bson::DateTime
        fn filepath_to_bson_date(file_path: std::path::PathBuf) -> bson::DateTime {
            let file_name: &str = file_path
                .file_name()
                .expect("could not read filename after reading data directory")
                .to_str()
                .expect("could not convert filename to &str")
                .get(..17)
                .expect("could not truncate filename");

            let fmt: &str = "%Y%m%d-%H.%M.%S";
            let chrono_dt: chrono::DateTime<Utc> = NaiveDateTime::parse_from_str(file_name, fmt)
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

        // Insert lots of documents in one go
        let insert_many_result = snapshot_collection
            .insert_many(communities_in_snapshot, None)
            .await?;

        // Increment counters at the end of the loop
        let insert_ids_count: u64 = insert_many_result.inserted_ids.len().try_into().unwrap();
        inserted_object_count += insert_ids_count;
        inserted_file_count += 1;
    }
    // print!("{inserted_object_count} objects added");
    println!("inserted {inserted_object_count} objects from {inserted_file_count} files");

    Ok(())
}
