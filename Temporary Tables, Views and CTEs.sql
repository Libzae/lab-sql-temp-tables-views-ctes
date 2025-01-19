-- 1. •	Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
-- Para crear una vista que resuma la información de alquiler para cada cliente en la base de datos Sakila,
-- debes combinar datos de varias tablas: customer, rental, y posiblemente address si deseas incluir 
-- el correo electrónico del cliente (ya que el correo electrónico se almacena en la tabla customer, 
-- no necesitarás hacer join con address para este requerimiento específico). 
-- La vista incluirá el ID del cliente, nombre, dirección de correo electrónico y el total de 
-- alquileres (rental_count).
CREATE VIEW customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM
    customer c
    LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id;
-- Una vez creada la vista customer_rental_summary, puedes fácilmente consultar esta información 
-- con una sentencia SELECT:
SELECT * FROM customer_rental_summary;

-- 2 •	Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment 
-- table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT
    crs.customer_id,
    crs.name,
    crs.email,
    SUM(p.amount) AS total_paid
FROM
    customer_rental_summary crs
    JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY
    crs.customer_id;

-- Después de crear esta tabla temporal, puedes acceder a los datos con una consulta SELECT, por ejemplo:
SELECT * FROM customer_payment_summary;

-- 3. •	Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary 
-- Table created in Step 2. The CTE should include the customer's name, email address, rental count, 
--  and total amount paid.

WITH CustomerSummaryReport AS (
    SELECT
        crs.customer_id,
        crs.name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM
        customer_rental_summary crs -- Este es el nombre de tu vista de resumen de alquiler
        JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)
SELECT
    *
FROM
    CustomerSummaryReport;
-- Next, using the CTE, create the query to generate the final customer summary report, 
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- this last column is a derived column from total_paid and rental_count.    
    

WITH CustomerSummaryReport AS (
    SELECT
        crs.customer_id,
        crs.name AS customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM
        customer_rental_summary crs
        JOIN customer_payment_summary cps ON crs.customer_id = cps.customer_id
)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count > 0 THEN total_paid / rental_count 
        ELSE 0 
    END AS average_payment_per_rental
FROM
    CustomerSummaryReport;

