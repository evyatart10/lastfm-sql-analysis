use music_project;

create index idx_artist_name on artists(artist_name);

drop table if exists tracks;
create table tracks (
  track_id int auto_increment primary key,
  artist_id int,
  track_name varchar(500),
  track_mbid varchar(40)
);

insert into tracks (artist_id, track_name, track_mbid)
select a.artist_id, s.track_name, min(nullif(s.track_mbid, ''))
from stg_listens s
join artists a on a.artist_name = s.artist_name
group by a.artist_id, s.track_name;

select count(*) from tracks;