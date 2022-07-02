---
--select *
--from PortoProject..CovidDeaths
--where continent is not null
--order by 3,4

--select *
--from PortoProject..CovidVaccinations
--order by 3,4
---

---
--select data that we are going to be using
select
location, date, total_cases, new_cases, total_deaths, population
from PortoProject..CovidDeaths
order by 1,2
---

-- looking at total cases vs total death
-- shows likelihood of dying if you contract covid in your country
select
location, 
date, 
total_cases, 
total_deaths, 
(total_deaths/total_cases)*100 as DeathPercetage
from PortoProject..CovidDeaths
where location like '%indo%'
order by 1,2
---

-- looking at total cases vs population
-- shows what percentage of population got covid
select
location, 
date, 
population, 
total_cases, 
(total_cases/population)*100 as CasePercetage
from PortoProject..CovidDeaths
where location like '%indo%'
order by 1,2
---

-- Looking at countries with highes infection rate compared to population
select
location, 
population, 
max(total_cases) as HighestInfectionCount, 
max((total_cases/population))*100 as PercetagePopulationInfected
from PortoProject..CovidDeaths
Group by location, population
order by 4 desc
---

-- showing countries with highest death count per population
select
location, 
max(cast(total_deaths as int)) as TotalDeathCount
from PortoProject..CovidDeaths
where continent is not null
Group by location
order by 2 desc
---

--lets break things down by continent


select
location, 
max(cast(total_deaths as int)) as TotalDeathCount
from PortoProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc
---

-- showing continents with the highest death count per population
select
continent, 
max(cast(total_deaths as int)) as TotalDeathCount
from PortoProject..CovidDeaths
where continent is not null
Group by continent
order by 2 desc
---

-- GLOBAL NUMBERS
select
--date,
sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortoProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2
---

-- use cte
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
-- looking at total population vs vacinations
select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortoProject..CovidDeaths as dea
join PortoProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select 
*, 
(RollingPeopleVaccinated/population)*100 as NewComVacPercentage
from PopvsVac
---

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
-- looking at total population vs vacinations
select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortoProject..CovidDeaths as dea
join PortoProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
select 
*, 
(RollingPeopleVaccinated/population)*100 as NewComVacPercentage
from #PercentPopulationVaccinated
---

-- creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) 
	over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortoProject..CovidDeaths as dea
join PortoProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated









