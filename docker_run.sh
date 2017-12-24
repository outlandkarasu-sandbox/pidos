#!/bin/sh

docker run --rm -i -u pidos -v $(pwd)/pidos:/home/pidos/pidos -w /home/pidos/pidos -t pidos/build bash -l

