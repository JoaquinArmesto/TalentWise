-- Use the correct schema
use talent_wise;


-- This procedure sorts table based on table name, column and sorting order
drop procedure if exists sp_TableSort;
delimiter $$
create procedure sp_TableSort (in tableName varchar(100), in columnName varchar(100), in sortVar varchar(10))
begin
    declare error_msg varchar(255);

    if tableName not like '' and columnName not like '' then
        if sortVar not like '' and (lower(sortVar) like 'asc' or lower(sortVar) like 'desc') then
            if tableName in (select TABLE_NAME from information_schema.TABLES where TABLE_SCHEMA='talent_wise') then
                set @query = concat('select * from ', tableName, ' ORDER BY ', columnName, ' ', sortVar);
                prepare param_stmt from @query;
                execute param_stmt;
                deallocate prepare param_stmt;
            else
                set error_msg = 'The table doesn\'t exist in the schema';
                select error_msg as Error;
            end if;
        else
            set error_msg = 'Sorting order has to be either asc or desc';
            select error_msg as Error;
        end if;
    else
        set error_msg = 'Missing parameters';
        select error_msg as Error;
    end if;
end $$


-- This procedure closes and open projects
drop procedure if exists sp_CloseOpenProject;
delimiter $$
create procedure sp_CloseOpenProject(in project int, in delete_full boolean, query_return boolean)
begin
    if delete_full is false then
        if project in (select id from project) and (select deleted_at from project where id=project) is null then
            update role
            set deleted_at=now()
            where project_id=project;
            update project
            set deleted_at=now()
            where id=project;
            update requisition
            set deleted_at=now()
            where role_id=any(select id from role where project_id=project);
        else
            update role
            set deleted_at=null
            where project_id=project;
            update project
            set deleted_at=null
            where id=project;
            update requisition
            set deleted_at=null
            where role_id=any(select id from role where project_id=project);
        end if;
    else
        delete from funnel
        where requisition_id=any(select id from requisition where role_id=any(select id from role where project_id=project));
        delete from requisition
        where role_id=any(select id from role where project_id=project);
        delete from role
        where project_id=project;
        delete from project
        where id=project;
    end if;

    if query_return is true then
        select * from project where id=project;
    end if;
end $$


-- This procedure closes and open all projects at once
drop procedure if exists sp_OpenCloseAllProjects;
delimiter $$
create procedure sp_OpenCloseAllProjects(delete_full boolean)
begin
    declare projectCount int default(select count(id) from project);
    declare iterator int default(0);
    declare project_id int;

    while iterator < projectCount do
            set iterator = iterator + 1;
            set project_id = (select id from project where id=iterator);
            if (select deleted_at from project where id=project_id) is null then
                call Sp_CloseOpenProject(project_id, delete_full, false);
            else
                call Sp_CloseOpenProject(project_id, delete_full, false);
            end if;
        end while;
    select * from project;
end $$


-- Procedure used for app login checks
drop procedure if exists sp_LoginCheck;
delimiter $$
create procedure sp_LoginCheck(in user_name text, in user_pass text, return_value boolean)
begin
    set return_value = false;
    set @user_exist = (
        select count(id)
        from app_user au
        where au.user_name like user_name
          and au.user_pass like user_pass);

    if (@user_exist > 0) then
        set return_value = true;
    end if;
    select return_value;
end
$$;


-- Procedure used for app_user and roster creation
drop procedure if exists sp_CreateAccount;
delimiter $$
create procedure sp_CreateAccount (in user_name text, in user_pass text, in user_email text, in user_gender text, in user_role text, in user_phone text)
begin
    declare new_user_id bigint default(0);

    insert into roster (name, gender, role, email, phone)
    values (user_name, user_gender, user_role, user_email, user_phone);

    set new_user_id = (
        select id
        from roster
        where name like user_name
          and email like user_email);

    insert into app_user (user_name, user_pass, user_email, roster_id)
    values (user_name, user_pass, user_email, new_user_id);
end $$;