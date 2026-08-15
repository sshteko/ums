FROM ubuntu:latest
LABEL authors="Sanjeef"

ENTRYPOINT ["top", "-b"]