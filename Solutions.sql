-- Answering queries on electoral bonds.
-- 1.Find out how much donors spent on bonds
select sum(Denominations) as "Total Amount bought"
from bonddata as a join donordata as b
on a.unique_key=b.unique_key;
-- 2. Find out total fund politicians got
select sum(Denominations) as "Total Amount received"
from bonddata as a join receiverdata as b
on a.unique_key=b.unique_key;
-- 3. Find out the total amount of unaccounted money received by parties[bonds without
--donors]
select sum(Denominations) as "unaccounted money"
from --[donor receviever , bonddata]
donordata as d right join receiverdata as r
on r.Unique_key=d.Unique_key
join bonddata as b on r.unique_Key=b.Unique_key
where purchaser is Null;
-- 4. Find year wise how much money is spend on bonds
select extract(year from d.PurchaseDate) as "Year", sum(b.Denominations) as"Year wise bond spending"
From donordata as d join bonddata as b
on b.unique_key=d.unique_key group by "Year" 
order by "Year wise bond spending" desc;
-- 5. In which month most amount is spent on bonds
select extract(month from d.PurchaseDate) as "Month",sum(b.Denominations) as "Bond value"
from donordata as d join bonddata as b
on b.unique_key=d.unique_key group by "Month"
Order by "Bond value" desc limit 1;
-- 6. Find out which company bought the highest number of bonds.
select purchaser,count(b.unique_key) as company_bondcount
from donordata d join bonddata as b on d.unique_key=b.unique_key
group by purchaser order by count(b.unique_key) desc limit 1;
-- 7. Find out which company spent the most on electoral bonds.
select purchaser,sum(b.Denominations) as company_spent
from donordata d join bonddata as b on d.unique_key=b.unique_key
group by purchaser order by sum(b.denominations) desc limit 1;
-- 8. List companies which paid the least to political parties.
select purchaser,sum(Denominations) as "Company spending"
from donordata as d join bonddata as b on d.unique_key=b.unique_key
group by purchaser
having sum(denominations) = (
select min(money_spent) from (
select sum(denominations) as money_spent from donordata as d join bonddata as b
on d.unique_key=b.unique_Key group by purchaser) as subquery)
);
-- 9. Which political party received the highest cash?
select partyname,sum(denominations) as "Fund received" from receiverdata as r
join bonddata as b on r.unique_key=b.unique_key
group by partyname order by sum(denominations) desc limit 1;
-- 10. Which political party received the highest number of electoral bonds?
select partyname,count(b.unique_key) as "Bond count" from receiverdata as r
join bonddata as b on r.unique_key=b.unique_key
group by partyname order by count(b.unique_key) desc limit 1;

--  11. Which political party received the least cash?
with spendingcounts as (
select partyname,sum(denominations) as Encashment from receiverdata as r
join bonddata as b on r.unique_key=b.unique_key group by partyname order by sum(denominations)
)select partyname,Encashment as "Fund received"
from spendingcounts where Encashment=(select MIN(Encashment) from spendingcounts);
--  12. Which political party received the least number of electoral bonds?
with spendingcounts as (
select partyname,count(denominations) as Encashment_count from receiverdata as r
join bonddata as b on r.unique_key=b.unique_key group by partyname order by count(denominations)
)select partyname,Encashment_count as "Company spending" from spendingcounts
where Encashment_count=(select MIN(Encashment_count) from spendingcounts);
--  13. Find the 2nd highest donor in terms of amount he paid?
with main as (
select purchaser,sum(denominations) as total from donordata as d
join bonddata as b on d.unique_key=b.unique_Key 
group by purchaser order by sum(denominations)) ,
sub_cte as (select *,dense_rank() over(order by total desc) as ranks from main)
select purchaser,total from sub_cte where ranks=3;
--  14. Find the party which received the second highest donations?
select partyname,sum(denominations) as donations from receiverdata as r
join bonddata as b on r.unique_key=b.unique_key group by partyname order by
sum(denominations) desc limit 1 offset 1;
--  15. Find the party which received the second highest number of bonds?
select partyname,count(b.unique_key) as donations from receiverdata as r
join bonddata as b on r.unique_key=b.unique_key group by partyname order by
sum(denominations) desc limit 1 offset 1 ;
--  16. In which city were the most number of bonds purchased?
with city_bond_count as (
select b.city,count(c.Denominations) as "city bond spending" from donordata as d
join bankdata as b on d.paybranchcode=b.branchcodeno
join bonddata as c on c.unique_key=d.unique_key group by b.city)
select * from city_bond_count where "city bond spending" = 
(select max("city bond spending") from city_bond_count);
--  17. In which city was the highest amount spent on electoral bonds?
WITH city_bond_amt AS (
    SELECT b.city, SUM(c.Denominations) AS "city bond spending"
    FROM donordata d
    JOIN bankdata b ON d.paybranchcode = b.branchcodeNo
    JOIN bonddata c ON c.unique_key = d.unique_key
    GROUP BY b.city
    ORDER BY "city bond spending" DESC
)
SELECT *
FROM city_bond_amt
WHERE "city bond spending" = (
    SELECT MAX("city bond spending")
    FROM city_bond_amt
);

