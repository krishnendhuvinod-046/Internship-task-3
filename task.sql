CREATE DATABASE ecommerce_sql_db;
USE ecommerce_sql_db;

CREATE TABLE ecommerce_data (
    InvoiceNo   VARCHAR(20),
    StockCode   VARCHAR(20),
    Description VARCHAR(255),
    Quantity    INT,
    InvoiceDate DATE, 
    UnitPrice   DECIMAL(10, 2),
    CustomerID  INT, 
    Country     VARCHAR(100)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dataset.csv'
INTO TABLE ecommerce_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

UPDATE ecommerce_data
SET InvoiceDate = STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i');

ALTER TABLE ecommerce_data ADD COLUMN Invoice_Date_Only DATE;
UPDATE ecommerce_data SET Invoice_Date_Only = DATE(InvoiceDate);


CREATE VIEW v_clean_sales AS
SELECT
    *
FROM
    ecommerce_data
WHERE
    CustomerID IS NOT NULL;

CREATE OR REPLACE VIEW v_clean_sales AS
SELECT
    *
FROM
    ecommerce_data
WHERE
    CustomerID IS NOT NULL
    AND Quantity > 0
    AND UnitPrice > 0;
    
CREATE OR REPLACE VIEW v_clean_sales AS
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    UnitPrice,
    CustomerID,
    Country,
    (Quantity * UnitPrice) AS Revenue
FROM
    ecommerce_data
WHERE
    CustomerID IS NOT NULL
    AND Quantity > 0
    AND UnitPrice > 0;
    
    


SELECT
    InvoiceNo,
    Description,
    Quantity,
    UnitPrice,
    Revenue
FROM
    v_clean_sales
ORDER BY
    Revenue DESC
LIMIT 10;



SELECT
    Country,
    SUM(Revenue) AS Total_Revenue,
    COUNT(DISTINCT CustomerID) AS Total_Customers
FROM
    v_clean_sales
GROUP BY
    Country
ORDER BY
    Total_Revenue DESC;
    
    
    

SELECT
    CustomerID,
    SUM(Revenue) AS Customer_Total_Revenue
FROM
    v_clean_sales
GROUP BY
    CustomerID
HAVING
    SUM(Revenue) > (
        SELECT
            AVG(Customer_Revenue)
        FROM
            (
                SELECT
                    SUM(Revenue) AS Customer_Revenue
                FROM
                    v_clean_sales
                GROUP BY
                    CustomerID
            ) AS Customer_Aggregates
    )
ORDER BY
    Customer_Total_Revenue DESC;
    
    
    


CREATE INDEX idx_customer_id
ON ecommerce_data (CustomerID);