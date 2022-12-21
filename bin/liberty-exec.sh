#!/bin/bash
# echo "PARAMS: $@  bin=${WLP_BIN_DIR} user=${WLP_USER_DIR}"
if [ -z "$WLP_BIN_DIR" ]; then
  echo -e "\nERROR: WLP_BIN_DIR nicht gesetzt!\n"
  exit 1
elif [ -z "$WLP_USER_DIR" ]; then
  echo -e "\nERROR: WLP_USER_DIR nicht gesetzt!\n"
  exit 2
fi
echo "executing: $WLP_BIN_DIR/wlp/bin/server $@"
exec $WLP_BIN_DIR/wlp/bin/server $@

