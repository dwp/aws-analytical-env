FROM python:3-alpine

WORKDIR /usr/src/app

RUN pip install --no-cache-dir boto3

COPY create_metrics_data.py ./

ENTRYPOINT [ "python", "./create_metrics_data.py" ]
