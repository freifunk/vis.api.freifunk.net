use chrono::{NaiveDateTime, Utc};
use mongodb::{bson, Collection};
use serde_json::Value;
use std::fs;
mod setup_db;
mod models;

#[tokio::main]

async fn main() -> mongodb::error::Result<()> {
    let snapshot_collection: Collection<models::Community> = setup_db::get_collection().await;

    for file in fs::read_dir("../../api.freifunk.net/data/history/").unwrap() {
        // File path for sample json file, change this later
        let file_path = file.unwrap().path();

        // Convert JSON to string, then to value, then to bson
        let contents: String = fs::read_to_string(file_path).expect("couldn't read file");
        let value: Value = serde_json::from_str(&contents).expect("couldn't parse json");

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

        let mut communities_in_snapshot: Vec<models::Community> = Vec::new();
        for (community_label, community_info) in value.as_object().unwrap() {
            let mtime = &community_info["mtime"].to_string();
            let bson_time = mtime_to_bson(mtime);

            let community = models::Community {
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
