select *
from Youtube.dbo.marathon_PDC



-- How many States were represented in the race
select  COUNT(distinct State) as distinct_count
from Youtube.dbo.marathon_PDC

--what was thw average time of Men Vs Women

select Gender ,AVG(Total_Minutes) as avg_time
from Youtube.dbo.marathon_PDC
group by Gender


--what were the youngest and oldset ages in the race

select Gender , MIN(Age) as youngest, MAX(Age) as oldset
from Youtube.dbo.marathon_PDC
group by Gender;

--What was the average time for each age groupe

with age_buckets as (
select Total_Minutes,Age,
	case when age < 30 then 'age_29-29'
		 when age < 40 then 'age_30-39'
		 when age < 50 then 'age_40-49'
		 when age < 60 then 'age_50-59'
	else 'age_60+' end as age_group
from Youtube.dbo.marathon_PDC
)
select age_group, AVG(Total_Minutes) avg_race_time
from age_buckets
group by age_group;


--Top 3 males and females


with gender_rank as (
	
	select RANK() over (partition by Gender order by Total_Minutes asc) as gender_rank,
	fullname,
	Gender,
	Total_Minutes
	from  Youtube.dbo.marathon_PDC
)

select *
from gender_rank
where gender_rank < 4
order by Total_Minutes