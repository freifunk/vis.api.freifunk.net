use chrono::{NaiveDateTime, Utc};
use flate2::read::GzDecoder;
use mongodb::{bson, Collection};
use serde_json::Value;
use std::fs;
use std::io::Read;
use tar::Archive;
mod models;
mod setup_db;

const DATA_DIRECTORY: &str = "../../api.freifunk.net/data/history/";

#[tokio::main]

async fn main() -> mongodb::error::Result<()> {
    let snapshot_collection: Collection<models::Community> = setup_db::get_collection().await;
    let mut inserted_object_count: u64 = 0u64;
    let mut inserted_file_count: u64 = 0u64;

    for file in fs::read_dir(DATA_DIRECTORY).unwrap() {
        let file_path: std::path::PathBuf = file.unwrap().path();

        println!("reading file {:?}", file_path);

        fn read_file_to_string(file_path: std::path::PathBuf) -> std::string::String {
            if file_path.extension().unwrap() == "gz" {
                let tar_gz = fs::File::open(file_path).expect("could not open file");
                let tar = GzDecoder::new(tar_gz);
                let mut archive = Archive::new(tar);
                // get the first file in the archive
                let file = archive.entries().unwrap().next();
                let mut file: tar::Entry<GzDecoder<fs::File>> = file
                    .unwrap()
                    .expect("could not read first file in the archive");
                let mut file_string = String::new();
                file.read_to_string(&mut file_string).unwrap();
                return file_string;
            } else {
                let file_string: String =
                    fs::read_to_string(file_path).expect("couldn't read file");
                return file_string;
            };
        }

        // Convert JSON to string, then to value, then to bson
        let contents: String = read_file_to_string(file_path.clone());
        // some files are empty, and if so, skip them
        if contents.is_empty() {
            continue;
        }

        let value: Value = serde_json::from_str(&contents).expect("couldn't parse json");

        // Construct bson datetime function
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

    println!("inserted {inserted_object_count} objects from {inserted_file_count} files");

    Ok(())
}
