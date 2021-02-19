#!/bin/sh

set -e
O="lsstsqre"
T="dev"
L="latest"

R1="${O}/inituserhome"
R2="${O}/initsmersh"

I1="${R1}:${T}"
L1="${R1}:${L}"
I2="${R2}:${T}"
L2="${R2}:${L}"

docker build -t ${I1} . --platform=amd64
docker tag ${I1} ${L1}
docker tag ${I1} ${I2}
docker tag ${I1} ${L2}
docker push ${I1}
docker push ${L1}
docker push ${I2}
docker push ${L2}
