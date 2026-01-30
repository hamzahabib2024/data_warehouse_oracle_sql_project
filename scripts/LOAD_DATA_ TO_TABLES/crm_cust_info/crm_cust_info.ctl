-- Control file for loading cust_info.csv into CRM_CUST_INFO

options (skip = 1)
LOAD DATA
INFILE 'F:/COURSES/DATABASE/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/cust_info.csv'

TRUNCATE
INTO TABLE CRM_CUST_INFO
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
(
  cst_id,
  cst_key,
  cst_firstname,
  cst_lastname,
  cst_marital_status,
  cst_gndr,
  cst_create_date date "YYYY-MM-DD"
)