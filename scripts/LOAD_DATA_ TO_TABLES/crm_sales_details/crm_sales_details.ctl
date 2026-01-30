
options (skip = 1)
LOAD DATA
INFILE 'F:/COURSES/DATABASE/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'

TRUNCATE
INTO TABLE CRM_SALES_DETAILS
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price NULLIF sls_price = BLANKS
)


