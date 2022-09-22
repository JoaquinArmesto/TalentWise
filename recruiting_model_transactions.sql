use recruiting_model;


-- Setting autocommit to false
set @@autocommit=0;



START TRANSACTION;


-- Primera consigna


-- Preview
select * from stage;


-- Deletion
with
     vw_stage_ids as (
         select id as id from stage where id not in (select stage_id from funnel)
     )
DELETE FROM stage
where id=any(select id from vw_stage_ids);

-- Changes
select * from stage;

-- Rollback / Commit
-- rollback;
-- commit



-- Segunda consigna
insert into project(name, created_at, updated_at, deleted_at)
select name, created_at, updated_at, deleted_at from project where id=any(select id from project where id=1);
insert into project(name, created_at, updated_at, deleted_at)
select name, created_at, updated_at, deleted_at from project where id=any(select id from project where id=2);
insert into project(name, created_at, updated_at, deleted_at)
select name, created_at, updated_at, deleted_at from project where id=any(select id from project where id=3);
insert into project(name, created_at, updated_at, deleted_at)
select name, created_at, updated_at, deleted_at from project where id=any(select id from project where id=4);
SAVEPOINT temp_1;
insert into project(name, created_at, updated_at, deleted_at)
select name, created_at, updated_at, deleted_at from project where id=any(select id from project where id=5);
insert into project(name, created_at, updated_at, deleted_at)
select name, created_at, updated_at, deleted_at from project where id=any(select id from project where id=6);
insert into project(name, created_at, updated_at, deleted_at)
select name, created_at, updated_at, deleted_at from project where id=any(select id from project where id=7);
insert into project(name, created_at, updated_at, deleted_at)
select name, created_at, updated_at, deleted_at from project where id=any(select id from project where id=8);
SAVEPOINT temp_2;

-- release savepoint temp_1;