--  18. In which city were the least number of bonds purchased?
WITH city_bond_count AS (
    SELECT b.city, COUNT(c.Denominations) AS "city bond spending"
    FROM donordata d
    JOIN bankdata b ON d.paybranchcode = b.branchcodeNo
    JOIN bonddata c ON c.unique_key = d.unique_key
    GROUP BY b.city
    ORDER BY "city bond spending" DESC
)
SELECT *
FROM city_bond_count
WHERE "city bond spending" = (
    SELECT MIN("city bond spending")
    FROM city_bond_count
);

--  19. In which city were the most number of bonds enchased?
with city_bond_amt as (
select b.city,count(r.unique_key) as "city bond encashment" from 
receiverdata as r join bankdata as b on 
r.paybranchcode=b.branchcodeno
join bonddata as c on c.unique_Key=r.unique_key group by b.city)
select * from city_bond_amt where "city bond encashment" = 
(select max("city bond encashment") from city_bond_amt);
--  20. In which city were the least number of bonds enchased?
with city_bond_amt as (
select b.city,count(r.unique_key) as "city bond encashment" from 
receiverdata as r join bankdata as b on 
r.paybranchcode=b.branchcodeno
join bonddata as c on c.unique_Key=r.unique_key group by b.city)
select * from city_bond_amt where "city bond encashment" = 
(select min("city bond encashment") from city_bond_amt);
 -- 21. List the branches where no electoral bonds were bought; if none, mention it as null.
select city
from bankdata b 
left join donordata d
on b.branchCodeNo=d.PayBranchCode
where d.PayBranchCode is null ;
 -- 22. Break down how much money is spent on electoral bonds for each year.
 -- same as question no 4:
 -- 23. Break down how much money is spent on electoral bonds for each year and provide the year and the amount. Provide values
 -- for the highest and least year and amount
with yearwisebonds as(
select Extract(year from purchasedate),sum(denominations) total_bond_value from donordata as d join bonddata as b
on d.unique_key=b.unique_key group by 1)
select 'Highest year ' as "Note",* from yearwisebonds 
where total_bond_value = (select max(total_bond_value) from yearwisebonds)
union
select 'lowest year ' as "Note" ,* from yearwisebonds 
where total_bond_value = (select min(total_bond_value) from yearwisebonds);


-- 24. Find out how many donors bought the bonds but not donated to any political party?
select count(*) from donordata as d
left join receiverdata as r on r.unique_key=d.unique_key
where r.partyname is null;

-- 25.Find out the money that could have went to PM Office 

select sum(Denominations) as "PM fund" from donordata as d 
left join receiverdata as r on r.unique_key=d.unique_key
join bonddata as b on b.unique_key=d.unique_key
where partyname is null;

