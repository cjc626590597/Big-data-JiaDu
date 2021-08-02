set hive.exec.dynamic.partition.mode=nonstrict;

CREATE  TABLE IF NOT EXISTS TB_IMMETEL_DW_RELATION_NOT_NULL_1( 
IMEI STRING,                                   
MSISDN STRING,                                   
DAY_CNT BIGINT,                                
MIN_JGRQSJ STRING,                             
MAX_JGRQSJ STRING)
STORED AS ORC TBLPROPERTIES("ORC.COMPRESS"="SNAPPY");



DROP TABLE IF EXISTS TB_IMMETEL_DW_RELATION_TMP;
CREATE TABLE TB_IMMETEL_DW_RELATION_TMP STORED AS ORC AS
SELECT IMEI,MSISDN,COUNT(DISTINCT STAT_DAY ) AS DAY_CNT,MIN(JGSK) AS MIN_JGRQSJ,
MAX(JGSK) AS MAX_JGRQSJ FROM EFENCE_DETECT_INFO   WHERE  isValidEntity(IMEI,'IMEI')  AND isValidEntity(MSISDN,'PHONE')  AND   STAT_DAY=SUBSTR('@BATCHID@',3,6)
GROUP BY IMEI,MSISDN; 

DROP TABLE IF EXISTS   TB_IMMETEL_DW_RELATION_NOT_NULL_2;
CREATE TABLE TB_IMMETEL_DW_RELATION_NOT_NULL_2 STORED AS ORC  AS 
SELECT T.IMEI,T.MSISDN,T.DAY_CNT ,T.MIN_JGRQSJ ,T.MAX_JGRQSJ    FROM TB_IMMETEL_DW_RELATION_TMP T
LEFT JOIN (SELECT  IMEI,COUNT(1) AS CNT  FROM TB_IMMETEL_DW_RELATION_TMP WHERE REGEXP_EXTRACT(IMEI,"^0*$",0) = IMEI GROUP BY IMEI ) S 
ON T.IMEI =S.IMEI WHERE S.CNT IS NULL
DISTRIBUTE BY RAND(123); 

DROP TABLE IF EXISTS   TB_IMMETEL_DW_RELATION_NOT_NULL_3;
CREATE TABLE TB_IMMETEL_DW_RELATION_NOT_NULL_3 STORED AS ORC  AS 
SELECT T.IMEI,T.MSISDN,SUM(T.DAY_CNT) AS DAY_CNT ,MIN(T.MIN_JGRQSJ) AS MIN_JGRQSJ  ,MAX(T.MAX_JGRQSJ) AS  MAX_JGRQSJ  FROM (
SELECT   T.IMEI,T.MSISDN,T.DAY_CNT ,T.MIN_JGRQSJ ,T.MAX_JGRQSJ    FROM TB_IMMETEL_DW_RELATION_NOT_NULL_2 T 
UNION ALL
SELECT   T.IMEI,T.MSISDN,T.DAY_CNT ,T.MIN_JGRQSJ ,T.MAX_JGRQSJ   FROM   TB_IMMETEL_DW_RELATION_NOT_NULL_1 T 
) T 
GROUP BY IMEI,MSISDN;

DROP TABLE IF EXISTS TB_IMMETEL_DW_RELATION_NOT_NULL_1;
ALTER TABLE TB_IMMETEL_DW_RELATION_NOT_NULL_3 RENAME TO TB_IMMETEL_DW_RELATION_NOT_NULL_1;


DROP TABLE IF EXISTS   TB_IMMETEL_DW_RELATION_DIFF;
CREATE TABLE TB_IMMETEL_DW_RELATION_DIFF  STORED AS ORC  AS 
SELECT T.IMEI,T.MSISDN AS MSISDN_A,T.DAY_CNT AS DAY_CNT_A,T.MIN_JGRQSJ AS MIN_JGRQSJ_A,T.MAX_JGRQSJ AS MAX_JGRQSJ_A ,
              S.MSISDN AS MSISDN_B,S.DAY_CNT AS DAY_CNT_B,S.MIN_JGRQSJ AS MIN_JGRQSJ_B,S.MAX_JGRQSJ AS MAX_JGRQSJ_B,
              CEILING(ABS(UNIX_TIMESTAMP(CONCAT("20",T.MAX_JGRQSJ),'yyyyMMddHHmmss') - UNIX_TIMESTAMP(CONCAT("20",S.MAX_JGRQSJ ),'yyyyMMddHHmmss'))/86400) AS TIMEDIFF FROM 
