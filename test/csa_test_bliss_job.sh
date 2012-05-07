#!/bin/sh

python $SAGA_BLISS_LOCATION/bliss/test/compliance/job/01_*.py $1 && \
python $SAGA_BLISS_LOCATION/bliss/test/compliance/job/02_*.py $1 && \
python $SAGA_BLISS_LOCATION/bliss/test/compliance/job/03_*.py $1 && \
python $SAGA_BLISS_LOCATION/bliss/test/compliance/job/04_*.py $1 && \
python $SAGA_BLISS_LOCATION/bliss/test/compliance/job/05_*.py $1 && echo "[SUCCESS]"

false

