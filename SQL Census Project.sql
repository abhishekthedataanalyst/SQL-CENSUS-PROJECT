SELECT * FROM census.data1;
SELECT * FROM census.data2;

-- numbers of rows in datasets
SELECT count(*) FROM census.data1;
SELECT count(*) FROM census.data2;

-- data for Jharkhand and Bihar
SELECT * FROM data1
WHERE State IN ('Jharkhand' , 'Bihar');

-- total population of India
SELECT  SUM(population) AS Total_Population
FROM data2;

-- avg growth
SELECT AVG(growth) AS avg_growth
FROM data1;

-- avg growth per state 
SELECT  state, AVG(growth) AS avg_growth
FROM data1
GROUP BY state;

-- avg sex ratio
SELECT state, ROUND(AVG(Sex_Ratio)) AS avg_sex_ratio
FROM data1
GROUP BY state
ORDER BY avg_sex_ratio DESC;

-- avg literacy rate
SELECT State, ROUND(AVG(Literacy)) AS avg_literacy_ratio
FROM data1
GROUP BY State
HAVING avg_literacy_ratio > 90
ORDER BY avg_literacy_ratio DESC;

-- top 3 state showing highest growth ratio
SELECT state, AVG(growth) AS avg_growth
FROM data1
GROUP BY state
ORDER BY avg_growth DESC
LIMIT 3;
    
-- bottom 3 state showing lowest sex ratio
SELECT state, ROUND(AVG(Sex_Ratio)) AS avg_sex_ratio
FROM data1
GROUP BY state
ORDER BY avg_sex_ratio ASC
LIMIT 3;

-- top and bottom 3 states in literacy state
CREATE TABLE topstates (
    State NVARCHAR(255),
    topstate FLOAT
);

INSERT INTO topstates
SELECT State, ROUND(AVG(Literacy)) AS avg_literacy_ratio
FROM data1
GROUP BY State
ORDER BY avg_literacy_ratio DESC;

SELECT *
FROM topstates
ORDER BY topstate DESC
LIMIT 3;

-- bottom

CREATE TABLE bottomstates (
    State NVARCHAR(255),
    bottomstate FLOAT
);

INSERT INTO bottomstates
SELECT State, ROUND(AVG(Literacy)) AS avg_literacy_ratio
FROM data1
GROUP BY State 
ORDER BY avg_literacy_ratio DESC;

SELECT *
FROM bottomstates
ORDER BY bottomstate ASC
LIMIT 3;

-- using union operator

SELECT * FROM
    (SELECT * FROM topstates
    ORDER BY topstate DESC
    LIMIT 3) AS a 
UNION 
SELECT * FROM
    (SELECT * FROM bottomstates
    ORDER BY bottomstate ASC
    LIMIT 3) AS b;

-- states starting with letter a

SELECT DISTINCT State
FROM data1
WHERE State LIKE 'A%' OR State LIKE 'B%';

-- states starting with letter a and ending with m

SELECT DISTINCT State
FROM data1
WHERE State LIKE 'A%' AND State LIKE '%M';


-- joining both table, calculating total males and females
 
SELECT d.state, SUM(d.males), SUM(d.females)
FROM
(SELECT c.district, c.state, ROUND(c.population / (c.sex_ratio + 1), 0) AS males,
		ROUND((c.population * c.sex_ratio) / (c.sex_ratio + 1), 0) AS females
    FROM (SELECT  a.district, a.state, a.sex_ratio / 1000 AS sex_ratio, b.population
    FROM data1 AS a
    INNER JOIN data2 AS b ON a.District = b.District) AS c) AS d
GROUP BY d.state;

-- total literacy rate

SELECT c.state,
    SUM(literate_people) AS total_literate_pop,
    SUM(illiterate_people) AS total_lliterate_pop
FROM
    (SELECT d.district, d.state,
            ROUND(d.literacy_ratio * d.population, 0) AS literate_people,
            ROUND((1 - d.literacy_ratio) * d.population, 0) AS illiterate_people
    FROM
        (SELECT a.district, a.state, a.literacy / 100 literacy_ratio, b.population
    FROM
        data1 AS a
    INNER JOIN data2 AS b ON a.district = b.district)As d) As c
GROUP BY c.state;

-- population in previous census

SELECT 
    SUM(m.previous_census_population) AS previous_census_population,
    SUM(m.current_census_population) AS current_census_population
FROM
    (SELECT e.state, 
		SUM(e.previous_census_population) AS previous_census_population,
		SUM(e.current_census_population) AS current_census_population
    FROM
        (SELECT d.district, d.state,
            ROUND(d.population / (1 + d.growth), 0) AS previous_census_population,
            d.population AS current_census_population
    FROM
        (SELECT a.district, a.state, a.growth AS growth, b.population
    FROM
        data1 AS a
    INNER JOIN data2 AS b ON a.district = b.district) AS d) AS e
    GROUP BY e.state) AS m;

-- top 3 districts from each state with highest literacy rate

SELECT a.* FROM
	(SELECT district, state, literacy, 
		RANK() OVER(PARTITION BY state ORDER BY literacy DESC) AS rnk FROM data1) AS a
WHERE a.rnk IN (1,2,3) ORDER BY STATE;
	