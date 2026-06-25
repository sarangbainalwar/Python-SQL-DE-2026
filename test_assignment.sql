-- Sample Schema Creation
-- The original assignment provided only the source columns.
-- The sample tables and test data below are created to have a better understanding.

-- Source table containing meter and customer information
drop table if EXISTS meter_table;

create table meter_table(
    id int primary key,
    account_type varchar(30),
    name varchar(50),
    meter_number varchar(30),
    device_id varchar(30),
    installed_date date,
    supply_start_date date,
    ignition_status varchar(20),
    smart_meter_type varchar(10)
);

INSERT INTO meter_table VALUES
(101,'Install','John','MTR001','DEV101','2024-01-10','2024-01-15','ACTIVE','S1'),

(102,'Migration','Alice','MTR002',NULL,'2024-02-15','2024-02-20','ACTIVE','S1'),

(103,'Install','Bob','MTR003','DEV103','2024-03-12','2027-01-01','ACTIVE','S2'),

(104,'OSGain','David','MTR004','DEV104','2024-04-20','2024-04-25','ACTIVE','S2'),

(105,'Install','Emma','MTR005',NULL,'2024-05-18','2024-05-20','ACTIVE','S1E'),

(106,'Migration','Mike','MTR006','DEV106','2024-06-05','2024-06-10','ACTIVE','S1E'),

(107,'Install','Chris','MTR007','DEV107','2024-07-10','2024-07-15','ACTIVE','Legacy');



-- Source table containing meter readings.
-- Multiple readings per meter are intentionally inserted
-- to test retrieval of the latest reading.

DROP TABLE IF EXISTS reading_table;

CREATE TABLE reading_table
(
    reading_id INT AUTO_INCREMENT PRIMARY KEY,
    meter_number VARCHAR(30),
    reading_date TIMESTAMP
);

INSERT INTO reading_table(meter_number,reading_date)
VALUES

('MTR001','2025-03-01'),

('MTR001','2025-06-01'),

('MTR002','2025-01-01'),

('MTR003','2025-05-15'),

('MTR003','2025-06-10'),

('MTR004','2025-02-01'),

('MTR005','2025-04-15'),

('MTR006','2025-06-20');


-- Lookup table containing device details.
-- Used to retrieve CHF device information.
DROP TABLE IF EXISTS device_table;

CREATE TABLE device_table
(
    device_id_chf VARCHAR(30),
    device_id VARCHAR(30),
    name VARCHAR(50)
);

INSERT INTO device_table
VALUES

('CHF1001','DEV101','John'),

('CHF1002','DEV103','Bob'),

('CHF1003','DEV104','David'),

('CHF1004','DEV106','Mike');

select * from meter_table;
select * from device_table;
select * from reading_table;


-- CTE: Retrieve the latest reading for each meter and
-- calculate the number of days since the latest reading.

with days_diff as (
    select meter_number,max(reading_date) as latest_reading_date, TIMESTAMPDIFF(DAY,max(reading_date),CURRENT_TIMESTAMP) as last_reading_days_ago  from reading_table
    group by meter_number
)

-- Final Output
-- Implements the business rules defined in the assignment:
-- 1. Filter only S1, S1E and S2 smart meters.
-- 2. Derive no_read_flag for S2 devices.
-- 3. Retrieve CHF device information.
-- 4. Calculate supply_active_flag.
-- 5. Determine next_action using CASE expressions.

select 
    mt.id id,
    mt.account_type account_type_esm,
    mt.name name,
    mt.meter_number meter_number,
    mt.device_id device_id,
    mt.installed_date installed_date, 
    mt.supply_start_date supply_start_date, 
    mt.ignition_status device_status, 
    mt.smart_meter_type smart_meter_type, 
    case 
        when d.last_reading_days_ago > 60 and mt.smart_meter_type = 'S2' then 'TRUE'
        when d.last_reading_days_ago <= 60 and mt.smart_meter_type = 'S2' then 'FALSE'
        else NULL 
    end as no_read_flag,
    dt.device_id_chf device_id_chf,
    case 
        when mt.supply_start_date > CURRENT_DATE then 'yes'
        else 'no'
    end as supply_active_flag,  
-- NOTE: -- Business rule:
-- Supply is considered active if the supply start date is greater than the current date,
-- as specified in the assignment document.
    case 
        when mt.smart_meter_type='S1' and mt.device_id is NULL then 'Exchange - S1'
        when mt.smart_meter_type='S1' and mt.device_id is NOT NULL then 'Exchange - S1 working'
        when mt.smart_meter_type='S1E' and mt.device_id is  NULL then 'Exchange S1E' -- note: no case for not null
        when mt.smart_meter_type='S2' and mt.device_id is  not NULL then 'Exchange - S1' -- note: no case for S2
    end as next_action
from meter_table mt 
left JOIN days_diff d 
on mt.meter_number = d.meter_number
left JOIN device_table dt 
on mt.device_id = dt.device_id and mt.name=dt.name
where mt.smart_meter_type in ('S1','S1E','S2');