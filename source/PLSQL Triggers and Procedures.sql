CREATE OR REPLACE TRIGGER csr_area_limits_assign_team
    BEFORE INSERT OR UPDATE OF teamID
    ON assign_teams_to_clients
    FOR EACH ROW
DECLARE
    area_count integer;
    CURSOR CSRS IS SELECT csr_empid FROM form_teams
        WHERE teamID = :new.teamID;
BEGIN
    FOR C IN CSRS LOOP
        area_count := 0;   
        SELECT count(distinct area_ID) INTO area_count FROM assign_teams_to_clients 
        NATURAL JOIN client_sites 
        WHERE status = 'active' AND teamID IN (
            SELECT teamID FROM form_teams where csr_empid = C.csr_empid);
        IF area_count >= 5 THEN
            raise_application_error(-20010, 
            'Error: Change not made. Customer service representative '||C.csr_empid||' would have more than 5 areas.'); 
        END IF;
    END LOOP;


END;
/

CREATE OR REPLACE TRIGGER csr_area_limits_form_team
    BEFORE INSERT OR UPDATE
    ON form_teams
    FOR EACH ROW
DECLARE
    area_count integer := 0;
BEGIN  
        SELECT count(distinct area_ID) INTO area_count FROM assign_teams_to_clients 
        NATURAL JOIN client_sites 
        WHERE status = 'active' AND teamID IN (
            SELECT teamID FROM form_teams where csr_empid = :new.csr_empid);
        IF area_count >= 5 THEN
            raise_application_error(-20011, 
            'Error: Change not made. Customer service representative '||:new.csr_empid||' would have more than 5 areas.'); 
        END IF;

END;
/

CREATE OR REPLACE TRIGGER alert_excess_incidents
    BEFORE INSERT OR UPDATE OF clientID
    ON report_problems
    FOR EACH ROW
DECLARE
    month_count integer := 0;
    client_count integer := 0;
    cur_month number(2) := 0;
    cur_year number(4) := 0;

BEGIN
 
        SELECT EXTRACT(month FROM incidentDate), EXTRACT(year FROM incidentDate) INTO cur_month, cur_year
            FROM problem_incidents P LEFT OUTER JOIN report_problems R 
                ON P.incidentNo = R.incidentNo 
                WHERE P.incidentNo = :new.incidentNo;
        SELECT count(incidentNo) INTO month_count 
            FROM problem_incidents 
                WHERE EXTRACT(month FROM incidentDate) = cur_month
                AND EXTRACT(year FROM incidentDate) = cur_year;
        IF month_count >= 5 THEN
            dbms_output.put_line ('Warning: There have been more than 5 incidents during the month of '||cur_month||', '||cur_year||'!');
        END IF;
        SELECT count(distinct incidentNo) INTO client_count FROM problem_incidents 
            NATURAL JOIN report_problems 
            WHERE EXTRACT(month FROM incidentDate) = cur_month
                AND EXTRACT(year FROM incidentDate) = cur_year
                AND clientID = :new.clientID;
        IF client_count >= 1 THEN
            dbms_output.put_line ('Urgent Warning!!! There has been more than 1 incident during the month of '||cur_month||', '||cur_year||' for this client!!');
        END IF;       

END;
/

CREATE OR REPLACE TRIGGER numOfClientSitesandAreas_trig
AFTER INSERT OR DELETE OR UPDATE OF teamID, siteID, status 
ON assign_teams_to_clients

DECLARE
    site_count integer :=0;
    area_count integer :=0;
    CURSOR CSR_cur IS select empID FROM CSR_EMP join FORM_TEAMS 
    ON empID = CSR_empID;

BEGIN

    FOR C IN CSR_cur LOOP
        site_count := 0;
        area_count := 0;
        SELECT COUNT(DISTINCT siteid) INTO site_count  
            FROM ASSIGN_TEAMS_TO_CLIENTS NATURAL JOIN FORM_TEAMS
            where CSR_empID = C.empid
            AND LOWER(status) = 'active'; 
        SELECT count(distinct area_ID) INTO area_count FROM assign_teams_to_clients 
         NATURAL JOIN client_sites 
            WHERE LOWER(status) = 'active' AND teamID IN (
                SELECT teamID FROM form_teams where csr_empid = C.empid);
        UPDATE CSR_EMP SET numOfClients = site_count, numOfAreas = area_count 
        WHERE empID = C.empID;
    END LOOP;

END;
/

CREATE OR REPLACE TRIGGER formTeam_numOfSitesAreas_trig
AFTER INSERT OR DELETE OR UPDATE 
ON form_teams

