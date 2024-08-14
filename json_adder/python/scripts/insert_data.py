import os
import json
import logging
import tarfile
from models.community import Community
from db.setup_db import get_collection
from datetime import datetime
from bson.datetime_ms import DatetimeMS

def filepath_to_bson_date(file_path):
    logging.debug(f"Extracting date from filename: {file_path}")
    file_name = os.path.basename(file_path)[:17]
    fmt = "%Y%m%d-%H.%M.%S"
    chrono_dt = datetime.strptime(file_name, fmt)
    bson_dt = DatetimeMS(chrono_dt)
    return bson_dt

def process_community_data(file_contents, file_path, collection):
    logging.info(f"Processing community data from file: {file_path}")
    try:
        value = json.loads(file_contents)
    except json.JSONDecodeError as e:
        logging.error(f"Error decoding JSON from file {file_path}: {e}")
        return 0
    
    communities_in_snapshot = []
    bson_time = filepath_to_bson_date(file_path)

    for community_label, community_info in value.items():
        community = Community(
            metadata=community_label,
            timestamp=bson_time,
            content=community_info
        )
        if collection.count_documents({"metadata": community_label, "timestamp": bson_time}, limit=1) == 0:
            communities_in_snapshot.append(community.to_bson())

    logging.info(f"working on file {file_path}, added {len(communities_in_snapshot)} communities")
    if len(communities_in_snapshot) > 0: 
        insert_many_result = collection.insert_many(communities_in_snapshot)
        return len(insert_many_result.inserted_ids)
    return 0

def process_json_file(file_path, collection):
    logging.debug(f"Processing JSON file: {file_path}")
    try:
        with open(file_path, 'r') as file:
            contents = file.read()
        return process_community_data(contents, file_path, collection)
    except IOError as e:
        logging.error(f"Error reading file {file_path}: {e}")
        return 0

def process_tar_gz_file(file_path, collection):
    logging.debug(f"Processing tar.gz file: {file_path}")
    try:
        with tarfile.open(file_path, "r:gz") as tar:
            for member in tar.getmembers():
                if member.isfile() and member.name.endswith('.json'):
                    f = tar.extractfile(member)
                    if f:
                        contents = f.read().decode('utf-8')
                        return process_community_data(contents, file_path, collection)
    except (IOError, tarfile.TarError) as e:
        logging.error(f"Error processing tar.gz file {file_path}: {e}")
        return 0
    return 0

def insert_data(config):
    data_directory = config['paths']['data_directory']
    snapshot_collection = get_collection(config)

    inserted_object_count = 0
    inserted_file_count = 0

    for file_name in os.listdir(data_directory):
        file_path = os.path.join(data_directory, file_name)
        logging.debug(f"Start reading file {file_name}")

        if file_name.endswith('.tar.gz'):
            # Process tar.gz file
            inserted_count = process_tar_gz_file(file_path, snapshot_collection)
        elif file_name.endswith('.json'):
            # Process normal JSON file
            inserted_count = process_json_file(file_path, snapshot_collection)
        else:
            # Skip other file types
            logging.warning(f"Skipping unknown file type: {file_name}")
            continue

        inserted_object_count += inserted_count
        inserted_file_count += 1

    logging.info(f"Inserted {inserted_object_count} objects from {inserted_file_count} files")

if __name__ == "__main__":
    insert_data()
