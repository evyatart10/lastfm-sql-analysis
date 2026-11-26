use music_project;

create index idx_listens_user_time on listens (user_id, played_at);
create index idx_listens_track on listens (track_id);

alter table tracks
  add constraint fk_tracks_artist foreign key (artist_id) references artists (artist_id);
alter table listens
  add constraint fk_listens_user foreign key (user_id) references users (user_id);
alter table listens
  add constraint fk_listens_track foreign key (track_id) references tracks (track_id);