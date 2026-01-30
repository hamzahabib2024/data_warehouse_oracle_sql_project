options (skip = 1)
LOAD DATA
INFILE 'F:/COURSES/DATABASE/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/loc_a101.csv'

TRUNCATE
INTO TABLE erp_loc_a101
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    CID,
    CNTRY NULLIF CNTRY = BLANKS
)


