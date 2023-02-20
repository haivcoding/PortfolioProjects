Select *
From 
	[Portfolio Project].dbo.CovidDeaths
where
	continent is not null
order by 
	3,4

Select *
From 
	[Portfolio Project].dbo.CovidVaccination
where
	continent is not null
order by 
	3,4

--Select Data we are using
Select 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from 
	[Portfolio Project]..CovidDeaths
where
	continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of deaths by covid in your country
Select 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPercentage
from 
	[Portfolio Project]..CovidDeaths
where 
	location like '%australia%'
	and continent is not null
order by 1,2

-- Looking at Total cases vs Population
-- Shows the population percentage got Covid
Select 
	Location, 
	date, 
	total_cases, 
	population, (total_cases/population)*100 as PopulationInfectedPercentage
from 
	[Portfolio Project]..CovidDeaths
where 
	location like '%vietnam%'
	and continent is not null
order by PopulationInfectedPercentage


-- Looking at country with highest infection rate
Select 
	Location, 
	population, 
	MAX(total_cases) as HighestInfectionCount, 
	MAX(total_cases/population)*100 as PopulationInfectedPercentage
from 
	[Portfolio Project]..CovidDeaths
where
	Location like '%States%'
Group by
	Location, population
order by
	PopulationInfectedPercentage desc


-- Looking at country with highest death count per Population
Select 
	Location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
from 
	[Portfolio Project]..CovidDeaths
--where
--	Location like '%States%'
where
	continent is not null
Group by
	Location
order by
	TotalDeathCount desc


-- BREAK DOWN BY CONTINENTS
Select 
	Continent, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where Location like '%States%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBER
Select 	
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--Group by date
order by 1,2


-- Looking at Total population vs Vaccinations
--USE CTE
With PopvsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	
from [Portfolio Project]..CovidVaccination vac
Join [Portfolio Project]..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

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
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	
from [Portfolio Project]..CovidVaccination vac
Join [Portfolio Project]..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualisation
Create View PercentPopulationVaccinated as
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidVaccination vac
Join [Portfolio Project]..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated