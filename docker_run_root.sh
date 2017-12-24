#!/bin/sh

docker run --rm -i -v $(pwd)/pidos:/home/pidos/pidos -t pidos/build bash -l

