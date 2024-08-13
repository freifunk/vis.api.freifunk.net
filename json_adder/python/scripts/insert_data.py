import os
import json
import tarfile
from models.community import Community
from db.setup_db import get_collection
from datetime import datetime
from bson.datetime_ms import DatetimeMS

def filepath_to_bson_date(file_path):
    file_name = os.path.basename(file_path)[:17]
    fmt = "%Y%m%d-%H.%M.%S"
    chrono_dt = datetime.strptime(file_name, fmt)
    bson_dt = DatetimeMS(chrono_dt)
    return bson_dt

def process_json_file(file_path, collection):
    with open(file_path, 'r') as file:
        contents = file.read()
        value = json.loads(contents)

    communities_in_snapshot = []
    bson_time = filepath_to_bson_date(file_path)

    for community_label, community_info in value.items():
        community = Community(
            metadata=community_label,
            timestamp=bson_time,
            content=community_info
        )
        communities_in_snapshot.append(community.to_bson())

    insert_many_result = collection.insert_many(communities_in_snapshot)
    return len(insert_many_result.inserted_ids)

def process_tar_gz_file(file_path, collection):
    with tarfile.open(file_path, "r:gz") as tar:
        for member in tar.getmembers():
            if member.isfile() and member.name.endswith('.json'):
                f = tar.extractfile(member)
                if f:
                    contents = f.read().decode('utf-8')
                    value = json.loads(contents)
                    
                    communities_in_snapshot = []
                    bson_time = filepath_to_bson_date(file_path)

                    for community_label, community_info in value.items():
                        community = Community(
                            metadata=community_label,
                            timestamp=bson_time,
                            content=community_info
                        )
                        communities_in_snapshot.append(community.to_bson())

                    insert_many_result = collection.insert_many(communities_in_snapshot)
                    return len(insert_many_result.inserted_ids)
    return 0

def insert_data():
    DATA_DIRECTORY = "../../api/history/"
    snapshot_collection = get_collection()

    inserted_object_count = 0
    inserted_file_count = 0

    for file_name in os.listdir(DATA_DIRECTORY):
        file_path = os.path.join(DATA_DIRECTORY, file_name)

        if file_name.endswith('.tar.gz'):
            # Process tar.gz file
            inserted_count = process_tar_gz_file(file_path, snapshot_collection)
        elif file_name.endswith('.json'):
            # Process normal JSON file
            inserted_count = process_json_file(file_path, snapshot_collection)
        else:
            # Skip other file types
            continue

        inserted_object_count += inserted_count
        inserted_file_count += 1

    print(f"Inserted {inserted_object_count} objects from {inserted_file_count} files")

if __name__ == "__main__":
    insert_data()
