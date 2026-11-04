#!/bin/sh
sed -i.bak -e 's/DEC(1)::/DEC(99)::/' -e 's/planet of the apes/planet of the apes 2/' "$1"
