package com.suntek.algorithm.process.dtw

import com.suntek.algorithm.common.conf.Param
import org.slf4j.{Logger, LoggerFactory}

/**
 * @author zhy
 * @date 2020-12-14 16:37
 */
object DtwHandler {
  val logger: Logger = LoggerFactory.getLogger(this.getClass)
  def process(param: Param): Unit = {
    val master = param.master
    val relType = param.keyMap("relType").toString
    val dataBaseName = param.keyMap.getOrElse("dataBaseName", "default").toString
    val databaseType = param.keyMap.getOrElse("databaseType", "hive").toString
    val minImpactCountDay = param.keyMap.getOrElse("minImpactCountDay", "1").toString
    val minImpactCountResult = param.keyMap.getOrElse("minImpactCountResult", "3").toString
    val days = param.keyMap.getOrElse("days", "60").toString
    val spark_executor_memory_day = param.keyMap.getOrElse("spark.executor.memory.day", "6g").toString
    val spark_port_maxRetries_day = param.keyMap.getOrElse("spark.port.maxRetries.day", "500").toString
    val spark_default_parallelism_day = param.keyMap.getOrElse("spark.default.parallelism.day", "576").toString
    val spark_executor_cores_day = param.keyMap.getOrElse("spark.executor.cores.day", "6").toString

    val spark_executor_memory_result = param.keyMap.getOrElse("spark.executor.memory.result", "20g").toString
    val spark_port_maxRetries_result = param.keyMap.getOrElse("spark.port.maxRetries.result", "500").toString
    val spark_default_parallelism_result = param.keyMap.getOrElse("spark.default.parallelism.result", "900").toString
    val spark_executor_cores_result = param.keyMap.getOrElse("spark.executor.cores.result", "5").toString
    val batchId = param.batchId
    val jsonDtwDay =
      s"""${master}#--#{"analyzeModel":{"inputs":[
         |      {"cnName":"","enName":"spark.executor.memory","desc":"","inputVal":"${spark_executor_memory_day}"},
         |      {"cnName":"","enName":"spark.port.maxRetries","desc":"","inputVal":"${spark_port_maxRetries_day}"},
         |      {"cnName":"","enName":"spark.default.parallelism","desc":"","inputVal":"${spark_default_parallelism_day}"},
         |      {"cnName":"","enName":"spark.executor.cores","desc":"","inputVal":"${spark_executor_cores_day}"},
         |      {"cnName":"??????????????????","enName":"minImpactCount","desc":"??????????????????","inputVal":"${minImpactCountDay}"},
         |      {"cnName":"???????????????","enName":"numPartitions","desc":"???????????????","inputVal":"50"},
         |      {"cnName":"????????????","enName":"relType","desc":"????????????,??????imei-imsi,imsi-imsi","inputVal":"${relType}"},
         |      {"cnName":"???????????????","enName":"dataBaseName","desc":"???????????????","inputVal":"${dataBaseName}"},
         |      {"cnName":"???????????????","enName":"databaseType","desc":"???????????????","inputVal":"${databaseType}"}],
         |      "isTag":1,"tagInfo":[],"mainClass":"com.suntek.algorithm.process.dtw.DtwDayHandler",
         |      "modelId":8,"modelName":"DTW","stepId":15,"taskId":12, "descInfo":""},
         |      "batchId":$batchId}
       """.stripMargin
    logger.info(jsonDtwDay)
    val dtwDayParam = new Param(jsonDtwDay)
    DtwDayHandler.process(dtwDayParam)
    val jsonDtwResult =
      s"""${master}#--#{"analyzeModel":{"inputs":[
         |      {"cnName":"","enName":"spark.executor.memory","desc":"","inputVal":"${spark_executor_memory_result}"},
         |      {"cnName":"","enName":"spark.port.maxRetries","desc":"","inputVal":"${spark_port_maxRetries_result}"},
         |      {"cnName":"","enName":"spark.default.parallelism","desc":"","inputVal":"${spark_default_parallelism_result}"},
         |      {"cnName":"","enName":"spark.executor.cores","desc":"","inputVal":"${spark_executor_cores_result}"},
         |      {"cnName":"??????????????????","enName":"minImpactCount","desc":"??????????????????","inputVal":"${minImpactCountResult}"},
         |      {"cnName":"??????????????????","enName":"days","desc":"??????????????????","inputVal":"${days}"},
         |      {"cnName":"???????????????","enName":"numPartitions","desc":"???????????????","inputVal":"500"},
         |      {"cnName":"????????????","enName":"relType","desc":"????????????,??????imei-imsi,imsi-imsi","inputVal":"${relType}"},
         |      {"cnName":"???????????????","enName":"dataBaseName","desc":"???????????????","inputVal":"${dataBaseName}"},
         |      {"cnName":"???????????????","enName":"databaseType","desc":"???????????????","inputVal":"${databaseType}"}],
         |      "isTag":1,"tagInfo":[],"mainClass":"com.suntek.algorithm.process.dtw.DtwResultHandler",
         |      "modelId":8,"modelName":"DTW??????","stepId":15,"taskId":12,"descInfo":""},
         |      "batchId":$batchId}
       """.stripMargin
    logger.info(jsonDtwResult)
    val dtwResultParam = new Param(jsonDtwResult)
    DtwResultHandler.process(dtwResultParam)
  }
}
