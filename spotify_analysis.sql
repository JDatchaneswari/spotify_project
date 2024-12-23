-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
COPY spotify  
FROM 'C:\Users\Admin\Downloads\archive\cleaned_dataset.csv' with csv header;

SELECT * FROM spotify;
SELECT COUNT(*) FROM spotify;

select max(duration_min)from spotify;
select min(duration_min)from spotify;


select * from spotify where duration_min=0;

delete from spotify where duration_min=0;

select count(distinct artist)from spotify;

select distinct album_type from spotify;

select distinct channel from spotify;

select distinct most_played_on from spotify;

-- 15 Problem Statement

--1.Retrieve the names of all tracks that have more than 1 billion streams.
    select * from spotify 
	where stream > 1000000000;
	
--2.List all albums along with their respective artists.
    select distinct artist,album from spotify
	order by album;
	
--3.Get the total number of comments for tracks where licensed = TRUE.
    select sum(comments) from spotify where licensed='true';
	
--4.Find all tracks that belong to the album type single.
    select track from spotify where album_type = 'single'
	
--5.Count the total number of tracks by each artist.
    select artist,count(track) as total_track  from spotify
	group by artist
	order by total_track;
	
--6.Calculate the average danceability of tracks in each album.
    select album,avg(danceability) as avg_danceability from spotify 
	group by album
	order by 2 desc;
	
--7.Find the top 5 tracks with the highest energy values.
    select track,max(energy)as max from spotify
	group by track
	order by max desc limit 5;
	
--8.List all tracks along with their views and likes where official_video = TRUE.
    select track,sum(views) as total_views,
	sum(likes)as total_likes from spotify
	where official_video=true
	group by track
	order by total_views desc;
	
--9.For each album, calculate the total views of all associated tracks.
    select album,track,sum(views)as total_views 
	from spotify
	group by track,album
	order by total_views desc;
--10.Retrieve the track names that have been streamed on Spotify more than YouTube.
    Select * from (
    select track,
    coalesce(sum(case when most_played_on='Youtube'then stream end),0)as stream_in_YT,
    coalesce(sum(case when most_played_on='Spotify'then stream end),0)as stream_in_spotify
    from spotify
    group by track
    )as cte
    where stream_in_spotify > stream_in_YT
    and stream_in_YT <> 0;

--11.Find the top 3 most-viewed tracks for each artist using window functions.
    with cte as(
	select artist,track,sum(views)as total_view,
	dense_rank() over(partition by artist order by sum(views) desc)as rank
	from spotify
	group by artist,track
	order by 1,3 desc)
	select * from cte where rank <=3;
	
--12.Write a query to find tracks where the liveness score is above the average.
    select track from spotify where liveness > (select avg(liveness) as avg_live
	from spotify);
	
--13.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
    with cte
    as 
    (select 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
    from spotify
    group by album
    )
    select
	album,
	highest_energy - lowest_energery as energy_diff
    from cte
    order by energy_diff desc;
	
--14.Find tracks where the energy-to-liveness ratio is greater than 1.2.
    select track,
	(energy/liveness) as ratio
	from spotify
	where liveness>0 and (energy/liveness) >1.2;
	
--15.Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
    select track,
	sum(likes)over(order by views)as cum_sum_likes
	from spotify
	order by sum(likes)over(order by views)desc;