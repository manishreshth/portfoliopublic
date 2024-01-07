-- looking at total population vs vaccinations

select dea.continent, dea.location, cast(dea.date as date) as Vdate,
	dea.population, 
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as CumPeoplVaccinated

from portfolioCovid.dbo.coviddeaths dea
join portfolioCovid.dbo.covidvaccines vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3


-- use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumPeopleVaccinated)
as (
select dea.continent, dea.location, cast(dea.date as date) as Vdate,
	dea.population, 
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as CumPeoplVaccinated

from portfolioCovid.dbo.coviddeaths dea
join portfolioCovid.dbo.covidvaccines vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 

)
select *, round((CumPeopleVaccinated/Population)*100,2) as percentagevaccinated
from PopvsVac
order by 2,3

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
CumPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,
	dea.population, 
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as CumPeoplVaccinated

from portfolioCovid.dbo.coviddeaths dea
join portfolioCovid.dbo.covidvaccines vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null 
order by 2,3

select *, round((CumPeopleVaccinated/Population)*100,2) as percentagevaccinated
from #PercentPopulationVaccinated



-- Creating view to store data for later visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,
	dea.population, 
	vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as CumPeoplVaccinated

from portfolioCovid.dbo.coviddeaths dea
join portfolioCovid.dbo.covidvaccines vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated