-- Drop procedures if they exist
DROP PROCEDURE IF EXISTS SptableSort;
DROP PROCEDURE IF EXISTS SpCloseOpenProject;
DROP PROCEDURE IF EXISTS SpOpenCloseAllProjects;


-- This procedure sorts table based on table name, column and sorting order
DELIMITER $$
CREATE PROCEDURE SpTableSort (IN tableName varchar(50), IN columnName varchar(50), IN sortVar varchar(50))
    BEGIN
        DECLARE error_msg varchar(255);

        IF tableName NOT LIKE '' AND columnName NOT LIKE '' THEN
            IF sortVar NOT LIKE '' AND (lower(sortVar) LIKE 'asc' OR lower(sortVar) LIKE 'desc') THEN
                IF tableName IN (SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA='recruiting_model') THEN
                    SET @query = CONCAT('select * from ', tableName, ' ORDER BY ', columnName, ' ', sortVar);
                    PREPARE param_stmt FROM @query;
                    EXECUTE param_stmt;
                    DEALLOCATE PREPARE param_stmt;
                ELSE
                     SET error_msg = 'The table doesn\'t exist in the schema';
                     SELECT error_msg AS Error;
                END IF;
            ELSE
                SET error_msg = 'Sorting order has to be either asc or desc';
                SELECT error_msg AS Error;
            END IF;
        ELSE
            SET error_msg = 'Missing parameters';
            SELECT error_msg AS Error;
        END IF;
    END $$


-- This procedure closes and open projects
DELIMITER $$
CREATE PROCEDURE SpCloseOpenProject(IN project int, IN delete_full boolean, query_return boolean)
    BEGIN
        IF delete_full is False THEN
            IF project in (SELECT id FROM project) AND (SELECT deleted_at FROM project WHERE id=project) IS NULL THEN
                UPDATE role
                SET deleted_at=now()
                WHERE project_id=project;
                UPDATE project
                SET deleted_at=now()
                WHERE id=project;
                UPDATE requisition
                SET deleted_at=now()
                WHERE role_id=ANY(SELECT id from role where project_id=project);
            ELSE
                UPDATE role
                SET deleted_at=null
                WHERE project_id=project;
                UPDATE project
                SET deleted_at=null
                WHERE id=project;
                UPDATE requisition
                SET deleted_at=null
                WHERE role_id=ANY(SELECT id from role where project_id=project);
            END IF;
        ELSE
            DELETE FROM funnel
            WHERE requisition_id=ANY(SELECT id FROM requisition WHERE role_id=ANY(SELECT id FROM role WHERE project_id=project));
            DELETE FROM requisition
            WHERE role_id=ANY(SELECT id FROM role WHERE project_id=project);
            DELETE FROM role
            WHERE project_id=project;
            DELETE FROM project
            WHERE id=project;
        END IF;

        if query_return is true then
            SELECT * FROM project WHERE id=project;
        end if;
    END $$


-- This procedure closes and open all projects at once
delimiter $$
CREATE PROCEDURE SpOpenCloseAllProjects(delete_full boolean)
    begin
        declare projectCount int default(select count(id) from project);
        declare iterator int default(0);
        declare project_id int;

        while iterator < projectCount do
            set iterator = iterator + 1;
            set project_id = (select id from project where id=iterator);
            if (select deleted_at from project where id=project_id) is null THEN
                call SpCloseOpenProject(project_id, delete_full, false);
            else
                call SpCloseOpenProject(project_id, delete_full, false);
            end if;

        end while;

        select * from project;
    end $$


-- Procedure used for app login checks
drop procedure if exists sp_login_check;
delimiter $$
create procedure sp_login_check(in user_name varchar(255), in user_pass varchar(255), out test_value boolean)
    begin
        set test_value = false;
        set @user_exist = (
            select count(id)
            from app_user au
            where au.user_name like user_name
              and au.user_pass like user_pass);

        if (@user_exist > 0) then
            set test_value = true;
        end if;
    select test_value;
    end
$$;
