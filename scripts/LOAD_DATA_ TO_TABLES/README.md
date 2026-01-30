# first of all make the .ctl file
## then use the following cmd command to load the data from csv files to database tables
sqlldr username/password@database control=your_file.ctl log=your_file.log
sqlldr userid=bronze_user/hr@dwhdb control=cust_info.ctl log=cust_info.log

cmd:
sqlldr userid=bronze_user/hr@dwhdb control=crm_cust_info.ctl log=crm_cust_info.log
 sqlldr userid=bronze_user/hr@dwhdb control=erp_px_cat_g1v2.ctl log=erp_px_cat_g1v2.log
