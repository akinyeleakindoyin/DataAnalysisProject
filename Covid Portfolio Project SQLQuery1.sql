
Select *
From PortfolioProject..['covid-deaths$']
where continent is not null
order by 3,4


--Select *
--From PortfolioProject..[covidvaccination$]
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['covid-deaths$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
where location like '%nigeria%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
where location like '%nigeria%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
-- where location like '%nigeria%'
Group by Location, Population
order by PercentPopulationInfected


-- Showing Countries with Highest death  Count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
-- where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Breaking by continent


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
-- where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
-- where location like '%nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage -- total_cases, total_deaths,  (total_cases/total_deaths)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
-- where location like '%nigeria%'
where continent is not null
-- Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.Date) as RollingPeoplevaccinated
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..[covidvaccination$] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)

-- USE CTE

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP Table

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location
, dea.date) as RollingPeoplevaccinated
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..[covidvaccination$] vac
	On dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location
, dea.date) as RollingPeoplevaccinated
From PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..[covidvaccination$] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select * 
From PercentPopulationVaccinated