-- Dropping the schema for reruns
DROP SCHEMA IF EXISTS talent_wise;


-- Creating the schema
CREATE SCHEMA IF NOT EXISTS talent_wise;


-- Use the correct schema
USE talent_wise;


-- Creating roster table
CREATE TABLE IF NOT EXISTS roster (
	id bigint auto_increment,
    created_at timestamp default (current_timestamp),
    updated_at timestamp default (current_timestamp),
    deleted_at timestamp default (null),
    name text not null,
    gender text not null,
    role text(50) not null,
    email varchar(255) not null,
    phone varchar (255),
	CONSTRAINT PK_roster PRIMARY KEY (id)
);


-- Create table app_user for app usage
CREATE TABLE IF NOT EXISTS app_user (
    id bigint auto_increment,
    user_name text not null,
    user_pass text not null,
    user_email varchar(255) not null,
    roster_id bigint not null,
    CONSTRAINT PK_app_user_id PRIMARY KEY (id),
    CONSTRAINT FK_app_roster_id FOREIGN KEY (roster_id) REFERENCES roster (id)
);


-- Creating client table
CREATE TABLE IF NOT EXISTS client (
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
    CONSTRAINT PK_client_id PRIMARY KEY (id),
    CONSTRAINT FK_internal_manager_id FOREIGN KEY (internal_manager_id) REFERENCES roster (id)
);


-- Creating project table
CREATE TABLE IF NOT EXISTS project (
	id bigint auto_increment,
	client_id bigint not null,
	project_name varchar(255) not null,
	created_at timestamp default (current_timestamp),
    updated_at timestamp default (current_timestamp),
    deleted_at timestamp null,
	CONSTRAINT PK_project_id PRIMARY KEY (id),
	CONSTRAINT FK_client_id FOREIGN KEY (client_id) REFERENCES client (id)
);


-- Creating role table
CREATE TABLE IF NOT EXISTS role (
	id bigint auto_increment,
    created_at timestamp default (current_timestamp),
    updated_at timestamp default (current_timestamp),
    deleted_at timestamp null,
    title varchar(255),
    start_date datetime not null,
    end_date datetime null,
    client varchar(255) not null,
    project_id bigint not null,
    CONSTRAINT PK_roles_id PRIMARY KEY (id),
    CONSTRAINT FK_project_id FOREIGN KEY  (project_id) REFERENCES project (id)
 );


-- Creating country table
CREATE TABLE IF NOT EXISTS country (
    id bigint auto_increment,
    ISO text(2) not null,
    ISO3 text(3) not null,
    numeric_code int not null,
    name varchar(255) not null,
    CONSTRAINT PK_country_id PRIMARY KEY (id)
);


-- Creating city table
CREATE TABLE IF NOT EXISTS city (
    id bigint auto_increment,
    name text,
    lat bigint not null,
    lng bigint not null,
    country_id bigint not null,
    CONSTRAINT PK_city_id PRIMARY KEY (id),
    CONSTRAINT FK_country_id FOREIGN KEY (country_id) REFERENCES country (id)
);


-- Creating requisition table
CREATE TABLE IF NOT EXISTS requisition (
    id bigint auto_increment,
    created_at timestamp default (current_timestamp),
    updated_at timestamp default (current_timestamp),
    deleted_at timestamp null,
    start_date datetime NOT NULL,
    end_date datetime,
    seniority text NOT NULL,
    role_id bigint NOT NULL,
    city_id bigint NOT NULL,
    CONSTRAINT PK_requisition_id PRIMARY KEY (id),
    CONSTRAINT FK_role_id FOREIGN KEY (role_id) REFERENCES role (id),
    CONSTRAINT FK_city_id FOREIGN KEY (city_id) REFERENCES city (id)
);


-- Creating candidate table
CREATE TABLE IF NOT EXISTS candidate (
    id bigint auto_increment,
    name text not null,
    email varchar (255) not null,
    phone varchar (255) not null,
    linkedin varchar (255) not null,
    CONSTRAINT PRIMARY KEY (id)
);


-- Creating stage table
CREATE TABLE IF NOT EXISTS stage (
    id int auto_increment,
    created_at timestamp default(current_timestamp),
    updated_at timestamp default(current_timestamp),
    deleted_at timestamp null,
    name text not null,
    description text not null,
    notes text null,
    CONSTRAINT PRIMARY KEY (id)
);


-- Creating funnel table
CREATE TABLE IF NOT EXISTS funnel (
    id bigint auto_increment,
    date datetime default(current_date),
    candidate_id bigint not null,
    stage_id int not null,
    requisition_id bigint not null,
    roster_id bigint not null,
    CONSTRAINT PK_funnel_activity PRIMARY KEY  (id),
    CONSTRAINT FK_candidate_id FOREIGN KEY (candidate_id) REFERENCES candidate (id),
    CONSTRAINT FK_stage_id FOREIGN KEY (stage_id) REFERENCES stage (id),
    CONSTRAINT FK_requisition_id FOREIGN KEY (requisition_id) REFERENCES requisition (id),
    CONSTRAINT FK_roster_id FOREIGN KEY (roster_id) REFERENCES roster (id)
);


CREATE TABLE IF NOT EXISTS log_funnel_new_entry (
    id bigint auto_increment,
    user varchar(255) not null,
    date date default(current_date),
    time time default(current_time),
    funnel_id int not null,
    CONSTRAINT PK_logFunnelNewEntries PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS log_funnel_new_state (
    id bigint auto_increment,
    funnel_id bigint,
    created_at timestamp default(current_timestamp),
    updated_at timestamp default(null),
    value_before varchar(255),
    value_after varchar(255),
    modified int not null default(0),
    CONSTRAINT PK_logFunnelUpdatesId PRIMARY KEY (id),
    CONSTRAINT FK_logFunnelUpdatesId FOREIGN KEY (funnel_id) REFERENCES funnel (id)
);


CREATE TABLE IF NOT EXISTS log_requisition_update (
    id bigint auto_increment,
    requisition_id bigint not null,
    user varchar(255) not null,
    date date default(current_date),
    time time default(current_time),
    CONSTRAINT PK_logFunnelUpdateId PRIMARY KEY (id),
    CONSTRAINT FK_logRequisitionUpdateRequisitionId FOREIGN KEY (requisition_id) REFERENCES requisition (id)
);


CREATE UNIQUE INDEX idx_funnel_alt_pk
on funnel (candidate_id, stage_id, requisition_id);