TB_IMMETEL_DW_RELATION_NOT_NULL_1 T JOIN 
TB_IMMETEL_DW_RELATION_NOT_NULL_1 S
ON T.IMEI = S.IMEI AND T.MSISDN < S.MSISDN;

DROP TABLE IF EXISTS   TB_IMMETEL_DW_RELATION_MSISDN2;
CREATE TABLE TB_IMMETEL_DW_RELATION_MSISDN2  STORED AS ORC  AS SELECT  T.* , 0.7*EXP(-1*0.0127*T.TIMEDIFF) + 0.3*(1-(2/(EXP(0.05*(T.DAY_CNT_A+T.DAY_CNT_B))+1)))  AS SIM   FROM  TB_IMMETEL_DW_RELATION_DIFF T ;


DROP TABLE IF EXISTS TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP;
--相似度;
CREATE TABLE TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP  STORED AS ORC AS
SELECT MSISDN_A ,MSISDN_B ,CAST(MAX(SIM) AS DECIMAL(10,2))*100 AS  SCORE , SUM(DAY_CNT_A) + SUM(DAY_CNT_B)  AS TOTAL FROM TB_IMMETEL_DW_RELATION_MSISDN2  GROUP BY MSISDN_A ,MSISDN_B;

DROP TABLE IF EXISTS TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP_1;

CREATE TABLE TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP_1  STORED AS ORC AS 
SELECT  MSISDN_A AS  OBJECT_ID_A, MSISDN_B AS   OBJECT_ID_B, 
 CAST(CONCAT("20",IF(MIN_JGRQSJ_A <MIN_JGRQSJ_B ,MIN_JGRQSJ_A,MIN_JGRQSJ_B)) AS BIGINT)   AS   FIRST_TIME, T.IMEI AS FIRST_DEVICE,  
 CAST(CONCAT("20",IF(MAX_JGRQSJ_A <MAX_JGRQSJ_B ,MAX_JGRQSJ_B,MAX_JGRQSJ_A)) AS BIGINT)   AS  LAST_TIME ,  T.IMEI AS  LAST_DEVICE 
FROM TB_IMMETEL_DW_RELATION_MSISDN2  T;


DROP TABLE IF EXISTS TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP_2;
CREATE  TABLE TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP_2  STORED AS ORC AS
SELECT T.OBJECT_ID_A  ,T.OBJECT_ID_B,T.FIRST_TIME,T.FIRST_DEVICE,S.LAST_TIME,S.LAST_DEVICE  FROM 
(SELECT OBJECT_ID_A  ,OBJECT_ID_B, ROW_NUMBER() OVER(PARTITION BY OBJECT_ID_A,OBJECT_ID_B ORDER BY FIRST_TIME ASC ) AS RN_FIRST,FIRST_TIME,FIRST_DEVICE,LAST_TIME,LAST_DEVICE
FROM TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP_1) T  JOIN
(SELECT OBJECT_ID_A  ,OBJECT_ID_B ,FIRST_TIME,FIRST_DEVICE,ROW_NUMBER() OVER(PARTITION BY OBJECT_ID_A,OBJECT_ID_B ORDER BY LAST_TIME DESC ) AS RN_LAST,LAST_TIME,LAST_DEVICE 
FROM TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP_1 )S
ON T.OBJECT_ID_A=S.OBJECT_ID_A AND T.OBJECT_ID_B = S.OBJECT_ID_B  AND T.RN_FIRST=1 AND T.RN_FIRST=S.RN_LAST;





INSERT OVERWRITE TABLE    DM_RELATION PARTITION( STAT_DATE,REL_TYPE,REL_ID)
SELECT  OBJECT_ID_A , 3 AS  TYPE_A, "" AS OBJECT_ATTR_A ,OBJECT_ID_B, 3 AS TYPE_B,"" AS OBJECT_ATTR_B ,  T.SCORE ,FIRST_TIME,FIRST_DEVICE , LAST_TIME,LAST_DEVICE ,T.TOTAL,""AS REL_ATTR
,SUBSTR('@BATCHID@',1,8) AS STAT_DATE ,'2' AS REL_TYPE ,'08-0003-0003-02' AS REL_ID
FROM  TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP T JOIN
TB_IMMETEL_IMSS_DW_RELATION_MSISDN2_TMP_2 S ON T.MSISDN_A=S.OBJECT_ID_A AND T.MSISDN_B=S.OBJECT_ID_B;





