USE sakila;

---------------------------------------------------
-- STEP 1: VIEW - Resumen de alquileres por cliente
---------------------------------------------------

DROP VIEW IF EXISTS v_customer_rental_summary;

CREATE VIEW v_customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    customer_name,
    c.email;

-- Para comprobar (opcional):
-- SELECT * FROM v_customer_rental_summary LIMIT 10;



---------------------------------------------------
-- STEP 2: TEMPORARY TABLE - Total pagado por cliente
---------------------------------------------------

DROP TEMPORARY TABLE IF EXISTS tmp_customer_payment_summary;

CREATE TEMPORARY TABLE tmp_customer_payment_summary AS
SELECT
    v.customer_id,
    IFNULL(SUM(p.amount), 0) AS total_paid
FROM v_customer_rental_summary v
LEFT JOIN payment p
    ON v.customer_id = p.customer_id
GROUP BY
    v.customer_id;

-- Para comprobar (opcional):
-- SELECT * FROM tmp_customer_payment_summary LIMIT 10;



---------------------------------------------------
-- STEP 3: CTE + Customer Summary Report final
---------------------------------------------------

WITH customer_summary AS (
    SELECT
        v.customer_name,
        v.email,
        v.rental_count,
        t.total_paid
    FROM v_customer_rental_summary v
    LEFT JOIN tmp_customer_payment_summary t
        ON v.customer_id = t.customer_id
)

SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    CASE
        WHEN rental_count = 0 THEN NULL
        ELSE ROUND(total_paid / rental_count, 2)
    END AS average_payment_per_rental
FROM customer_summary
ORDER BY
    customer_name;
