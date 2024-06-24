/* ------------------------------------------------------------ */
/*  Version    : 0.1    							            */
/*  Created On : 21-Jun-2024 23:11:04                           */
/*  Created By : Nikit Gokhale                                  */
/*  DBMS       : PostgreSQL                                     */
/*  Notes      : Script to create Pet Insurance schema          */
/* ------------------------------------------------------------ */

-- Create claims_data table
CREATE TABLE claims_data (
	claim_id INTEGER
);

-- Create audit status data table
CREATE TABLE audit_status (
	claim_id INTEGER,
	claim_audit_status VARCHAR
);

-- Create condition data table
CREATE TABLE condition_data (
	claim_id INTEGER,
	condition_id INTEGER,
	condition_migrated_flag INTEGER,
	condition_type_desc VARCHAR(60),
	condition_type_code VARCHAR(10),
	condition_treatment_start_date TIMESTAMP,
	condition_known_from_date TIMESTAMP,
	condition_claimed_amount NUMERIC,
	condition_net_amount NUMERIC,
	condition_rejected_amount NUMERIC,
	condition_excess_amount NUMERIC
);

-- Load data into claims_data table
COPY claims_data(claim_id)
	FROM '/Users/nikit/Documents/DataAssesment_Allianz/claims_data.csv'
	DELIMITER ','
	CSV HEADER
;

-- Show claims_data table
SELECT * FROM claims_data
;

-- Load data into audit_status data table
COPY audit_status(claim_id, claim_audit_status)
	FROM '/Users/nikit/Documents/DataAssesment_Allianz/audit_status_data.csv'
	DELIMITER ','
	CSV HEADER
;

-- Show audit_status data table
SELECT * FROM audit_status
;

-- Load data into condition_data table
COPY condition_data(claim_id, condition_id, condition_migrated_flag, condition_type_desc, condition_type_code, condition_treatment_start_date, condition_known_from_date, condition_claimed_amount, condition_net_amount, condition_rejected_amount, condition_excess_amount)
	FROM '/Users/nikit/Documents/DataAssesment_Allianz/condition_data.csv'
	DELIMITER ','
	CSV HEADER
;

-- Show condition_data table
SELECT * FROM condition_data
;

-- Join Audit Data table with Claims Data table
SELECT cd.claim_id,
	   ad.claim_audit_status
FROM   claims_data cd
LEFT JOIN audit_status ad ON cd.claim_id  = ad.claim_id
;

-- Join Condition Data table with the Claims Data table
SELECT cd.claim_id,
	   co.condition_id,
	   co.condition_migrated_flag,
	   co.condition_type_desc,
	   co.condition_type_code,
	   co.condition_treatment_start_date,
	   co.condition_known_from_date,
	   co.condition_claimed_amount,
	   co.condition_net_amount,
	   co.condition_rejected_amount,
	   co.condition_excess_amount
FROM claims_data cd
LEFT JOIN condition_data co ON cd.claim_id = co.claim_id
;

-- 1.1
-- Join Audit Data with Claims Data table
-- Also create views to simlify future queries and reusability
CREATE VIEW claims_with_audit AS
SELECT cd.claim_id,
	   ad.claim_audit_status
FROM   claims_data cd
LEFT JOIN audit_status ad ON cd.claim_id  = ad.claim_id
;

-- 1.2
-- Condition data (to incorporate related disease conditions that have been paid on the claims by us as an insurer)
-- Join Condition Data table with the 'claims_with_audit' table
-- Create views to simplyfy future queries and reusability
CREATE VIEW expanded_claims_data AS
SELECT ca.claim_id,
	   ca.claim_audit_status,
	   co.condition_id,
	   co.condition_migrated_flag,
	   co.condition_type_desc,
	   co.condition_type_code,
	   co.condition_treatment_start_date,
	   co.condition_known_from_date,
	   co.condition_claimed_amount,
	   co.condition_net_amount,
	   co.condition_rejected_amount,
	   co.condition_excess_amount
