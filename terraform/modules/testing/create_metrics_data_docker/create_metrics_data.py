import json
import boto3
import os

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


def write_data_and_upload_to_s3(output_data_file_name, count, chunk_length, chunk_id):
    local_filename = "/tmp/{}.json".format(output_data_file_name)

    with open(local_filename, "a") as output:
        output.write("[")

        for x in range(0, chunk_length):
            template["_id"]["d_oid"] = str(count)
            output_data = template
            count += 1
            output.write(json.dumps(output_data))
            if x != chunk_length - 1:
                output.write(",")
            else:
                output.write("]")

    upload_file_to_s3(local_filename,
                        os.getenv('dataset_s3_name'),
                        "{}/{}/{}{}.json".format(
                          os.getenv('path_to_folder'),
                          output_data_file_name,
                          output_data_file_name,
                          chunk_id
                        )
                      )
    os.remove(local_filename)


def create_false_data(output_data_file_name, number_of_copies):

    whole_chunks = round(number_of_copies/chunk_size)
    last_chunk = number_of_copies - (whole_chunks*chunk_size)
    count = 100000000000000000000000
    chunk_id = 1

    for x in range(0, whole_chunks):
        write_data_and_upload_to_s3(output_data_file_name, count, chunk_size, chunk_id)
        chunk_id += 1

    write_data_and_upload_to_s3(output_data_file_name, count, last_chunk, chunk_id)
    # wait_for_file_in_s3(os.getenv('dataset_s3_name'), "{}/".format(os.getenv('path_to_folder')))


create_false_data(small_dataset, 1000)
create_false_data(large_dataset, 5000000)
create_hive_on_s3_data(os.getenv('dataset_s3_name'), "{}/{}/".format(os.getenv('path_to_folder'), small_dataset), small_dataset)
create_hive_on_s3_data(os.getenv('dataset_s3_name'), "{}/{}/".format(os.getenv('path_to_folder'), large_dataset), large_dataset)
