package com.atguigu.bigdata.spark.core.framework.util

import org.apache.spark.SparkContext

object EnvUtil {
  private val scLocal = new ThreadLocal[SparkContext]()

  def put(sc:SparkContext): Unit ={
    scLocal.set(sc)
  }

  def get(): SparkContext ={
    scLocal.get()
  }

  def remove(): Unit ={
    scLocal.remove()
  }
}
