#!/bin/bash

echo "Setting up database..."
python3 /usr/src/app/pilot/db_init.py && echo "Database successfully configured." || echo "Error occurred when configuring database."

ttyd bash
