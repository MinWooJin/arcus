#!/bin/bash

## Get working directory based on the location of this script.
##
## @param $1 location of this script ($0)
## @return working directory
get_working_directory() {
  pushd `dirname $0`/../.. > /dev/null
  CURR_DIR=`pwd`
  popd > /dev/null
  echo $CURR_DIR
}

WORKDIR=$(get_working_directory $0)

if [ -z "$WORKDIR" ]; then
  exit 1
fi

echo "===== git submodule update ====="
pushd $WORKDIR > /dev/null
git submodule init
git submodule update
popd > /dev/null
echo "===== git submodule update end ====="

# server
echo "===== server ======"
echo "===== server ======" >> $WORKDIR/scripts/build.log
pushd $WORKDIR/server > /dev/null
echo "working directory is $WORKDIR/server"
echo "execute autorun file is $WORKDIR/server/config/autorun.sh"
/bin/bash config/autorun.sh 1>> $WORKDIR/scripts/build.log
popd > /dev/null

# clients/c
echo "===== c client ======"
echo "===== c client ======" >> $WORKDIR/scripts/build.log
pushd $WORKDIR/clients/c > /dev/null
echo "working directory is $WORKDIR/clients/c"
echo "execute autorun file is $WORKDIR/clients/c/config/autorun.sh"
/bin/bash config/autorun.sh 1>> $WORKDIR/scripts/build.log
popd > /dev/null

# deps/libevent -- uncomment below if you got libevent from the source
#echo "===== libevent ======"
#pushd $WORKDIR/deps/libevent
#./autogen.sh
#popd

# zookeeper
echo "===== zookeeper ======"
echo "===== zookeeper ======" >> $WORKDIR/scripts/build.log
pushd $WORKDIR/zookeeper > /dev/null
echo "working directory is $WORKDIR/zookeeper"
echo "execute ant in $WORKDIR/zookeeper"
sed -i -e s/,api-report//g build.xml # FIXME it looks like that api-report does not work properly (causing NPE)
ant clean compile_jute bin-package 1>> $WORKDIR/scripts/build.log
popd > /dev/null
pushd $WORKDIR/zookeeper/src/c > /dev/null
echo "working directory is $WORKDIR/zookeeper/src/c"
echo "execute autoreconf in $WORKDIR/zookeeper/src/c"
autoreconf -if 1>> $WORKDIR/scripts/build.log
popd > /dev/null

