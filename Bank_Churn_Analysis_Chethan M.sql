CREATE TABLE bank_churn 
(RowNumber INT, 
CustomerId BIGINT, 
Surname TEXT,
CreditScore INT, 
Geography TEXT, 
Gender TEXT,
Age INT,
Tenure INT,
Balance NUMERIC, 
NumOfProducts INT, 
HasCrCard INT, 
IsActiveMember INT, 
EstimatedSalary NUMERIC, 
Exited INT);

SELECT rownumber, customerid, surname, creditscore, geography, gender, age, tenure, balance, numofproducts, hascrcard, isactivemember, estimatedsalary, exited
	FROM public.bank_churn;

1. Demographic Analysis

#Churn_by_Gender

SELECT Gender,Exited,COUNT(*) AS total_customers
FROM bank_churn
GROUP BY Gender, Exited
ORDER BY Gender;

#Churn_by_Geography

SELECT Geography,Exited,COUNT(*) AS total_customers
FROM bank_churn
GROUP BY Geography, Exited
ORDER BY Geography;

#Average_Age_of_Customers_Who_Exited

SELECT Exited,ROUND(AVG(Age),2) AS avg_age
FROM bank_churn
GROUP BY Exited;


2. Financial Analysis

#Average_Balance_by_Exit_Status

SELECT Exited,ROUND(AVG(Balance),2) AS avg_balance
FROM bank_churn
GROUP BY Exited;

#Average_Credit_score_by_Exit_Status

SELECT Exited,ROUND(AVG(CreditScore),2) AS avg_credit_score
FROM bank_churn
GROUP BY Exited;


3. Customer Activity Analysis

#Active_Status_vs_Churn

SELECT IsActiveMember,Exited,COUNT(*) AS total_customers
FROM bank_churn
GROUP BY IsActiveMember, Exited
ORDER BY IsActiveMember;

#Credit_Card_Ownership_Analysis

SELECT HasCrCard,Exited,COUNT(*) AS total_customers
FROM bank_churn
GROUP BY HasCrCard, Exited;

#Number_of_Products_Analysis

SELECT NumOfProducts,Exited,COUNT(*) AS total_customers
FROM bank_churn
GROUP BY NumOfProducts, Exited
ORDER BY NumOfProducts;


##Statistics_Analysis

#Credit_Score_Analysis

SELECT 
    MIN(CreditScore) AS min_credit_score,
    MAX(CreditScore) AS max_credit_score,
    ROUND(AVG(CreditScore),2) AS avg_credit_score,
    PERCENTILE_CONT(0.5)WITHIN GROUP (ORDER BY CreditScore) AS median_credit_score,
    ROUND(STDDEV(CreditScore),2) AS stddev_credit_score
FROM bank_churn;


#Balance_Analysis

SELECT 
    MIN(Balance) AS min_balance,
    MAX(Balance) AS max_balance,
    ROUND(AVG(Balance),2) AS avg_balance,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Balance) AS median_balance,
    ROUND(STDDEV(Balance),2) AS stddev_balance
FROM bank_churn;


##Final_Query_to_identify_the _Churned/Non-churned_Customers

#Identify_Churned_and_Non-Churned_Customers

SELECT CustomerId,Surname,Geography,Gender,Age,Balance,NumOfProducts,IsActiveMember,CreditScore,
CASE 
    WHEN Exited = 1 THEN 'Churned'
    ELSE 'Non-Churned'
    END AS customer_status
FROM bank_churn;

##Window_Function_Analysis 

1.Top_10_Customers_by_Balance

SELECT CustomerId,Surname,Geography,Balance,Exited,
    DENSE_RANK() OVER (ORDER BY Balance DESC) 
	AS balance_rank
FROM bank_churn;

*Trend/Pattern_observed
--High-balance customers are financially valuable.
--Some premium customers still churned.
--Financial value alone does not guarantee retention.

2.Top_5_Customers_by_Estimated_Salary

SELECT CustomerId,Surname,EstimatedSalary,Geography,Exited,
      ROW_NUMBER() OVER (ORDER BY EstimatedSalary DESC) 
	  AS salary_rank
FROM bank_churn;

*Trend/Pattern_observed
--High-income customers may expect premium banking services.
--Customer experience plays a major role in retention.

3.Top_3_Customers_by_Number_of_Products

SELECT CustomerId,Surname,NumOfProducts,Balance,IsActiveMember,
RANK() OVER (
        ORDER BY NumOfProducts DESC
    ) AS product_rank

FROM bank_churn;

*Trend/Pattern_observed
--Customers using multiple products showed stronger engagement.
--Product adoption strongly influences customer loyalty.


##To_Identify_Top_5_Customers_for_Reduced_Interest_Rate

WITH ranked_customers AS (

    SELECT CustomerId,Surname,Geography,Gender,Age,CreditScore,Balance,
	       NumOfProducts,IsActiveMember,EstimatedSalary,Exited,
        RANK() OVER (
            ORDER BY 
                Balance DESC,
                CreditScore DESC,
                NumOfProducts DESC
        ) AS customer_rank

    FROM bank_churn

    WHERE 
        IsActiveMember = 1
        AND Exited = 0
)

SELECT *
FROM ranked_customers
WHERE customer_rank <= 5;


