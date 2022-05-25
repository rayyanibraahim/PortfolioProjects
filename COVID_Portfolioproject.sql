
-- This project about COVID _ SQL Data Exploration 

SELECT*FROM PortfolioProject.dbo.CovidDeaths order by 1,2

SELECT*FROM PortfolioProject.dbo.CovidDeaths
where continent is not null  
order by 3,4

SELECT location, date, total_cases,new_cases,total_deaths, population FROM  PortfolioProject.dbo.CovidDeaths order by 1,2



------------------------------------- TOTAL CASES vs TOTAL DEATHS -------------------------------------
-- looking at total cases vs total deaths
-- shows liklihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths 
where location like '%africa%'
and continent is not null 
order by 1,2

-- looking at total cases vs population
-- show percentage of the population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as percentageofpopulationInfected
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
order by 1,2

-- looking to contries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectedCount, MAX((total_cases/population))*100 as casespercentage
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
GROUP BY location, population
order by casespercentage DESC

-- showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
GROUP BY location
order by TotalDeathsCount DESC

--convert the variable (total_deaths) from varchar to int
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
GROUP BY location
order by TotalDeathsCount DESC


--showing total_death count by continent
-- showing continents with the highest death count per population


SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null
GROUP BY continent
order by TotalDeathsCount DESC

--Global Numbers
SELECT date, SUM(cast(total_deaths as int)) -- total_cases, (total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
group by date
order by 1,2

SELECT date, SUM(new_cases) as SumNewCases, sum(cast(new_deaths as int)) as SumNewDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
group by date
order by 1,2

SELECT SUM(new_cases) as SumNewCases, sum(cast(new_deaths as int)) as SumNewDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
--group by date
order by 1,2

----looking at total population vs total vaccination

SELECT*FROM PortfolioProject.dbo.CovidVaccinations 
SELECT*FROM PortfolioProject.dbo.CovidDeaths 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as sumofnewvaccinations             
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE

WITH PopvsVac (continent,location, date, population, new_vaccinations,sumofnewvaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as sumofnewvaccinations             
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (sumofnewvaccinations/population)*100
from PopvsVac


--Temp table
DROP TABLE IF EXISTS #percentageofpopulationvaccinated
CREATE TABLE #percentageofpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations NVARCHAR(255),
sumofnewvaccinations numeric
)
insert into #percentageofpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as sumofnewvaccinations             
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (sumofnewvaccinations/population)*100
from #percentageofpopulationvaccinated
           

------------------------------------- TOTAL CASES vs ICU CASES -------------------------------------
-- looking at total cases vs ICU cases

SELECT location, date, total_cases, icu_patients, (icu_patients/total_cases)*100 as icu_patientsPercentage
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
WHERE continent is not null 
--GROUP BY location, date
order by 1,2

-- looking at icu_patients vs population
-- show percentage of the population at ICU with covid

SELECT location, date, population, icu_patients, (icu_patients/population)*100 as PercentofPopulationInICU
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
order by 1,2

-- looking to contries with highest icu_patients rate compared to population
SELECT location, population, MAX(CAST(icu_patients AS INT)) AS HighestICUpatientsCount, MAX((CAST(icu_patients AS INT)/population))*100 as icu_patientspercentage
FROM PortfolioProject..CovidDeaths 
--where location like '%africa%'
where continent is not null 
GROUP BY location, population
order by icu_patientspercentage DESC

----looking at total vaccination VS icu_patients

SELECT dea.continent, dea.location, dea.date, dea.icu_patients, vac.total_vaccinations, 
SUM(convert(numeric,vac.total_vaccinations)) over (partition by dea.location order by dea.location, dea.date)as sumoftotal_vaccinations             
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE

WITH ICUpatientsvsVac (continent,location, date, icu_patients, total_vaccinations,sumoftotal_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.icu_patients, vac.total_vaccinations, 
SUM(convert(numeric,vac.total_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as sumoftotal_vaccinations             
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (convert(numeric,icu_patients)/sumoftotal_vaccinations)*100
from ICUpatientsvsVac

--Temp table

DROP TABLE IF EXISTS #percentageofICUpatients
CREATE TABLE #percentageofICUpatients
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
icu_patients nvarchar(255),   
total_vaccinations NVARCHAR(255),
sumoftotal_vaccinations numeric
)
insert into #percentageofICUpatients
SELECT dea.continent, dea.location, dea.date, dea.icu_patients, vac.total_vaccinations,
SUM(convert(numeric,vac.total_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as sumoftotalvaccinations             
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select*, (convert(numeric,icu_patients)/sumoftotal_vaccinations)*100
from #percentageofICUpatients







