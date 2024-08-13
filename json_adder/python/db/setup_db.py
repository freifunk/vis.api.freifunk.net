from pymongo import MongoClient
from pymongo.errors import CollectionInvalid
from pymongo.collection import Collection

def get_collection() -> Collection:
    URI = "mongodb://localhost:27017"
    client = MongoClient(URI)
    db = client["communities"]

    collection_name = "hourly_snapshot"
    if collection_name in db.list_collection_names():
        print(f"{collection_name} exists, move on")
    else:
        print(f"{collection_name} collection not found, creating it")

        ts_opts = {
            "timeField": "timestamp",
            "metaField": "metadata",
            "granularity": "hours"
        }

        try:
            db.create_collection(collection_name, timeseries=ts_opts)
        except CollectionInvalid as e:
            print(f"Failed to create collection: {str(e)}")

    snapshot_collection = db[collection_name]
    return snapshot_collection
