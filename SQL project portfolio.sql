

select       *
from         [dbo].[CovidDeaths$]
where        continent is not null 

select       *
from         [dbo].[CovidDeathsvaccination]

select       location, date, total_cases, new_cases, total_deaths, population
from         [dbo].[CovidDeaths$]

-- looking at total cases vs total deaths
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

select       location, date, total_cases, total_deaths,(TOTAL_DEATHS / TOTAL_CASES)*100 AS DEATHPERCENTAGE
from         [dbo].[CovidDeaths$]
WHERE        LOCATION LIKE '%STATES%'

--LOOKING AT TOTAL CASES VS POPULATION
--shows what % of population got covid

select      location, date, population, total_cases,(TOTAL_cases / population)*100 AS percentpopulationinfected
from        [dbo].[CovidDeaths$]
WHERE       LOCATION LIKE '%STATES%'

-- looking at countries with highest infection rate compared to population

select      location,population, max(total_cases) as highestinfectioncount,max((TOTAL_cases / population)*100) AS percentpopulationinfected
from        [dbo].[CovidDeaths$]
--WHERE LOCATION LIKE '%STATES%'
group by    location,population
order by    percentpopulationinfected desc

--showing countries with highest death count per population

select      location, max(cast (total_deaths as int)) as totaldeathcount
from        [dbo].[CovidDeaths$]
where       continent is not null 
group by    location
order by    totaldeathcount desc



--showing continents with the highest death count per population

select      continent, max(cast (total_deaths as int)) as totaldeathcount
from        [dbo].[CovidDeaths$]
where       continent is not null 
group by    continent
order by    totaldeathcount desc


--joining the covid deaths and vaccinations table

select      *
from        [dbo].[CovidDeaths$] dea
join        [dbo].[CovidDeathsvaccination] vac
     on     dea.location = vac.location
	 and    dea.date = vac.date

-- looking at total population vs vaccinations

select      dea.continent, dea.location,dea.date,dea.population, vac.[new_vaccinations],
            sum(cast (vac.[new_vaccinations] as int)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from        [dbo].[CovidDeaths$] dea
join        [dbo].[CovidDeathsvaccination] vac
     on     dea.location = vac.location
	 and    dea.date = vac.date
where       dea.continent is not null

--with ctp

with        popvsvac (continent , location, date, population,new_vaccinations,rollingpeoplevaccinated)
as
            (select dea.continent, dea.location,dea.date,dea.population, vac.[new_vaccinations],
             sum(cast (vac.[new_vaccinations] as int)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from        [dbo].[CovidDeaths$] dea
join        [dbo].[CovidDeathsvaccination] vac
     on     dea.location = vac.location
	 and    dea.date = vac.date
where       dea.continent is not null
)

select      *
from        popvsvac

--temp table 

drop table if   exists #percentpopulationvaccinated
create table    #percentpopulationvaccinated
                (
                  continent nvarchar (255),
                  location nvarchar (255),
                  date datetime,
                  population numeric ,
                  new_vaccinations numeric,
                  rollingpeoplevaccinated numeric
                )



insert into      #percentpopulationvaccinated
select           dea.continent, dea.location,dea.date,dea.population, vac.[new_vaccinations],
                 sum(cast (vac.[new_vaccinations] as int)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from            [dbo].[CovidDeaths$] dea
join            [dbo].[CovidDeathsvaccination] vac
     on         dea.location = vac.location
	 and        dea.date = vac.date
where           dea.continent is not null
 
 select         *
from            #percentpopulationvaccinated

--creating view to store data for later visulization

create view     percentpopulationvaccinated as
select          dea.continent, dea.location,dea.date,dea.population, vac.[new_vaccinations],
                sum(cast (vac.[new_vaccinations] as int)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from            [dbo].[CovidDeaths$] dea
join            [dbo].[CovidDeathsvaccination] vac
     on         dea.location = vac.location
	 and        dea.date = vac.date
where           dea.continent is not null

select          *
from            percentpopulationvaccinated

-- for tableau

--1.

select          sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
                sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from            [dbo].[CovidDeaths$]
where           continent is not null

 
--2 we take these out as they are not included in the above quries and want to stay consitent
--european is part of europe

select          location,sum(cast(new_deaths as int)) as totaldeathcount
from            [dbo].[CovidDeaths$]
where           continent is null
      and       location not in ('world','european union','international')
group by        location
order by        totaldeathcount desc

--3

select          location,population,max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentagepopulationinfected 
from            [dbo].[CovidDeaths$]
--where continentis null
      --and location not in ('world','european union','international')
group by        location,population
order by        percentagepopulationinfected desc

--4

select          location,population,date,max(total_cases) as highestinfectioncount, 
                max((total_cases/population))*100 as percentagepopulationinfected 
from            [dbo].[CovidDeaths$]
      --where continent is null
      --and location not in ('world','european union','international')
group by        location,population,date
order by        percentagepopulationinfected desc