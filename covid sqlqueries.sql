
/*

Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select * from [Portfolio Project]..['covid deaths'] where continent is not null order by 3,4;



-- Select Data that we are going to be starting with

select location,population,date,new_cases,total_cases,total_deaths from [Portfolio Project]..['covid deaths'] 
where continent is not null order by location,date;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location ,date,population,total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage from [Portfolio Project]..['covid deaths']
where continent is not null order by 1,2;



-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location ,date,population,total_cases,(total_cases/population)*100 as Percent_of_infection from [Portfolio Project]..['covid deaths'] 
where continent is not null order by 1,2;



--Shows what percentage of population got infected with covid in india

select location ,date,population,total_cases,(total_cases/population)*100 as Percent_of_infection from [Portfolio Project]..['covid deaths']
where continent is not null and location like 'india' order by 1,2;

--Shows Total infected and Total deaths in India
select max(population) as total_Population, sum(cast(new_cases as int)) as total_cases ,sum(cast(new_deaths as int)) as total_deaths from [Portfolio Project]..['covid deaths'] 
where location like 'india' ;

--Shows Total infected and Total Deaths Globally

select sum(cast(new_cases as int)) as total_cases ,sum(cast(new_deaths as int)) as total_deaths ,
sum(cast(new_deaths as int))/sum(new_cases )*100 as DeathPercentage
from [Portfolio Project]..['covid deaths'] ;


-- Countries with Highest Infection Rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..['covid deaths']
where continent is not null 
Group by location,population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

select location ,  max(cast(total_deaths as int)) as Total_deaths from [Portfolio Project]..['covid deaths'] where continent is not null 
group by location,population order by Total_deaths desc;

-- Showing contintents with the highest death count per population

select continent ,max(cast(total_deaths as int)) as Total_Deaths from [Portfolio Project]..['covid deaths'] where continent is not null group by continent order by Total_Deaths desc;

--As the above query leads to some misunderstanding of data lets fetch data of continents from location column


select location as continent,max(cast(total_deaths as int)) as Total_deaths from [Portfolio Project]..['covid deaths'] 
where continent is null and location not in ('International','World','European Union')
group by location order by Total_deaths desc;


--Global Numbers

select date, sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percent
from [Portfolio Project]..['covid deaths'] 
where continent is not null group by date;

--Lets join covid death table with covid  vaccinations table 

select * from [Portfolio Project]..['covid deaths']  as a inner join [Portfolio Project]..['covid vaccinated'] as b 
on a.location=b.location and a.date=b.date  where a.continent is not null order by 3,4; 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select 
a.continent,a.location,a.date, a.population,b.new_vaccinations 
,sum(cast (b.new_vaccinations as int)) over(partition by a.location order by a.location,a.date)
as RunningTotalofVaccination
from [Portfolio Project]..['covid deaths']  as a inner join [Portfolio Project]..['covid vaccinated'] as b 
on a.location=b.location and a.date=b.date  where a.continent is not null order by a.location,a.date; 


-- Using CTE to perform Calculation on Partition By in previous query

with cte as
(

select 
a.continent,a.location,a.date, a.population,b.new_vaccinations 
,sum(cast (b.new_vaccinations as int)) over(partition by a.location order by a.location,a.date)
as RunningTotalofVaccination
from [Portfolio Project]..['covid deaths']  as a inner join [Portfolio Project]..['covid vaccinated'] as b 
on a.location=b.location and a.date=b.date  where a.continent is not null -- order by a.location,a.date; 
)select continent ,location,date,population ,new_vaccinations ,RunningTotalofVaccination ,
(RunningTotalofVaccination/population)*100 as percentofvaccination from cte order by location;


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RunningTotalofVaccination numeric)

insert into #PercentPopulationVaccinated
select 
a.continent,a.location,a.date, a.population,b.new_vaccinations 
,sum(cast (b.new_vaccinations as int)) over(partition by a.location order by a.location,a.date)
as RunningTotalofVaccination
from [Portfolio Project]..['covid deaths']  as a inner join [Portfolio Project]..['covid vaccinated'] as b 
on a.location=b.location and a.date=b.date  --where a.continent is not null -- order by a.location,a.date; 

select*,(RunningTotalofVaccination/population)*100 as percentofvaccination from  #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select 
a.continent,a.location,a.date, a.population,b.new_vaccinations 
,sum(cast (b.new_vaccinations as int)) over(partition by a.location order by a.location,a.date)
as RunningTotalofVaccination
from [Portfolio Project]..['covid deaths']  as a inner join [Portfolio Project]..['covid vaccinated'] as b 
on a.location=b.location and a.date=b.date  where a.continent is not null;

  