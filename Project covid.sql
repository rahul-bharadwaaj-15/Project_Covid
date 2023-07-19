Select *
FROM Project_covid..CovidDeaths
order by 3,4

--Select *
--FROM Project_covid..CovidVaccinations
--order by 3,4
-- Selecting data that Iam going to use

Select location,date,total_cases,new_cases,total_deaths,population
FROM Project_covid..CovidDeaths
order by 1,2

-- Total cases vs total deaths
-- likelihood of dying if you attacked by covid in India

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM Project_covid..CovidDeaths
Where location like '%India%'
order by 1,2

-- Population vs total cases
-- what percent of people in India are Infected by covid

Select location,date,population,total_cases, (total_cases/population)*100 as infectionrate
FROM Project_covid..CovidDeaths
Where location like '%India%'
order by 1,2

-- Countries with highest infected rate as compared to their population

Select location,population,MAX(total_cases) as highestinfectedrate, MAX(total_cases/population)*100 as infectionrate
FROM Project_covid..CovidDeaths
Group by location,population
order by infectionrate desc

-- Countries with highest death count per population

Select location,MAX(cast (total_deaths as int)) as deathcount
FROM Project_covid..CovidDeaths
where continent is not null
Group by location
order by deathcount desc

-- BY CONTINENT

Select location,MAX(cast (total_deaths as int)) as deathcount
FROM Project_covid..CovidDeaths
where continent is null
Group by location
order by deathcount desc

-- Global numbers

Select date,SUM(new_cases) as Global_cases,SUM(cast(new_deaths as int)) as Global_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Project_covid..CovidDeaths
where continent is not null
group by date
order by 1,2

--total 

Select SUM(new_cases) as Global_cases,SUM(cast(new_deaths as int)) as Global_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Project_covid..CovidDeaths
where continent is not null
order by 1,2

--Population vs no_of vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date) as total_vac
From Project_covid..CovidDeaths dea
join Project_covid..CovidVaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

with PopvsVac(Continent, Location , date, Population,new_vaccinations, total_vac)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date) as total_vac
From Project_covid..CovidDeaths dea
join Project_covid..CovidVaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (total_vac/Population)*100 as Pecentage_roll
from PopvsVac


-- temp table

DROP table if exists  #Percentpopvaccinated
create table #Percentpopvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
total_vac numeric
)


Insert into #Percentpopvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date) as total_vac
From Project_covid..CovidDeaths dea
join Project_covid..CovidVaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
Select *, (total_vac/Population)*100 as Pecentage_roll
from #Percentpopvaccinated



-- creating view to store data for visualization

 Create View Percentpopvaccinated as
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER ( Partition by dea.location order by dea.location,dea.date) as total_vac
From Project_covid..CovidDeaths dea
join Project_covid..CovidVaccinations vac
on dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * 
from Percentpopvaccinated