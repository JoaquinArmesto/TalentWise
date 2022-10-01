-- Use the correct schema
use talent_wise;


-- Trigger that corrects issues with auto_increment when an error occurs on insertion
DROP TRIGGER if exists trFunnelNewEntry;
delimiter $$
create trigger trFunnelNewEntry before insert on funnel
    for each row
begin
    set new.id = (select max(id)+1 from funnel);
end $$;


-- Trigger creates entries in log_funnel_new_entry and log_gunnel_new_state for new entries in funnel
DROP TRIGGER if exists trFunnelNewEntryLog;
delimiter $$
create trigger trFunnelNewEntryLog after insert on funnel
    for each row
    begin
        insert into log_funnel_new_entry(user, funnel_id)
        values(user(), new.id);

        insert into log_funnel_new_state(funnel_id, value_before,modified)
        values(new.id,
               CONCAT(new.id, ':', new.date, ':', new.candidate_id, ':', new.stage_id, ':', new.requisition_id, ':', new.roster_id),
               false);
    end $$;


-- Tigger saves before state and after state of funnel entries in a csv format using : as separator
DROP TRIGGER IF EXISTS trFunnelNewState;
DELIMITER $$
CREATE TRIGGER trFunnelNewState after update on funnel
for each row
    begin
        if (select value_after from log_funnel_new_state where funnel_id=new.id) is null THEN
            update log_funnel_new_state
                set value_after=CONCAT(
                    new.id, ':',
                    new.date, ':',
                    new.candidate_id, ':',
                    new.stage_id, ':',
                    new.requisition_id, ':',
                    new.roster_id),
                    updated_at=now(),
                    modified=modified+1
                where funnel_id=new.id;
        else
            update log_funnel_new_state
                set value_before=value_after,
                    value_after=CONCAT(
                        new.id, ':',
                        new.date,':',
                        new.candidate_id,':',
                        new.stage_id, ':',
                        new.requisition_id, ':',
                        new.roster_id),
                    updated_at=now(),
                    modified=modified+1
                where funnel_id=new.id;
        end if;
    end $$;


-- Trigger updates updated_at of requisition
drop trigger if exists trRequisitionUpdate;
DELIMITER $$
CREATE TRIGGER trRequisitionUpdate before update on requisition
for each row
    begin
        set new.updated_at=now();
    end $$;


-- Trigger creates an insert on log_requisition_update on requisition updates
DROP TRIGGER IF EXISTS trRequisitionUpdateLog;
delimiter $$
CREATE TRIGGER trRequisitionUpdateLog after update on requisition
    for each row
        begin
            insert into log_requisition_update(requisition_id, user, date, time)
                values(new.id, user(), date(current_time), time(current_time));
        end $$;