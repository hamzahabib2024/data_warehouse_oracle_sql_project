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





