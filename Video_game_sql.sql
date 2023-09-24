-- Looking for duplicates in the PS4 and xbox sales data

with T1 as (Select *, row_number() over(partition by year, genre, europe, japan,  global) as row_num
from video_games_data.ps4_game_sale) 
select * 
from T1 
where row_num > 1

with T2 as (Select *, row_number() over(partition by year, genre, europe, japan,  global) as row_num
from video_games_data.xboxone_game_sales) 
select * 
from T2 
where row_num > 1

-- most popular platform with regards to global sales of games

select distinct platform, sum(global_sales) over(partition by platform) as Total_global_sale
from video_games_data.video_games_sales
order by Total_global_sale desc

-- which genre of games has sold the most?

select distinct genre, sum(global_sales) over(partition by genre) as global_sales_per_Genre
from video_games_data.video_games_sales
order by global_sales_per_Genre desc

-- The top 5 sold games for xbox and ps

with XB as
 (select  game, year, genre, max(global) as max_global_sales
from video_games_data.xboxone_game_sales
group by  game, year, genre, global
limit 5),
ps as
(select  game, year, genre,  max(global) as max_global_sales
from video_games_data.ps4_game_sale
group by  game, year, genre, global
limit 5)
select * 
from xb 
join ps on xb.year = ps.year

-- How much was made in each year globally for xbox and ps 

with TS as(with T1 as (select year as xbox_year, sum(global) as xbox_total_sales 
from video_games_data.xboxone_game_sales
group by year 
order by year),
T2 as(select year as PS_year, sum(global) as PS_total_sales 
from video_games_data.ps4_game_sale
group by year 
order by year)
select t1.*, t2.*
from T1 
join t2 on t1.xbox_year = t2.ps_year)
select TS.xbox_year,TS.xbox_total_sales,TS.PS_year,TS.PS_total_sales
from TS

-- which region of the world has the most games sold and what is the most popular genre in that region.

with regional_sales as (select 'NA_sales' as Region,sum(NA_sales) as Region_sum
from  video_games_data.video_games_sales
union all 
select 'EU_sales' as Region, sum(EU_sales) as EU_sales
from  video_games_data.video_games_sales
union all
select 'JP_sales' as Region,Sum(JP_sales)
from  video_games_data.video_games_sales
union all
select 'Other_sales' as Region,sum(other_sales) as Other_sales
from  video_games_data.video_games_sales
order by 2 desc
), 
Genre as (select distinct genre,sum(NA_sales) AS NA_sales, sum(EU_sales) AS EU_Sales, sum(JP_sales) AS JP_Sales, sum(other_sales) AS Other_sales
from video_games_data.video_games_sales
group by genre)
select r.region, r.region_sum, G.genre
from regional_sales R 
cross join genre G
order by region_sum desc, NA_Sales desc, EU_sales desc, JP_sales desc, Other_sales desc
limit 1

-- which publisher has sold the most games and what is their highest selling game 

with publisher_global_sales as (select distinct publisher, sum(global_sales) as Total_global_sales
from video_games_data.video_games_sales
group by publisher
order by 2 desc), 
games as (select name, publisher, max(global_sales) as games_sold
from video_games_data.video_games_sales
group by name, publisher
order by 3 desc)
select p.publisher, p.Total_global_sales, g.name, g.games_sold
from publisher_global_sales p join games g on p.publisher = g.publisher
order by 2 desc, games_sold desc
limit 1










