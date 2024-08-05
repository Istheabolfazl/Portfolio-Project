

-- Countries with Highest Infection Rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
group by location,population
order  by PercentPopulationInfected desc




-- Countries with Highest Death Count per Population

select location, sum(cast(Total_deaths as int)) as TotalDeathCount
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
where continent is null
and location not in ('World','European Union','International')
group by location
order by TotalDeathCount desc



select SUM(new_cases) as total_cases,SUM(CAST(total_deaths	 as int)) as total_deaths ,SUM(CAST(total_deaths  as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
where continent is not null
--group by date
order  by 1,2





select location,population,date,max(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as PercentPopulationInfected
from Portfolio_Project..CovidDeaths$
--where location like '%states%'  
group by location,population,date
order  by PercentPopulationInfected desc
