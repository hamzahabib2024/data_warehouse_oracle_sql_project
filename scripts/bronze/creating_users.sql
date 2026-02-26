/*
Note: 
  1. First of all create the database using the dbca
  2. then after creating the new database with the name "dwhdb" and the hr
  3. now in the oracle there is 1 schema for 1 user 
  4. so for that i created 3 users
    As:
        a. bronze_user
        b. silver_user
        c. gold_user
Warning:
  once the code is executed the user will be created in the database
* Reexecuting of the code will result in error
*/


--================
--for bronze_user
--================

create user bronze_user
identified by hr
default tablespace users
temporary tablespace temp
quota unlimited on users;

-- Granting previlligies

grant 
    create session,
    create table,
    create view,
    create sequence
to bronze_user;

GRANT
    CREATE PROCEDURE,
    CREATE TRIGGER,
    CREATE TYPE,
    UNLIMITED TABLESPACE
TO bronze_user;

GRANT 
    SELECT, INSERT, UPDATE, DELETE
ON silver_user.crm_cust_info
TO bronze_user;

-- GRANT 
--     SELECT, INSERT, UPDATE, DELETE
-- ON gold_user.final_cust_info
-- TO bronze_user;


--================
--for silver_user
--================

create user silver_user
identified by hr
default tablespace users
temporary tablespace temp
quota unlimited on users;

grant 
    create session,
    create table,
    create view,
    create sequence
to silver_user;


GRANT 
    CREATE PROCEDURE,
    CREATE TRIGGER,
    CREATE TYPE,
    UNLIMITED TABLESPACE
TO silver_user;


-- GRANT 
--     SELECT, INSERT, UPDATE, DELETE
-- ON gold_user.final_cust_info
-- TO silver_user;


--================
--for gold_user
--================

create user gold_user
identified by hr
default tablespace users
temporary tablespace temp
quota unlimited on users;

grant 
    create session,
    create table,
    create view,
    create sequence
to gold_user;

GRANT 
    CREATE PROCEDURE,
    CREATE TRIGGER,
    CREATE TYPE,
    UNLIMITED TABLESPACE
TO gold_user;


---------------------------------------------------------------------------------------------------------------------

GRANT 
    ALTER ANY TABLE,
    DROP ANY TABLE,
    EXECUTE ANY PROCEDURE
TO bronze_user;

GRANT 
    ALTER ANY TABLE,
    DROP ANY TABLE,
    EXECUTE ANY PROCEDURE
TO silver_user;

GRANT 
    ALTER ANY TABLE,
    DROP ANY TABLE,
    EXECUTE ANY PROCEDURE
TO gold_user;


