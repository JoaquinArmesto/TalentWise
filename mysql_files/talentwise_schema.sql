-- Dropping the schema for reruns
drop schema if exists talent_wise;


-- Creating the schema
create schema if not exists talent_wise;


-- Use the correct schema
use talent_wise;


-- Creating roster table
create table if not exists roster (
	id bigint auto_increment,
    created_at timestamp default (current_timestamp),
    updated_at timestamp default (current_timestamp),
    deleted_at timestamp default (null),
    name text not null,
    gender text not null,
    role text(50) not null,
    email varchar(255) not null,
    phone varchar (255),
	constraint PK_roster primary key (id));


-- Create table app_user for app usage
create table if not exists app_user (
    id bigint auto_increment,
    user_name text not null,
    user_pass text not null,
    user_email varchar(255) not null,
    roster_id bigint not null,
    constraint PK_app_user_id primary key (id),
    constraint FK_app_roster_id foreign key (roster_id) references roster (id));


-- Creating client table
create table if not exists client (
    id bigint auto_increment,
    created_at timestamp default(current_timestamp),
    updated_at timestamp default(current_timestamp),
    deleted_at timestamp default(null),
    client_name varchar(255) not null,
    internal_manager text not null,
    internal_manager_id bigint not null,
    external_manager text not null,
    website varchar(500) default(null),
    revenue_quarter bigint default(null),
    revenue_year bigint default(null),
    operation_costs bigint default(null),
    earnings bigint default(null),
    constraint PK_client_id primary key (id),
    constraint FK_internal_manager_id foreign key (internal_manager_id) references roster (id));


-- Creating project table
create table if not exists project (
	id bigint auto_increment,
	client_id bigint not null,
	project_name varchar(255) not null,
	created_at timestamp default (current_timestamp),
    updated_at timestamp default (current_timestamp),
    deleted_at timestamp null,
	constraint PK_project_id primary key (id),
	constraint FK_client_id foreign key (client_id) references client (id));


-- Creating role table
create table if not exists role (
	id bigint auto_increment,
    created_at timestamp default (current_timestamp),
    updated_at timestamp default (current_timestamp),
    deleted_at timestamp null,
    title varchar(255),
    start_date datetime not null,
    end_date datetime null,
    client varchar(255) not null,
    project_id bigint not null,
    constraint PK_roles_id primary key (id),
    constraint FK_project_id foreign key  (project_id) references project (id));


-- Creating country table
create table if not exists country (
    id bigint auto_increment,
    ISO text(2) not null,
    ISO3 text(3) not null,
    numeric_code int not null,
    name varchar(255) not null,
    constraint PK_country_id primary key (id));


-- Creating city table
create table if not exists city (
    id bigint auto_increment,
    name text,
    lat bigint not null,
    lng bigint not null,
    country_id bigint not null,
    constraint PK_city_id primary key (id),
    constraint FK_country_id foreign key (country_id) references country (id));


-- Creating requisition table
create table if not exists requisition (
    id bigint auto_increment,
    created_at timestamp default (current_timestamp),
    updated_at timestamp default (current_timestamp),
    deleted_at timestamp null,
    start_date datetime NOT NULL,
    end_date datetime,
    seniority text NOT NULL,
    role_id bigint NOT NULL,
    city_id bigint NOT NULL,
    constraint PK_requisition_id primary key (id),
    constraint FK_role_id foreign key (role_id) references role (id),
    constraint FK_city_id foreign key (city_id) references city (id));


-- Creating candidate table
create table if not exists candidate (
    id bigint auto_increment,
    name text not null,
    email varchar (255) not null,
    phone varchar (255) not null,
    linkedin varchar (255) not null,
    constraint primary key (id));


-- Creating stage table
create table if not exists stage (
    id int auto_increment,
    created_at timestamp default(current_timestamp),
    updated_at timestamp default(current_timestamp),
    deleted_at timestamp null,
    name text not null,
    description text not null,
    notes text null,
    constraint primary key (id));


-- Creating funnel table
create table if not exists funnel (
    id bigint auto_increment,
    date datetime default(current_date),
    candidate_id bigint not null,
    stage_id int not null,
    requisition_id bigint not null,
    roster_id bigint not null,
    constraint PK_funnel_activity primary key  (id),
    constraint FK_candidate_id foreign key (candidate_id) references candidate (id),
    constraint FK_stage_id foreign key (stage_id) references stage (id),
    constraint FK_requisition_id foreign key (requisition_id) references requisition (id),
    constraint FK_roster_id foreign key (roster_id) references roster (id));


create table if not exists log_funnel_new_entry (
    id bigint auto_increment,
    user varchar(255) not null,
    date date default(current_date),
    time time default(current_time),
    funnel_id int not null,
    constraint PK_logFunnelNewEntries primary key (id));


create table if not exists log_funnel_new_state (
    id bigint auto_increment,
    funnel_id bigint,
    created_at timestamp default(current_timestamp),
    updated_at timestamp default(null),
    value_before varchar(255),
    value_after varchar(255),
    modified int not null default(0),
    constraint PK_logFunnelUpdatesId primary key (id),
    constraint FK_logFunnelUpdatesId foreign key (funnel_id) references funnel (id));


create table if not exists log_requisition_update (
    id bigint auto_increment,
    requisition_id bigint not null,
    user varchar(255) not null,
    date date default(current_date),
    time time default(current_time),
    constraint PK_logFunnelUpdateId primary key (id),
    constraint FK_logRequisitionUpdateRequisitionId foreign key (requisition_id) references requisition (id));


create unique index idx_funnel_alt_pk
on funnel (candidate_id, stage_id, requisition_id);