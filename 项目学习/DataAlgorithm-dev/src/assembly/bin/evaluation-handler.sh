#!/bin/bash


parentDir=`dirname $0`
path2=`cd $parentDir;pwd`
root_dir=`dirname $0`
CURPATH=`cd $path2;cd ../;pwd`
echo ${CURPATH}
cd ${CURPATH}

export HADOOP_CONF_DIR=/etc/hadoop/conf/

JAR_PATH=${CURPATH}/lib
JARS="$JAR_PATH/fastjson-1.2.49.jar"

#执行模式：默认是yarn-client
execMode=yarn

mainClass=$1
jobId=$2
logId=$3
jobServiceUrl=$4
json=$execMode"#--#"$5

#日志配置文件
driverLogFileName=log4j-driver.properties
executorLogFileName=log4j-executor.properties
driverLog4jPath=${CURPATH}/conf/${driverLogFileName}
executorLog4jPath=${CURPATH}/conf/${executorLogFileName}
echo "driverLog4jPath=${driverLog4jPath}"
echo "executorLog4jPath=${executorLog4jPath}"

starttimestamp=`date +%s`
startdatetime=`date -d @$starttimestamp  "+%Y-%m-%d %H:%M:%S"`

separator='#--#'
DATA_ALGORITHM=$(ls ${CURPATH}/lib/data-algorithm*.jar)
echo $DATA_ALGORITHM
spark-submit --class com.suntek.algorithm.process.main \
   --master yarn \
   --driver-cores 1 \
   --num-executors 3 \
   --executor-cores 3 \
   --conf "spark.driver.extraJavaOptions=-Dlog4j.configuration=file://${driverLog4jPath} -DmainClass=${mainClass}" \
   --conf "spark.executor.extraJavaOptions=-Dlog4j.configuration=${executorLogFileName}" \
   --conf "spark.shuffle.consolidateFiles=true" \
   --conf "spark.driver.memory=1g" \
   --conf "spark.executor.memory=2g" \
   --conf "spark.memory.fraction=0.8" \
   --conf "spark.memory.storageFraction=0.3" \
   --conf "spark.shuffle.memoryFraction=0.7" \
   --conf "spark.default.parallelism=10" \
   --conf "spark.yarn.executor.memoryOverhead=2g" \
   --conf "spark.task.cpus=1" \
   --conf "spark.port.maxRetries=500" \
   --files ${driverLog4jPath},${executorLog4jPath} \
   --jars $JARS \
   $DATA_ALGORITHM "${jobId}${separator}${logId}${separator}${jobServiceUrl}${separator}${json}"

endtimestamp=`date +%s`
enddatetime=`date -d @$endtimestamp  "+%Y-%m-%d %H:%M:%S"`

sub_time=`expr $endtimestamp - $starttimestamp`
echo "运行结束，at ${enddatetime}，耗时：${sub_time} s"
