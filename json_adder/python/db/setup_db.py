import logging
from pymongo import MongoClient
from pymongo.errors import CollectionInvalid
from pymongo.collection import Collection

def connect_to_collection(connection_string: str, db_name: str, collection_name: str):
    db = connect_to_database(connection_string, db_name)
    return db[collection_name]

def connect_to_database(connection_string: str, db_name: str):
    """
    Establishes a connection to the specified database and returns the database instance.
    
    :param connection_string: The MongoDB connection string.
    :param db_name: The name of the database.
    :return: A database instance.
    """
    logging.info("Setting up database connection...")
    client = MongoClient(connection_string)
    db = client[db_name]
    return db

def create_or_update_collection(config) -> Collection:
    """
    Connects to the database and creates (if necessary) a collection.
    
    :param config: Configuration data containing the connection string, database name, and granularity.
    :return: The collection instance.
    """
    connection_string = config['database']['connection_string']
    db_name = config['database']['database_name']
    granularity = config['import']['granularity']

    db = connect_to_database(connection_string, db_name)

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

