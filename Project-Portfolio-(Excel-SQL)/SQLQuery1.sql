select *
from RaysPitching.Dbo.[LastPitchRays(File Cleaned)]

select *
from RaysPitching.Dbo.[RayPitchingStats(File Cleaned)]


--Question 1 AVG Pitches Per at bat Analysis



--1a AVG Pitches Per At Bat (LastPitchRays)

select AVG(1.00 * pitch_number) AvgNumofPitchersPerAtbat
from RaysPitching.dbo.[LastPitchRays(File Cleaned)]



--1b AVG Pitches Per At Bat Home Vs Away (LastPitchRays) -> Union



select 'Home' TypeOfGame,
	AVG(1.00 * pitch_number) AvgNumofPitchersPerAtbat
	from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
	where home_team = 'TB'
union
select 'Away' typeOfGame,
	AVG(1.00 * pitch_number) AvgNumofPitchersPerAtbat
	from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
	where away_team = 'TB'





--1c AVG Pitches Per At Bat Leftly Vs Righty  -> case Statement


select 
	AVG(case when Batter_position = 'L' then  1.00 * pitch_number end) LeftlyatBats,
	AVG(case when Batter_position = 'R' then  1.00 * pitch_number end) RightlyatBats
from RaysPitching.dbo.[LastPitchRays(File Cleaned)]



--1d AVG Pitches Per At Bat Leftly Vs Righty | Each Away game -> Partition By


select distinct
		home_team,
		Pitcher_position,
		AVG(1.00 * pitch_number) over (partition by  home_team,Pitcher_position)
from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
		where away_team = 'TB'

--1e Top 3 Most Common Pitch for at bat 1 through 10,and total amounts (LastPitchRays)


with totalpitchsequence as (
select distinct
		Pitch_name,
		Pitch_number,
		COUNT(pitch_name) over (partition by Pitch_name,Pitch_number) Pitchfrequency
from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
where Pitch_number < 11
),
PitchfrequencyRankquery as (
	select 
	Pitch_name,
	Pitch_number,
	Pitchfrequency,
	rank() over (partition by Pitch_number order by Pitchfrequency desc) PitchfrequencyRanking
from totalpitchsequence
)

select *
from PitchfrequencyRankquery
where PitchfrequencyRanking  <4



--1f AVG Pitches Per At Bat Per Pitcher with 20+ iInnings | Order in descending (LastPitchRays + RayPitchingStats)



select	RPS.Name,
		AVG(1.00 * pitch_number) AVGpitchers
from RaysPitching.Dbo.[LastPitchRays(File Cleaned)] LPR
join RaysPitching.dbo.[RayPitchingStats(File Cleaned)] RPS on RPS.pitcher_id = LPR.pitcher
where IP > 20
group by  RPS.Name 
order by AVG(1.00 * pitch_number) desc




--Question 2 last Picth Analysis



--2a Count of the last Pitches Thrown in Desc Order (LastPitchRays)


select pitch_name,COUNT(*) timesthrown
from RaysPitching.Dbo.[LastPitchRays(File Cleaned)]
group by pitch_name
order by COUNT(*) desc
  


--2b Count of the Different last Pitches Fastball or Offspead (LastPitchRays)



select
	sum(case when pitch_name in ('4-Seam Fastball','Cutter') then 1 else 0 end) Fastball
	,sum(case when pitch_name Not in ('4-Seam Fastball','Cutter') then 1 else 0 end) Offspead
from RaysPitching.Dbo.[LastPitchRays(File Cleaned)]




--2c Percentage of the Different last Pitches Fastball or Offspead (LastPitchRays)


select
	100 * sum(case when pitch_name in ('4-Seam Fastball','Cutter') then 1 else 0 end) / COUNT(*)  Fastball ,
	100 * sum(case when pitch_name Not in ('4-Seam Fastball','Cutter') then 1 else 0 end) / COUNT(*) Offspead 
from RaysPitching.Dbo.[LastPitchRays(File Cleaned)]



--2d Top 5 Most common last pitch for a Reliof vs Starting Pitcher (LastPitchRays + RayPitchingStats)

select *
from	(
	select 
		a.Pos, a.pitch_name, a.timesthrown,
		RANK() over (partition by a.Pos order by a.timesthrown desc) PitchRank
	from (
	select RPS.Pos,LPR.pitch_name , COUNT(*) timesthrown
	from RaysPitching.Dbo.[LastPitchRays(File Cleaned)] LPR
	join RaysPitching.dbo.[RayPitchingStats(File Cleaned)] RPS on RPS.pitcher_id = LPR.pitcher
	group by RPS.Pos,LPR.pitch_name
	) a
)b
where b.PitchRank < 6



