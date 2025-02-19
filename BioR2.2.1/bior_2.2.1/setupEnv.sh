# DESC:	This script is designed to setup your UNIX shell for the maven
#		built distribution located as a subfolder under target.
#
# NOTE: From the root of the project folder, run this file via 2 methods:
#
#	1.	"source setupEnv.sh"
# 	2.	". setupEnv.sh"

BASEDIR=`pwd`

# dynamically grab the unzipped distribution folder name
FOLDER=.

# setup env vars
export BIOR_LITE_HOME=$BASEDIR
export PATH=$BIOR_LITE_HOME/bin:$PATH
