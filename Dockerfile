# lsstsqre/inituserhome
FROM alpine:latest
RUN  apk add jq
COPY inituserhome.sh /inituserhome
USER root # Must run with privilege
ENTRYPOINT ["/inituserhome"]
