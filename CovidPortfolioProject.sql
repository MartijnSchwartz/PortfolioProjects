/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
FROM CovidDeaths
Where continent is not null
order by 3,4
;

--Select * 
--FROM CovidVaccinations
--order by 3,4
--;

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select 
	location, 
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases)*100 AS Deathpercentage 
FROM CovidDeaths
Where continent is not null and location = 'Netherlands'
order by 1,2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select 
	location, 
	date,
	Population,
	total_cases, 
	(total_cases/Population)*100 AS PercentofPopulationInfected 
FROM CovidDeaths
Where continent is not null
-- where location = 'Netherlands'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

Select 
	location, 
	Population,
	MAX(total_cases) AS highestInfectionCount, 
	Max((total_cases/Population))*100 AS Population_in_percentage 
FROM CovidDeaths
Where continent is not null
Group by location, Population 
order by Population_in_percentage desc 
;

-- Countries with Highest Death Count per Population

Select 
	location,
	MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc
;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Netherlands'
Where continent is not null 
Group by continent
order by TotalDeathCount desc
;

-- GLOBAL NUMBERS

Select 
	-- location, 
	-- date,
	SUM(new_cases) AS TotalCases,
	SUM(cast(new_deaths as int)) AS TotalDeaths,
	SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS Deathpercentage 
FROM CovidDeaths
Where continent is not null -- and 
--Where location = 'Netherlands'
--GROUP BY date
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
	Join CovidVaccinations vac
		on	dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
--order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With popvsvac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated )
as 
(
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
	Join CovidVaccinations vac
		on	dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 as PercentofPeopleVaccinated
FROM popvsvac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, 
dea.location, dea.date, 
dea.population, 
vac.new_vaccinations,  
SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * ,(RollingPeopleVaccinated/Population)*100 as PercentofPeopleVaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulatedVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * FROM PercentPopulatedVaccinated;

Create View GlobalNumbers as
Select 
	-- location, 
	-- date,
	SUM(new_cases) AS TotalCases,
	SUM(cast(new_deaths as int)) AS TotalDeaths,
	SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS Deathpercentage 
FROM CovidDeaths
Where continent is not null -- and 
--Where location = 'Netherlands'
--GROUP BY date
--order by 1,2;

Select * FROM GlobalNumbers;

Create View TotalPopuvsVacc as
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
	Join CovidVaccinations vac
		on	dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
--order by 2,3;

Select * FROM TotalPopuvsVacc;