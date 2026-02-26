


-- =============================================================
--              Checking the table: "crm_cust_info"
-- =============================================================

-- 1. Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    cst_id,
    COUNT(*)
FROM BRONZE_USER.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- Now the problem of the duplicate primary keys has to be handled in the silver layer as per the new logic:

SELECT 
    cst_id,
    COUNT(*)
FROM 
    (SELECT 
        CST_ID,
        CST_KEY,
        CST_FIRSTNAME,
        CST_LASTNAME,
        CST_MARITAL_STATUS,
        CST_GNDR,
        CST_CREATE_DATE,
        ROW_NUMBER() OVER (PARTITION BY CST_ID ORDER BY CST_CREATE_DATE DESC) AS flag_last 
    FROM BRONZE_USER.crm_cust_info)
WHERE flag_last = 1
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;



-- 2. Check for Unwanted Spaces in the cst_key column
-- Expectation: No Results

SELECT 
    cst_key
FROM BRONZE_USER.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- so it is already correct in the data no changes needed.

-- 3. check for the Unwanted Spaces in the cst_firstname and cst_lastname columns
-- Expectation: No Results

SELECT 
    cst_firstname,
    cst_lastname
FROM BRONZE_USER.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) OR cst_lastname != TRIM(cst_lastname);
-- TRIM fuction removes unwanted spaces from the data before and after the string.

-- solution:
SELECT
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname
FROM BRONZE_USER.crm_cust_info;

-- 4. Data Standardization & Consistency Check for cst_marital_status and cst_gndr columns
-- Expectation: Only expected standardized values

SELECT DISTINCT 
    cst_marital_status,
    cst_gndr
FROM BRONZE_USER.crm_cust_info;

-- Observations:
-- cst_marital_status has values like 'S', 'M', AND NULL
-- cst_gndr has values like 'F', 'M', AND NULL
-- Solution: Standardize these values during the silver layer processing.
-- For cst_marital_status:
-- 'S' to 'Single'
-- 'M' to 'Married'
-- NULL to 'n/a'
-- For cst_gndr:
-- 'F' to 'Female'
-- 'M' to 'Male'
-- NULL to 'n/a'

