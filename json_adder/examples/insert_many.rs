// Example from https://www.mongodb.com/docs/drivers/rust/current/usage-examples/insertMany/

use std::fs;

// Loop over files in a directory, in this case I've created /data
fn main() {
    for file in fs::read_dir("../../api.freifunk.net/data/history/").unwrap() {
        println!("{}", file.unwrap().path().display());
    }
}