FROM 
	claims_with_audit ca
LEFT JOIN 
	condition_data co ON ca.claim_id = co.claim_id
;

-- Show the expanded_claims_data table
SELECT * FROM expanded_claims_data
;

-- 2.0
-- Present a monthly time series of the total claimed amount with a STARTS_AT for the months from January 2023 to May 2024.
-- Calculate the total claimed amount by month
SELECT DATE_TRUNC('month', condition_treatment_start_date) AS starts_at,
	   SUM(condition_claimed_amount) AS total_claimed_amount
FROM expanded_claims_data
WHERE condition_treatment_start_date BETWEEN '2023-01-01' AND '2024-05-31'
GROUP BY starts_at
ORDER BY starts_at
;


-- Data Integrity Checks
-- Identify and report anomalies
-- 1. Check for missing values in important columns
SELECT COUNT(*) - COUNT(claim_id) AS missing_claim_id,
	   COUNT(*) - COUNT(claim_audit_status) AS missing_audit_status,
	   COUNT(*) - COUNT(condition_treatment_start_date) AS missing_start_date,
	   COUNT(*) - COUNT(condition_claimed_amount) AS missing_claimed_amount
FROM expanded_claims_data
;


-- 2. Check for duplicate entries
-- 2.1 Check for duplicate claim ids
SELECT claim_id,
	   COUNT(*)
FROM expanded_claims_data
GROUP BY claim_id
HAVING COUNT(*) > 1
;
-- There are 14 claim_ids which are repeated twice and 4 times (for 4644844)

-- 2.2 Check for duplicate claim ids with multiple condition
SELECT claim_id,
	   COUNT(DISTINCT condition_id) AS condition_count
FROM expanded_claims_data
GROUP BY claim_id
HAVING COUNT(DISTINCT condition_id) > 1
;
-- There are 2 ids which have same type of condition

-- 2.3 Check for duplicate audit statuses
SELECT claim_id,
	   claim_audit_status,
	   COUNT(*)
FROM expanded_claims_data
GROUP BY claim_id, claim_audit_status
HAVING COUNT(*) > 1
;
-- There are 5 claim_ids that have same audit statuses

-- 2.4 Check for duplicate claims with other fields (Checking for duplicate rows)
SELECT claim_id,
	   condition_id,
	   condition_claimed_amount,
	   claim_audit_status,
	   COUNT(*)
FROM expanded_claims_data
GROUP BY claim_id,
		 condition_id,
		 condition_claimed_amount,
		 claim_audit_status
HAVING COUNT(*) > 1
;
-- There are 2 claim_ids, which have the same claimed amount, same condition and same claim_audit status
-- Note these are the values to be removed from the data, as they are stating the same condition

-- 3. Check for negative claimed amounts
SELECT *
FROM expanded_claims_data
WHERE condition_claimed_amount < 0
;


-- 4. Check for valid dates
-- treatment_start_date shouldn't be before known_from_date
SELECT *
FROM expanded_claims_data
WHERE condition_known_from_date > condition_treatment_start_date
;
-- There are 5 claim_ids where the treatment_start_date is earlier than the condition_known_from_date


-- Improve the dataset
-- Remove the claim_ids with duplicate claimed_amount, audit_status and conditions
-- Also note that, remove only those with net_amount <= 0
DELETE FROM condition_data
WHERE claim_id IN(
	SELECT claim_id
	FROM (
			SELECT claim_id,
		   		   condition_id,
		   		   condition_claimed_amount,
		   		   claim_audit_status,
		   		   COUNT(*)
			FROM expanded_claims_data
			GROUP BY claim_id,
					 condition_id,
					 condition_claimed_amount,
			 	     claim_audit_status
			HAVING COUNT(*) > 1
		) AS ta
) AND condition_net_amount < 1
;
-- Note: deleting from actual records in the database is not a good practice
-- Show the condition_data table
SELECT * FROM condition_data
;

