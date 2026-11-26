use music_project;

drop table if exists artists;
create table artists (
  artist_id int auto_increment primary key,
  artist_name varchar(500),
  artist_mbid varchar(40)
);

insert into artists (artist_name, artist_mbid)
select artist_name, min(nullif(artist_mbid, ''))
from stg_listens
group by artist_name;

select count(*) from artists;