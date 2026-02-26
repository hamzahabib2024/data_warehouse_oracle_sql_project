
-------------------------------------------------------------------------------------------------------------------------
-- FOR CRM_CUST_INFO TABLE
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(TRIM(CST_GNDR)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(CST_GNDR)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT 
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last 
    FROM BRONZE_USER.crm_cust_info
)t
WHERE t.flag_last = 1;


-------------------------------------------------------------------------------------------------------------------------

-- FOR CRM_PRD_INFO TABLE

SELECT 
    prd_id,
    REPLACE(SUBSTR(prd_key, 1,5), '-', '_') AS cat_id,
    SUBSTR(prd_key, 7) AS prd_key,
    prd_nm,
    NVL(PRD_COST, 0) AS prd_cost,
    CASE
        WHEN UPPER(TRIM(PRD_LINE)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(PRD_LINE)) = 'T' THEN 'Touring'
        WHEN UPPER(TRIM(PRD_LINE)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(PRD_LINE)) = 'S' THEN 'Other Sales'
        ELSE 'n/a'
    END AS prd_line,
    prd_start_dt,
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS prd_end_dt
FROM BRONZE_USER.CRM_PRD_INFO;



--------------------------------------------------------------------------------------------------------------------------

-- FOR CRM_SALES_DETAILS TABLE

SELECT 
    sls_ord_num,
    SUBSTR(sls_prd_key, 1, 7) AS sls_prd_key,
    sls_cust_id,
    CASE
        WHEN SLS_ORDER_DT = 0 OR LENGTH(SLS_ORDER_DT) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(SLS_ORDER_DT), 'YYYYMMDD')
    END AS sls_order_dt,
    CASE
        WHEN SLS_SHIP_DT = 0 OR LENGTH(SLS_SHIP_DT) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(SLS_SHIP_DT), 'YYYYMMDD')
    END AS sls_ship_dt,
    CASE
        WHEN SLS_DUE_DT = 0 OR LENGTH(SLS_DUE_DT) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(SLS_DUE_DT), 'YYYYMMDD')
    END AS sls_due_dt,
    CASE
        WHEN SLS_SALES IS NULL OR SLS_SALES <= 0 OR SLS_SALES != SLS_QUANTITY * ABS(SLS_PRICE)
        THEN SLS_QUANTITY * ABS(SLS_PRICE)
        ELSE SLS_SALES
    END AS SLS_SALES,
    SLS_QUANTITY,
    CASE
        WHEN SLS_PRICE IS NULL OR SLS_PRICE <= 0 
        THEN SLS_SALES / NULLIF(ABS(SLS_QUANTITY),0)
        ELSE ABS(SLS_PRICE)
    END AS SLS_PRICE

FROM BRONZE_USER.CRM_SALES_DETAILS;


---------------------------------------------------------------------------------------------------------------------------------
-- FOR ERP_CUST_AZ12 TABLE

SELECT 
    CASE 
        WHEN CID LIKE 'NAS%' THEN SUBSTR(CID, 4, LENGTH(CID))
        ELSE CID
    END AS cid,
    CASE 
        WHEN BDATE > SYSDATE THEN NULL
        ELSE BDATE
    END AS bdate,
    CASE
        WHEN UPPER(TRIM(GEN)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(GEN)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM BRONZE_USER.ERP_CUST_AZ12;

---------------------------------------------------------------------------------------------------------------------------------
-- FOR ERP_LOC_A101 TABLE

SELECT 
    REPLACE(CID, '-', '') AS CID,
    CASE 
        WHEN CNTRY IS NULL OR TRIM(CNTRY) = '' THEN N'n/a'
        WHEN UPPER(TRIM(TO_CHAR(CNTRY))) IN ('US', 'USA', 'UNITED STATES') THEN N'United States'
        WHEN UPPER(TRIM(TO_CHAR(CNTRY))) IN ('DE', 'DEU', 'GERMANY') THEN N'Germany'
        ELSE CNTRY
    END AS CNTRY
FROM BRONZE_USER.erp_loc_a101;


-------------------------------------------------------------------------------------------------------------------------
-- FOR ERP_PX_CAT_G1V2 TABLE






SELECT 
    *
FROM BRONZE_USER.CRM_SALES_DETAILS;

SELECT 
    *
FROM BRONZE_USER.ERP_CUST_AZ12;

SELECT
    *
FROM BRONZE_USER.ERP_LOC_A101;


SELECT 
    *
FROM BRONZE_USER.erp_px_cat_g1v2;