options (skip = 1)
LOAD DATA
INFILE 'F:/COURSES/DATABASE/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/cust_az12.csv'

TRUNCATE
INTO TABLE erp_cust_az12
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    CID,
    BDATE DATE "YYYY-MM-DD",
    GEN  NULLIF GEN = BLANKS
)



