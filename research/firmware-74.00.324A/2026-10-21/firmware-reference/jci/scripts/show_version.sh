#!/bin/sh

FLAVOR=$(cat  /jci/version.ini | grep JCI_SW_FLAVOR | cut -f2 -d"\"" )
VERSION=$(cat  /jci/version.ini | grep JCI_SW_VER | cut -f2 -d"\""  | tr -d '\n')

#logger "=============== $OUTPUT ==============="
echo "=============== $VERSION  Flavor $FLAVOR ==============="
