// #[derive(Serialize, Deserialize)]
// use std::env;
use std::fs;
use std::error::Error;


fn main() -> Result<(), Box<dyn Error>> {
    let file_path: &str =
        "../../api.freifunk.net/data/history/20240129-10.01.02-ffSummarizedDir.json";

    // println!("In file {}", file_path);

    let contents: String = fs::read_to_string(file_path)?;

    // println!("With text:\n{contents}");
    Ok(())
}
