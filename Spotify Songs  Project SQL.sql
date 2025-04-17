
-- Spotify Songs Data Analyst Project
 
use spotify;
select * from spotifysongs;

-- Basic Level Queries

-- 1. Find the Total Streams by Genre 
select genre,sum(stream)as total_streams
from spotifysongs
group by genre
order by total_streams;

-- 2. Get the Top 10 Most Streamed Songs  
select distinct song_title,artist,stream
from spotifysongs
order by stream desc
limit 10;

-- 3. Count of Explicit vs. Non-Explicit Songs
select explicit_content, count(*) as Song_count
from spotifysongs
group by explicit_content;

-- 4. Find the Average Song Duration by Language
select language, avg(duration) as Avg_Duration_seconds
from spotifysongs
group by language;  

-- 5. Number of Songs Released Each Year 
select release_date as Year, count(*) as Songs_Released
from spotifysongs
group by Year
order by Year;

-- Intermediate Level

-- 6. Artists with the Most Collaborations
select artist, count(*) as collaboration_count 
from spotifysongs 
group by artist 
order by collaboration_count desc;
    
-- 7. Top 5 Labels by Total Streams
select label, sum(stream) as total_Streams 
from spotifysongs 
group by label 
order by total_Streams desc 
limit 5; 

-- 8. Most Prolific Composers (Top 10)
SELECT composer, count(distinct song_id) as Songs_Composed 
from spotifysongs 
group by composer 
order by Songs_Composed desc 
limit 10;

-- 9. Genre Popularity Trend Over Time Years
select Release_date as Year, genre, sum(stream) as Streams 
from spotifysongs 
group by Year, genre 
order by Year, Streams desc; 

-- 10. Find Artists with Songs in Multiple Languages
select artist, count(distinct language) as Languages_Count 
from spotifysongs 
group by artist 
having count(distinct language) > 1 
order by Languages_Count desc; 

-- 11. Songs with Longest Duration per Genre
select distinct genre, song_title, artist, duration 
from (
    select genre, song_title, artist, duration, 
           rank() over (partition by genre order by duration desc) as rank_
    FROM spotifysongs
) as ranked_songs
where rank_ = 1;

-- Advanced Level

-- 12. Year on year Growth Rate in Streams by Genre
with Yearly_Streams as (
    select distinct Genre, Release_date as Year, sum(Stream) as Streams 
    from Spotifysongs 
   group by Genre, Year
)
select distinct Genre, Year, Streams, 
       (Streams - lag(Streams) over (partition by Genre order by Year)) / lag(Streams) 
       over (partition by Genre order by Year) * 100 as Growth_Percentage 
from Yearly_Streams 
order by Genre, Year; 

-- 13. Identify "Hit" Songs (Top 1% by Streams)
with Percentile AS (
    select distinct Song_title, Artist, Stream, 
           ntile(100) over (order by Stream desc) as Percentile_Rank 
    from Spotifysongs
)
select Song_title, Artist, Stream 
from Percentile 
where Percentile_Rank = 1; 

-- 14. Producer-Artist Pairs with Highest Success Rate
select Producer, Artist, avg(Stream) as Avg_Streams, count(*) as Songs_Produced 
from Spotifysongs 
group by Producer, Artist 
having count(*) > 3 
order by Avg_Streams desc ;


-- 15. 	Label Market Share by Genre
with Genre_Label_Streams as (
    select Genre, label, sum(Stream) as Total_Streams 
    from Spotifysongs 
   group by Genre, label
),
Genre_Totals as (
    select Genre, sum(Total_Streams) as Genre_Total 
    from Genre_Label_Streams 
    group by Genre
)
select gls.Genre, gls.label, 
       (gls.Total_Streams / gt.Genre_Total) * 100 as Market_Share_Percentage 
from Genre_Label_Streams gls 
join Genre_Totals gt on gls.Genre = gt.Genre 
order by gls.Genre, Market_Share_Percentage desc; 


  