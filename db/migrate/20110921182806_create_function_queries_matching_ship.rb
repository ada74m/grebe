class CreateFunctionQueriesMatchingShip < ActiveRecord::Migration
  def self.up

    execute <<-SQL
      create function queries_matching_ship(ship_id int) returns table(criterion_id int)
        as $$

        declare
          max_level int;
        begin

        create temporary table matches(cid int, ctype varchar(20), pid int, level int);

        insert into matches

        with recursive levels as (
          select c.id as cid, 1 as level
          from criteria as c
          where c.parent_id is null

          union all

          select c.id, 1 + parent.level
          from criteria as c
          inner join levels as parent
            on c.parent_id = parent.cid
        )

        ,matches as (
          select
            s.id as sid,
            c.id as cid,
            c.type as ctype,
            c.parent_id as pid
          from criteria as c
          inner join ships as s
            on criterion_matches_ship(c, s)

          union all

          select
            m.sid,
            c.id,
            c.type,
            c.parent_id
          from criteria c
          inner join matches m
            on m.pid = c.id
        )

        select distinct
          m.cid,
          m.ctype,
          m.pid,
          l.level
        from matches m
        inner join levels l
          on m.cid = l.cid
        where m.sid = ship_id
        order by level;

        select into max_level max(level)
        from matches;

        if max_level is not null then
          for l in reverse max_level..1 LOOP
            -- delete criteria at this level that are ANDs
            -- which have some children that are not matched
            delete from matches as m
            where (
              m.level = l
              and m.ctype = 'and'
              and exists (
                select *
                from criteria as c
                left join matches
                  on c.id = matches.cid
                where
                  c.parent_id = m.cid
                  and matches.cid is null
              )
            )
            ;
          end loop;
        end if;

        return query
        select cid
        from matches
        where level = 1;

        drop table matches;

      end $$
      language plpgsql;

    SQL


  end

  def self.down

    execute <<-SQL

      drop function queries_matching_ship(integer);

    SQL

  end

end