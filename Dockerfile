# lsstsqre/inituserhome and lsstsqre/initsmersh
# leave CMD at ["/sis"] to give an agent a home
# set CMD to ["/smersh"] to retire the agent
FROM alpine:latest
RUN  apk add jq
COPY agent.sh sis smersh /
USER root # Must run with privilege
CMD ["/sis"]
