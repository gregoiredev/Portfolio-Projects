SELECT *
FROM
	Portfolio_Project..covid_deaths
WHERE
	continent is not null
ORDER BY 
	3,4

SELECT 
	*
FROM
	Portfolio_Project..covid_vaccinations
WHERE
	continent is not null
ORDER BY 
	3,4

-- Select data that we are going to be using

SELECT
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	Portfolio_Project..covid_deaths
WHERE
	continent is not null
ORDER BY 
	1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if ou contract COVID in México

SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	(CAST(total_deaths as float)/total_cases)*100 AS death_percentage
FROM
	Portfolio_Project..covid_deaths
WHERE 
	location = 'México' AND continent is not null
ORDER BY 
	1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT
	Location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS sick_percentage
FROM
	Portfolio_Project..covid_deaths
WHERE
	continent is not null
ORDER BY 
	1, 2


-- Looking at countries with highest infection rate compared to population

SELECT
	Location,
	population,
	MAX(total_cases) AS Highest_Infection_Count,
	MAX((total_cases)/MAX(population))*100 AS infection_percentage
FROM
	Portfolio_Project..covid_deaths
WHERE
	continent is not null
GROUP BY
	Location,
	population	
ORDER BY 
	infection_percentage DESC


-- Showing countries with highest death count per population

SELECT
	Location,
	MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM
	Portfolio_Project..covid_deaths
WHERE
	continent is not null
GROUP BY
	Location
ORDER BY 
	Total_Death_Count DESC 


-- Showing highest death count by continent

SELECT
	Location,
	MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM
	Portfolio_Project..covid_deaths
WHERE
	continent is null
GROUP BY
	Location
ORDER BY 
	Total_Death_Count DESC


-- Global numbers

SELECT
	SUM(new_cases) as total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/(SUM(new_cases))*100 AS death_percentage
FROM
	Portfolio_Project..covid_deaths
WHERE
	continent is not null
ORDER BY
	1, 2


-- Looking at Total Population vs Vaccinations

SELECT
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY death.Location ORDER BY death.Location, death.Date) AS Rolling_People_Vaccinated
FROM
	Portfolio_Project..covid_deaths AS death
JOIN
	Portfolio_Project..covid_vaccinations AS vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE 
	death.continent is not null
ORDER BY 
	2, 3


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
Location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY death.Location ORDER BY death.Location, death.Date) AS Rolling_People_Vaccinated
FROM
	Portfolio_Project..covid_deaths AS death
JOIN
	Portfolio_Project..covid_vaccinations AS vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE 
	death.continent is not null

SELECT 
	*,
	(rolling_people_vaccinated/population)*100 AS percentage
FROM #PercentPopulationVaccinated


-- Creating Views to store data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	death.continent,
	death.location,
	death.date,
	death.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY death.Location ORDER BY death.Location, death.Date) AS Rolling_People_Vaccinated
FROM
	Portfolio_Project..covid_deaths AS death
JOIN
	Portfolio_Project..covid_vaccinations AS vac
	ON death.location = vac.location
	AND death.date = vac.date
WHERE 
	death.continent is not null
