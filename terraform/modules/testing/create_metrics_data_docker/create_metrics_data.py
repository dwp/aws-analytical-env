import boto3
import os
import pandas as pd
from fastparquet import write
from copy import deepcopy

small_dataset = "table1k"
large_dataset = "table5m"
chunk_size = 405000
template = {
    '_id': {
        'd_oid': '100000000000000000000000'
    },
    '_version': 10,
    'acceptedDateTime': {
        'd_date': '2000-01-01T00:00:00.000Z'
    },
    'element': {
        'array': [],
        'testId': '10000000-0000-0000-0000-000000000000',
        'declaredDateTime': None,
        'type': 'aaaaaaaaAaaaaaaaaaaaa',
        'Date': {
            'date': None,
            'type': 'AAAAAAAAAAAAAAAA',
            'knownDate': None
        },
        'additionalId': None,
        'effectiveDate': {
            'date': None,
            'type': 'AAAAAAAAAAAAAAAA',
            'knownDate': None
        },
        'hasAdditionalField': None
    },
    'secondTestId': '10000000-0000-0000-0000-000000000000'
}


def create_parquet(output_data_file_name, chunk_id, json_data):
    write(
        '{}.parquet'.format(output_data_file_name),
        pd.DataFrame({'id': chunk_id, 'val': json_data}),
    )


def wait_for_file_in_s3(s3_bucket, s3_key):
    waiter = boto3.client('s3').get_waiter("object_exists")
    waiter.wait(
        Bucket=s3_bucket, Key=s3_key, WaiterConfig={"Delay": 2, "MaxAttempts": 60}
    )
    return s3_key


def upload_file_to_s3(file_location, s3_bucket, s3_key):
    s3 = boto3.resource('s3')
    s3.meta.client.upload_file(file_location, s3_bucket, s3_key)


def create_hive_on_s3_data(bucket_name, s3_file_path, collection_name):
    client = boto3.client("glue", region_name='eu-west-2')

    DatabaseName = os.getenv('db_name')
    try:
        client.delete_table(DatabaseName=DatabaseName, Name=collection_name)
    except client.exceptions.EntityNotFoundException:
        pass

    client.create_table(
        DatabaseName=DatabaseName,
        TableInput={
            "Name": collection_name,
            "Description": "Hive table to e2e test tagging",
            "StorageDescriptor": {
                "Columns": [
                    {"Name": "id", "Type": "string"},
                    {"Name": "data", "Type": "string"},
                ],
                "Location": f"s3://{bucket_name}/{s3_file_path}",
                "Compressed": False,
                "NumberOfBuckets": -1,
                "InputFormat": "org.apache.hadoop.mapred.TextInputFormat",
                "OutputFormat": "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat",
                "SerdeInfo": {
                    "Name": "string",
                    "SerializationLibrary": "org.openx.data.jsonserde.JsonSerDe",
                    "Parameters": {
                        "hbase.columns.mapping": ":key,cf:record",
                        "serialization.format": "1",
                    },
                },
            },
            "TableType": "EXTERNAL_TABLE",
        },
    )


def write_data_and_upload_to_s3(output_data_file_name, chunk_length, chunk_id):
    local_filename = "./{}{}".format(output_data_file_name, chunk_id)
    json_builder = []

    for x in range(0, chunk_length):
        output_data = template
        output_data["_id"]["d_oid"] = str(int(output_data["_id"]["d_oid"]) + 1)
        json_builder.append(deepcopy(output_data))

    print(json_builder)

    create_parquet(local_filename, chunk_id, json_builder)

    upload_file_to_s3(
                        '{}.parquet'.format(local_filename),
                        os.getenv('dataset_s3_name'),
                        "{}/{}/{}.parquet".format(
                            os.getenv('path_to_folder'),
                            output_data_file_name,
                            local_filename
                        )
                      )
    os.remove(local_filename)


def create_false_data(output_data_file_name, number_of_copies):

    whole_chunks = round(number_of_copies/chunk_size)
    last_chunk = number_of_copies - (whole_chunks*chunk_size)
    count = 100000000000000000000000
    chunk_id = 1

    for x in range(0, whole_chunks):
        write_data_and_upload_to_s3(output_data_file_name, chunk_size, chunk_id)
        chunk_id += 1

    write_data_and_upload_to_s3(output_data_file_name, last_chunk, chunk_id)
    # wait_for_file_in_s3(os.getenv('dataset_s3_name'), "{}/".format(os.getenv('path_to_folder')))


create_false_data(small_dataset, 1000)
create_false_data(large_dataset, 5000000)
create_hive_on_s3_data(os.getenv('dataset_s3_name'), "{}/{}/".format(os.getenv('path_to_folder'), small_dataset), small_dataset)
create_hive_on_s3_data(os.getenv('dataset_s3_name'), "{}/{}/".format(os.getenv('path_to_folder'), large_dataset), large_dataset)
