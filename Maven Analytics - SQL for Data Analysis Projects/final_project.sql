-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SELECT * FROM schools;
SELECT * FROM school_details;


-- 2. In each decade, how many schools were there that produced players?
SELECT 		yearID - MOD(yearID, 10) AS decade,		-- 2. Calculate the decade that each player attended the school
		COUNT(DISTINCT schoolID) AS schools		-- 4. Count the total distinct schools by each decade
FROM 		schools						-- 1. Use the schools table containing the player and school info
GROUP BY	decade						-- 3. Group by decade
ORDER BY	decade;						-- 5. Order by decade

]
-- 3. What are the names of the top 5 schools that produced the most players?
SELECT		sd.name_full, 
		COUNT(DISTINCT s.playerID) AS total_players	-- 3. Count distinct names of players by school
FROM		schools s					-- 1. Add school details info to player schools			
		LEFT JOIN school_details sd		
            	ON s.schoolID = sd.schoolID
GROUP BY	sd.name_full					-- 2. Group by schools' full name
ORDER BY	total_players DESC				-- 4. Order from most to least players produced by each school
LIMIT		5;						-- 5. Limit to top 5


-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
WITH player_school_info AS (
		SELECT		yearID - MOD(yearID, 10) AS decade,		-- 2. Calculate the decade that each player attended the school
				sd.name_full, 
				COUNT(DISTINCT s.playerID) AS total_players	-- 4. Count distinct players by decade and school attended
		FROM		schools s					-- 1. Add school details info to player schools		
				LEFT JOIN school_details sd
				ON s.schoolID = sd.schoolID
		GROUP BY	decade, sd.name_full),				-- 3. Group by decade and school full name
    
    schools_ranked AS (
		SELECT		decade, name_full, total_players,
				ROW_NUMBER() 							-- A1. Rank the schools from most to least attended
					OVER(PARTITION BY decade 				--     by the given players.
					     ORDER BY total_players DESC) AS school_rank	--     NOTE: Since ROW_NUMBER() is used, that means that
        	FROM		player_school_info)						--           some schools that have the same number of
																			--           attendees are not included
SELECT		*
FROM		schools_ranked									-- B1. Keep top 3 schools by decade 
WHERE		school_rank <= 3;


-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT * FROM salaries;


-- 2. Return the top 20% of teams in terms of average annual spending
WITH annual_spendings AS (
		SELECT		yearID, teamID, SUM(salary) AS total_spending	-- 2. Calculate the annual spendings of each team
		FROM		salaries
		GROUP BY	yearID, teamID),				-- 1. Group by year and team
	
    avg_annual_team_spendings AS (
		SELECT		teamID, AVG(total_spending) AS avg_spendings	-- 2. Calculate average annual spendings by each team
		FROM		annual_spendings								
        	GROUP BY	teamID),					-- 1. Group annual spendings by each team
        
	avg_team_spendings_divided AS (
		SELECT		teamID, avg_spendings,
				NTILE(5)					-- 1. Divide teams in 5 teams from most to leas average annual spendings
					OVER(ORDER BY avg_spendings DESC)
                        	  AS avg_spending_pct
		FROM		avg_annual_team_spendings)
        
SELECT		teamID, 
		ROUND(avg_spendings / POWER(10,6) , 2) AS avg_spendings_mil	-- 1. Round average annual spendings to millions be each team
FROM		avg_team_spendings_divided
WHERE		avg_spending_pct = 1						-- 2. Filter the top 20% of teams
ORDER BY	avg_spendings_mil DESC;						-- 3. Order by most to least average annual spendings


-- 3. For each team, show the cumulative sum of spending over the years
WITH annual_spendings AS (
		SELECT		yearID, teamID, SUM(salary) AS total_spending	-- 2. Calculate the annual spendings of each team
		FROM		salaries
		GROUP BY	yearID, teamID)					-- 1. Group by year and team
        
SELECT		teamID, yearID, 
			total_spending,
			ROUND(SUM(total_spending) 				-- 1. Calculate the cumulative sum of the annual spendings of each team in millions
			    	OVER(PARTITION BY teamID 
					ORDER BY yearID) / POWER(10,6), 2) 
				AS cumsum_team_spendings_millions
