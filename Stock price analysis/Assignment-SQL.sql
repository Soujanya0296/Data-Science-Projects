-- CREATE THE SCHEMA 'assignment' 
create schema assignment;

-- USING THE SCHEMA
use assignment;

-- 1. CREATE A NEW TABLE NAMED 'bajaj1' CONTAINING THE COLUMNS - DATE, CLOSE PRICE, 20 DAY MA and 50 DAY MA. 
-- (THIS HAS TO BE DONE FOR ALL 6 STOCKS).

create table `bajaj1` (
	select str_to_date(`Date`, '%d-%M-%Y') as `Date`, `Close Price` as `Close Price`, 
		case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 19 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 19 preceding) 
            else null 
		end as `20 Day MA`, 
        case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 49 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 49 preceding) 
            else null 
		end as `50 Day MA` 
	from bajaj 
	where `Close Price` is not null and `Date` is not null 
    order by `Date` desc);

create table `eicher1` (
	select str_to_date(`Date`, '%d-%M-%Y') as `Date`, `Close Price` as `Close Price`, 
		case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 19 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 19 preceding) 
            else null 
		end as `20 Day MA`, 
        case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 49 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 49 preceding) 
            else null 
		end as `50 Day MA` 
	from eicher 
	where `Close Price` is not null and `Date` is not null 
    order by `Date` desc);
    
create table `hero1` (
	select str_to_date(`Date`, '%d-%M-%Y') as `Date`, `Close Price` as `Close Price`, 
		case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 19 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 19 preceding) 
            else null 
		end as `20 Day MA`, 
        case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 49 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 49 preceding) 
            else null 
		end as `50 Day MA` 
	from hero 
	where `Close Price` is not null and `Date` is not null 
    order by `Date` desc);

create table `infosys1` (
	select str_to_date(`Date`, '%d-%M-%Y') as `Date`, `Close Price` as `Close Price`, 
		case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 19 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 19 preceding) 
            else null 
		end as `20 Day MA`, 
        case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 49 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 49 preceding) 
            else null 
		end as `50 Day MA` 
	from infosys 
	where `Close Price` is not null and `Date` is not null 
    order by `Date` desc);

create table `tcs1` (
	select str_to_date(`Date`, '%d-%M-%Y') as `Date`, `Close Price` as `Close Price`, 
		case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 19 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 19 preceding) 
            else null 
		end as `20 Day MA`, 
        case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 49 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 49 preceding) 
            else null 
		end as `50 Day MA` 
	from tcs 
	where `Close Price` is not null and `Date` is not null 
    order by `Date` desc);

create table `tvs1` (
	select str_to_date(`Date`, '%d-%M-%Y') as `Date`, `Close Price` as `Close Price`, 
		case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 19 
			then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 19 preceding) 
            else null 
		end as `20 Day MA`, 
        case 
			when row_number() over (order by str_to_date(`Date`, '%d-%M-%Y')) > 49 
            then avg(`Close Price`) over (order by str_to_date(`Date`, '%d-%M-%Y') asc rows 49 preceding) 
            else null 
		end as `50 Day MA` 
	from tvs
	where `Close Price` is not null and `Date` is not null 
    order by `Date` desc);

-- LET'S VIEW THE VALUES IN EACH TABLE.

select * from bajaj1 order by `Date` desc;
select * from eicher1 order by `Date` desc;
select * from hero1 order by `Date` desc;
select * from infosys1 order by `Date` desc;
select * from tcs1 order by `Date` desc;
select * from tvs1 order by `Date` desc;

-- 2. CREATE A MASTER TABLE CONTANING THE DATE AND CLOSE PRICE OF ALL THE SIX STOCKS. 
-- (COLUMN HEADER FOR THE PRICE IS THE NAME OF THE STOCK).

create table `master_table` (
	`Date` date, 
	`Bajaj` decimal(10,2), 
    `TCS` decimal(10,2), 
    `TVS` decimal(10,2), 
    `Infosys` decimal(10,2), 
    `Eicher` decimal(10,2), 
    `Hero` decimal(10,2)  
);

-- INSERTING VALUES INTO MASTER TABLE.

insert into `master_table` (`Date`, Bajaj, TCS, TVS, Infosys, Eicher, Hero) 
	select str_to_date(bajaj.Date, '%d-%M-%Y') as `Date`, bajaj.`Close Price`,  tcs.`Close Price`,  
    tvs.`Close Price`,  infosys.`Close Price`, eicher.`Close Price`,  hero.`Close Price` 
    from bajaj 
    inner join tcs on bajaj.Date = tcs.Date 
    inner join tvs on bajaj.Date = tvs.Date 
    inner join infosys on bajaj.Date = infosys.Date 
    inner join eicher on bajaj.Date = eicher.Date 
    inner join hero on bajaj.Date = hero.Date 
    order by `Date` desc;
    
