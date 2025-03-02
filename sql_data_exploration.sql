-- Looking at the data that I'm going to use

SELECT
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
FROM 
  CovidDeaths
ORDER BY
  1,2;

-- Looking at Total Cases vs. Total Deaths (Calculating the percentage)
-- Shows roughly the likelihood of dying when contracted with covid

SELECT
  location, 
  date, 
  total_cases, 
  total_deaths,
  ROUND((CAST(total_deaths AS float)/NULLIF(CAST(total_cases AS float), 0))*100, 2) AS death_percentage
FROM 
  CovidDeaths
WHERE
  continent != '' -- I saw the data contains also the numbers for the continents and I decided to filter them out for now
ORDER BY
  1,2;


-- Looking at Total Cases vs Population
-- Shows percentage of infected population

SELECT
  location, 
  date,
  population,
  total_cases,
  ROUND((CAST(total_cases AS float)/NULLIF(CAST(population AS float), 0))*100, 2) AS infection_percentage
FROM 
  CovidDeaths
WHERE
  continent != ''
ORDER BY
  1,2;


-- Looking at countries with highest infection rate compared to population

SELECT
  location,
  population,
  MAX(total_cases) AS highest_infection_count,
  ROUND(MAX((CAST(total_cases AS float)/NULLIF(CAST(population AS float), 0)))*100, 2) AS percentage_highest_infection
FROM 
  CovidDeaths
WHERE
  continent != ''
GROUP BY
  location,
  population
ORDER BY
  percentage_highest_infection DESC;


-- Showing Countries with highest death count per population

SELECT
  location,
  MAX(CAST(total_deaths AS float)) AS total_deaths
FROM 
  CovidDeaths
WHERE
  continent != ''
GROUP BY
  location
ORDER BY
  total_deaths DESC;


-- Same as above but we look at the continents instead

SELECT
  continent,
  SUM(CAST(new_deaths AS float)) AS total_deaths
FROM 
  CovidDeaths
WHERE
  continent != ''
GROUP BY
  continent
ORDER BY
  total_deaths DESC;

-- Global death percentage

SELECT 
  SUM(CAST(new_cases AS float)) AS total_global_cases,
  SUM(CAST(new_deaths AS float)) AS total_global_deaths,
  ROUND(SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float)) * 100, 2) AS global_death_percentage
FROM
  CovidDeaths
WHERE
  continent != ''
ORDER BY
  1, 2;

-- Looking at total population vs vaccinations

WITH popvsvacc 
AS (
  SELECT
    deaths.continent,
    deaths.location,
    deaths.date,
    deaths.population,
    vacci.new_vaccinations,
    SUM(CAST(vacci.new_vaccinations AS float)) OVER(PARTITION BY deaths.location ORDER BY deaths.date) AS rolling_people_vaccinated
  FROM
    CovidDeaths AS deaths
  JOIN
    CovidVaccinations AS vacci
    ON deaths.location = vacci.location
    AND deaths.date = vacci.date
  WHERE
    deaths.continent != ''
)

SELECT *,
  ROUND((CAST(rolling_people_vaccinated AS float)/NULLIF(CAST(population AS float), 0))*100, 2) AS vaccinated_percentage
FROM
  popvsvacc
--WHERE
	--location = 'Italy';


-- creating views to store data for later visualizations

CREATE VIEW percent_population_vaccinated AS
	SELECT
		deaths.continent,
		deaths.location,
		deaths.date,
		deaths.population,
		vacci.new_vaccinations,
		SUM(CAST(vacci.new_vaccinations AS float)) OVER(PARTITION BY deaths.location ORDER BY deaths.date) AS rolling_people_vaccinated
	FROM
		CovidDeaths AS deaths
	JOIN
		CovidVaccinations AS vacci
		ON deaths.location = vacci.location
		AND deaths.date = vacci.date
	WHERE
		deaths.continent != '';


CREATE VIEW deaths_per_continent AS
	SELECT
	  continent,
	  SUM(CAST(new_deaths AS float)) AS total_deaths
	FROM 
	  CovidDeaths
	WHERE
	  continent != ''
	GROUP BY
	  continent;

CREATE VIEW country_deaths_top_10 AS
	SELECT TOP 10
	  location,
	  MAX(CAST(total_deaths AS float)) AS total_deaths
	FROM 
	  CovidDeaths
	WHERE
	  continent != ''
	GROUP BY
	  location;


CREATE VIEW highest_infection_rate_country AS
	SELECT
	  location,
	  population,
	  MAX(total_cases) AS highest_infection_count,
	  ROUND(MAX((CAST(total_cases AS float)/NULLIF(CAST(population AS float), 0)))*100, 2) AS percentage_highest_infection
	FROM 
	  CovidDeaths
	WHERE
	  continent != ''
	GROUP BY
	  location,
	  population;


CREATE VIEW correlation_cases_gdp AS
	SELECT
		deaths.location,
		MAX(CAST(deaths.total_cases AS float)) AS number_of_cases,
		gdp_per_capita
	FROM
		CovidDeaths AS deaths
		JOIN
		CovidVaccinations AS vacci
		ON deaths.location = vacci.location
	WHERE
		deaths.continent != ''
	GROUP BY
		deaths.location,
		gdp_per_capita;
