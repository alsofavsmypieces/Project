-- Active: 1730882062131@@127.0.0.1@3306@covidproject
SELECT *
FROM coviddeaths
ORDER BY 3,4

SELECT *
FROM covidvaccinations

SELECT location,
        date,
        total_cases,
        new_cases,
        total_deaths,
        population
FROM
coviddeaths
ORDER BY 
    1,2

--looking at total cases vs total deaths
--show likelyhood of dying when you contract COVID
SELECT location,
        date,
        total_cases,
        total_deaths,
        (total_deaths/total_cases)*100 AS DeathsPercentage
FROM coviddeaths
ORDER BY 1,2

--looking at total cases vs Population
SELECT total_cases,
        population
FROM coviddeaths

--highest infection rate compared to conntry and population
SELECT
location,
population,
MAX(total_cases) AS HighestInfectionCount,
MAX(total_cases/population) *100 AS PercentagePopulationInfection
FROM coviddeaths
GROUP BY location,population
ORDER BY PercentagePopulationInfection DESC

--How many people actually died
--DeathsCount per population
SELECT
location,
MAX(total_deaths) AS TotalDeathsCount
FROM coviddeaths
GROUP BY location
ORDER BY TotalDeathsCount DESC

SELECT *
FROM coviddeaths


SELECT
location,
MAX(total_deaths) AS TotalDeathsCount
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- let's break things down by continent
SELECT
continent,
MAX(total_deaths) AS TotalDeathsCount
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

SELECT continent, MAX(total_deaths) as TotalDeathsCount
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--showing the continent with the highest deathsCount per population
SELECT
continent,
MAX(total_deaths) AS TotalDeathsCount
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--GLOBAL NUMBER
SELECT
        date,
        SUM(new_cases) AS TotalCases,
        SUM(new_deaths) AS TotalDeaths,
            (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM
coviddeaths
WHERE
continent is NOT NULL
GROUP BY
    date
ORDER BY 
    1,2

SELECT
        SUM(new_cases) AS TotalCases,
        SUM(new_deaths) AS TotalDeaths,
            (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM
coviddeaths
WHERE
continent is NOT NULL
ORDER BY 
    1,2

SELECT *
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date

--total population vs vaccinations
SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100 -- cant do this do CTE
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--use CTE
WITH PopulationVSVaccination (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as(
SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100 -- cant do this do CTE
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopulationVSVaccination



--temp table
DROP TABLE if EXISTS #PercantagePopulationVaccinated
CREATE TABLE #PercantagePopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccination NUMERIC,
    RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercantagePopulationVaccinated
SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100 -- cant do this do CTE
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
--WHERE dea.continent is not null
-- ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercantagePopulationVaccinated;

--create view to store for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM( vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100 -- cant do this do CTE
FROM coviddeaths dea
JOIN covidvaccinations vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *
FROM percentpopulationvaccinated