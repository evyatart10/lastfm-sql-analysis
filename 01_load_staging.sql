-- 01_load_staging.sql
-- Load the raw Last.fm 1K files as-is into staging tables.
-- Requires: set global local_infile = 1;  (and OPT_LOCAL_INFILE=1 in the connection)

create database if not exists music_project;
use music_project;

drop table if exists stg_profile;
create table stg_profile (
  user_id varchar(20),
  gender varchar(5),
  age varchar(10),
  country varchar(100),
  registered varchar(30)
);

load data local infile 'C:/music_project/data/userid-profile.tsv'
into table stg_profile
fields terminated by '\t'
lines terminated by '\n'
ignore 1 lines;

drop table if exists stg_listens;
create table stg_listens (
  user_id varchar(20),
  played_at varchar(30),
  artist_mbid varchar(40),
  artist_name varchar(500),
  track_mbid varchar(40),
  track_name varchar(500)
);

load data local infile 'C:/music_project/data/userid-timestamp-artid-artname-traid-traname.tsv'
into table stg_listens
fields terminated by '\t' escaped by ''
lines terminated by '\n';