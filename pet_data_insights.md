# Pet Data Exercise
## **Overview**
This report outlines the approach to completing the assigned tasks, addressing data integrity issues, and suggesting improvements to bring the dataset to a production-ready level. 
Additionally, it includes SQL statements for implementation and suggestions for enhancing the data dictionary.

The task follows structured approach to complete the assigned task and address the questions.
The data is loaded into PostgreSQL to explore, process, analyse and suggest some improvements to make data production-ready.
The ```pet_data_schemal.sql``` script can be referred and used for this purpose.

### 1. Data Exploration
The each individual data is loaded into a table to inspect the  data and understand the structure and content.

**Data Insights:**
1. **claims_data:** This table contains claim IDs.
2. **audit_status:** This table contains claim IDs and their corresponding audit status.
3. **condition_data**: This table contains detailed information about the conditions associated with each claim.

### 2. Task Breakdown
#### 1. Expanding the Dataset

1.1 **audit_status** was joined with the claims_data using basic SQL joins, incorporating audit status for each claim ID. 

1.2 **condition_data** was also joined with the combined claims_data and audit_status using SQL joins, incorporating each condition information with audit_status and claim_ids

```
-- Task 1.0 Expand the dataset
-- 1.1 Join Audit Data with Claims Data table
-- Also create views to simlify future queries and reusability
CREATE VIEW claims_with_audit AS
SELECT cd.claim_id,
	   ad.claim_audit_status
FROM   claims_data cd
LEFT JOIN audit_status ad ON cd.claim_id  = ad.claim_id
;

-- 1.2 Condition data (to incorporate related disease conditions that have been paid on the claims by us as an insurer)
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
```

This approach creates a view *expanded_claims_data* which can be used to carry out any future queries or tasks.

#### 2. Present a Monthly Time Series of the Total Claimed Amount

To create a monthly time series of the total claimed amount, the claim amounts were aggregated by month, starting from January 2023 to May 2024.
```
-- Task 2.0
-- Present a monthly time series of the total claimed amount with a STARTS_AT for the months from January 2023 to May 2024.
-- Calculate the total claimed amount by month
SELECT DATE_TRUNC('month', condition_treatment_start_date) AS starts_at,
	   SUM(condition_claimed_amount) AS total_claimed_amount
FROM expanded_claims_data
WHERE condition_treatment_start_date BETWEEN '2023-01-01' AND '2024-05-31'
GROUP BY starts_at
ORDER BY starts_at
;
```

### 3. Data Integrity Checks
Various integrity check viz., checking for missing values and checking for duplicates for finding any anomalies in dataset was performed.
```
-- Check for duplicate entries
SELECT claim_id,
	   COUNT(*)
FROM expanded_claims_data
GROUP BY claim_id
HAVING COUNT(*) > 1
;
```
There were 14 claim_ids which are repeated twice and 4 times (for 4644844)

To investigate further claim ids with same condition, audit_status and other fields were checked, which resulted in 2 claims_id with same claimed amount, same condition and same claim_audit status were found.
The claim ids were ```47307373``` and ```47682240```. Upon further investigation they indicated that there might have been a problem with the data entry or repeated entry because the ```condition_net_amount``` for these claim ids are less than 0.

To rectify this issue, these claim ids were removed from the condition data where the entries of ```condition_net_amount``` was found to be negative.
```
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
```

### 4.Proactive Maintainance
To maintain data and to avoid any anomalies in the data during the future entries following processes can be implemented:
1. **Validation Rules**: Implement validation rules to ensure data correctness.
2. **Alerts**: Create alerts for anomalous data patterns.

Below code snippet shows a suggestion of implementing a ```TRIGGER``` in SQL to avoid negative claim amounts to be inserted in the data table.
```
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
```

Conducting regular data checks and audits can also avoid such anomalies in the datasets.

### 5. Making Data Production Ready

1. Indexing: Adding indexes to frequently queried fields is a proven way to improve performance.
```
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
```

2. If the data is large enough then Data Partitioning can also improve query performance.
3. Implementing a backup and recovery strategy to safeguard data.

#### Additional Improvements for Production-Readiness
1. Data Modeling and Normalization: Ensure proper normalization and efficient storage.
2. Data Access Controls: Implement appropriate access controls and security measures.
3. Data Documentation: Maintain comprehensive data documentation.
4. Data Lineage and Provenance: Track and document data origin and transformations.
5. Data Monitoring and Alerting: Implement monitoring and alerting mechanisms.
6. Data Governance and Stewardship: Establish a data governance framework.
7. Integration and Automation: Automate data ingestion, transformation, and loading processes.


### 6. Enhancing the Data Dictionary
1. **Comprehensive Field Descriptions**: Providing detailed descriptions for each field.
2. **Data Relationships and Dependencies**: Documenting relationships and dependencies.
3. **Data Lineage and Provenance**: Including information about data origin and transformations.
4. **Data Quality Rules and Metrics**: Defining and documenting data quality rules.
5. **Business Glossary**: Maintaining a business glossary for key terms and concepts.
6. **Data Governance and Stewardship**: Documenting data governance policies and roles.
7. **Data Security and Privacy**: Including information about data security measures.
8. **Version Control and Change Management**: Implementing version control for the data dictionary.
9. **Metadata Management**: Using metadata management tools to centralize the data dictionary.
10. **Collaboration and Accessibility**: Ensuring that the data dictionary is accessible and shareable.

