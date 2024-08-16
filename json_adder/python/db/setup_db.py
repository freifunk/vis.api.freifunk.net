import logging
from pymongo import MongoClient
from pymongo.errors import CollectionInvalid
from pymongo.collection import Collection

def get_collection(config) -> Collection:
    logging.info("Setting up database connection...")
    
    connection_string = config['database']['connection_string']
    db_name = config['database']['database_name']
    client = MongoClient(connection_string)
    db = client[db_name]
    granularity = config['import']['granularity']

    collection_name = f"{granularity}_snapshot"
    if collection_name in db.list_collection_names():
        logging.info(f"Using existing collection: {collection_name}")
    else:
        logging.info(f"Creating timeseries collection: {collection_name}")
        ts_opts = {}
        if granularity == "hourly": 
            ts_opts = {
                "timeField": "timestamp",
                "metaField": "metadata",
                "granularity": "hourly"
            }
        elif granularity == "daily":
            ts_opts = {
                "timeField": "timestamp",
                "metaField": "metadata",
                "bucketRoundingSeconds": 86400,
                "bucketMaxSpanSeconds": 86400
            }
        else:
            raise Exception(f"Granularity {granularity} not allowed!")


        try:
            db.create_collection(collection_name, timeseries=ts_opts)
        except CollectionInvalid as e:
            logging.info(f"Failed to create collection: {str(e)}")

    snapshot_collection = db[collection_name]
    return snapshot_collection
