-- Drop procedures if they exist
DROP FUNCTION IF EXISTS BusinessDays;
DROP FUNCTION IF EXISTS ElapsedBusinessDaysForRole;


-- This function calculates the business days elapsed between two dates, taking out Sundays and Saturdays
DELIMITER $$
CREATE FUNCTION BusinessDays(start_date date, end_date date)
RETURNS int DETERMINISTIC
    BEGIN
        DECLARE elapsed_days int;
        DECLARE non_business_days int default(0);
        DECLARE iterator int DEFAULT 0;
        DECLARE result int;
        DECLARE day_name varchar(250);

        SET elapsed_days = ABS(DATEDIFF(start_date, end_date));
        SET iterator = 0;

        WHILE iterator <= elapsed_days DO
                SET day_name = (SELECT DAYNAME(DATE_ADD(start_date, INTERVAL iterator DAY)));
                IF (day_name='Sunday' OR day_name='Saturday') THEN
                    SET non_business_days = non_business_days + 1;
                END IF;
                SET iterator = iterator + 1;
        END WHILE;
        SET result = elapsed_days - non_business_days;
        RETURN result;
    END $$


-- This function uses BusinessDays function to calculate the elapsed business days for each role
DELIMITER $$
CREATE FUNCTION ElapsedBusinessDaysForRole(id int)
RETURNS VARCHAR(250) DETERMINISTIC
    BEGIN
        DECLARE min_date date;
        DECLARE max_date date;
        DECLARE business_days_elapsed int default 0;
        DECLARE alt_response varchar(250);

        SET min_date = (SELECT min(date) FROM funnel WHERE requisition_id=id);
        SET max_date = (SELECT max(date) FROM funnel WHERE requisition_id=id);
        SET business_days_elapsed = BusinessDays(min_date, max_date);

        IF business_days_elapsed is null THEN
            SET alt_response = 'Candidate present in only one stage at the moment';
            RETURN alt_response;
        END IF;

        RETURN business_days_elapsed;
    END $$