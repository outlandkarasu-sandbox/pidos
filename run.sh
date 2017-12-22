#!/bin/sh

docker run --rm -i -v $(pwd)/pidos:/mnt/pidos -t pidos/build bash