-- 26. Find out how many bonds don't have donars associated with it. (k)
 SELECT COUNT(*)
 FROM donordata d
 RIGHT JOIN receiverdata r ON r.Unique_key = d.Unique_key
 WHERE purchaser is NULL
 
/* creating view for employee and donor*/

CREATE VIEW donor_employee_performance AS (
 SELECT Payteller, COUNT(b.unique_key) AS "employee_bond_count", 
 SUM(Denominations) AS "employee_bond_amount"
 FROM donordata d
 JOIN bonddata b ON d.unique_key = b.unique_key
 GROUP BY Payteller
 ORDER BY employee_bond_count, employee_bond_amount
);
select * from donor_employee_performance;

-- 27.Find the employee ID who issued the highest number of bonds 
select payteller,employee_bond_count from donor_employee_performance where
employee_bond_count=(select max(employee_bond_count) from donor_employee_performance);
-- 28.Find the employee ID who issued the bonds for highest amount 
select payteller,employee_bond_amount from donor_employee_performance where
employee_bond_amount=(select max(employee_bond_amount) from donor_employee_performance);
-- 29.Find the employee ID who issued the least number of bonds 
select payteller,employee_bond_count from donor_employee_performance where
employee_bond_count=(select min(employee_bond_count) from donor_employee_performance);
-- 30.Find the employee ID who issued the bonds for least amount
select payteller,employee_bond_amount from donor_employee_performance where
employee_bond_amount=(select min(employee_bond_amount) from donor_employee_performance);
/* creating view for employee  and receiver */
create view receiver_employee_performance as (
select payteller,count(r.unique_key) as "employee_bond_count",
sum(Denominations) as "employee_bond_amount" from receiverdata as r
join bonddata as b on r.unique_key=b.unique_Key group by payteller
);
select * from receiver_employee_performance;
-- 31. Find the employee ID who assisted in redeeming or encashing a bonds in higest number
-- [ receiverdata  bonddata]
select payteller,employee_bond_count from receiver_employee_performance where
employee_bond_count=(select max(employee_bond_count) from receiver_employee_performance);
-- 32. Find the employee ID who assisted in redeeming or encashing bonds for highest amount 
select payteller,employee_bond_amount from receiver_employee_performance where
employee_bond_amount=(select max(employee_bond_amount) from receiver_employee_performance);
-- 33. Find the employee ID who assisted in redeeming or encashing a bonds in least number 
select payteller,employee_bond_count from receiver_employee_performance where
employee_bond_count=(select min(employee_bond_count) from receiver_employee_performance);
-- 34. Find the employee ID who assisted in redeeming or encashing bonds for least amount
select payteller,employee_bond_amount from receiver_employee_performance where
employee_bond_amount=(select min(employee_bond_amount) from receiver_employee_performance);

/* Additonal questions that can be answered 
-- 1. Tell me total how many bonds are created? 
-- 2. Find the count of Unique Denominations provided by SBI? 
-- 3. List all the unique denominations that are available? 
-- 4. Total money received by the bank for selling bonds 
-- 5. Find the count of bonds for each denominations that are created. 
-- 6. Find the count and Amount or Valuation of electoral bonds for each denominations. 
-- 7. Number of unique bank branches where we can buy electoral bond? 
-- 8. How many companies bought electoral bonds?
-- 9. How many companies made political donations?
-- 10. How many number of parties received donations? 
-- 11. List all the political parties that received donations? 
-- 12. What is the average amount that each political party received?
-- 13. What is the average bond value produced by bank?
-- 14. List the political parties which have enchased bonds in different cities? 
-- 15. List the political parties which have enchased bonds in different cities and list the cities in which the bonds have enchased as well?
*/


-- 1. Tell me total how many bonds are created? 
SELECT COUNT(Unique_key) AS "All Bonds Count"
FROM bonddata;

 -- 2. Find the count of Unique Denominations provided by SBI
SELECT COUNT(DISTINCT Denominations) AS "Unique count of amount denominations"
FROM bonddata;

 -- 3. List all the unique denominations that are available?
