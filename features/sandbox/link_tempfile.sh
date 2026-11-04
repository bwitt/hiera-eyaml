#!/bin/sh
# keep a hard link to the temporary file so its content can be checked after deletion
ln -f "$1" linked_tempfile.yaml
