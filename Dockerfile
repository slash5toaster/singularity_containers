FROM debian:latest

RUN apt-get update -y && apt-get install -y apt-utils figlet ddate --no-install-recommends
RUN mkdir -vp /gne/research/scratch
RUN mkdir -vp /gne/home

COPY figlet_entry.sh /

ENTRYPOINT ["/figlet_entry.sh"]
