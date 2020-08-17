FROM python:3-alpine

WORKDIR /usr/src/app

RUN apk update; apk add llvm-dev make automake gcc g++ subversion py3-pip

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

COPY create_metrics_data.py ./

ENTRYPOINT [ "python", "./create_metrics_data.py" ]
