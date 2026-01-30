
options (skip = 1)
LOAD DATA
INFILE 'F:/COURSES/DATABASE/sql-data-warehouse-project-main/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'

TRUNCATE
INTO TABLE CRM_PRD_INFO
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(

    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt date "YYYY-MM-DD" NULLIF prd_start_dt=BLANKS,
    prd_end_dt date "YYYY-MM-DD" NULLIF prd_end_dt=BLANKS
)

