from functools import partial
import os
import json
import logging
import re
import tarfile
from models.community import Community
from db.setup_db import connect_to_collection, create_or_update_collection
from datetime import datetime
from bson.datetime_ms import DatetimeMS
from multiprocessing import Pool, cpu_count

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

def process_file(data_directory, file_name, config):
    
    connection_string = config['database']['connection_string']
    db_name = config['database']['database_name']
    granularity = config['import']['granularity']
    collection_name = f"{granularity}_snapshot"
    collection = connect_to_collection(connection_string, db_name, collection_name)
    file_path = os.path.join(data_directory, file_name)
    logging.debug(f"Start reading file {file_name}")
    inserted_count = 0

    if file_name.endswith('.tar.gz'):
        # Process tar.gz file
        inserted_count = process_tar_gz_file(file_path, collection)
    elif file_name.endswith('.json'):
        # Process normal JSON file
        inserted_count = process_json_file(file_path, collection)
    else:
        # Skip other file types
        logging.warning(f"Skipping unknown file type: {file_name}")

    logging.info(f"Processed {inserted_count} objects")
    return inserted_count

def insert_data(config):
    data_directory = config['paths']['data_directory']
    create_or_update_collection(config)
    granularity = config['import']['granularity']

    pool = Pool(cpu_count())

    file_list = os.listdir(data_directory)
    
    if granularity == "daily":
        files = sorted([file for file in file_list if re.match(r'\d{8}-00\.\d{2}\.\d{2}-ffSummarizedDir.json.*', file)])
    elif granularity == "hourly":
        files = sorted(file_list)
    else:
        raise Exception(f"Granularity {granularity} not valid")

    logging.info(f"We're going to process {len(files)} files.")

    process_file_with_args = partial(process_file, data_directory, config=config)
    inserted_object_count = pool.map(process_file_with_args, files)
    
    logging.info(f"Inserted {sum(inserted_object_count)} objects from {len(files)} files")

if __name__ == "__main__":
    insert_data()
