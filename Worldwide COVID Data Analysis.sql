-- Checking NULL data 
SELECT *
FROM coviddeaths
WHERE Location IS NULL OR 
	Date IS NULL OR
    total_cases IS NULL OR
    new_cases IS NULL OR
    total_deaths IS NULL OR 
    population IS NULL

-- Identifying important columns of data for analysis
SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY date ASC

-- Looking at Total cases vs. Total Deaths; shows the likelihood of dying if you contract Covid
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeaths
ORDER BY total_cases ASC 

SELECT 
	Location, GROUP_CONCAT(Date ORDER BY Date ASC) AS concatenated_dates, SUM(sum_cases) AS total_cases, SUM(total_deaths) AS total_deaths, (SUM(total_deaths) / SUM(sum_cases)) * 100 AS death_percentage
FROM (
    SELECT Location, Date, SUM(total_cases) AS sum_cases, SUM(total_deaths) AS total_deaths
    FROM coviddeaths
    GROUP BY Location, Date
) AS aggregated_data
GROUP BY Location -- To aggregate data, group_concat is necessary to SUM total_cases & total_deaths for viz

CREATE VIEW total_cases_total_deaths AS
SELECT Location, SUM(sum_cases) AS total_cases, SUM(total_deaths) AS total_deaths, (SUM(total_deaths) / SUM(sum_cases)) * 100 AS death_percentage
FROM (
    SELECT Location, Date, SUM(total_cases) AS sum_cases, SUM(total_deaths) AS total_deaths
    FROM coviddeaths
    GROUP BY Location, Date
) AS aggregated_data
GROUP BY Location;

SELECT *
FROM total_cases_total_deaths

-- Looking at Total Cases vs Population; shows what percentage of the population contracted Covid in the states
SELECT Location, Date, total_cases, Population, (total_cases/Population)*100 AS Percent_Population_Infected
FROM coviddeaths
WHERE location like '%states%'
ORDER BY total_cases ASC 

-- What country has the highest infection rate compared to the population?
-- Andorra has a 17.13%  due to a small population size.
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM coviddeaths
Group BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Shows countries with the highest death count per population
SELECT Location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM coviddeaths
Group BY Location
ORDER BY Total_Death_Count DESC

-- Shows Continents with the highest death count per population
SELECT Continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM coviddeaths
Group BY Continent
ORDER BY Total_Death_Count DESC

-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
FROM coviddeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2

-- Using Joins to join Covid deaths and Covid Vaccinations table
SELECT *
FROM coviddeaths AS dea -- Creating aliases for these two tables
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date
ORDER BY total_tests ASC
    
-- Looking at Total Population vs. Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS Rolling_Count_Vaccinations
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date
ORDER BY 2,3 

-- Using CTE, if # of columns in CTE is different it will give an error
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_Count_Vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS Rolling_Count_Vaccinations
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date
)
SELECT *, (Rolling_Count_Vaccinations/Population) *100 AS VaccinationsPerPopulation
FROM PopvsVac

-- Using TEMP Tables instead of CTE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
Rolling_Count_Vaccinations numeric
)
INSERT INTO
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS Rolling_Count_Vaccinations
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
    and dea.date = vac.date

SELECT *, (Rolling_Count_Vaccinations/Population) *100 AS VaccinationsPerPopulation
FROM #PercentPopulationVaccinated