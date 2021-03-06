CREATE TABLE AREAS 
(
area_id char(5),
area_name varchar2(25) NOT NULL,
area_description varchar2(25),
CONSTRAINT area_pk PRIMARY KEY (area_id),
CONSTRAINT areaName_unique UNIQUE (area_name)
);


CREATE TABLE CLIENTS
(
clientID char (10),
orgname varchar2 (25) NOT NULL,
contact_name varchar2 (25),
contact_email varchar2 (25),
contact_phone char (10),
contact_title varchar2 (25),
city varchar2 (25),
street varchar2 (25),
state char (2),
zip char (5),
corp_pricing_discount number (3,2),
CONSTRAINT clients_pk PRIMARY KEY (clientID),
CONSTRAINT clients_percdiscount_check CHECK (corp_pricing_discount BETWEEN 0 AND 1) --Percentage discount
);


CREATE TABLE CLIENT_SITES
(
siteid char (8),
site_name varchar2 (25) NOT NULL,
street varchar2 (25),
city varchar2 (25),
state char (2),
zip char (5),
clientID char (10) NOT NULL,
area_ID char (5) NOT NULL,
CONSTRAINT client_sites_pk PRIMARY KEY (siteid),
FOREIGN KEY (clientID) REFERENCES CLIENTS (clientID),
FOREIGN KEY (area_ID) REFERENCES AREAS (area_ID)
);


CREATE TABLE ORDERS
(
orderNo char(10),
order_date date,
order_discount number(7,2),
shipping_method varchar2(15) CHECK(shipping_method IN ('Ground', 'Freight', 'Priority', 'Overnight')),
shipping_date date ,
delivery_date date,
order_status varchar2(25) CHECK (order_status IN('in process', 'in transit', 'cancelled', 'fulfilled', 'not fulfilled', 'backordered')),
ord_status_notes varchar2(40),
CONSTRAINT orderNo_pk PRIMARY KEY (orderNo)
);


CREATE TABLE COURSES
(
courseNo char(6),
courseName varchar2(25) NOT NULL,
courseDesc varchar2(40),
internal_cost number(7,2),
course_type varchar2(25),
CONSTRAINT courses_pk PRIMARY KEY (courseNo),
CONSTRAINT courseName_unique UNIQUE (courseName)
);


CREATE TABLE PROBLEM_INCIDENTS
(
incidentNo char(10),
incidentDate date,
reviewDate date,
receivedDate date,
incident_description varchar2(40),
incident_status varchar(20) CHECK (incident_status IN('Open', 'Work in Progress', 'Awaiting Client', 'Resolved', 'Closed')),
CONSTRAINT incidentNo_pk PRIMARY KEY (incidentNo)
);


CREATE TABLE PRODUCT_GROUPS
(
groupID char(5),
groupName varchar2(25)NOT NULL,
numOfCSRs varchar2(25),
CONSTRAINT groupID_pk PRIMARY KEY (groupID),
CONSTRAINT groupName_unique UNIQUE (groupName)
);


CREATE TABLE PRODUCT_LINES
(
lineNo char(6),
lineName varchar2(25) NOT NULL,
line_beginDate date,
line_notes varchar2(25),
line_status varchar2(25),
line_retireDate date,
groupid char (5),
CONSTRAINT lineNo_pk PRIMARY KEY (lineNo),
CONSTRAINT lineName_unique UNIQUE (lineName)
);


CREATE TABLE BRANCHES
(
BranchNo char (5),
BranchName varchar2 (25) NOT NULL,
type varchar2 (5) CHECK (type IN ('local', 'main')),
street varchar2 (25),
city varchar2 (25),
state char (2),
zip char(5),
Main_branchno char(5),
CONSTRAINT branches_pk PRIMARY KEY (BranchNo),
CONSTRAINT BranchName_unique UNIQUE (BranchName)
); 


