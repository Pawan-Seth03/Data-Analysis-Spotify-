DROP TABLE IF EXISTS SPOTIFY;

CREATE TABLE spotify(
artist VARCHAR(255),
track VARCHAR(255),
album VARCHAR(255),
albumtype VARCHAR(50),
danceability float,
energy float,
loudness FLOAT,
speechiness FLOAT, 
Acoustiness FLOAT,
instrumentalness FLOAT,
liveness FLOAT,
valence FLOAT,
tempo FLOAT,
durationmin FLOAT,
title VARCHAR(255),
channel VARCHAR(255),
views FLOAT,
likes BIGINT,
comments BIGINT,
licensed BOOLEAN,
officialvideo BOOLEAN,
stream BIGINT,
energy_liveness Float,
mostplayedon VARCHAR(50)
);

SELECT * FROM spotify
LIMIT(10);
--COUNT OF ARTIST
SELECT COUNT(DISTINCT artist) FROM spotify;

SELECT COUNT(DISTINCT album) FROM spotify;

SELECT DISTINCT albumtype FROM spotify;

SELECT MAX(durationmin) FROM spotify;

SELECT Min(durationmin) FROM spotify;

SELECT * FROM  spotify
WHERE durationmin=0;

DELETE FROM spotify
WHERE durationmin = 0;

SELECT * FROM  spotify
WHERE durationmin=0;

SELECT DISTINCT channel FROM spotify;
SELECT DISTINCT mostplayedon FROM spotify;

-- ----------------------
-- EASY LEVEL QUESTIONS
-- ----------------------
-- Q1 Retrieve the names of all the tracks that have more than 1 billion streams
SELECT track, stream
FROM spotify
WHERE stream > 1000000000
ORDER BY stream DESC;

-- Q2 List all the albums along with their respective artist
SELECT DISTINCT album, artist
FROM spotify;

-- Q3 Get the total number of comments for track when licensed = TRUE
SELECT SUM(comments)
FROM spotify
WHERE licensed = TRUE;
-- Q4 Find all the track that belong to the album type single 
SELECT track
FROM spotify
WHERE albumtype = 'single';
-- Q5 Count the total number of tracks by each Artist
SELECT artist, COUNT(track)
FROM spotify
GROUP BY artist
ORDER BY COUNT(track) DESC;

-- ----------------------
-- MEDIUM LEVEL QUESTIONS
-- ----------------------

-- Q6 Calculate the average danceablility of track in each album
SELECT DISTINCT album, AVG(danceability)
FROM spotify 
GROUP BY album
ORDER BY AVG(danceability);
-- Q7 Find the top 5 track with the highest energy values
SELECT track, AVG(energy)
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT(5);
-- Q8 List all the tracks along with their views and likes where official_VIDEO = TRUE

SELECT track, SUM(views) AS totalVIEWS, SUM(likes) AS totalLIKES
FROM spotify
WHERE officialvideo = 'TRUE'
GROUP BY 1
ORDER BY 2 DESC;
-- Q9 For each album calculate the total views of all associated tracks 
SELECT album,track, SUM(views) AS totalviews
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;
-- Q10 Retrieve the track names that have been streamed on spotify more than youtube
SELECT * FROM
(SELECT track,
	COALESCE(SUM(CASE WHEN mostplayedon = 'Youtube' THEN STREAM END),0)AS Stream_on_Youtube,
	COALESCE(SUM(CASE WHEN mostplayedon = 'Spotify' THEN STREAM END),0)AS Stream_on_Spotify
FROM spotify
GROUP BY 1
)AS t1
WHERE 
	Stream_on_Spotify > Stream_on_Youtube
	AND 
	Stream_on_Youtube <> 0 ;
-- -----------------------
-- ADVANCE LEVEL QUESTIONS
-- -----------------------

-- Q11 Find the top 3 most viewed tracks for each artist using window function
WITH ranking_artist 
AS
(SELECT 
	artist,
	track,
	SUM(views) AS total_views,
	DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC ) AS rank
FROM spotify
GROUP BY 1, 2 
ORDER BY 1,3 DESC)
SELECT * FROM ranking_artist
WHERE rank <= 3;
-- Q12 Write a query to find track where the liveness score is above the average
SELECT *
FROM spotify
WHERE liveness > (SELECT AVG (liveness) FROM spotify);
-- Q13 Use a WITH clause to calculate the difference between the heighest and the lowest energy values for tack in each album
WITH CTE
AS
(SELECT album,
	MAX(energy) AS HIGH,
	MIN(energy) AS LOW
FROM spotify
GROUP BY 1)
SELECT album,
	HIGH - LOW AS difference
FROM CTE
ORDER BY 2 DESC
-- Q14 Find the track where the energy-liveness ratio is greater than 1.2
SELECT track , energy_liveness 
FROM spotify
WHERE energy_liveness > 1.2
ORDER BY 2 DESC

-- Q15 Calculate the cumulative sum of likes for the track 
--ordered by the number of views, using window function
SELECT 
    artist,
    track,
    views,
    likes,
    SUM(likes) OVER (ORDER BY views) AS cumulative_likes
FROM 
    spotify
ORDER BY 
    Views;

-- QUERY optimization
EXPLAIN ANALYZE -- "Execution Time: 2.961 ms" AND AFTER OPTIMIZATION "Execution Time: 0.077 ms"
SELECT 
	artist,
	track,
	views
FROM spotify
WHERE artist = 'Gorillaz'
	AND  		
	mostplayedon = 'Youtube'
ORDER BY stream DESC LIMIT(25)

CREATE INDEX artist_index ON spotify(artist);

