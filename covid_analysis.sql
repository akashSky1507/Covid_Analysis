SELECT * FROM covidcases_analzing.coviddeaths
where continent !=''
order by 3,4;

SELECT STR_TO_DATE(date,'%d-%m-%Y') as date1 FROM coviddeaths;

SELECT 
    location,
    STR_TO_DATE(date, '%d-%m-%Y') AS Date,
    new_cases,
    total_cases,
    total_deaths,
    Population
FROM
    coviddeaths
    where continent !=''
ORDER BY 1 , 2;



/* TOTAL CASES VS TOTAL DEATHS*/



SELECT 
    location,
    STR_TO_DATE(date, '%d-%m-%Y') AS Date,
    total_cases,
    nullif(total_deaths, '')
    total_deaths,
    (total_deaths/total_cases)*100 as Percentage_Death
FROM
    coviddeaths
    where continent !=''
ORDER BY 1 , 2;


/* TOTAL CASES VS POPULATION*/
/* POPUlATION SUFFERED/SUFFERING FROM COVID*/ 


SELECT 
    location,
    STR_TO_DATE(date, '%d-%m-%Y') AS Date,
    population,
    total_cases,
    (total_cases/population)*100 as Percentage_Death 
FROM
    coviddeaths
    where continent !=''
ORDER BY 1 , 2;


/* TOP 10 COUNTRIES HAVING HIGHEST INFECTION RATE COMPARES TO POPULATION  */

SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infection_count,
    max((total_cases/population))*100 as Percentage_Infected_Population 
FROM
    coviddeaths
    where continent !=''
    group by 1,2
ORDER BY 4 desc;
 

/* TOP COUNTRIES HAVING HIGHEST DEATH COUNTS COMPARES TO POPULATION  */

SELECT CAST(Total_deaths AS unsigned) FROM coviddeaths;


SELECT 
    location, MAX(cast(Total_deaths as unsigned)) AS Total_Death_count
FROM
    coviddeaths
WHERE
continent !=''
    group by 1
ORDER BY Total_Death_count DESC;

/*CONTINENTS HAVING HIGHEST DEATH COUNTS*/

SELECT 
    continent,
    MAX(CAST(Total_deaths AS UNSIGNED)) AS Total_Death_count
FROM
    coviddeaths
WHERE
    continent != ''
GROUP BY 1
ORDER BY Total_Death_count DESC;

/* CONTINENTS HAVING HIGHEST DEATH COUNTS COMPARES TO POPULATION  */
SELECT 
    continent,
    MAX(CAST(Total_deaths AS UNSIGNED)) AS Total_Death_count
FROM
    coviddeaths
WHERE
    continent != ''
GROUP BY 1
ORDER BY Total_Death_count DESC;

/* GLOBAL DATA */

SELECT 
    STR_TO_DATE(date, '%d-%m-%Y') AS Date,
    SUM(new_cases) AS Total_Cases,
    SUM(CAST(new_deaths AS UNSIGNED)) AS Total_deaths,
    Total_Deaths / Total_Cases * 100 AS Death_Percentage
FROM
    coviddeaths
WHERE
    continent != ''
GROUP BY date
ORDER BY 1 , 2;

/* TOTAL POPULATION VS VACCINATION */

select d.continent,d.location,STR_TO_DATE(d.date, '%d-%m-%Y') AS Date,d.population,nullif(v.new_vaccinations, '') new_vaccinations,
sum(cast(v.new_vaccinations as unsigned int)) 
over (partition by d.location order by d.location,(STR_TO_DATE(d.date, '%d-%m-%Y'))) as Total_vaccination
from coviddeaths d
join covidvaccines v
on d.location=v.location and d.date=v.date
where d.continent !=''
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, STR_TO_DATE(d.date, '%d-%m-%Y') AS Date, d.population, nullif(v.new_vaccinations, '') new_vaccinations,
sum(cast(v.new_vaccinations as unsigned int)) 
over (partition by d.location order by d.location,(STR_TO_DATE(d.date, '%d-%m-%Y'))) as Total_vaccination
from coviddeaths d
join covidvaccines v
on d.location=v.location and d.date=v.date
where d.continent !=''
order by 2,3

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists Percent_PopulationVaccinated;

Create Table Percent_PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated bigint
);

Insert into Percent_PopulationVaccinated
Select d.continent, d.location, STR_TO_DATE(d.date, '%d-%m-%Y') AS Date, d.population, nullif(v.new_vaccinations, '') new_vaccinations,
sum(cast(v.new_vaccinations as char)) 
over (partition by d.location order by d.location,(STR_TO_DATE(d.date, '%d-%m-%Y'))) as RollingPeopleVaccinated
from coviddeaths d
join covidvaccines v
on d.location=v.location and d.date=v.date;


Select *, (RollingPeopleVaccinated/Population)*100 as Percentage_RollingPeopleVaccinated
From Percent_PopulationVaccinated;




-- Creating View to store data for later visualizations


DROP view if exists PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as
Select d.continent, d.location, STR_TO_DATE(d.date, '%d-%m-%Y') AS Date, d.population, nullif(v.new_vaccinations, '') new_vaccinations,
sum(cast(v.new_vaccinations as unsigned int)) 
over (partition by d.location order by d.location,(STR_TO_DATE(d.date, '%d-%m-%Y'))) as RollingPeopleVaccinated
from coviddeaths d
join covidvaccines v
on d.location=v.location and d.date=v.date
where d.continent !='';