CREATE TABLE EMPLOYEES
(
empID char(10),
lname varchar2(25)NOT NULL,
fname varchar2(25)NOT NULL,
DOB date NOT NULL,
phone char(10),
SSN char (9),
email varchar2(50),
gender varchar2(20),
street varchar2(25),
city varchar2(25),
state char(2),
zip char(5),
position varchar2(25),
branchNo char(5),
CONSTRAINT SSN_unique UNIQUE (SSN),
CONSTRAINT empID_pk PRIMARY KEY (empID),
FOREIGN KEY (branchNo) REFERENCES BRANCHES (branchNo)
);


CREATE TABLE CSR_EMP
(
empID char(10),
csr_status varchar2(25),
seniority_rank varchar2(10) CHECK (seniority_rank IN ('Senior','Junior','Associate')),
actual_sales number(10,2),
numOfClients number(10),
numofAreas number(10),
CONSTRAINT csrID_pk PRIMARY KEY (empID),
FOREIGN KEY (empID) REFERENCES EMPLOYEES (empID)
);


CREATE TABLE FUNCTIONAL_MANAGERS
(
empID char(10),
mgr_type char(5),
CONSTRAINT functID_pk PRIMARY KEY (empID),
FOREIGN KEY (empID) REFERENCES EMPLOYEES (empID)
);


CREATE TABLE PERSONNEL_MANAGERS
(
empID char(10),
yrs_exp number(2),
CONSTRAINT pers_pk PRIMARY KEY (empID),
FOREIGN KEY (empID) REFERENCES EMPLOYEES (empID)
);


CREATE TABLE PRODLINE_MANAGERS
(
empID char(10),
prod_lineNo char(6),
CONSTRAINT line_pk PRIMARY KEY (empID),
FOREIGN KEY (empID) REFERENCES EMPLOYEES (empID),
FOREIGN KEY (prod_lineNo) REFERENCES PRODUCT_LINES (lineNo)
);


CREATE TABLE HOURLY_EMPLOYEES
(
empID char(10),
wage_rate number(5,2),
CONSTRAINT hour_pk PRIMARY KEY (empID),
FOREIGN KEY (empID) references EMPLOYEES (empID)
);

CREATE TABLE SALARY_EMPLOYEES
(
empID char(10),
salary number(10,2),
CONSTRAINT sal_pk PRIMARY KEY (empID),
FOREIGN KEY (empID) references EMPLOYEES (empID)
);


CREATE TABLE REGIONS
(
regionID char(5),
regionName varchar2 (25),
mgr_id char(10),
CONSTRAINT regions_pk PRIMARY KEY (regionID),
FOREIGN KEY (mgr_id) REFERENCES PERSONNEL_MANAGERS (empID)
);


CREATE TABLE MAIN_BRANCHES
(
BranchNo char (5),
regionID char (5) NOT NULL,
CONSTRAINT main_branches_pk PRIMARY KEY (BranchNo),
FOREIGN KEY (branchNo) REFERENCES BRANCHES(branchNo),
FOREIGN KEY (regionID) REFERENCES REGIONS(regionID)
);

ALTER TABLE BRANCHES 
ADD CONSTRAINT mainbranch_fk 
FOREIGN KEY (Main_branchno) REFERENCES MAIN_BRANCHES (BranchNo);


CREATE TABLE TRAINING_SESSIONS
(
sessionID char(10),
location varchar2(25),
startDate date,
endDate date,
instructor_id char(10)NOT NULL,
courseNo char(6)NOT NULL,
CONSTRAINT sessionID_pk PRIMARY KEY (sessionID),
FOREIGN KEY (instructor_id) REFERENCES EMPLOYEES (empID),
FOREIGN KEY (courseNo) REFERENCES COURSES (courseNo)
);


CREATE TABLE TAKE_TRAINING
(
empID char(10),
sessionID char(10),
CONSTRAINT take_training_pk PRIMARY KEY (empID, sessionID),
FOREIGN KEY (empID) REFERENCES EMPLOYEES (empID),
FOREIGN KEY (sessionID) REFERENCES TRAINING_SESSIONS (sessionID)
);


