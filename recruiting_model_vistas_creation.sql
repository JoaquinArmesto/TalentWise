-- Use the correct schema
USE recruiting_model;


-- Funnel activity view
CREATE OR REPLACE VIEW vw_funnel_activity
    as (
        select
               f.date as date,
               c.name as candidate,
               c.email as email,
               s.name as stage,
               rl.title as role,
               p.name as project
        from funnel f
            left join candidate c
                on f.candidate_id = c.id
            left join requisition r
                on f.requisition_id = r.id
            left join stage s
                on f.stage_id = s.id
            left join role rl
                on rl.id = r.role_id
            left join project p
                on rl.project_id = p.id);


-- Transposed funnel activity view
CREATE OR REPLACE VIEW  vw_funnel_activity_transposed
    as (
        select
               f.date as date,
               rl.title as title,
               sum(case when lower(s.name) = 'outreach' then 1 else 0 end) as outreach,
               sum(case when lower(s.name) = 'rps' then 1 else 0 end) as rps,
               sum(case when lower(s.name) = 'assessment' then 1 else 0 end) as assessment,
               sum(case when lower(s.name = 'hmps') then 1 else 0 end) as hmps,
               sum(case when lower(s.name) = 'onsite' then 1 else 0 end) as onsite,
               sum(case when lower(s.name) = 'offer' then 1 else 0 end) as offer,
               sum(case when lower(s.name) = 'accepted' then 1 else 0 end) as accepted
        from funnel f
            left join candidate c
                on f.candidate_id=c.id
            left join requisition r
                on f.requisition_id = r.id
            left join stage s
                on f.stage_id = s.id
            left join role rl
                on rl.id = r.role_id
            left join project p
                on rl.project_id = p.id
        group by f.date,
                 rl.title
        order by f.date asc,
                 rl.title asc);


-- Transposed funnel activity view with recruiter / sourcer
CREATE OR REPLACE VIEW  vw_funnel_activity_transposed_roster
    as (
        select
               f.date as date,
               ro.name,
               ro.role,
               rl.title as title,
               sum(case when lower(s.name) = 'outreach' then 1 else 0 end) as outreach,
               sum(case when lower(s.name) = 'rps' then 1 else 0 end) as rps,
               sum(case when lower(s.name) = 'assessment' then 1 else 0 end) as assessment,
               sum(case when lower(s.name = 'hmps') then 1 else 0 end) as hmps,
               sum(case when lower(s.name) = 'onsite' then 1 else 0 end) as onsite,
               sum(case when lower(s.name) = 'offer' then 1 else 0 end) as offer,
               sum(case when lower(s.name) = 'accepted' then 1 else 0 end) as accepted
        from funnel f
            left join candidate c
                on f.candidate_id=c.id
            left join requisition r
                on f.requisition_id = r.id
            left join stage s
                on f.stage_id = s.id
            left join role rl
                on rl.id = r.role_id
            left join project p
                on rl.project_id = p.id
            left join roster ro on f.roster_id = ro.id
        group by f.date,
                 ro.name,
                 ro.role,
                 rl.title,
                 c.name
        order by  f.date asc,
                 rl.title asc);


-- Count of candidates by country
CREATE OR REPLACE VIEW  vw_count_of_candidates_by_country
    as (
        select distinct
                        co.name as country,
                        count(c.name) as count
        from funnel f
            left join candidate c
                on f.candidate_id = c.id
            left join requisition r
                on f.requisition_id = r.id
            left join city ci
                on r.city_id = ci.id
            left join country co
                on ci.country_id = co.id
            group by country);


-- Count of candidates by city
CREATE OR REPLACE VIEW  vw_count_of_candidates_by_city
    as (
        select distinct
                        ci.name as city,
                        count(c.name) as count
        from funnel f
            left join candidate c
                on f.candidate_id = c.id
            left join requisition r
                on f.requisition_id = r.id
            left join city ci
                on r.city_id = ci.id
            left join country co
                on ci.country_id = co.id
            group by city);


-- List of registered candidates
CREATE OR REPLACE VIEW  vw_list_of_candidates
    as (
        select distinct
                        c.name as candidate,
                        c.email,
                        c.phone,
                        c.linkedin,
                        ci.name as city,
                        co.name as country
        from funnel f
            left join candidate c
                on f.candidate_id = c.id
            left join requisition r
                on f.requisition_id = r.id
            left join city ci
                on r.city_id = ci.id
            left join country co
                on ci.country_id = co.id);


--  Transposed funnel activity view focused on candidate
CREATE OR REPLACE VIEW vw_candidate_evolution
    as (
        select
           c.name,
           rl.title,
           ro.name roster,
           max(case when lower(s.name) like 'rejected' then 'rejected' else 'active' end) as status,
           max(case when lower(s.name)='outreach' then  abs(datediff(f.date,now())) end) as aging,
           max(case when lower(s.name)='outreach' then f.date end) as outreach,
           max(case when lower(s.name)='rps' then f.date end) as rps,
           max(case when lower(s.name)='assessment' then f.date end) as assessment,
           max(case when lower(s.name)='hmps' then f.date end) as hmps,
           max(case when lower(s.name)='onsite' then f.date end) as onsite,
           max(case when lower(s.name)='offer' then f.date end) as offer,
           max(case when lower(s.name)='accepted' then f.date end) as accepted,
           max(case when lower(s.name)='rejected' then f.date end) as rejected
        from funnel f
            left join candidate c
                on f.candidate_id=c.id
            left join requisition r
                on f.requisition_id = r.id
            left join stage s
                on f.stage_id = s.id
            left join role rl
                on rl.id = r.role_id
            left join project p
                on rl.project_id = p.id
            left join roster ro on f.roster_id = ro.id
        group by c.name
        order by outreach);