SELECT DISTINCT
    CST_MARITAL_STATUS AS OLD_CST_MARITAL_STATUS,
    CASE
        WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(CST_MARITAL_STATUS)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CST_GNDR AS OLD_CST_GNDR,
    CASE
        WHEN UPPER(TRIM(CST_GNDR)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(CST_GNDR)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr
FROM BRONZE_USER.crm_cust_info;

-------------------------------------------------------------------------------------------------------------------------------

-- =============================================================
--              Checking the table: "crm_prd_info"
-- =============================================================
-- 1. Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT 
    prd_id,
    COUNT(*)
FROM BRONZE_USER.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- there are no duplicates or nulls in the primary key before loading into silver.

-- 2. Check for Unwanted Spaces in the prd_nm column
-- Expectation: No Results
SELECT 
    prd_nm
FROM BRONZE_USER.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- its okay no unwanted spaces.

-- 3. Check for NULLs or Negative Values in prd_cost column
-- Expectation: No Results  
SELECT 
    prd_cost
FROM BRONZE_USER.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- so we have some nulls in the cost column.
-- Solution: Replace NULLs with 0 during silver layer processing USING NVL function.
SELECT 
    NVL(prd_cost, 0) AS prd_cost
FROM BRONZE_USER.crm_prd_info
WHERE prd_cost IS NULL;


-- 4. Data Standardization & Consistency Check for prd_line column
-- Expectation: Only expected standardized values
SELECT DISTINCT 
    prd_line
FROM BRONZE_USER.crm_prd_info;
-- Observations:
-- prd_line has values NULL, R, T, M, S
-- Solution: Standardize these values during the silver layer processing.
-- 'R' to 'Road'
-- 'T' to 'Touring'
-- 'M' to 'Mountain'
-- 'S' to 'Other Sales'
SELECT DISTINCT
    PRD_LINE AS OLD_PRD_LINE,
    CASE
        WHEN UPPER(TRIM(PRD_LINE)) = 'R' THEN 'Road'
        WHEN UPPER(TRIM(PRD_LINE)) = 'T' THEN 'Touring'
        WHEN UPPER(TRIM(PRD_LINE)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(PRD_LINE)) = 'S' THEN 'Other Sales'
        ELSE 'n/a'
    END AS prd_line
FROM BRONZE_USER.crm_prd_info;


-- 5. Check for Invalid Date Orders (prd_start_dt > prd_end_dt)
-- Expectation: No Results
SELECT 
    *
FROM BRONZE_USER.crm_prd_info
-- WHERE prd_end_dt < prd_start_dt
ORDER BY prd_key;

-- SO THERE ARE FEW problemS WITH THE DATES.
-- 1. END DATE IS BEFORE START DATE IN SOME RECORDS.

-- PROPOSED SOLUTION:
-- 1. FIRST OF ALL WE WILL CREATE NEW column USING THE LEAD FUNCTION TO GET THE NEXT START DATE BASED ON THE prd_key ORDERED BY prd_start_dt.
-- 2. THEN WE WILL SET THE prd_end_dt AS ONE DAY BEFORE THE NEXT START DATE

SELECT 
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS next_prd_start_dt
FROM BRONZE_USER.crm_prd_info
ORDER BY prd_key, prd_start_dt;

SELECT 
    prd_start_dt
FROM BRONZE_USER.crm_prd_info
WHERE prd_start_dt IS NULL;
-- THERE ARE NO NULLS IN THE START DATE.


------------------------------------------------------------------------------------------------------------------------



-- =============================================================
--              Checking the table: "crm_sales_details"
-- =============================================================

-- 1. check for the nulls and duplicates in the primary key sls_ord_num
-- Expectation: No Results
SELECT 
    sls_ord_num,
    COUNT(*)
FROM BRONZE_USER.crm_sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1 OR sls_ord_num IS NULL;

SELECT
    SLS_ORD_NUM,
    SLS_PRD_KEY,
    SLS_CUST_ID,
    SLS_ORDER_DT,
    SLS_SHIP_DT,
    SLS_DUE_DT,
    SLS_SALES,
    SLS_QUANTITY,
    SLS_PRICE
FROM BRONZE_USER.crm_sales_details
WHERE sls_ord_num = 'SO51178';

SELECT
    sls_ord_num
FROM BRONZE_USER.crm_sales_details
WHERE SLS_ORD_NUM != TRIM(SLS_ORD_NUM);
-- there are no unwanted spaces.
-- so this column is okay.

-- 2. check for column sls_prd_key
-- Expectation: No Results
-- for unwanted spaces
SELECT
    sls_prd_key
FROM BRONZE_USER.crm_sales_details
WHERE SLS_PRD_KEY != TRIM(SLS_PRD_KEY);
-- it is okay no unwanted spaces.
-- now we only need the first 7 characters from this column as per the requirement.

SELECT
    SUBSTR(sls_prd_key, 1, 7) AS sls_prd_key
FROM BRONZE_USER.crm_sales_details;

-- 3. Check for the column : sls_cust_id   
-- Expectation: No Results
-- for unwantered spaces
select
    sls_cust_id
FROM BRONZE_USER.crm_sales_details
WHERE sls_cust_id != TRIM(sls_cust_id);
-- It is okay no unwanted spaces.

-- for checking nulls
SELECT
    sls_cust_id 
FROM BRONZE_USER.crm_sales_details
WHERE sls_cust_id IS NULL;
-- It is okay no nulls.

-- 4. Check for Invalid Dates in sls_order_dt column
-- Expectation: No Invalid Dates
SELECT
    NULLIF(SLS_ORDER_DT, 0) AS SLS_ORDER_DT
FROM BRONZE_USER.crm_sales_details
WHERE LENGTH(SLS_ORDER_DT) != 8 
OR SLS_ORDER_DT IS NULL
OR SLS_ORDER_DT > 20500101
OR SLS_ORDER_DT < 19000101;

-- NOW FOR THE SLS_SHIP_DT column
SELECT
    NULLIF(SLS_SHIP_DT, 0) AS SLS_SHIP_DT
FROM BRONZE_USER.crm_sales_details
WHERE LENGTH(SLS_SHIP_DT) != 8
OR SLS_SHIP_DT IS NULL
OR SLS_SHIP_DT > 20500101
OR SLS_SHIP_DT < 19000101;

-- NOW FOR THE SLS_DUE_DT column
SELECT
    NULLIF(SLS_DUE_DT, 0) AS SLS_DUE_DT
FROM BRONZE_USER.crm_sales_details
WHERE LENGTH(SLS_DUE_DT) != 8
OR SLS_DUE_DT IS NULL
OR SLS_DUE_DT > 20500101
OR SLS_DUE_DT < 19000101;

-- NOW CHECK FOR THE INVALID ORDER DATES WHERE SHIP DATE IS BEFORE ORDER DATE OR DUE DATE IS BEFORE ORDER DATE.
SELECT
    SLS_ORD_NUM,
    SLS_ORDER_DT,
    SLS_SHIP_DT,
    SLS_DUE_DT
FROM BRONZE_USER.crm_sales_details
WHERE (SLS_SHIP_DT < SLS_ORDER_DT AND SLS_SHIP_DT IS NOT NULL)
OR (SLS_DUE_DT < SLS_ORDER_DT AND SLS_DUE_DT IS NOT NULL);
-- SO WE FOUND NOTHING WRONG WITH THE DATES IN THIS TABLE.

-- SO NOW
-- IT IS THE BUSSINESS RULE THAT
-- 1. SUM OF SALES = PRODUCT OF QUANTITY * PRICE
-- 2. NEGATIVE VALUES, NULLS AND ZERO VALUES ARE NOT ALLOWED IN THE SALES, QUANTITY AND PRICE COLUMNS.

SELECT DISTINCT
    SLS_ORD_NUM,
    SLS_SALES,
    SLS_QUANTITY,
    SLS_PRICE
FROM BRONZE_USER.crm_sales_details
WHERE SLS_SALES != SLS_QUANTITY * SLS_PRICE
OR SLS_SALES <= 0 OR SLS_QUANTITY <= 0 OR SLS_PRICE <= 0
OR SLS_SALES IS NULL OR SLS_QUANTITY IS NULL OR SLS_PRICE IS NULL
ORDER BY SLS_SALES, SLS_QUANTITY, SLS_PRICE;

-- SO IN ORDER TO FIX THIS PROBLEM WE CAN USE THE FOLLOWING LOGIC/ BUSINESS RULES IN THE SILVER LAYER:
-- 1. IF SLS_SALES IS NULL OR SLS_SALES <= 0 THEN CALCULATE SLS_SALES AS SLS_QUANTITY * SLS_PRICE
-- 2. IF PRICE IS NULL OR PRICE <= 0 THEN CALCULATE PRICE AS SLS_SALES / SLS_QUANTITY
-- 3. IF PRICE IS NEGATIVE THEN CONVERT IT TO POSITIVE USING ABS FUNCTION

SELECT DISTINCT
    SLS_ORD_NUM,
    SLS_SALES AS OLD_SLS_SALES,
    SLS_QUANTITY,
    SLS_PRICE AS OLD_SLS_PRICE,

    CASE
        WHEN SLS_SALES IS NULL OR SLS_SALES <= 0 OR SLS_SALES != SLS_QUANTITY * ABS(SLS_PRICE)
        THEN SLS_QUANTITY * ABS(SLS_PRICE)
        ELSE SLS_SALES
    END AS SLS_SALES,

    CASE
        WHEN SLS_PRICE IS NULL OR SLS_PRICE <= 0 
        THEN SLS_SALES / NULLIF(ABS(SLS_QUANTITY),0)
        ELSE ABS(SLS_PRICE)
    END AS SLS_PRICE

FROM BRONZE_USER.crm_sales_details
WHERE SLS_SALES != SLS_QUANTITY * SLS_PRICE
OR SLS_SALES <= 0 OR SLS_QUANTITY <= 0 OR SLS_PRICE <= 0
OR SLS_SALES IS NULL OR SLS_QUANTITY IS NULL OR SLS_PRICE IS NULL
ORDER BY SLS_SALES, SLS_QUANTITY, SLS_PRICE;



---------------------------------------------------------------------------------------------------------------------------

-- =============================================================
--              Checking the table: "erp_cust_az12"
-- =============================================================

SELECT 
    cid,
    CASE 
        WHEN CID LIKE 'NAS%' THEN SUBSTR(CID, 4, LENGTH(CID))
        ELSE CID
    END AS cid_without_prefix,
    BDATE,
    CASE 
        WHEN BBDATE > SYSDATE THEN NULL
        ELSE BDATE
    END AS valid_bdate,
    GEN
FROM BRONZE_USER.erp_cust_az12;



SELECT 
    COUNT(*)
FROM(
SELECT 
    BDATE
FROM BRONZE_USER.erp_cust_az12
WHERE BDATE < TO_DATE('1926-01-01', 'YYYY-MM-DD') OR BDATE > SYSDATE);

SELECT DISTINCT
    GEN,
    CASE 
        WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS standardized_gen
FROM BRONZE_USER.erp_cust_az12;



-----------------------------------------------------------------------------------------------------------------------
-- =============================================================
--              Checking the table: "erp_loc_a101"  
-- =============================================================

SELECT 
    REPLACE(CID, '-', '') AS CID,
    CASE 
        WHEN CNTRY IS NULL OR TRIM(CNTRY) = '' THEN N'n/a'
        WHEN UPPER(TRIM(TO_CHAR(CNTRY))) IN ('US', 'USA', 'UNITED STATES') THEN N'United States'
        WHEN UPPER(TRIM(TO_CHAR(CNTRY))) IN ('DE', 'DEU', 'GERMANY') THEN N'Germany'
        ELSE CNTRY
    END AS CNTRY
FROM BRONZE_USER.erp_loc_a101;

SELECT DISTINCT
   
    CNTRY
FROM BRONZE_USER.erp_loc_a101;

SELECT DISTINCT
     CASE 
        WHEN CNTRY IS NULL OR TRIM(CNTRY) = '' THEN N'n/a'
        WHEN UPPER(TRIM(TO_CHAR(CNTRY))) IN ('US', 'USA', 'UNITED STATES') THEN N'United States'
        WHEN UPPER(TRIM(TO_CHAR(CNTRY))) IN ('DE', 'DEU', 'GERMANY') THEN N'Germany'
        ELSE TRIM(CNTRY)
    END AS CNTRY_NEW
FROM BRONZE_USER.erp_loc_a101;


--------------------------------------------------------------------------------------------------------------------------

-- =============================================================
--              Checking the table: "erp_px_cat_g1v2"   
-- =============================================================

SELECT 
    ID
FROM BRONZE_USER.erp_px_cat_g1v2
WHERE ID IS NULL OR TRIM(ID) = '';

SELECT 
    CAT
FROM BRONZE_USER.erp_px_cat_g1v2
WHERE CAT != TRIM(CAT) OR SUBCAT != TRIM(SUBCAT) OR MAINTENANCE != TRIM(MAINTENANCE);
-- it is okay no unwanted spaces.

SELECT DISTINCT
    CAT
FROM BRONZE_USER.erp_px_cat_g1v2;

SELECT DISTINCT
    SUBCAT
FROM BRONZE_USER.erp_px_cat_g1v2;

SELECT DISTINCT
    MAINTENANCE
FROM BRONZE_USER.erp_px_cat_g1v2;


SELECT
    *
FROM BRONZE_USER.erp_px_cat_g1v2;

SELECT
    *
FROM BRONZE_USER.CRM_PRD_INFO;


SELECT DATA_TYPE 
FROM ALL_TAB_COLUMNS
WHERE TABLE_NAME = 'ERP_LOC_A101'
  AND COLUMN_NAME = 'CNTRY'
  AND OWNER = 'BRONZE_USER';