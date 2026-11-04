#!/bin/sh
# add a duplicate DEC(ID) on the first run, then remove it and change a value on the retry
if [ -f duplicate_dec_id_added ]; then
  sed -i.bak -e '/^duplicate_key:/d' -e 's/value6/value7/' "$1"
else
  touch duplicate_dec_id_added
  echo 'duplicate_key: DEC(1)::PKCS7[planet of the apes]!' >> "$1"
fi
