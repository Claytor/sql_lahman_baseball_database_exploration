--1. Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

WITH earnings AS(
	SELECT playerid,
		SUM(salary)::numeric::money AS big_league_pay 
	FROM salaries
	GROUP BY playerid),
vandy AS(
	SELECT DISTINCT(playerid)
	FROM collegeplaying
	WHERE schoolid = 'vandy')
SELECT playerid, p.namelast, p.namefirst, big_league_pay 
FROM people as p
INNER JOIN vandy
USING(playerid)
LEFT JOIN earnings
USING(playerid)
ORDER BY big_league_pay DESC;
--DAVID Price earned the most money.  Why is there no pay information about Scrappy Moore?  Slim Embry? 

--2. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
SELECT 
	CASE WHEN pos = 'OF' THEN 'Outfield' 
		WHEN pos IN('SS', '1B', '2B', '3B') THEN 'Infield' 
		WHEN pos IN ('P', 'C') THEN 'Battery' END AS position, 
	SUM(po) as put_outs	
FROM fielding
WHERE yearid = '2016'
GROUP BY position
ORDER BY put_outs DESC;
-- Infield - 58,934; Battery - 41,424; Outfield - 29,560 

--3. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends? (Hint: For this question, you might find it helpful to look at the **generate_series** function (https://www.postgresql.org/docs/9.1/functions-srf.html). If you want to see an example of this in action, check out this DataCamp video: https://campus.datacamp.com/courses/exploratory-data-analysis-in-sql/summarizing-and-aggregating-numeric-data?ex=6)

WITH decade AS (SELECT 
generate_series (1920, 2016, 10) AS decade)
	SELECT decade::text || 's' AS decade,
	COALESCE(ROUND (SUM(so)*1.0/SUM(g), 2), 0) as Avg_Strikeouts,
	COALESCE(ROUND (SUM(hr)*1.0/SUM(g), 2), 0) as Avg_Homeruns
	FROM pitching
	INNER JOIN decade
		ON decade+1 <= yearid 
		AND decade+10 >= yearid
		WHERE yearid >= 1920
		GROUP BY decade
	ORDER BY decade ASC;
-- Trends in both had been increasing from the 20s to the 1960s.  Strikeouts started declining after that point and homeruns remained around 3%

--4. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases. Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.

SELECT namelast,
	namegiven,
	sb AS stolen,
	cs AS caught,
	b.sb + b.cs AS attempts,
	ROUND(b.sb *100.0/(b.sb + b.cs), 2)AS success
FROM batting as b
INNER JOIN people AS p
ON b.playerid = p.playerid
WHERE b.sb + b.cs >= 20 AND yearid = 2016
ORDER BY success DESC;
-- Chris Owens was the most successful stealer.

--5a. From 1970 to 2016, what is the largest number of wins for a team that did not win the world series? 
SELECT name, SUM(w) as wins
FROM teams
WHERE wswin = 'N' AND yearid BETWEEN 1970 AND 2016
GROUP BY name
ORDER BY wins DESC;
-- The Los Angeles Dodgers had the largest number of wins while not winning the world series during this time.

--5b. What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion; determine why this is the case. 
SELECT name, SUM(w) as wins
FROM teams
WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016
GROUP BY name
ORDER BY wins DESC;
--

--5c. Then redo your query, excluding the problem year. 
SELECT name, SUM(w) as wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND yearid !=1981
GROUP BY name
ORDER BY wins;

--5d. How often from 1970 to 2016 was it the case that a team with the most wins also won the world series?
WITH wins AS(
	SELECT DISTINCT(yearid), name, MAX(w) OVER(PARTITION BY yearid) AS team_wins 
	FROM teams
	WHERE yearid between 1970 AND 2016
	GROUP BY yearid, teams.w
	ORDER BY yearid DESC),
	team_wins AS(
	SELECT yearid, name, WSwin AS worldseries
	FROM teams
	WHERE yearid between 1970 AND 2016
	GROUP BY yearid, name, worldseries)
SELECT yearid, name, season_wins, worldseries
FROM wins
LEFT JOIN team_wins
USING (yearid)
ORDER BY yearid

	
	
	
	
SELECT yearid, name, WSwin AS worldseries, MAX(w) AS wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND yearid !=1981
GROUP BY yearid, name, WSwin

--5e. What percentage of the time?

--6. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
SELECT *
FROM awardsmanagers 


--7. Which pitcher was the least efficient in 2016 in terms of salary / strikeouts? Only consider pitchers who started at least 10 games (across all teams). Note that pitchers often play for more than one team in a season, so be sure that you are counting all stats for each player.

--8. Find all players who have had at least 3000 career hits. Report those players' names, total number of hits, and the year they were inducted into the hall of fame (If they were not inducted into the hall of fame, put a null in that column.) Note that a player being inducted into the hall of fame is indicated by a 'Y' in the **inducted** column of the halloffame table.

--9. Find all players who had at least 1,000 hits for two different teams. Report those players' full names.

--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

--After finishing the above questions, here are some open-ended questions to consider.

--**Open-ended questions**

--11. Is there any correlation between number of wins and team salary? Use data from 2000 and later to answer this question. As you do this analysis, keep in mind that salaries across the whole league tend to increase together, so you may want to look on a year-by-year basis.

--12. In this question, you will explore the connection between number of wins and attendance.
--a. Does there appear to be any correlation between attendance at home games and number of wins?  
--b. Do teams that win the world series see a boost in attendance the following year? What about teams that made the playoffs? Making the playoffs means either being a division winner or a wild card winner.


--13. It is thought that since left-handed pitchers are more rare, causing batters to face them less often, that they are more effective. Investigate this claim and present evidence to either support or dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it into the hall of fame?