CREATE TABLE PRODUCTS
(
prodID char(10),
prodname varchar2(25) NOT NULL,
brand varchar2(25),
avg_costperunit number(7,2) CHECK (avg_costperunit > 0),
launch_date date,
prod_status varchar2(20),
retire_date date,
lineNo char(6),
CONSTRAINT prodID_pk PRIMARY KEY (prodID),
CONSTRAINT prodname_unique UNIQUE (prodname),
FOREIGN KEY (lineNo) REFERENCES PRODUCT_LINES (lineNo)
);


CREATE TABLE ORDER_DETAILS	
(
orderNo char(10),
prodID char(10),
quantity number(5),
unitPrice number(12,2),
prod_discount number(7,2),
CONSTRAINT order_deatils_pk PRIMARY KEY (orderNo, prodID),
FOREIGN KEY (orderNo) REFERENCES ORDERS (orderNo),
FOREIGN KEY (prodID) REFERENCES PRODUCTS (prodID)
);


CREATE TABLE PLACE_ORDERS
(
orderNo char(10),
siteID char(8),
CSR_empID char(10),
CONSTRAINT place_orders_pk PRIMARY KEY (orderNo, siteID, CSR_empID),
FOREIGN KEY (orderNo) REFERENCES ORDERS (orderNo),
FOREIGN KEY (siteID) REFERENCES CLIENT_SITES (siteID),
FOREIGN KEY (CSR_empID) REFERENCES CSR_EMP (empID)
);


CREATE TABLE PROBLEM_COMMENTS
(
incidentNo char(10),
comments varchar2(100),
CONSTRAINT problem_comments_pk PRIMARY KEY (incidentNo, comments),
FOREIGN KEY (incidentNo) REFERENCES PROBLEM_INCIDENTS(incidentNo)
);


CREATE TABLE PROBLEM_ACTION_ITEMS
(
incidentNo char(10),
action_item varchar2(40),
due_date date,
action_status varchar2(25),
CONSTRAINT problem_action_items PRIMARY KEY (incidentNo, action_item),
FOREIGN KEY (incidentNo) REFERENCES PROBLEM_INCIDENTS(incidentNo)
);


CREATE TABLE REPORT_PROBLEMS
(
clientID char(10),
CSR_empID char(10),
incidentNo char(10),
CONSTRAINT report_problems PRIMARY KEY (clientID, CSR_empID, incidentNo),
FOREIGN KEY (clientID) REFERENCES CLIENTS(clientID),
FOREIGN KEY (CSR_empID) REFERENCES CSR_EMP(empID),
FOREIGN KEY (incidentNo) REFERENCES PROBLEM_INCIDENTS(incidentNo)
);


CREATE TABLE TEAMS
(
teamid char(7),
teamName varchar2(25) NOT NULL,
local_workarea varchar2(25),
team_leadID char(10),
CONSTRAINT teamid_pk PRIMARY KEY (teamid),
FOREIGN KEY (team_leadID) REFERENCES EMPLOYEES (empID)
);


CREATE TABLE FORM_TEAMS
(
teamid char(7),
CSR_empID char(10),
CONSTRAINT fomr_teams_pk PRIMARY KEY (teamid, CSR_empID),
FOREIGN KEY (teamid) REFERENCES TEAMS(teamid),
FOREIGN KEY (CSR_empID) REFERENCES CSR_EMP(empID)
);


CREATE TABLE ASSIGN_TEAMS_TO_CLIENTS
(
siteID char(8),
teamID char(7),
begin_date date,
end_date date,
status varchar2(10) CHECK (status IN('active', 'inactive')),
CONSTRAINT assignteam_pk PRIMARY KEY (siteID, teamID),
FOREIGN KEY (siteID) REFERENCES CLIENT_SITES (siteID),
FOREIGN KEY (teamID) REFERENCES TEAMS (teamID)
);


