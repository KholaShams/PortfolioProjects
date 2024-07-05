
SELECT *
FROM SQLPortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM SQLPortfolioProject..CovidVaccinations$
--ORDER BY 3,4


-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLPortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- looking at total cases vs total deaths
-- Shows the likelihood of dying if you have covid in Pakistan
 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SQLPortfolioProject..CovidDeaths$
where location like '%Pakistan%' and continent is not null
ORDER BY 1,2


-- looking at the total cases vs the population
-- show what percentage of population in Pakistan got covid
 SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentagePerPopulation
FROM SQLPortfolioProject..CovidDeaths$
where location like '%Pakistan%' and continent is not null
ORDER BY 1,2


-- what coutries have the highest infection rates based on population
 SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as PercentagePerPopulationInfected
FROM SQLPortfolioProject..CovidDeaths$
--where location like '%Pakistan%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePerPopulationInfected DESC


--how many people actually died because of covid
 SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- by continent

--how many people actually died because of covid
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
 SELECT  SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases*100) as DeathPercentage
 FROM SQLPortfolioProject..CovidDeaths$
 where continent is not null
 --Group by date
 order by 1,2



-- looking at total population vs vaccinations
Select daa.continent, daa.location, daa.date, daa.population, daa.new_vaccinations
from SQLPortfolioProject..CovidDeaths$ daa
join SQLPortfolioProject..CovidVaccinations$ vac
on daa.location=vac.location 
and daa.date= vac.date
where daa.continent is not null
order by 1,2,3





Select daa.continent, daa.location, daa.date, daa.population, daa.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(partition by daa.location Order by daa.location, daa.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from SQLPortfolioProject..CovidDeaths$ daa
join SQLPortfolioProject..CovidVaccinations$ vac
on daa.location=vac.location 
and daa.date= vac.date
where daa.continent is not null
order by 1,2,3

-- Use CTE for the above query cuz you cant just use the column you just created in the next intsruction right after creation

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(
Select daa.continent, daa.location, daa.date, daa.population, daa.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(partition by daa.location Order by daa.location, daa.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from SQLPortfolioProject..CovidDeaths$ daa
join SQLPortfolioProject..CovidVaccinations$ vac
on daa.location=vac.location 
and daa.date= vac.date
where daa.continent is not null
--order by 1,2,3
)

Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

Select daa.continent, daa.location, daa.date, daa.population, daa.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(partition by daa.location Order by daa.location, daa.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from SQLPortfolioProject..CovidDeaths$ daa
join SQLPortfolioProject..CovidVaccinations$ vac
on daa.location=vac.location 
and daa.date= vac.date
where daa.continent is not null
--order by 1,2,3

Select *, (cast(RollingPeopleVaccinated as int)/Population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualization
create  View PercentPopulationVaccinated as

Select daa.continent, daa.location, daa.date, daa.population, daa.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(partition by daa.location Order by daa.location, daa.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from SQLPortfolioProject..CovidDeaths$ daa
join SQLPortfolioProject..CovidVaccinations$ vac
on daa.location=vac.location 
and daa.date= vac.date
where daa.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated