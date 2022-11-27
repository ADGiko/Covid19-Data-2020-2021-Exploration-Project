/*
Queries used for Tableau Project
*/



-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Percentage
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Percentage
--FROM [Covid19Data_2020-2021]..CovidDeaths
----WHERE location = 'India'
--WHERE location = 'World'
----GROUP BY date
--ORDER BY 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS int)) AS Total_Death_Count
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_Death_Count DESC


-- 3.

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count,  Max((total_cases/population))*100 AS Percent_Population_Infected
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC


-- 4.


SELECT Location, Population,date, MAX(total_cases) AS Highest_Infection_Count,  Max((total_cases/population))*100 AS Percent_Population_Infected
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
GROUP BY Location, Population, date
ORDER BY Percent_Population_Infected DESC












-- Some other Queries here, in case you want to check them out


-- 1.

SELECT dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM [Covid19Data_2020-2021]..CovidDeaths dea
JOIN [Covid19Data_2020-2021]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3




-- 2.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Percentage
--FROM [Covid19Data_2020-2021]..CovidDeaths
----WHERE location = 'India'
--WHERE location = 'World'
----GROUP BY date
--ORDER BY 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS int)) AS Total_Death_Count
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_Death_Count DESC



-- 4.

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count,  Max((total_cases/population))*100 AS Percent_Population_Infected
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC



-- 5.

--SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
--FROM [Covid19Data_2020-2021]..CovidDeaths
----WHERE location = 'India'
--WHERE continent IS NOT NULL 
--ORDER BY 1,2

-- took the above query and added population
SELECT Location, date, population, total_cases, total_deaths
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- 6. 


WITH Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM [Covid19Data_2020-2021]..CovidDeaths dea
JOIN [Covid19Data_2020-2021]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Percent_People_Vaccinated
FROM Pop_vs_Vac


-- 7. 

SELECT Location, Population,date, MAX(total_cases) AS Highest_Infection_Count,  Max((total_cases/population))*100 AS Percent_Population_Infected
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
GROUP BY Location, Population, date
ORDER BY Percent_Population_Infected DESC