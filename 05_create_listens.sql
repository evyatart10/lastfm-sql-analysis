use music_project;

create index idx_tracks_artist_name on tracks(artist_id, track_name);

drop table if exists listens;
create table listens (
  listen_id bigint auto_increment primary key,
  user_id varchar(20),
  track_id int,
  played_at datetime
);

insert into listens (user_id, track_id, played_at)
select s.user_id, t.track_id, str_to_date(s.played_at, '%Y-%m-%dT%H:%i:%sZ')
from stg_listens s
join artists a on a.artist_name = s.artist_name
join tracks t on t.artist_id = a.artist_id and t.track_name = s.track_name;

select count(*) from listens;