-- LET'S VIEW THE VALUES INSERTED IN MASTER TABLE.

select * from master_table;

-- 3. USE TABLE CREATED IN PART(1) TO GENERATE BUY AND SELL SIGNAL. STORE THIS IN ANOTHER TABLE NAMED 'bajaj2'.
-- PERFORM THIS OPERATION ON ALL STOCKS. 
-- CREATING NEW TABLES - bajaj2, eicher2, hero2, infosys2, tcs2, tvs2.

create table `bajaj2` (
	select `Date`, `Close Price` as `Close Price`,
		case 
			when row_number() over (order by `Date`) < 50 
				then 'HOLD'
			when `20 Day MA` > `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) < (lag(`50 Day MA`, 1) over (order by `Date`)) 
				then 'BUY'
			when `20 Day MA` < `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) > (lag(`50 Day MA`, 1) over (order by `Date`))
				then 'SELL'
			else 'HOLD'	
		end	as `Signal`
	from  bajaj1
   	order by `Date` desc);

create table `eicher2` (
	select `Date`, `Close Price` as `Close Price`,
		case 
			when row_number() over (order by `Date`) < 50 
				then 'HOLD'
			when `20 Day MA` > `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) < (lag(`50 Day MA`, 1) over (order by `Date`)) 
				then 'BUY'
			when `20 Day MA` < `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) > (lag(`50 Day MA`, 1) over (order by `Date`))
				then 'SELL'
			else 'HOLD'	
		end	as `Signal`
	from  eicher1
   	order by `Date` desc);

create table `hero2` (
	select `Date`, `Close Price` as `Close Price`,
		case 
			when row_number() over (order by `Date`) < 50 
				then 'HOLD'
			when `20 Day MA` > `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) < (lag(`50 Day MA`, 1) over (order by `Date`)) 
				then 'BUY'
			when `20 Day MA` < `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) > (lag(`50 Day MA`, 1) over (order by `Date`))
				then 'SELL'
			else 'HOLD'	
		end	as `Signal`
	from  hero1
   	order by `Date` desc);

create table `infosys2` (
	select `Date`, `Close Price` as `Close Price`,
		case 
			when row_number() over (order by `Date`) < 50 
				then 'HOLD'
			when `20 Day MA` > `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) < (lag(`50 Day MA`, 1) over (order by `Date`)) 
				then 'BUY'
			when `20 Day MA` < `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) > (lag(`50 Day MA`, 1) over (order by `Date`))
				then 'SELL'
			else 'HOLD'	
		end	as `Signal`
	from  infosys1
   	order by `Date` desc);
    
create table `tcs2` (
	select `Date`, `Close Price` as `Close Price`,
		case 
			when row_number() over (order by `Date`) < 50 
				then 'HOLD'
			when `20 Day MA` > `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) < (lag(`50 Day MA`, 1) over (order by `Date`)) 
				then 'BUY'
			when `20 Day MA` < `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) > (lag(`50 Day MA`, 1) over (order by `Date`))
				then 'SELL'
			else 'HOLD'	
		end	as `Signal`
	from  tcs1
   	order by `Date` desc);

create table `tvs2` (
	select `Date`, `Close Price` as `Close Price`,
		case 
			when row_number() over (order by `Date`) < 50 
				then 'HOLD'
			when `20 Day MA` > `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) < (lag(`50 Day MA`, 1) over (order by `Date`)) 
				then 'BUY'
			when `20 Day MA` < `50 Day MA` and (lag(`20 Day MA`, 1) over (order by `Date`)) > (lag(`50 Day MA`, 1) over (order by `Date`))
				then 'SELL'
			else 'HOLD'	
		end	as `Signal`
	from  tvs1
   	order by `Date` desc);
    
-- LET'S VIEW THE VALUES IN EACH TABLE.

select * from bajaj2 order by `Date` desc;
select * from eicher2 order by `Date` desc;
select * from hero2 order by `Date` desc;
select * from infosys2 order by `Date` desc;
select * from tcs2 order by `Date` desc;
select * from tvs2 order by `Date` desc;

-- 4. CREATE A USER DEFINED FUNCTION, THAT TAKES THE DATE AS INPUT AND RETURNS THE SIGNAL FOR THAT PARTICULAR DAY (BUY/SELL/HOLD) FOR THE BAJAJ STOCK.

drop function if exists UDF_for_Bajaj;

delimiter $

create function UDF_for_Bajaj(input_date date) 
  returns varchar(15) 
  deterministic
begin   
  declare UDF_Signal varchar(15);
  
  select bajaj2.`Signal` into UDF_Signal from bajaj2 
  where date = input_date;
  
  return UDF_Signal;
  end
  
$ delimiter ;

-- LET'S CHECK THE OUTPUT OF UDF CREATED ABOVE.

select UDF_for_Bajaj('2015-05-18') as Bajaj_Signal;