use music_project;

-- Q1: top 10 artists by number of listens

select a.artist_name, count(*) as num_of_listens
from listens l
join tracks t on t.track_id = l.track_id
join artists a on a.artist_id = t.artist_id
group by a.artist_id, a.artist_name
order by num_of_listens desc
limit 10;

-- Q2: top 3 artists per user

select *
from(
select *,
dense_rank() over (partition by user_id order by num_of_listens desc) as rnk
from(
select l.user_id, a.artist_id, a.artist_name, count(*) as num_of_listens
from listens l
join tracks t on t.track_id = l.track_id
join artists a on a.artist_id = t.artist_id
group by l.user_id, a.artist_id, a.artist_name
) t
) f
where rnk <= 3
order by user_id, rnk

-- Q3: listens by hour of day

select hour(played_at) as hour_of_play, count(*) as num_of_listens
from listens 
group by hour_of_play
order by hour_of_play asc;

-- Q4: 7-day moving average of daily listens

select day_of_playing, moving_avg
from(
select day_of_playing, round(avg(cnt) over (order by day_of_playing rows between 6 preceding and 
current row), 2) as moving_avg,
row_number() over (order by day_of_playing) as rnk
from(
select date(played_at) as day_of_playing, count(*) as cnt
from listens
group by day_of_playing
) t 
) f
where rnk > 6
order by day_of_playing

-- Q5: number of listening sessions per user

select user_id, sum(new_session) as num_sessions
from(
select user_id, played_at, prev_played,
case when prev_played is null or timestampdiff(minute, prev_played, played_at) > 30 then 1 else 0 end as new_session
from( 
select user_id, played_at,
       lag(played_at) over (partition by user_id order by played_at) as prev_played
from listens
) t
) f
group by user_id
order by num_sessions desc
limit 10;

-- Q6: average listens per session (active users, >= 100 listens)
-- note: user_000691: 273 sessions, avg 485 listens/session (likely always-on player),

select user_id, count(*) as num_sessions, round(avg(listens_in_session), 1) as avg_listens_per_session
from(
    select user_id, session_id, count(*) as listens_in_session
	from(
		select user_id, played_at, new_session, 
		sum(new_session) over(partition by user_id order by played_at) as session_id
			from(
			select user_id, played_at, prev_played,
			case when prev_played is null or timestampdiff(minute, prev_played, played_at) > 30 then 1 else 0 end as new_session
				from( 
				select user_id, played_at,
				lag(played_at) over (partition by user_id order by played_at) as prev_played
					from listens
				) t

			) f
		) s
    group by user_id, session_id
) g
group by user_id
having sum(listens_in_session) >= 100
order by avg_listens_per_session desc
limit 10;

-- Q7: repeat-listen rate per user

select user_id, count(*) as listens, round(avg(rn > 1), 3) as repeat_rate
from (
    select user_id, track_id,
           row_number() over (partition by user_id, track_id order by played_at) as rn
    from listens
) t
group by user_id
having count(*) >= 100
order by repeat_rate desc
limit 10;

-- Q8a: top artist per country (by listens)

with country_artist as (
    select a.artist_name, u.country, count(*) as num_of_listens
    from listens l
    join users u on u.user_id = l.user_id
    join tracks t on t.track_id = l.track_id
    join artists a on a.artist_id = t.artist_id
    group by a.artist_name, u.country
),
ranked as (
    select artist_name, country, num_of_listens,
           dense_rank() over (partition by country order by num_of_listens desc) as rnk
    from country_artist
)
select country, artist_name, num_of_listens as listens
from ranked
where rnk = 1
order by listens desc;

-- Q8b: top artist per country (by distinct users, countries with 10+ users)

with country_artist as (
    select a.artist_name, u.country, count(distinct l.user_id) as num_of_users
    from listens l
    join users u on u.user_id = l.user_id
    join tracks t on t.track_id = l.track_id
    join artists a on a.artist_id = t.artist_id
    where u.country in (select country from users group by country having count(*) >= 10)
    group by a.artist_name, u.country
),
ranked as (
    select artist_name, country, num_of_users,
           dense_rank() over (partition by country order by num_of_users desc) as rnk
    from country_artist
)
select country, artist_name, num_of_users
from ranked
where rnk = 1
order by country, artist_name;

-- Q9: 

select sum(new_session) as total_sessions
from(
select user_id, played_at, prev_played,
case when prev_played is null or timestampdiff(minute, prev_played, played_at) > 15 then 1 else 0 end as new_session
from( 
select user_id, played_at,
       lag(played_at) over (partition by user_id order by played_at) as prev_played
from listens
) t
) f
;

select sum(new_session) as total_sessions
from(
select user_id, played_at, prev_played,
case when prev_played is null or timestampdiff(minute, prev_played, played_at) > 30 then 1 else 0 end as new_session
from( 
select user_id, played_at,
       lag(played_at) over (partition by user_id order by played_at) as prev_played
from listens
) t
) f
;

select sum(new_session) as total_sessions
from(
select user_id, played_at, prev_played,
case when prev_played is null or timestampdiff(minute, prev_played, played_at) > 60 then 1 else 0 end as new_session
from( 
select user_id, played_at,
       lag(played_at) over (partition by user_id order by played_at) as prev_played
from listens
) t
) f
;

-- Results: 15 min = 1,142,833 | 30 min = 901,709 | 60 min = 739,901