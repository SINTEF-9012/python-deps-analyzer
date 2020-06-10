FROM python:latest

RUN apt-get update && apt-get install -y git-core cloc && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["bash", "entrypoint.sh"]