DECLARE
    site_count integer :=0;
    area_count integer :=0;
    CURSOR CSR_cur IS select empID FROM CSR_EMP join FORM_TEAMS 
    ON empID = CSR_empID;

BEGIN

    FOR C IN CSR_cur LOOP
        site_count := 0;
        area_count := 0;
        SELECT COUNT(DISTINCT siteid) INTO site_count  
            FROM ASSIGN_TEAMS_TO_CLIENTS NATURAL JOIN FORM_TEAMS
            where CSR_empID = C.empid
            AND LOWER(status) = 'active'; 
        SELECT count(distinct area_ID) INTO area_count FROM assign_teams_to_clients 
         NATURAL JOIN client_sites 
            WHERE LOWER(status) = 'active' AND teamID IN (
                SELECT teamID FROM form_teams where csr_empid = C.empid);
        UPDATE CSR_EMP SET numOfClients = site_count, numOfAreas = area_count 
        WHERE empID = C.empID;
    END LOOP;

END;
/

CREATE OR REPLACE TRIGGER groupNumOfCSRs_trig
AFTER INSERT OR DELETE OR UPDATE OF groupID, CSR_empID, sp_status
ON specialize

DECLARE
    CSR_count integer :=0;
    
    CURSOR CUR IS select groupID FROM product_groups;

BEGIN

    FOR C IN CUR LOOP
        CSR_count := 0;
        SELECT COUNT(DISTINCT CSR_empID) INTO CSR_count  
            FROM specialize
            where groupID = C.groupID
            AND LOWER(sp_status) = 'active'; 
        UPDATE product_groups SET numOfCSRs = CSR_count 
        WHERE groupID = C.groupID;
    END LOOP;
END;
/

CREATE OR REPLACE TRIGGER CSRsspecialization_trig
BEFORE INSERT OR UPDATE OF groupID, CSR_empID, sp_status
ON specialize
FOR EACH ROW

DECLARE
    group_count integer :=0;
    
BEGIN

    SELECT COUNT(DISTINCT groupID) INTO group_count  
        FROM specialize
        where CSR_empID = :new.CSR_empID
        AND LOWER(sp_status) = 'active'; 
    IF group_count >= 3 THEN
        dbms_output.put_line ('Warning! This client service representative is specializing in 3 or more groups!');
    END IF;

END;
/

CREATE OR REPLACE TRIGGER MainBranches_trig
BEFORE INSERT OR UPDATE OF main_branchno
ON branches
FOR EACH ROW

DECLARE
    branch_count integer :=0;
    
BEGIN

    IF :new.main_branchno IS NOT NULL THEN
        SELECT COUNT(DISTINCT branchno) INTO branch_count  
         FROM branches
            where main_branchno = :new.main_branchno; 
        IF branch_count >= 25 THEN
            raise_application_error ('-20120', 'Error: This main branch already has 25 or more local branches assigned to it.');
        END IF;
   END IF;  

END;
/

CREATE OR REPLACE TRIGGER TeamCount_trig
BEFORE INSERT OR UPDATE 
ON form_teams
FOR EACH ROW

DECLARE
    CSR_count integer :=0;
    
BEGIN

    SELECT COUNT(DISTINCT CSR_empID) INTO CSR_count  
        FROM form_teams
        where teamID = :new.teamID; 
    IF CSR_count >= 10 THEN
        raise_application_error ('-20160', 'Error: This team already has 10 CSRs assigned to it.');
    END IF;

END;
/

CREATE OR REPLACE PROCEDURE AnnualActualSales_proc (year_p number) AS

sales csr_emp.actual_sales%type;
counter integer;
Cursor CSRs IS select empid from CSR_emp
FOR UPDATE OF actual_sales;
BEGIN

    IF to_char(year_p) > extract(year from sysdate) then
        raise_application_error(-20000, 'The year entered is in the future.');
    END IF;
    
    For C in CSRs Loop       
        sales :=0;      
        SELECT count(orderno) INTO counter
        FROM csr_emp CS left join place_orders PO on CS.empid = PO.csr_empid
        WHERE empid = C.empid;
        IF counter > 0 THEN
            select coalesce(sum((quantity*unitPrice)*(1-prod_discount)),0) into sales 
                FROM order_details OD join orders O ON O.orderno = OD.orderno
                join place_orders P on P.orderno = O.orderno
                where csr_empid = C.empid and extract(year from order_date) = year_p
                group by csr_empid;
        END IF;
            UPDATE csr_emp set actual_sales = sales WHERE CURRENT OF CSRs;
    END LOOP;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        sales := 0;
END;
/

exec AnnualActualSales_proc(2019);
show errors;