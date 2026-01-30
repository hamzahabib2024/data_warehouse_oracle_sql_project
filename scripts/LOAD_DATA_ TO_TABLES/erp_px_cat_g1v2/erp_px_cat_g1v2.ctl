options (skip = 1)
LOAD DATA
INFILE 'F:/COURSES/DATABASE/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_erp/px_cat_g1v2.csv'

TRUNCATE
INTO TABLE erp_px_cat_g1v2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
(
    ID,
    CAT,
    SUBCAT,
    MAINTENANCE
)