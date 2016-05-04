#! /bin/bash

if [ -z "$PACKAGE_BASE" ];
then
  # For testing purposes
  export PACKAGE_BASE="/mnt/galaxyTools/quadui/1.3.6"
  echo "Setting PACKAGE_BASE=$PACKAGE_BASE"
fi

export PATH=$PACKAGE_BASE:$PATH
export CLASSPATH=$PACKAGE_BASE:$CLASSPATH
