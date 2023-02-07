SHOW DATABASES;

USE PortfolioProject2;
SHOW TABLES;

SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL;

/*SELECT *
FROM covidvaccinations
ORDER BY 3,4;
*/

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2;



-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_deaths
WHERE location LIKE 'Greece' AND continent IS NOT NULL
ORDER BY 1,2;



-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM covid_deaths
WHERE location LIKE 'Greece' AND continent IS NOT NULL
ORDER BY 1,2;



-- Looking at Countriesd with Highest Infection compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM covid_deaths
-- WHERE location LIKE 'Greece' AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;



-- Showing Countries with Highest Death COunt per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
-- WHERE location LIKE 'Greece'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;



-- Let's break things down by Continent
-- Showing continents with highesr death count

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM covid_deaths
-- WHERE location LIKE 'Greece'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM covid_deaths
-- WHERE location LIKE 'Greece' 
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2; 


-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3;


-- Use CTE 

WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac;


-- Temp Table
DROP TABLE if exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;
-- WHERE dea.continent IS NOT NULL;
-- ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;


-- Creating view to store data for later visualizations

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
-- ORDER BY 2,3;


SELECT *
FROM PercentPopulationVaccinated;













