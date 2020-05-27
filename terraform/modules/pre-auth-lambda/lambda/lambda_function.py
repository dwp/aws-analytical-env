import os
import datetime
from dateutil.relativedelta import relativedelta
import boto3
from boto3.dynamodb.conditions import Key

table_name = os.environ.get("TABLE_NAME")
if table_name is None:
    message = "Variable TABLE_NAME was not provided."
    print(message)
    raise Exception(message)

region_name = os.environ.get("AWS_REGION")
if region_name is None:
    message = "Variable AWS_REGION was not provided."
    print(message)
    raise Exception(message)

dynamodb = boto3.resource("dynamodb", region_name=region_name)
table = dynamodb.Table(table_name)


def query_user(username):
    print("Query user: " + username)
    response = table.query(KeyConditionExpression=Key("username").eq(username))
    items = response["Items"]
    if items:
        return items[0]
    return None


def create_user(username):
    print("Create user: " + username)
    creation_date = datetime.date.today()
    expiration_date = creation_date + relativedelta(months=3)
    last_logged_in = datetime.datetime.now()
    insert_user(username, creation_date, expiration_date, last_logged_in)


def insert_user(username, creation_date, expiration_date, last_logged_in):
    print(
        "Inserting user: "
        + username
        + " "
        + str(creation_date)
        + " "
        + str(expiration_date)
        + " "
        + str(last_logged_in)
    )
    table.put_item(
        Item={
            "username": username,
            "creation_date": str(creation_date),
            "expiration_date": str(expiration_date),
            "last_logged_in": str(last_logged_in),
        }
    )


def check_user_expired(user):
    expiration_date = datetime.date.fromisoformat(user["expiration_date"])
    if datetime.date.today() >= expiration_date:
        return True
    return False


def user_is_expired(username):
    message = "User " + username + " is expired."
    print(message)
    raise Exception(message)


def update_user_last_logged_in(user):
    username = user["username"]
    print("Update user last logged in: " + username)
    table.update_item(
        Key={"username": username},
        UpdateExpression="SET last_logged_in = :last_logged_in",
        ExpressionAttributeValues={":last_logged_in": str(datetime.datetime.now())},
    )


def lambda_handler(event, context):
    username = event["userName"]
    user = query_user(username)
    if user is None:
        create_user(username)
    else:
        if check_user_expired(user):
            user_is_expired(username)
        else:
            update_user_last_logged_in(user)
    return event
