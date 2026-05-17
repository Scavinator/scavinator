#!/bin/bash

set -x

FILE=$(mktemp)
for i in {0..32}; do
    printf "%s\n" "CREATE DATABASE \"scavinator_test_$i\" WITH TEMPLATE scavinator_test;" >> $FILE
done
cat $FILE
PGPASSWORD=password psql -f $FILE
