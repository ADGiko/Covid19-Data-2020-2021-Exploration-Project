/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



SELECT *
FROM [Covid19Data_2020-2021]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Select Data That We are Going to be Starting With

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Covid19Data_2020-2021]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [Covid19Data_2020-2021]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths in India
-- Shows Likelihood of Dying if You Contract Covid in Your Country

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM [Covid19Data_2020-2021]..CovidDeaths
WHERE location = 'India'
and continent is not null
ORDER BY 1,2


-- Total Cases vs Population
-- Shows What Percentage of Population Got Covid

SELECT location,date,population,total_cases, (total_cases/population)*100 AS Percent_Population_Infected
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
ORDER BY 1,2


-- Countries with Highest Infection Rate Compared to Population

SELECT location,population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population)*100) AS Percent_Population_Infected
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
GROUP BY location,population
ORDER BY Percent_Population_Infected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Contintents With the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count   --(The correct way, but there is some error in the dataset)
FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY Total_Death_Count DESC

--SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count   --(Not the correct way, but there is some error in the dataset)
--FROM [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
--WHERE continent IS NULL 
--GROUP BY location
--ORDER BY Total_Death_Count DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS Death_Percentage
From [Covid19Data_2020-2021]..CovidDeaths
--WHERE location = 'India'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has Recieved at Least One Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM [Covid19Data_2020-2021]..CovidDeaths dea
JOIN [Covid19Data_2020-2021]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- Using CTE to Perform Calculation on Partition By in Previous Query

WITH Pop_vs_Vac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM [Covid19Data_2020-2021]..CovidDeaths dea
JOIN [Covid19Data_2020-2021]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Percent_Population_Vaccinated
FROM Pop_vs_Vac


-- Using Temp Table to Perform Calculation on Partition By in Previous Query

--DROP Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM [Covid19Data_2020-2021]..CovidDeaths dea
JOIN [Covid19Data_2020-2021]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Percent_Population_Vaccinated
FROM #PercentPopulationVaccinated


-- Creating View to Store Data for Later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
FROM [Covid19Data_2020-2021]..CovidDeaths dea
JOIN [Covid19Data_2020-2021]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
