use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Serialize, Deserialize, Debug)]
pub struct Community {
    pub metadata: String,
    pub timestamp: bson::DateTime,
    pub content: Value,
}