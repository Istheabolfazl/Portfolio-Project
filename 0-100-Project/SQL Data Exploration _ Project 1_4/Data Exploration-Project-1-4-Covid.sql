select * 
from Portfolio_Project..CovidDeaths$
order by 3,4


--select * 
--from Portfolio_Project..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be starting with

select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project..CovidDeaths$
where continent is not null
order  by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths , (total_cases/total_deaths)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
where location like '%states%'  
and continent is not null
order  by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location,date,total_cases,population , (total_cases/population)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
order  by 1,2



-- Countries with Highest Infection Rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
group by location,population
order  by PercentPopulationInfected desc




-- Countries with Highest Death Count per Population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS


select SUM(new_cases) as total_cases,SUM(CAST(total_deaths	 as int)) as total_deaths ,SUM(CAST(total_deaths	 as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
where continent is not null
--group by date
order  by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.date ,dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated) *100
from Portfolio_Project..CovidDeaths$ as dea
join Portfolio_Project..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated) *100
from Portfolio_Project..CovidDeaths$ as dea
join Portfolio_Project..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query



DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated) *100
from Portfolio_Project..CovidDeaths$ as dea
join Portfolio_Project..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated





-- Creating View to store data for later visualizations



drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated) *100
from Portfolio_Project..CovidDeaths$ as dea
join Portfolio_Project..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3