CREATE TABLE VISITLOG
(
visit_date date,
CSR_empID char(10),
siteID char(8),
hours_worked number(4,2),
CONSTRAINT visit_date_pk PRIMARY KEY (visit_date, CSR_empID, siteID),
FOREIGN KEY (CSR_empID) REFERENCES CSR_EMP (empID),
FOREIGN KEY (siteID) REFERENCES CLIENT_SITES (siteID)
);


CREATE TABLE SPECIALIZE
(
groupID char(5),
CSR_empID char(10),
sp_start_date date,
sp_end_date date,
sp_status varchar2(7) CHECK (sp_status IN('active', 'inactive')),
CONSTRAINT special_pk PRIMARY KEY (groupID, CSR_empID),
FOREIGN KEY (CSR_empID) references CSR_EMP (empID),
FOREIGN KEY (groupID) references PRODUCT_GROUPS (groupID)
);


CREATE TABLE SUPERVISE_LINES
(
lineNo char(6),
mgr_id char(10),
sup_start_date date,
sup_end_date date,
supervise_status varchar2(7) CHECK (supervise_status IN('active', 'inactive')) ,
CONSTRAINT super_pk PRIMARY KEY (lineNo, mgr_ID),
FOREIGN KEY (lineNo) REFERENCES PRODUCT_LINES (lineNo),
FOREIGN KEY (mgr_id) REFERENCES PRODLINE_MANAGERS (empID)
);


CREATE TABLE PRODUCT_PRICING
(
prodID char(10),
state char (2),
listPrice number(7,2),
CONSTRAINT price_pk PRIMARY KEY (prodID, state),
FOREIGN KEY (prodID) REFERENCES PRODUCTS (prodID)
);

CREATE TABLE PROMOTIONS
(
promoID char(10),
promoname varchar2(25),
promodescription varchar2(25),
prodID char(10),
mgrID char(10),
CONSTRAINT promoID_pk PRIMARY KEY (promoID),
FOREIGN KEY (prodID) REFERENCES PRODUCTS (prodID),
FOREIGN KEY (mgrID) REFERENCES PRODLINE_MANAGERS (empID)
);

CREATE TABLE PROMOSTATE
(
promoID char(10),
state char(2),
budget number (12,2),
promo_start_date date,
promo_end_date date,
CONSTRAINT promostate_pk PRIMARY KEY (promoID, state),
FOREIGN KEY (promoID) REFERENCES PROMOTIONS (promoID)
);

CREATE TABLE FEEDBACK
(
siteid char (8),
prodID char(10),
commentNo char(6),
comments varchar2(50),
feedback_date date,
CONSTRAINT feedback_pk PRIMARY KEY (commentNo),
FOREIGN KEY (siteID) REFERENCES CLIENT_SITES (siteID),
FOREIGN KEY (prodID) REFERENCES PRODUCTS (prodID)
);

commit;



CREATE SEQUENCE AREA_SEQ  
	INCREMENT BY 1 
START WITH 1001 
MAXVALUE 9999;

CREATE SEQUENCE REGION_SEQ
	INCREMENT BY 1 
START WITH 1001 
MAXVALUE 9999;

CREATE SEQUENCE BRANCH_SEQ
	INCREMENT BY 1 
START WITH 1001 
MAXVALUE 9999;

CREATE SEQUENCE PROMO_SEQ
	INCREMENT BY 1 
START WITH 100000001 
MAXVALUE 999999999;

CREATE SEQUENCE PLINE_SEQ
	INCREMENT BY 1 
START WITH 10001 
MAXVALUE 99999;

CREATE SEQUENCE PGROUP_SEQ
	INCREMENT BY 1 
START WITH 1001 
MAXVALUE 9999;

CREATE SEQUENCE PRODUCT_SEQ
	INCREMENT BY 1 
START WITH 1000001 
MAXVALUE 9999999;

CREATE SEQUENCE CLIENTS_SEQ
	INCREMENT BY 1 
START WITH 100000001 
MAXVALUE 999999999;

CREATE SEQUENCE CLIENTSITE_SEQ
	INCREMENT BY 1 
START WITH 100001
MAXVALUE 999999;

CREATE SEQUENCE INCIDENT_SEQ
	INCREMENT BY 1 
START WITH 100000001
MAXVALUE 999999999;

CREATE SEQUENCE SESSION_SEQ
	INCREMENT BY 1 
START WITH 10000001
MAXVALUE 99999999;

CREATE SEQUENCE COURSE_SEQ
	INCREMENT BY 1 
START WITH 1001
MAXVALUE 9999;

CREATE SEQUENCE ORDERS_SEQ
	INCREMENT BY 1 
START WITH 100000001
MAXVALUE 999999999;

CREATE SEQUENCE EMPLOYEES_SEQ
	INCREMENT BY 1 
START WITH 10000001
MAXVALUE 99999999;

CREATE SEQUENCE COMMENT_SEQ
	INCREMENT BY 1 
START WITH 10001
MAXVALUE 99999;

CREATE SEQUENCE TEAMS_SEQ
	INCREMENT BY 1 
START WITH 100001
MAXVALUE 999999;

commit;



CREATE OR REPLACE TRIGGER AREA_ID_generator
BEFORE INSERT
ON AREAS
FOR EACH ROW

DECLARE
    temp_area_id AREAS.area_id%type;

BEGIN
    	SELECT 'A'||AREA_SEQ.nextval INTO temp_area_id FROM dual;
     	:new.area_id := temp_area_id;
END;
/


CREATE OR REPLACE TRIGGER EMP_ID_generator
BEFORE INSERT
ON EMPLOYEES
FOR EACH ROW

DECLARE
    temp_emp_id employees.empid%type;

BEGIN
    	SELECT 'EM'||EMPLOYEES_SEQ.nextval INTO temp_emp_id FROM dual;
     	:new.empid := temp_emp_id;
END;
/

CREATE OR REPLACE TRIGGER CLIENT_ID_generator
BEFORE INSERT
ON CLIENTS
FOR EACH ROW

DECLARE
    temp_client_id CLIENTS.clientid%type;

BEGIN
    	SELECT 'C'||CLIENTS_SEQ.nextval INTO temp_client_id FROM dual;
     	:new.clientid := temp_client_id;
END;
/


CREATE OR REPLACE TRIGGER BRANCH_No_generator
BEFORE INSERT
ON BRANCHES
FOR EACH ROW

DECLARE
    temp_branchno BRANCHES.branchno%type;

BEGIN
    	SELECT 'B'||BRANCH_SEQ.nextval INTO temp_branchno FROM dual;
     	:new.branchno := temp_branchno;
END;
/


CREATE OR REPLACE TRIGGER CLIENT_SITE_ID_generator
BEFORE INSERT
ON CLIENT_SITES
FOR EACH ROW

DECLARE
    temp_client_site_id CLIENT_SITES.siteid%type;

BEGIN
    	SELECT 'CS'||CLIENTSITE_SEQ.nextval INTO temp_client_site_id FROM dual;
     	:new.siteid := temp_client_site_id;
END;
/

CREATE OR REPLACE TRIGGER REGION_ID_generator
BEFORE INSERT
ON REGIONS
FOR EACH ROW

DECLARE
    temp_region_id REGIONS.regionid%type;

BEGIN
    	SELECT 'R'||REGION_SEQ.nextval INTO temp_region_id FROM dual;
     	:new.regionid := temp_region_id;
END;
/

CREATE OR REPLACE TRIGGER PROMO_ID_generator
BEFORE INSERT
ON PROMOTIONS
FOR EACH ROW

DECLARE
    temp_promo_id PROMOTIONS.promoid%type;

