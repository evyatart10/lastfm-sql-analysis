create table users (
  user_id varchar(20) primary key,
  gender char(1),
  age int,
  country varchar(100),
  registered_date date
);

insert into users
select user_id,
       nullif(gender, ''),
       nullif(age, ''),
       nullif(country, ''),
       str_to_date(nullif(trim(registered), ''), '%b %e, %Y')
from stg_profile;

select count(*) from users;
select * from users limit 5;

select sum(age is null), sum(country is null), sum(country = '') from users;