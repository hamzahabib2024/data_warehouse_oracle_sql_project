
BEGIN 
    EXECUTE IMMEDIATE 'DROP TABLE crm_cust_info PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/
CREATE TABLE crm_cust_info (
    cst_id NUMBER,
    cst_key NVARCHAR2(50),
    cst_first_name NVARCHAR2(50),
    cst_last_name NVARCHAR2(50),
    cst_marital_status NVARCHAR2(50),
    cst_gndr NVARCHAR2(50),
    cst_create_date DATE
);




BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE crm_prd_info PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/
CREATE TABLE crm_prd_info (
    prd_id NUMBER,
    cat_id NVARCHAR2(50),
    prd_key NVARCHAR2(50),
    prd_nm NVARCHAR2(50),
    prd_cost NUMBER,
    prd_line NVARCHAR2(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);





BEGIN 
    EXECUTE IMMEDIATE 'DROP TABLE crm_sales_details PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/
CREATE TABLE crm_sales_details (
    sls_ord_num	nvarchar2 (50),
    sls_prd_key	nvarchar2(50),
    sls_cust_id	number,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales	number,
    sls_quantity number,
    sls_price number
);




BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE erp_cust_az12 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/
CREATE TABLE erp_cust_az12 (
    cid	nvarchar2(50),
    bdate date,
    gen nvarchar2(50)
);





BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE erp_loc_a101 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/
CREATE TABLE erp_loc_a101 (
    cid nvarchar2 (50),
    cntry nvarchar2(50)
);  --> cntry = country


BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE erp_px_cat_g1v2 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/
CREATE TABLE erp_px_cat_g1v2 (
    id nvarchar2 (50),
    cat nvarchar2(50),
    subcat nvarchar2(50),
    maintenance nvarchar2(50)
);