FROM python:3-alpine

WORKDIR /usr/src/app

RUN apk update
RUN apk add make automake gcc g++ subversion python3-dev
RUN pip3 install numpy

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

COPY create_metrics_data.py ./

ENTRYPOINT [ "python", "./create_metrics_data.py" ]