-- Improvement to bring the dataset to production-ready level
-- 1. Indexing
-- 1.1 Index on claim_data table
CREATE INDEX idx_claim_id ON claims_data (claim_id)
;

-- 1.2 Index on condition_data table
CREATE INDEX idx_claim_id_condition ON condition_data (claim_id)
;

-- 1.3 Index on audit_status table
CREATE INDEX idx_claim_id_audit_status ON audit_status (claim_id)
;

-- 2. Data Quality checks
-- Trigger to check for negative claimed amounts
CREATE OR REPLACE FUNCTION check_negative_claims()
RETURNS TRIGGER AS $neg_clm$
BEGIN
	IF NEW.condition_claimed_amount < 0 THEN
		RAISE EXCEPTION 'Cannot insert negative claim amount for claim_id : % with claim amount: %', NEW.claim_id, NEW.condition_claimed_amount;
	END IF;
	RETURN NEW;
END;
$neg_clm$ LANGUAGE plpgsql
;

CREATE TRIGGER check_negative_claims_trigger
	BEFORE INSERT OR UPDATE ON condition_data
	FOR EACH ROW 
	EXECUTE FUNCTION check_negative_claims()
;

-- Test the trigger function
-- 1. Negative test
INSERT INTO condition_data (claim_id, condition_id, condition_migrated_flag, condition_type_desc, condition_type_code, condition_treatment_start_date, condition_known_from_date, condition_claimed_amount, condition_net_amount, condition_rejected_amount, condition_excess_amount)
VALUES (47682249,25777777,9,'adjustment','X05',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,-1706.44,1556.44,0,150)
;
-- 2. Positive test
INSERT INTO condition_data (claim_id, condition_id, condition_migrated_flag, condition_type_desc, condition_type_code, condition_treatment_start_date, condition_known_from_date, condition_claimed_amount, condition_net_amount, condition_rejected_amount, condition_excess_amount)
VALUES (47682249,25777777,9,'adjustment','X05',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,706.10,504.34,0,150)
;

-- Check insertion
SELECT * FROM condition_data
;
-- Remove insertion
DELETE FROM condition_data
	WHERE claim_id = 47682249
;

-- Trigger to check non empty condition treatment start dates
CREATE OR REPLACE FUNCTION non_null_treatment_start_dates()
RETURNS TRIGGER AS $nn_date$
BEGIN
	IF NEW.condition_treatment_start_date IS NULL THEN
		RAISE EXCEPTION 'There must exist a treatment start date!';
	END IF;
	RETURN NEW;
END;
$nn_date$ LANGUAGE plpgsql
;

CREATE TRIGGER check_treatment_start_date
	BEFORE INSERT OR UPDATE ON condition_data
	FOR EACH ROW
	EXECUTE FUNCTION non_null_treatment_start_dates()
;

-- Test the create_treatment_start_date trigger
-- 1. Negative test
INSERT INTO condition_data (claim_id, condition_id, condition_migrated_flag, condition_type_desc, condition_type_code, condition_treatment_start_date, condition_known_from_date, condition_claimed_amount, condition_net_amount, condition_rejected_amount, condition_excess_amount)
VALUES (47682249,25777777,9,'adjustment','X05',NULL,CURRENT_TIMESTAMP,1706.44,1556.44,0,150)
;

-- 2. Positive test
INSERT INTO condition_data (claim_id, condition_id, condition_migrated_flag, condition_type_desc, condition_type_code, condition_treatment_start_date, condition_known_from_date, condition_claimed_amount, condition_net_amount, condition_rejected_amount, condition_excess_amount)
VALUES (47682249,25777777,9,'adjustment','X05',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,706.10,504.34,0,150)
;

-- Check insertion
SELECT * FROM condition_data
;
-- Remove insertion
DELETE FROM condition_data
	WHERE claim_id = 47682249
;

