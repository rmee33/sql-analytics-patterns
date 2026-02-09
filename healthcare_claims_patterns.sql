/*
Healthcare Claims Analytics Patterns (Synthetic Examples)

Purpose:
Demonstrate common healthcare-flavored SQL patterns using synthetic fields.
This file does NOT contain real patient or claims data.

Typical use cases:
- claims-level validation checks
- member/service-level aggregations
- duplicate detection and deduplication
- window function patterns for "latest" and "running totals"

Assumed tables (illustrative):
claims(
  claim_id,
  member_id,
  provider_id,
  service_date,
  paid_amount,
  allowed_amount,
  diagnosis_code,
  procedure_code
)

members(
  member_id,
  dob,
  gender
)

providers(
  provider_id,
  npi,
  specialty
)
*/

--------------------------------------------------------------------------------
-- 1) Data Quality Checks (claims-level)
--------------------------------------------------------------------------------

-- 1A) Null checks for key fields
SELECT *
FROM claims
WHERE claim_id IS NULL
   OR member_id IS NULL
   OR service_date IS NULL
   OR paid_amount IS NULL;

-- 1B) Invalid numeric values
-- Paid amount should not be negative (domain rules vary; adjust as needed)
SELECT *
FROM claims
WHERE paid_amount < 0
   OR allowed_amount < 0;

-- 1C) Future-dated services (often indicates data issues)
SELECT *
FROM claims
WHERE service_date > CURRENT_DATE;

-- 1D) Paid greater than allowed (can be valid in edge cases; often worth review)
SELECT *
FROM claims
WHERE paid_amount > allowed_amount;


--------------------------------------------------------------------------------
-- 2) Referential Integrity / Orphan Checks
--------------------------------------------------------------------------------

-- 2A) Claims with member_id not present in members table
SELECT
  c.claim_id,
  c.member_id
FROM claims c
LEFT JOIN members m
  ON c.member_id = m.member_id
WHERE m.member_id IS NULL;

-- 2B) Claims with provider_id not present in providers table
SELECT
  c.claim_id,
  c.provider_id
FROM claims c
LEFT JOIN providers p
  ON c.provider_id = p.provider_id
WHERE p.provider_id IS NULL;


--------------------------------------------------------------------------------
-- 3) Aggregations (member-level and time-based)
--------------------------------------------------------------------------------

-- 3A) Total paid and allowed by member
SELECT
  member_id,
  COUNT(*) AS claim_count,
  SUM(paid_amount) AS total_paid,
  SUM(allowed_amount) AS total_allowed
FROM claims
GROUP BY member_id
ORDER BY total_paid DESC;

-- 3B) Paid amount by month (useful for trend reporting)
SELECT
  DATE_TRUNC('month', service_date) AS service_month,
  SUM(paid_amount) AS total_paid
FROM claims
GROUP BY DATE_TRUNC('month', service_date)
ORDER BY service_month;

-- 3C) Top procedure codes by total paid
SELECT
  procedure_code,
  COUNT(*) AS claim_count,
  SUM(paid_amount) AS total_paid
FROM claims
GROUP BY procedure_code
ORDER BY total_paid DESC
FETCH FIRST 20 ROWS ONLY;  -- for Postgres/Oracle style; change to LIMIT 20 if needed


--------------------------------------------------------------------------------
-- 4) Duplicate Detection / Deduplication (pattern-based)
--------------------------------------------------------------------------------

/*
Duplicate definitions vary by organization. A common starting point:
Potential duplicate claim lines = same member, same service date, same procedure code,
same paid amount (and sometimes same provider).
*/

-- 4A) Find potential duplicates
SELECT
  member_id,
  service_date,
  procedure_code,
  paid_amount,
  COUNT(*) AS record_count
FROM claims
GROUP BY member_id, service_date, procedure_code, paid_amount
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- 4B) Flag duplicates using ROW_NUMBER
SELECT *
FROM (
  SELECT
    c.*,
    ROW_NUMBER() OVER (
      PARTITION BY member_id, service_date, procedure_code, paid_amount
      ORDER BY claim_id
    ) AS rn
  FROM claims c
) sub
WHERE rn > 1;

-- 4C) Deletion pattern (commented out: use carefully!)
-- DELETE FROM claims
-- WHERE claim_id IN (
--   SELECT claim_id
--   FROM (
--     SELECT
--       claim_id,
--       ROW_NUMBER() OVER (
--         PARTITION BY member_id, service_date, procedure_code, paid_amount
--         ORDER BY claim_id
--       ) AS rn
--     FROM claims
--   ) t
--   WHERE rn > 1
-- );


--------------------------------------------------------------------------------
-- 5) Window Functions (common healthcare analytics patterns)
--------------------------------------------------------------------------------

-- 5A) Most recent service date per member (retain claim_id at row-level)
SELECT *
FROM (
  SELECT
    member_id,
    claim_id,
    service_date,
    paid_amount,
    ROW_NUMBER() OVER (
      PARTITION BY member_id
      ORDER BY service_date DESC, claim_id DESC
    ) AS rn
  FROM claims
) sub
WHERE rn = 1;

-- 5B) Running total of paid amount per member over time
SELECT
  member_id,
  service_date,
  claim_id,
  paid_amount,
  SUM(paid_amount) OVER (
    PARTITION BY member_id
    ORDER BY service_date, claim_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_paid_total
FROM claims
ORDER BY member_id, service_date, claim_id;

-- 5C) Rank top claims by paid amount within each member
SELECT
  member_id,
  claim_id,
  service_date,
  paid_amount,
  RANK() OVER (
    PARTITION BY member_id
    ORDER BY paid_amount DESC
  ) AS paid_rank_within_member
FROM claims;


--------------------------------------------------------------------------------
-- 6) Simple "Report-Ready" Output (example)
--------------------------------------------------------------------------------

/*
Example stakeholder question:
"Which members had high paid amounts in the last 90 days?"
*/

SELECT
  member_id,
  COUNT(*) AS claims_last_90d,
  SUM(paid_amount) AS total_paid_last_90d
FROM claims
WHERE service_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY member_id
HAVING SUM(paid_amount) >= 5000
ORDER BY total_paid_last_90d DESC;
