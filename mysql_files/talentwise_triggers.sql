-- Use the correct schema
use talent_wise;


-- Corrects issues with auto_increment when an error occurs on insertion
drop trigger if exists tr_FunnelNewEntry;
delimiter $$
create trigger tr_FunnelNewEntry before insert on funnel
    for each row
begin
    set new.id = (select max(id)+1 from funnel);
end $$;


-- Creates entries in log_funnel_new_entry and log_gunnel_new_state for new entries in funnel
drop trigger if exists tr_FunnelNewEntryLog;
delimiter $$
create trigger tr_FunnelNewEntryLog after insert on funnel
    for each row
    begin
        insert into log_funnel_new_entry(user, funnel_id)
        values(user(), new.id);

        insert into log_funnel_new_state(funnel_id, value_before,modified)
        values(new.id,
               CONCAT(new.id, ':', new.date, ':', new.candidate_id, ':', new.stage_id, ':', new.requisition_id, ':', new.roster_id),
               false);
    end $$;


-- Saves before state and after state of funnel entries in a csv format using : as separator
drop trigger if exists tr_FunnelNewState;
delimiter $$
create trigger tr_FunnelNewState after update on funnel
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


-- Updates updated_at of requisition
drop trigger if exists tr_RequisitionUpdate;
delimiter $$
create trigger tr_RequisitionUpdate before update on requisition
    for each row
begin
    set new.updated_at=now();
end $$;


-- Updates updated_at of role
drop trigger if exists tr_RoleUpdate;
delimiter $$
create trigger tr_RoleUpdate before update on role
    for each row
    begin
        set new.updated_at = now();
    end $$;


-- Updates updated_at of project
drop trigger if exists tr_ProjectUpdate;
delimiter $$
create trigger tr_ProjectUpdate before update on project
    for each row
    begin
        set new.updated_at = now();
    end $$;


-- Updates updated_at of client
drop trigger if exists tr_ClientUpdate;
delimiter $$
create trigger tr_ClientUpdate before update on client
    for each row
    begin
        set new.updated_at = now();
    end $$;


-- Creates an insert in log_requisition_update on requisition updates
drop trigger if exists tr_RequisitionUpdateLog;
delimiter $$
create trigger tr_RequisitionUpdateLog after update on requisition
    for each row
begin
    insert into log_requisition_update(requisition_id, user, date, time)
    values(new.id, user(), date(current_time), time(current_time));
end $$;