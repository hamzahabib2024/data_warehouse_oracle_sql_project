--cust --> customer

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE crm_cust_info PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

create table crm_cust_info (
    cst_id number,
    cst_key nvarchar2(50),
    cst_firstname nvarchar2(50),
    cst_lastname nvarchar2(50),
    cst_marital_status nvarchar2(50),
    cst_gndr nvarchar2(50),
    cst_create_date date
);

-----------------------------------------------------------------------------


BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE crm_prd_info PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

--prd --> product
create table crm_prd_info (
    prd_id number,
    prd_key nvarchar2(50),
    prd_nm nvarchar2(50),
    prd_cost number,
    prd_line nvarchar2(50),
    prd_start_dt date,
    prd_end_dt date
);


---------------------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE crm_sales_details PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

create table crm_sales_details (
    sls_ord_num	nvarchar2 (50),
    sls_prd_key	nvarchar2(50),
    sls_cust_id	number,
    sls_order_dt number,
    sls_ship_dt	number,
    sls_due_dt	number,
    sls_sales	number,
    sls_quantity number,
    sls_price number
);

---------------------------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE erp_cust_az12 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

create table erp_cust_az12 (
    cid	nvarchar2(50),
    bdate date,
    gen nvarchar2(50)
);

---------------------------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE erp_loc_a101 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

create table erp_loc_a101 (
    cid nvarchar2 (50),
    cntry nvarchar2(50)                  --> cntry = country
);

----------------------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE erp_px_cat_g1v2 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

create table erp_px_cat_g1v2 (
    id nvarchar2 (50),
    cat nvarchar2(50),
    subcat nvarchar2(50),
    maintenance nvarchar2(50)
);