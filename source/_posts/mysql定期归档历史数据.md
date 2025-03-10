---
title: mysql定期归档历史数据
author: guz
tags:
  - mysql
  - sql
  - 小工具
categories:
  - 开发
cover: https://www.helloimg.com/i/2024/01/13/65a26ddc09819.jpg
date: 2025-03-05 16:28:15
---
#### 需求背景
mysql中fin_invoice_log表一年稳定增加上千万条数据，导致联合查询性能降低，先需将每前两年的数据归档到历史表中。
例如表中存在2019,2020,2021,2022,2023,2024,2025，当前归档年份 2025年，则将包括2023年在内之前的数据归档到fin_invoice_log_2023中

#### 三种解决方案
##### 解决方案1 
利用event定时调度mysql存储过程实现,具体如下:
~~~
-- 创建存储过程
CREATE PROCEDURE fin_invoice_log_record_archive()
BEGIN
    DECLARE current_month VARCHAR(7);
    DECLARE year_month_limit VARCHAR(50);
    DECLARE archive_table_name VARCHAR(50);
    DECLARE current_year VARCHAR(50);
                
    SET current_year = YEAR(NOW()) - 2;
    SET year_month_limit = MAKEDATE(YEAR(CURDATE()) - 1, 1);
    SET archive_table_name = CONCAT('fin_invoice_log_', current_year);

                SET @sql = CONCAT('CREATE TABLE ', archive_table_name, 'select * from fin_invoice_log where operation_AT < "',year_month_limit,'";');
                PREPARE stmt FROM @sql;
    EXECUTE stmt;
                
                SET @sql = CONCAT('delete from fin_invoice_log where operation_AT <"', year_month_limit, '";');
                PREPARE stmt2 FROM @sql ;
    EXECUTE stmt2;
end;

-- 创建事件调度任务（1年调用一次）,调度也可以使用其他调度框架定时调用以上存储过程
CREATE EVENT fin_invoice_log_archive_event
ON SCHEDULE EVERY 1 YEAR
STARTS CURRENT_TIMESTAMP
DO
CALL fin_invoice_log_record_archive();

~~~

##### 解决方案2 
利用后端代码+定时调度框架去实现，比较容易实现具体不多做展示

##### 解决方案3 
利用后端分库分表去实现按照年度去入库分表，也比较容易不多做展示
