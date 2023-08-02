SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths*100/total_cases) AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'India'
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows percent of Population who contracted Covid

SELECT location, date, population, total_cases, total_deaths, (total_cases*100/population) AS covid_percentage
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2


-- Countries with highest infection rate

SELECT location, population, MAX(total_cases) AS highest_infection, MAX((total_cases*100/population)) AS infection_percent
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC


-- Countries with highest death count per population

SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC


-- Showing death count by continent

SELECT continent, MAX(total_deaths) AS total_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- Global Total

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)*100/(SUM(new_cases)+0.1) AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL


-- Global cases and deaths by date

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)+0.1)*100/(SUM(new_cases)+0.1) AS death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1


-- Total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location 
          ORDER BY dea.location, dea.date) AS appending_people_vaccinated
		  --(appending_people_vaccinated*100/population)

FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, appending_people_vaccinated)  AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location 
          ORDER BY dea.location, dea.date) AS appending_people_vaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (appending_people_vaccinated*100/population) AS vaccination_percentage
FROM PopvsVac


-- Temp Table

CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
appending_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location 
          ORDER BY dea.location, dea.date) AS appending_people_vaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (appending_people_vaccinated*100/population) AS vaccination_percentage
FROM #percent_population_vaccinated


-- Creating views for visuals

CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location 
          ORDER BY dea.location, dea.date) AS appending_people_vaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM percent_population_vaccinated