select * from PortfolioProject1..CovidDeaths
order by 3,4

--select * from PortfolioProject1..CovidDeaths 
--order by 3,4

-- Selecting data

select location,date,total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeaths
order by 1,2

-- Looking Total cases vs Total Deaths

select location,date,total_cases, total_deaths, (convert(decimal(15,3),total_deaths)/convert(decimal(15,3),total_cases))*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where location like '%Peru%'
order by 1,2

-- Looking Total cases vs Population

select location, date, total_cases, total_deaths, (convert(decimal(15,3),total_cases)/population)*100 as CasesPercentage
from PortfolioProject1..CovidDeaths
where location like '%Peru%'
order by 1,2


-- Looking at countries with Highest infection rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(convert(decimal(15,3),total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
--where location like '%Peru%'
group by location, population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc

-- ... by continent

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeaths
where continent is null and location not like '%income' 
group by location 
order by TotalDeathCount desc


select location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(cast(total_cases as int)) as TotalCasesCount, MAX(cast(total_deaths as float))/ MAX(cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is null and location not like '%income' and location <> 'European Union'--and location <> 'World' 
group by location 
order by TotalDeathCount desc


-- Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(convert(decimal(15,3),new_deaths))/sum( convert(decimal(15,3),new_cases)) *100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where continent is null and location not like '%income' and location not in ('World', 'European Union')
order by 1


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE Common table expression

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/population)*100 as PopVacPercentage
from PopVsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccionations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated


-- Create view to store data for later visualization
drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null


Select * 
From PercentPopulationVaccinated