FROM		annual_spendings;


-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
WITH annual_spendings AS (
		SELECT		yearID, teamID, SUM(salary) AS total_spending	-- 2. Calculate the annual spendings of each team
		FROM		salaries
		GROUP BY	yearID, teamID),				-- 1. Group by year and team
        
	cum_sum_spendings AS (
		SELECT		teamID, yearID, 
				total_spending,
				ROUND(SUM(total_spending) 			-- 1. Calculate the cumulative sum of the annual spendings of each team in billions
				      OVER(PARTITION BY teamID 
					   ORDER BY yearID) / POWER(10,9), 2) 
					AS cumsum_team_spendings_bil
		FROM		annual_spendings),
        
	only_1_bill_total_spendings AS (
		SELECT		teamID, yearID, 
					total_spending,
					cumsum_team_spendings_bil,
					ROW_NUMBER() 				-- 2. Rank cumulative sum of the annual spendings of each team by year
						OVER(PARTITION BY teamID	
						ORDER BY yearID) 
						AS year_order
		FROM		cum_sum_spendings
		WHERE		cumsum_team_spendings_bil > 1)			-- 1. FIlter annual spendings that surpassed 1 billion
        
SELECT		teamID, yearID, 
			total_spending,
			cumsum_team_spendings_bil
FROM		only_1_bill_total_spendings
WHERE		year_order = 1;			-- 1. Find the first year where cumulative sum of the annual spendings of each team 
						--    surpassed 1 billion


-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
SELECT * FROM players;
SELECT 	COUNT(DISTINCT playerID) AS total_players
FROM 	players;


-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years).
--    Sort from longest career to shortest career.
WITH player_dates AS (
		SELECT		nameGiven,
				DATE(
					CONCAT(					-- 1. Convert Year, Month and Day of birth columns to one date
						CAST(birthYear AS CHAR), '-',
                            			CAST(birthMonth AS CHAR), '-',
                            			CAST(birthDay AS CHAR)
					)
				) AS DOB,
                    debut, finalGame
		FROM		players)
        
       
SELECT		nameGiven, DOB, debut, finalGame,
		TIMESTAMPDIFF(YEAR, DOB, debut) AS age_at_debut,		-- 1. Calculate age at debut
            	TIMESTAMPDIFF(YEAR, DOB, finalGame) AS age_at_final_game,	-- 2. Calculate age at final game
            	TIMESTAMPDIFF(YEAR, debut, finalGame) AS career_span		-- 3. Calculate career span in years
FROM		player_dates
ORDER BY	career_span DESC;						-- 4. Order by career span


-- 3. What team did each player play on for their starting and ending years?
WITH debut_team AS (
	SELECT		p.playerID, p.nameGiven,
			YEAR(p.debut) AS debut_year,		-- 2. Calculate debut year
			s.teamID
	FROM		players p				-- 1. Add salary info to players info
			INNER JOIN salaries s
			ON p.playerID = s.playerID			
                	AND YEAR(p.debut) = s.yearID),
                
	final_team AS (
	SELECT		p.playerID, p.nameGiven,
			YEAR(p.finalGame) AS final_year,	-- 2. Calculate final year
			s.teamID
	FROM		players p				-- 1. Add salary info to players info
			INNER JOIN salaries s
			ON p.playerID = s.playerID
                	AND YEAR(p.finalGame) = s.yearID)
                
                
SELECT		dt.playerID, dt.nameGiven,
		dt.debut_year, dt.teamID AS debut_team,		-- 2. Keep only relevant columns
            	ft.final_year, ft.teamID AS final_team
FROM		debut_team dt					-- 1. Join tables containing debut and final year for each player
		INNER JOIN final_team ft
            	ON dt.playerID = ft.playerID;


