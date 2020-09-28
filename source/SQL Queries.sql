SELECT P.INCIDENTNO AS "Incident Number", P.INCIDENT_STATUS AS "Incident Status", P.INCIDENTDATE AS "Incident Date", C.COMMENTS AS "Problem Comments" 
FROM PROBLEM_INCIDENTS P, PROBLEM_COMMENTS C 
WHERE P.INCIDENTNO = C.INCIDENTNO AND P.INCIDENTDATE BETWEEN '01-JUL-19' AND '30-JUL-19' 
AND P.INCIDENT_STATUS = 'Open'
ORDER BY P.INCIDENTDATE;


SELECT SHIPPING_METHOD AS "Shipping Method", to_char(avg(DELIVERY_DATE - SHIPPING_DATE), ‘999.99’) as "AVG Shipping Time",
(CASE WHEN avg(DELIVERY_DATE - SHIPPING_DATE) >= 4 THEN 'Slow'
WHEN avg(DELIVERY_DATE - SHIPPING_DATE) BETWEEN 2 AND 4 THEN 'Average'
WHEN avg(DELIVERY_DATE - SHIPPING_DATE) <= 2 THEN 'Fast'
END) AS "Delivery Speed"
FROM ORDERS
GROUP BY SHIPPING_METHOD;


SELECT PL.LINENAME AS "Line Name", count(P.PRODID) AS "Products Sold in Line", to_char(sum(OD.QUANTITY*OD.UNITPRICE), '$9,999,999.99') AS "Total Revenue From Product",
RANK() OVER (PARTITION BY 'Line Name' ORDER BY sum(OD.QUANTITY*OD.UNITPRICE) desc) AS "Sales Rank"
FROM ORDER_DETAILS OD, Products P, PRODUCT_LINES PL WHERE OD.PRODID = P.PRODID AND P.LINENO = PL.LINENO
GROUP BY PL.LINENAME;


SELECT C.CLIENTID AS "ClientID", C.ORGNAME "Organization", SUM(QUANTITY * UNITPRICE) AS "Total Revenue"
FROM CLIENTS C
    JOIN CLIENT_SITES CS ON C.CLIENTID = CS.CLIENTID
    JOIN PLACE_ORDERS PO ON CS.SITEID = PO.SITEID
    JOIN ORDERS O ON PO.ORDERNO = O.ORDERNO
    JOIN ORDER_DETAILS OD ON PO.ORDERNO = OD.ORDERNO
WHERE O.ORDER_DATE >= '01-JAN-2019'
GROUP BY C.CLIENTID, C.ORGNAME;


SELECT CSR.EMPID AS "CSR ID", E.FNAME || ' ' || E.LNAME AS "CSR Name", CSR.SENIORITY_RANK AS "Rank", coalesce(COUNT(PO.ORDERNO),0) AS "Num Sales"
FROM CSR_EMP CSR
	JOIN EMPLOYEES E ON CSR.EMPID = E.EMPID
	LEFT JOIN PLACE_ORDERS PO ON CSR.EMPID = PO.CSR_EMPID
WHERE E.CITY = 'Tucson' AND E.STATE = 'AZ'
GROUP BY CSR.EMPID, E.LNAME, E.FNAME, CSR.SENIORITY_RANK
ORDER BY COUNT(PO.ORDERNO) desc;


SELECT EXTRACT(MONTH FROM TS.STARTDATE) AS "Month", COUNT(TT.EMPID) AS "Num Attendees"
FROM TRAINING_SESSIONS TS
	JOIN TAKE_TRAINING TT ON TS.SESSIONID = TT.SESSIONID
WHERE EXTRACT(YEAR FROM TS.STARTDATE) = '2019'
GROUP BY EXTRACT(MONTH FROM TS.STARTDATE)
HAVING COUNT(TT.EMPID) > (
	SELECT AVG(COUNT(TT.EMPID))
	FROM TRAINING_SESSIONS TS
		JOIN TAKE_TRAINING TT ON TS.SESSIONID = TT.SESSIONID
	WHERE EXTRACT(YEAR FROM TS.STARTDATE) < '2019'
	GROUP BY EXTRACT(MONTH FROM TS.STARTDATE));


SELECT PL.LINENAME AS "Line Name", P.PRODNAME AS "Product", P.BRAND AS "BRAND", to_char(P.AVG_COSTPERUNIT, '$999.99') AS "Average Unit Cost"
FROM PRODUCT_LINES PL
    JOIN PRODUCTS P ON PL.LINENO = P.LINENO
WHERE PL.LINENO = 'L10002'
AND P.AVG_COSTPERUNIT >= 4
AND P.LAUNCH_DATE >= PL.LINE_BEGINDATE
ORDER BY PL.LINENO, P.PRODNAME;


SELECT *
FROM
(
	SELECT PS.STATE, EXTRACT(YEAR FROM PS.PROMO_START_DATE) AS Year, PS.Budget
	FROM PROMOSTATE PS
)
PIVOT
(
	AVG(BUDGET)
	FOR Year IN ('2017', '2018', '2019')
);


SELECT C.CLIENTID AS "Client ID", CS.SITE_NAME AS "Client Site Name", COALESCE(COUNT(FT.CSR_EMPID), 0) AS "Num CSRs"
FROM CLIENTS C
	LEFT JOIN CLIENT_SITES CS ON CS.CLIENTID = C.CLIENTID
	JOIN ASSIGN_TEAMS_TO_CLIENTS ATC ON ATC.SITEID = CS.SITEID
	JOIN FORM_TEAMS FT ON FT.TEAMID = ATC.TEAMID
GROUP BY ROLLUP(C.CLIENTID, CS.SITE_NAME);


SELECT V.SITEID AS "Site ID", C.ORGNAME AS "Client Name", CS.SITE_NAME AS "Site Name", sum(V.HOURS_WORKED) AS "Hours Worked"
FROM VISITLOG V, CLIENT_SITES CS, CLIENTS C
WHERE V.SITEID = CS.SITEID AND CS.CLIENTID = C.CLIENTID
AND V.VISIT_DATE BETWEEN '01-MAR-19' AND '31-MAR-19'
GROUP BY V.SITEID, CS.SITE_NAME, C.ORGNAME
ORDER BY sum(V.HOURS_WORKED) desc;