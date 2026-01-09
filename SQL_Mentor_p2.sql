-- Project: SQL Mentor:
-- SQL Mentor User Performance

-- DROP TABLE user_submissions; 

-- Creating the user_submissions table and inserting data
CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(50)
);

SELECT * FROM user_submissions;

-- Finding insights in the data:

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.

-- Solving Question --

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)

Select
     username,
	 count(id) as total_submissions,
	 sum(points) as points_earned
FROM user_submissions
GROUP BY username
ORDER BY total_submissions DESC
	 
-- Q.2 Calculate the daily average points for each user.

Select
    --Extract(DAY FROM submitted_at) as day
	 TO_CHAR(submitted_at,'DD-MM') as day,
     username,
	 Avg(points) as daily_avg_points
FROM user_submissions
GROUP BY 1,2
ORDER BY username;


-- Q.3 Find the top 3 users with the most positive submissions for each day.

WITH daily_submissions
AS
(
Select
    --Extract(DAY FROM submitted_at) as day
	 TO_CHAR(submitted_at,'DD-MM') as daily,
     username,
	 SUM(CASE
	     WHEN points > 0 THEN 1 ELSE 0
	 END) as correct_submissions
FROM user_submissions
GROUP BY 1,2
),
users_rank
as
(SELECT
     daily,
	 username,
	 correct_submissions,
	 DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) as rank
FROM daily_submissions
)
SELECT 
	daily,
	username,
	correct_submissions
FROM users_rank
WHERE rank <= 3;

-- Q.4 Find the top 5 users with the highest number of incorrect submissions.

SELECT
     username,
	 sum(CASE
	     WHEN points < 0 THEN 1 ELSE 0
		 END) as incorrect_submissions,
	 sum(CASE
	     WHEN points > 0 THEN 1 ELSE 0
		 END) as correct_submissions,
	 sum(CASE
	     WHEN points < 0 THEN points ELSE 0
		 END) as incorrect_submissions_points,
	 sum(CASE
	     WHEN points > 0 THEN points ELSE 0
		 END) as correct_submissions_earned_points,
	 sum(points) as point_earned
FROM user_submissions
GROUP BY 1
ORDER BY incorrect_submissions DESC
LIMIT 5

-- Q.5 Find the top 10 performers for each week.


SELECT *  
FROM
(
	SELECT 
		-- WEEK()
		EXTRACT(WEEK FROM submitted_at) as week_no,
		username,
		SUM(points) as total_points_earned,
		DENSE_RANK() OVER(PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) as rank
	FROM user_submissions
	GROUP BY 1, 2
	ORDER BY week_no, total_points_earned DESC
)
WHERE rank <= 10



-- THE END --