BEGIN
    	SELECT 'P'||PROMO_SEQ.nextval INTO temp_promo_id FROM dual;
     	:new.promoid := temp_promo_id;
END;
/

CREATE OR REPLACE TRIGGER PLINE_ID_generator
BEFORE INSERT
ON PRODUCT_LINES
FOR EACH ROW

DECLARE
    temp_pline_id PRODUCT_LINES.lineNo%type;

BEGIN
    	SELECT 'L'||PLINE_SEQ.nextval INTO temp_pline_id FROM dual;
     	:new.lineNo := temp_pline_id;
END;
/

CREATE OR REPLACE TRIGGER PGROUP_ID_generator
BEFORE INSERT
ON PRODUCT_GROUPS
FOR EACH ROW

DECLARE
    temp_pgroup_id PRODUCT_GROUPS.groupID%type;

BEGIN
    	SELECT 'G'||PGROUP_SEQ.nextval INTO temp_pgroup_id FROM dual;
     	:new.groupID := temp_pgroup_id;
END;
/

CREATE OR REPLACE TRIGGER PRODUCT_ID_generator
BEFORE INSERT
ON PRODUCTS
FOR EACH ROW

DECLARE
    temp_prod_id PRODUCTS.prodID%type;

BEGIN
    	SELECT 'PRD'||PRODUCT_SEQ.nextval INTO temp_prod_id FROM dual;
     	:new.prodID := temp_prod_id;
END;
/

CREATE OR REPLACE TRIGGER INCIDENT_No_generator
BEFORE INSERT
ON PROBLEM_INCIDENTS
FOR EACH ROW

DECLARE
    temp_inc_id PROBLEM_INCIDENTS.incidentNo%type;

BEGIN
    	SELECT 'I'||INCIDENT_SEQ.nextval INTO temp_inc_id FROM dual;
     	:new.incidentNo := temp_inc_id;
END;
/

CREATE OR REPLACE TRIGGER SESSION_ID_generator
BEFORE INSERT
ON TRAINING_SESSIONS
FOR EACH ROW

DECLARE
    temp_sess_id TRAINING_SESSIONS.sessionID%type;

BEGIN
    	SELECT 'TS'||SESSION_SEQ.nextval INTO temp_sess_id FROM dual;
     	:new.sessionID := temp_sess_id;
END;
/

CREATE OR REPLACE TRIGGER COURSE_No_generator
BEFORE INSERT
ON COURSES
FOR EACH ROW

DECLARE
    temp_co_id COURSES.courseNo%type;

BEGIN
    	SELECT 'CO'||COURSE_SEQ.nextval INTO temp_co_id FROM dual;
     	:new.courseNo := temp_co_id;
END;
/

CREATE OR REPLACE TRIGGER ORDER_No_generator
BEFORE INSERT
ON ORDERS
FOR EACH ROW

DECLARE
    temp_o_no ORDERS.orderNo%type;

BEGIN
    	SELECT 'O'||ORDERS_SEQ.nextval INTO temp_o_no FROM dual;
     	:new.orderNo := temp_o_no;
END;
/

CREATE OR REPLACE TRIGGER COMMENT_ID_generator
BEFORE INSERT
ON FEEDBACK
FOR EACH ROW

DECLARE
    temp_f_id FEEDBACK.commentNo%type;

BEGIN
    	SELECT 'F'||COMMENT_SEQ.nextval INTO temp_f_id FROM dual;
     	:new.commentNo := temp_f_id;
END;
/

CREATE OR REPLACE TRIGGER TEAM_ID_generator
BEFORE INSERT
ON TEAMS
FOR EACH ROW

DECLARE
    temp_team_id TEAMS.teamid%type;

BEGIN
    	SELECT 'T'||TEAMS_SEQ.nextval INTO temp_team_id FROM dual;
     	:new.teamid := temp_team_id;
END;
/

commit;
