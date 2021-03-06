package com.suntek.algorithm.process.fptree

import com.suntek.algorithm.common.conf.Param

/**
  * @author zhy
  * @date 2020-12-14 17:03
  */
object FPTreeHandler {
  def process(param: Param): Unit = {
    val master = param.master
    val relType = param.keyMap("relType").toString
    val dataBaseName = param.keyMap.getOrElse("dataBaseName", "default").toString
    val databaseType = param.keyMap.getOrElse("databaseType", "hive").toString
    val daysSum = param.keyMap.getOrElse("daysSum", "3").toString
    val maxAssembleTotal = param.keyMap.getOrElse("maxAssembleTotal", "25").toString
    val minCount = param.keyMap.getOrElse("minCount", "2").toString
    val minSupport = param.keyMap.getOrElse("minSupport", "0.3").toString
    val aggDays = daysSum
    val days = param.keyMap.getOrElse("days", "90").toString

    val spark_executor_memory_day = param.keyMap.getOrElse("spark.executor.memory.day", "15g").toString
    val spark_port_maxRetries_day = param.keyMap.getOrElse("spark.port.maxRetries.day", "500").toString
    val spark_default_parallelism_day = param.keyMap.getOrElse("spark.default.parallelism.day", "800").toString
    val spark_executor_cores_day = param.keyMap.getOrElse("spark.executor.cores.day", "7").toString

    val spark_executor_memory_result = param.keyMap.getOrElse("spark.executor.memory.result", "15g").toString
    val spark_port_maxRetries_result = param.keyMap.getOrElse("spark.port.maxRetries.result", "500").toString
    val spark_default_parallelism_result = param.keyMap.getOrElse("spark.default.parallelism.result", "800").toString
    val spark_executor_cores_result = param.keyMap.getOrElse("spark.executor.cores.result", "8").toString

    val batchId = param.batchId
    val jsonFPTreeDay =
      s"""${master}#--#{"analyzeModel":{"inputs":[
         |      {"cnName":"","enName":"spark.executor.memory","desc":"","inputVal":"${spark_executor_memory_day}"},
         |      {"cnName":"","enName":"spark.port.maxRetries","desc":"","inputVal":"${spark_port_maxRetries_day}"},
         |      {"cnName":"","enName":"spark.default.parallelism","desc":"","inputVal":"${spark_default_parallelism_day}"},
         |      {"cnName":"","enName":"spark.executor.cores","desc":"","inputVal":"${spark_executor_cores_day}"},
         |      {"cnName":"???????????????","enName":"numPartitions","desc":"???????????????","inputVal":"10"},
         |      {"cnName":"??????????????????","enName":"daysSum","desc":"??????????????????","inputVal":"${daysSum}"},
         |      {"cnName":"????????????","enName":"relType","desc":"????????????,??????imei-imsi,imsi-imsi","inputVal":"${relType}"},
         |      {"cnName":"??????????????????","enName":"maxAssembleTotal","desc":"??????????????????","inputVal":"${maxAssembleTotal}"},
         |      {"cnName":"??????????????????","enName":"minCount","desc":"??????????????????","inputVal":"${minCount}"},
         |      {"cnName":"???????????????","enName":"minSupport","desc":"???????????????","inputVal":"${minSupport}"},
         |      {"cnName":"???????????????","enName":"dataBaseName","desc":"???????????????","inputVal":"${dataBaseName}"},
         |      {"cnName":"???????????????","enName":"databaseType","desc":"???????????????","inputVal":"${databaseType}"}],
         |      "isTag":1,"tagInfo":[],"mainClass":"com.suntek.algorithm.process.fptree.FPTreeDayHandler",
         |      "modelId":8,"modelName":"car-imsi???fptree","stepId":15,"taskId":12,"descInfo":""},
         |      "batchId":${batchId}
         |      }
       """.stripMargin
    val fPTreeDayParam = new Param(jsonFPTreeDay)
    FPTreeDayHandler.process(fPTreeDayParam)

    val jsonFPTreeResult =
      s"""${master}#--#{"analyzeModel":{"inputs":[
         |      {"cnName":"","enName":"spark.executor.memory","desc":"","inputVal":"${spark_executor_memory_result}"},
         |      {"cnName":"","enName":"spark.port.maxRetries","desc":"","inputVal":"${spark_port_maxRetries_result}"},
         |      {"cnName":"","enName":"spark.default.parallelism","desc":"","inputVal":"${spark_default_parallelism_result}"},
         |      {"cnName":"","enName":"spark.executor.cores","desc":"","inputVal":"${spark_executor_cores_result}"},
         |      {"cnName":"???????????????","enName":"numPartitions","desc":"???????????????","inputVal":"500"},
         |      {"cnName":"??????????????????","enName":"aggDays","desc":"??????????????????","inputVal":"${aggDays}"},
         |      {"cnName":"?????????????????????","enName":"days","desc":"?????????????????????","inputVal":"${days}"},
         |      {"cnName":"????????????","enName":"relType","desc":"????????????,??????imei-imsi,imsi-imsi","inputVal":"${relType}"},
         |      {"cnName":"???????????????","enName":"dataBaseName","desc":"???????????????","inputVal":"${dataBaseName}"},
         |      {"cnName":"???????????????","enName":"databaseType","desc":"???????????????","inputVal":"${databaseType}"}],
         |      "isTag":1,"tagInfo":[],"mainClass":"com.suntek.algorithm.process.fptree.FPTreeResultHandler",
         |      "modelId":8,"modelName":"car-car???fptree ????????????","stepId":15,"taskId":12,"descInfo":""},
         |      "batchId":${batchId}
         |      }
       """.stripMargin
    val fPTreeResultParam = new Param(jsonFPTreeResult)
    FPTreeResultHandler.process(fPTreeResultParam)
  }
}