SELECT DISTINCT Denominations AS "Unique denominations"
FROM bonddata;

 -- 4. Total money recived by the bank for selling bonds
 SELECT SUM(Denominations) AS "Total Amount Received by Bank"
FROM bonddata;

 -- 5. Find the count of bonds for each denominations that are created.
SELECT Denominations, COUNT(Denominations) AS "count of Denominations"
FROM bonddata
GROUP BY Denominations
ORDER BY Denominations;

 -- 6. Find the count and Amount or Valuation of electoral bonds for each denominations.
SELECT Denominations,
       COUNT(Denominations) AS "count of Denominations",
       Denominations * COUNT(Denominations) AS "Total Value"
FROM bonddata
GROUP BY Denominations
ORDER BY Denominations;-- Order by is not needed just for our convinence and understanding
 -- 7. Number of unique bank branches where we can buy electroal bond?
 SELECT COUNT(branchcodeno)
 FROM bankdata;
 -- 8. How many companies bought electoral bonds
SELECT COUNT(DISTINCT purchaser) AS "No of Political Donors"
FROM donordata;

 -- 9. How many companies made political donations
SELECT COUNT(DISTINCT purchaser) AS "No of Political Donors"
FROM donordata d
JOIN receiverdata r ON r.Unique_key = d.Unique_key;

 -- 10. How many number of parties recived donations
SELECT COUNT(DISTINCT Partyname) AS "No of Political Parties"
FROM receiverdata;

 -- 11. List all the political parties that received donations
SELECT DISTINCT Partyname AS "List of political parties"
FROM receiverdata;

 -- 12. What is the average amount that each political party recived
SELECT Partyname, SUM(Denominations) / COUNT(Denominations) AS "Average Amount Received by Political Party"
FROM receiverdata r
JOIN bonddata b ON b.Unique_key = r.Unique_key
GROUP BY Partyname;

-- 13. What is the average bond value produced by bank-- or-- 14 . List the political parties which have enchased bonds in different cities?-- 15 . List the political parties which have enchased bonds in different cities and list the cities in which the bonds have encashed as well?
SELECT SUM(Denominations) / COUNT(Denominations) AS "Average Bond Value"
FROM bonddata;
-- or
 SELECT AVG(Denomination) as "Average bond value"
 FROM bonddata;
 -- 14 . List the political parties which have enchased bonds in different cities?
SELECT Partyname
FROM (
    SELECT Partyname, CITY, COUNT(Unique_key) AS PartyCount
    FROM receiverdata r
    JOIN bankdata b ON r.PayBranchCode = b.branchcodeno
    GROUP BY Partyname, CITY
) AS d
GROUP BY Partyname
HAVING COUNT(CITY) > 1
ORDER BY Partyname;


-- 15 . List the political parties which have enchased bonds in different cities and list the cities in which the bonds have encashed as well?
SELECT Partyname, CITY
FROM (
    SELECT Partyname, CITY, COUNT(Unique_key) AS PartyCount
    FROM receiverdata r
    JOIN bankdata b ON r.PayBranchCode = b.branchcodeno
    GROUP BY Partyname, CITY
) AS d
WHERE Partyname IN (
    SELECT Partyname
    FROM (
        SELECT Partyname, COUNT(DISTINCT CITY) AS CityCount
        FROM receiverdata r
        JOIN bankdata b ON r.PayBranchCode = b.branchcodeno
        GROUP BY Partyname
    ) AS sub
    WHERE CityCount > 1
)
ORDER BY Partyname;

-- Same above query but in CTE form.
WITH PartyCityCounts AS (
    SELECT Partyname, CITY, COUNT(Unique_key) AS PartyCount
    FROM receiverdata r
    JOIN bankdata b ON r.PayBranchCode = b.branchcodeno
    GROUP BY Partyname, CITY
)
SELECT Partyname, CITY
FROM PartyCityCounts
WHERE Partyname IN (
    SELECT Partyname
    FROM PartyCityCounts
    GROUP BY Partyname
    HAVING COUNT(CITY) > 1
)
ORDER BY Partyname;


