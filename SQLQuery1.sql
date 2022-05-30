select *
from Portfolio_projects..CovidDeaths
where continent is not null
order by 3,4

--select *
--from Portfolio_projects..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio_projects..CovidDeaths
order by 1,2


--Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract Covid in Nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_projects..CovidDeaths
where location like '%Nigeria%'
order by 1,2

--Total cases vs population
select location, date, population, total_cases,(total_cases/population)*100 as Population_infected
from Portfolio_projects..CovidDeaths
--where location like '%Nigeria%'
order by 1,2



--Looking at countries with hoghest infection rate compared to populations
select location, population, max(total_cases) HighestInfectionCount, max(total_cases/population)*100 as PercentOfPopulationinfected
from Portfolio_projects..CovidDeaths
--where location like '%Nigeria%'
group by location, population
order by PercentOfPopulationinfected desc



--showiung the countries with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_projects..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc


--Showing the continents with the highest death counts

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio_projects..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc



-- global numbers

select sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, sum(cast (New_deaths as int))/sum(new_cases) *100 as DeathPercentage   --total_deaths, (total_deaths/population)*100 as Death_percentage
from Portfolio_projects..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2



--Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeaopleVaccinated
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac







-- TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeaopleVaccinated
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeaopleVaccinated
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeaopleVaccinated
from Portfolio_projects..CovidDeaths dea
join Portfolio_projects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated