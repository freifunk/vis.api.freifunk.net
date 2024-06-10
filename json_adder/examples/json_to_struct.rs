// use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::fs;
use mongodb::bson;

fn main() {
    let file_path: &str =
        "../../api.freifunk.net/data/history/20240129-10.01.02-ffSummarizedDir.json";

    let contents: String = fs::read_to_string(file_path).expect("couldn\'t read file");

    let value: Value = serde_json::from_str(&contents).expect("couldn\'t parse json");
    let bson_doc = bson::to_document(&value);
    // println!("{:?}", bson_doc);
}