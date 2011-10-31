
with recursive c as (
	      select 1 as id, 'built_year equals' as type, 1981 as int_a, null as int_b, cast(null as int) as child_a, cast(null as int) as child_b
	union select 2 as id, 'dwt between'              , 10000        , 20000        , null           , null
	union select 3 as id, 'and'                      , null         , null         , 1              , 2
	union select 4 as id, 'or'                       , null         , null         , 1              , 2
	
)


, s as (
	      select 1 as id, 1974 as built_year, 5000 as dwt
	union select 2      , 1981              , 6000 
	union select 3      , 1997              , 12000 
	union select 4      , 1981              , 12500 
)


, m as (
	select c.id as cid, s.id as sid
	from c 
	inner join s 
		on (c.type = 'built_year equals' and s.built_year = c.int_a)
		or (c.type = 'dwt between' and s.dwt between c.int_a and c.int_b)
)


select *
from c

where c.type = 'or'