-- 4. How many players started and ended on the same team and also played for over a decade?
WITH debut_team AS (
	SELECT		p.playerID, p.nameGiven,
			YEAR(p.debut) AS debut_year,	-- 2. Calculate the debut year for each player
			s.teamID
	FROM		players p						-- 1. Add salary info to players' info, since it contains the debut team
			INNER JOIN salaries s
			ON p.playerID = s.playerID
                	AND YEAR(p.debut) = s.yearID),
                
	final_team AS (
	SELECT		p.playerID, p.nameGiven,
			YEAR(p.finalGame) AS final_year,	-- 2. Calculate the final year for each player
			s.teamID		
	FROM		players p				-- 1. Add salary info to players' info, since it contains the final team
			INNER JOIN salaries s
			ON p.playerID = s.playerID
                	AND YEAR(p.finalGame) = s.yearID),
                
	player_debut_final_teams AS (              
		SELECT		dt.playerID, dt.nameGiven,
				dt.debut_year, dt.teamID AS debut_team,	-- 2. Keep only relevant columns
				ft.final_year, ft.teamID AS final_team
		FROM		debut_team dt				-- 1. Join tables containing debut and final year for each player	
				INNER JOIN final_team ft
				ON dt.playerID = ft.playerID)
	
SELECT		*
FROM		player_debut_final_teams
WHERE		debut_team = final_team AND	-- 1. Filter players who debuted and finished in the same team
		final_year - debut_year > 10;	--    and also had career span over 10 years


-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
SELECT * FROM players;


-- 2. Which players have the same birthday?
WITH BOD_players AS (    
		SELECT		DATE(concat(birthYear, '-', 		-- 1. Convert Year, Month and Day of birth columns to one date
					    birthMonth, '-',
					    birthDay
				     )
				) AS bod, 						
				GROUP_CONCAT(nameGiven) AS player_names	-- 3. Use GROUP_CONCAT() function to concatate names of players who have the same birthday
		FROM		players
		GROUP BY	bod)					-- 2. Group by birthday
        
SELECT		*
FROM		BOD_players
WHERE		bod IS NOT NULL AND 			-- 1. Filter list of players with same birthday where the birthday is unknown
		NOT instr(player_names, ',') = 0; 	--    and only players do not share the birthday


3. Create a summary table that shows for each team, what percent of players bat right, left and both
WITH total_players_by_team AS (
	SELECT		teamID,
			COUNT(DISTINCT playerID) AS total_players	-- 2. Count total players by each team
    	FROM		salaries 
	GROUP BY	teamID						-- 1. Group by teams
	),

	total_players_bats_by_team AS (
		SELECT		s.teamID, p.bats, 
				ROUND((COUNT(DISTINCT s.playerID) / tp.total_players)*100, 2) 	-- 4. Calculate the percents
		        	    AS bats_pct
		FROM		salaries s							-- 1. Add players' info to salary info since it contains the type of bats	
				LEFT JOIN players p
				ON s.playerID = p.playerID
                    		LEFT JOIN total_players_by_team tp				-- 2. Add the total players by each team
                    		ON s.teamID = tp.teamID
		GROUP BY	s.teamID, p.bats)						-- 3. Group by teams and type of bats
        
SELECT		teamID,
		SUM(CASE WHEN bats = 'R' THEN bats_pct END) AS right_bats,	 -- 2. Pivoting the data from the previous table and summing the results
            	SUM(CASE WHEN bats = 'L' THEN bats_pct END) AS left_bats,	 --    NOTE: SUM() is used since the cases produce NULL when each case is not true
            	SUM(CASE WHEN bats = 'B' THEN bats_pct END) AS both_bats	 --          so the final values are in a column with NULL
FROM		total_players_bats_by_team
GROUP BY	teamID;								 -- 1. Group by team


-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
WITH	avg_weight_heigths AS (
		SELECT		YEAR(debut) - MOD(YEAR(debut), 10) AS debut_decade,		-- 1- Calculate debut decade
				AVG(weight) AS avg_weight,					-- 3. Calculate average weight by decade
				AVG(height) AS avg_height					-- 4. Calculate average height by decade
		FROM		players
		GROUP BY	debut_decade)							-- 2. Group by debut decade
        
SELECT		debut_decade, 
            	avg_weight - LAG(avg_weight) OVER(ORDER BY debut_decade) AS avg_weight_year_diff,	-- 1. Calculate the differences between each consecutive decade
            	avg_height - LAG(avg_height) OVER(ORDER BY debut_decade) AS avg_height_year_diff
FROM		avg_weight_heigths
WHERE		debut_decade IS NOT NULL;								-- 2. Filter unknown decades

