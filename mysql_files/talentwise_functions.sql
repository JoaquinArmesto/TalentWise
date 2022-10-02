-- Use the correct schema
use talent_wise;


-- Calculates the business days elapsed between two dates, taking out Sundays and Saturdays
drop function if exists fn_BusinessDays;
delimiter $$
create function fn_BusinessDays(start_date date, end_date date)
returns int deterministic
    begin
        declare elapsed_days int;
        declare non_business_days int default(0);
        declare iterator int default 0;
        declare result int;
        declare day_name varchar(250);

        set elapsed_days = abs(datediff(start_date, end_date));
        set iterator = 0;

        while iterator <= elapsed_days DO
                set day_name = (select dayname(date_add(start_date, interval iterator day)));
                if (day_name='Sunday' OR day_name='Saturday') then
                    set non_business_days = non_business_days + 1;
                end if;
                set iterator = iterator + 1;
        end while;

        set result = elapsed_days - non_business_days;
        return result;
    end $$


-- Uses BusinessDays function to calculate the elapsed business days for each role
drop function if exists fn_ElapsedBusinessDaysForRole;
delimiter $$
create function fn_ElapsedBusinessDaysForRole(id int)
returns varchar(250) deterministic
    begin
        declare min_date date;
        declare max_date date;
        declare business_days_elapsed int default 0;
        declare alt_response varchar(250);

        set min_date = (select min(date) from funnel where requisition_id=id);
        set max_date = (select max(date) from funnel where requisition_id=id);
        set business_days_elapsed = fn_BusinessDays(min_date, max_date);

        if business_days_elapsed is null then
            set alt_response = 'Candidate present in only one stage at the moment';
            return alt_response;
        end if;

        return business_days_elapsed;
    end $$