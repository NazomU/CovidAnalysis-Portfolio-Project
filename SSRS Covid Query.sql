select *
from [SQL Portfolio]..CovidDeaths
ORDER BY 3,4

select *
from [SQL Portfolio]..CovidVaccinations
ORDER BY 3,4

-- Data to be used
select
location,
date,
total_cases,
new_cases,
total_deaths,
population
from
[SQL Portfolio]..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
select
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
from [SQL Portfolio]..CovidDeaths
where location like '%Canada%'
order by 1,2
-- From the results we could see the percentage of contacting and dying from the corona virus in Canada


-- Total Cases vs Population
select
location,
date,
population,
total_cases,
(total_cases/population)*100 as CovidCasesPercentage
from [SQL Portfolio]..CovidDeaths
where location like '%Canada%'
order by 1,2
-- The result shows what percentage of the population got Covid in Canada


--Top Countries with the highest infection Rate compared to population
Select 
Location, 
Population, 
MAX(total_cases) as HighestInfectionCount,  
Max((total_cases/population))*100 as PercentPopulationInfected
From [SQL Portfolio]..CovidDeaths
--Where location like '%Canada%'
Group by Location, Population
order by PercentPopulationInfected desc


--To know the countries with highest death count per population 
Select 
Location, 
MAX(cast(Total_deaths as int)) as TotalDeathCount
From [SQL Portfolio]..CovidDeaths
--Where location like '%Canada%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- To see data for contintents with the highest death count per population
Select continent, 
MAX(cast(Total_deaths as int)) as TotalDeathCount
From [SQL Portfolio]..CovidDeaths
--Where location like '%Canada%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global Numbers of Covid Cases and Deaths
Select 
SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [SQL Portfolio]..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


select *
from [SQL Portfolio]..CovidDeaths dea
join [SQL Portfolio]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2

-- Total Population vs Vaccinations (Shows Percentage of Population that has recieved at least one Covid Vaccine)
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations
From [SQL Portfolio]..CovidDeaths dea
Join [SQL Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- as the data increases the column increases so increase the column size using ALTER TABLE [SQL PORTFOLIO]..CovidDeaths ALTER COLUMN location varchar(150)

Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [SQL Portfolio]..CovidDeaths dea
Join [SQL Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL Portfolio]..CovidDeaths dea
Join [SQL Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL Portfolio]..CovidDeaths dea
Join [SQL Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinatedd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [SQL Portfolio]..CovidDeaths dea
Join [SQL Portfolio]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null





