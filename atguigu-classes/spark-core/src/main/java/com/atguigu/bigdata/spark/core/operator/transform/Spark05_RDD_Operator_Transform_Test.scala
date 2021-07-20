package com.atguigu.bigdata.spark.core.operator.transform

import org.apache.spark.rdd.RDD
import org.apache.spark.{SparkConf, SparkContext}

object Spark05_RDD_Operator_Transform_Test {
  def main(args: Array[String]): Unit = {
    val sparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
    val sc = new SparkContext(sparkConf)

    val rdd = sc.makeRDD(List(1,2,3,4), 2)

    val mapRDD: RDD[Array[Int]] = rdd.glom()

    val maxRDD: RDD[Int] = mapRDD.map(arr => {
      arr.max
    })

    println(maxRDD.collect().sum)
    sc.stop()
  }
}
