SET SERVEROUTPUT ON;
EXEC PROCESS_SILVER_LAYER;

BEGIN
   process_silver_layer;
   COMMIT;  -- commit only if procedure finishes without unhandled errors
   EXCEPTION
   WHEN OTHERS THEN
       ROLLBACK;  -- undo changes if something goes wrong
       DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE process_silver_layer AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('>> Starting Silver layer processing...');

-------------------------------------------------------------------------------------------------------------------------
-- FOR CRM_CUST_INFO TABLE

    DBMS_OUTPUT.PUT_LINE('>> Processing CRM_CUST_INFO table...');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE SILVER_USER.crm_cust_info');
    DBMS_OUTPUT.PUT_LINE('>> INSERTING DATA INTO CRM_CUST_INFO TABLE...');

    INSERT INTO SILVER_USER.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_first_name,
        cst_last_name,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
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
    DBMS_OUTPUT.PUT_LINE('>> Processing CRM_PRD_INFO table...');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE SILVER_USER.crm_prd_info');
    DBMS_OUTPUT.PUT_LINE('>> INSERTING DATA INTO CRM_PRD_INFO TABLE...');

    INSERT INTO SILVER_USER.crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
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
    DBMS_OUTPUT.PUT_LINE('>> Processing CRM_SALES_DETAILS table...');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE SILVER_USER.crm_sales_details');
    DBMS_OUTPUT.PUT_LINE('>> INSERTING DATA INTO CRM_SALES_DETAILS TABLE...');

    INSERT INTO SILVER_USER.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
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
    DBMS_OUTPUT.PUT_LINE('>> Processing ERP_CUST_AZ12 table...');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE SILVER_USER.erp_cust_az12');
    DBMS_OUTPUT.PUT_LINE('>> INSERTING DATA INTO ERP_CUST_AZ12 TABLE...');

    INSERT INTO SILVER_USER.erp_cust_az12
    (CID, BDATE, GEN)
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
    DBMS_OUTPUT.PUT_LINE('>> Processing ERP_LOC_A101 table...');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE SILVER_USER.erp_loc_a101');  
    DBMS_OUTPUT.PUT_LINE('>> INSERTING DATA INTO ERP_LOC_A101 TABLE...');

    INSERT INTO SILVER_USER.erp_loc_a101
    (CID, CNTRY)
    SELECT 
        REPLACE(CID, '-', '') AS CID,
        CASE 
            WHEN CNTRY IS NULL OR TRIM(CNTRY) = '' THEN N'n/a'
            WHEN UPPER(TRIM(CNTRY)) IN (N'US', N'USA', N'UNITED STATES') THEN N'United States'
            WHEN UPPER(TRIM(CNTRY)) IN (N'DE', N'DEU', N'GERMANY') THEN N'Germany'
            ELSE CNTRY
        END AS CNTRY
    FROM BRONZE_USER.erp_loc_a101;


    -------------------------------------------------------------------------------------------------------------------------
    -- FOR ERP_PX_CAT_G1V2 TABLE
    DBMS_OUTPUT.PUT_LINE('>> Processing ERP_PX_CAT_G1V2 table...');
    EXECUTE IMMEDIATE ('TRUNCATE TABLE SILVER_USER.erp_px_cat_g1v2');
    DBMS_OUTPUT.PUT_LINE('>> INSERTING DATA INTO ERP_PX_CAT_G1V2 TABLE...');

    INSERT INTO SILVER_USER.erp_px_cat_g1v2 
    (ID, CAT, SUBCAT, MAINTENANCE)
    SELECT
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
    FROM BRONZE_USER.erp_px_cat_g1v2;

    --------------------------------------------------------------------------------------------------------------------------
    DBMS_OUTPUT.PUT_LINE('>> Silver layer processing completed successfully!');


END;
/