--Question 3 Homerun Analysis

--3a What pitches have given up the most HRs ([LastPitchRays)



-- Doesnt work due to bad data
--select *
--from  RaysPitching.Dbo.[LastPitchRays(File Cleaned)]
--where hit_location is null and bb_type = 'fly_ball'



-- actual way to do it

select pitch_name, COUNT(*) HRs
from RaysPitching.Dbo.[LastPitchRays(File Cleaned)]
where events = 'home_run'
group by pitch_name
order by COUNT(*) desc
 


--3b Show HRs given up by zone  and pitch, show top 5 most common 



select top 5 zone ,pitch_name, COUNT(*) HRs
from RaysPitching.Dbo.[LastPitchRays(File Cleaned)]
where events = 'home_run'
group by zone, pitch_name
order by  COUNT(*) desc



--3c Show HRs for each count type -> Balls/Striks + type Of Pitcher


select RPS.Pos,LPR.balls,LPR.strikes , COUNT(*) HRs
from RaysPitching.Dbo.[LastPitchRays(File Cleaned)] LPR
join RaysPitching.dbo.[RayPitchingStats(File Cleaned)] RPS on RPS.pitcher_id = LPR.pitcher
where events = 'home_run'
group by RPS.Pos,LPR.balls,LPR.strikes
order by  COUNT(*) desc

 

--3d Show Each Pitchers Most common count to give up a HR (min 30 IP)


with hrcountpitchers as (

		select RPS.Name ,LPR.balls,LPR.strikes , COUNT(*) HRs
		from RaysPitching.Dbo.[LastPitchRays(File Cleaned)] LPR
		join RaysPitching.dbo.[RayPitchingStats(File Cleaned)] RPS on RPS.pitcher_id = LPR.pitcher
		where events = 'home_run' and IP >= 30
		group by RPS.Name ,LPR.balls,LPR.strikes

),

hrcountranks as (
	select
	hcp.Name,
	hcp.balls,
	hcp.strikes,
	hcp.HRs,
	RANK() over (partition by Name order by HRs desc) hrrank
	from hrcountpitchers hcp
)
select ht.Name , ht.balls , ht.strikes, ht.HRs
from hrcountranks ht
where hrrank = 1






--Question 4 McClanahan, Shane 

--4a AVG Release speed, spin rate, strikouts, most popular zone ONLY USING LastPitchRays


select 
		AVG(release_speed) AvgReleaseSpeed,
		AVG(release_spin_rate) AvgSpinrated,
		SUM(case when events = 'strikeout' then 1 else 0 end) Strikeouts,
		MAX(Zones.zone) as zone

from RaysPitching.Dbo.[LastPitchRays(File Cleaned)] LPR
join 
	(
		select top 1 pitcher,zone , COUNT(*) zonenum
		from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
		where player_name = 'McClanahan, Shane'
		group by pitcher, zone
		order by  COUNT(*) desc		  
	)	Zones on LPR.pitcher = Zones.pitcher

where player_name = 'McClanahan, Shane'









--4b top pitches for each position where total pitcher are over 5 , rank them

select *
from (
	select pitch_name, COUNT(*) timeshit , 'Third' Position
	from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
	where hit_location = 5 and player_name = 'McClanahan, Shane'
	group by pitch_name
	union
	select pitch_name, COUNT(*) timeshit , 'short' Position
	from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
	where hit_location = 6 and player_name = 'McClanahan, Shane'
	group by pitch_name
	union
	select pitch_name, COUNT(*) timeshit , 'Secound' Position
	from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
	where hit_location = 4 and player_name = 'McClanahan, Shane'
	group by pitch_name
	union
	select pitch_name, COUNT(*) timeshit , 'First' Position
	from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
	where hit_location = 3 and player_name = 'McClanahan, Shane'
	group by pitch_name
) a
where timeshit > 4
order by timeshit desc





--4c show different balls/strikes as well as frequency when someone is on base


select balls, strikes, COUNT(*) frequency
from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
where (on_1b is not null or on_2b is not null  or on_3b is not null )
and player_name = 'McClanahan, Shane'
group by balls, strikes
order by COUNT(*) desc


--4d What pitch causes the lowest launch speed



select  pitch_name, AVG(launch_speed) LaunchSpeed
from RaysPitching.dbo.[LastPitchRays(File Cleaned)]
where player_name = 'McClanahan, Shane'
group by pitch_name
order by AVG(launch_speed) desc