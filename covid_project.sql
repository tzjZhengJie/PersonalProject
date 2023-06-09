---------Documentation-----------
--For more info;
--https://www.kaggle.com/datasets/imdevskp/corona-virus-report
-----------------------------------

--Using relevant columns in this project
Select Location, date, total_cases, new_cases, total_deaths, population
From DataProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the statistic of COVID fatality in Singapore
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DataProject..CovidDeaths
Where location like '%Singapore%'
and continent is not null
order by 1,2

-- Looking at Total cases vs Population
-- The chances of contracting COVID-19 in Singapore
Select Location, date, total_cases,population, (total_cases/population)*100 as ContractedPercentage
From DataProject..CovidDeaths
Where location like '%Singapore%'
and continent is not null
order by 1,2 desc

--Looking at Countries with Highest infection rate 
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as ContractedPercentage
From DataProject..CovidDeaths
where continent is not null
group by location, population
order by ContractedPercentage desc
-- Output: Andorra with a 17.13% infection rate

--How Singapore fair in terms of global infection rate?
SELECT rank
FROM (
  SELECT Location, continent,ROW_NUMBER() OVER (ORDER BY MAX((total_cases/population))*100 DESC) as rank
  FROM DataProject..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY Location, continent
) AS ranks
WHERE Location = 'Singapore';
--output: rank 108

--How many countries are there in this Dataset?
SELECT COUNT(DISTINCT Location) AS NumberOfCountries
FROM DataProject..CovidDeaths
where continent is not null;
--output: 210 countries

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From DataProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc
--output: United States with the highest death count

--Breaking things down by continent
--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From DataProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc
--output: North American with the highest death count

--GLOBAL NUMBERS
Select SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/ SUM(new_cases)) *100 as DeathPercentage
From DataProject..CovidDeaths
where continent is not null
order by 1,2
--output: fatality rate globally is 2.11%

-- Looking at Total Population vs Vaccinations
--USE CTE
With PopulationvsVaccination (Continent, Location, Date, Population, new_vaccinations, SummationVaccination)
as
(
Select dead.continent, dead.location, dead.date, dead.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dead.location order by dead.location, dead.date) as SummationVaccinated
From DataProject..CovidVaccinations vac 
Join DataProject..CovidDeaths dead
	on dead.location = vac.location
	and dead.date = vac.date
where dead.continent is not null
and dead.location = 'Singapore'
and vac.new_vaccinations is not null
)
Select *, (SummationVaccination/Population)*100 as VaccinatedPerPopulation
From PopulationvsVaccination
--Output: By March 2021, an est 0.94% of the population are vaccinated in Singapore

-- TEMP TABLE
DROP Table if exists #PopulationvsVaccination
Create Table #PopulationvsVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
SummationVaccination numeric
) 
Insert into #PopulationvsVaccination
Select dead.continent, dead.location, dead.date, dead.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dead.location order by dead.location, dead.date) as SummationVaccinated
From DataProject..CovidVaccinations vac 
Join DataProject..CovidDeaths dead
	on dead.location = vac.location
	and dead.date = vac.date
where dead.continent is not null
and dead.location = 'Singapore'
and vac.new_vaccinations is not null

Select *, (SummationVaccination/Population)*100 as VaccinatedPerPopulation
From #PopulationvsVaccination
--Output same as above

-- Creating View to store data for later visualisations
Create View PopulationvsVaccination as
Select dead.continent, dead.location, dead.date, dead.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dead.location order by dead.location, dead.date) as SummationVaccinated
From DataProject..CovidVaccinations vac 
Join DataProject..CovidDeaths dead
	on dead.location = vac.location
	and dead.date = vac.date
where dead.continent is not null
and vac.new_vaccinations is not null
