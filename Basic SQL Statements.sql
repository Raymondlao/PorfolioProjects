-- Create Database
Create database test;
Use test;
Create table stocks(TradeDate CHAR(10),
SPY double,
GLD double,
AMZN double,
GOOG double,
KPTI double,
GILD double,
MPC double);
SELECT * FROM stocks;
INSERT INTO stocks VALUES();
Update stocks SET TradeDate = str_to_date(TradeDate, "%m/%d/%Y");stocks

-- Where Statement - helps limit data
-- WHERE statement -> =, <>, <, >, And, Or, Like, Null, Not Null, In 
-- % is a wildcard 
Select *
From EmployeeDemographics
WHERE FirstName IN ('Jim', 'Michael')

-- Group By, Order By Statements

Select gender, Age, COUNT(Gender)
FROM employeedemographics
GROUP BY Gender, Age