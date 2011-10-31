--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: criteria; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE criteria (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    model character varying(255),
    property character varying(255),
    parent_id integer,
    negative boolean DEFAULT false NOT NULL,
    integer_a integer,
    integer_b integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: ships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ships (
    id integer NOT NULL,
    dwt integer,
    built_year integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: criterion_matches_ship(criteria, ships); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION criterion_matches_ship(c criteria, s ships) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ begin
        return
             (c.type = 'built_year equal' and s.built_year = c.integer_a)
          or (c.type = 'dwt between' and s.dwt between c.integer_a and c.integer_b);

      end $$;


--
-- Name: queries_matching_ship(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION queries_matching_ship(ship_id integer) RETURNS TABLE(criterion_id integer)
    LANGUAGE plpgsql
    AS $$

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

      end $$;


--
-- Name: criteria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE criteria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: criteria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE criteria_id_seq OWNED BY criteria.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: ships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ships_id_seq OWNED BY ships.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE criteria ALTER COLUMN id SET DEFAULT nextval('criteria_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ships ALTER COLUMN id SET DEFAULT nextval('ships_id_seq'::regclass);


--
-- Name: criteria_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY criteria
    ADD CONSTRAINT criteria_pkey PRIMARY KEY (id);


--
-- Name: ships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ships
    ADD CONSTRAINT ships_pkey PRIMARY KEY (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20110917151613');

INSERT INTO schema_migrations (version) VALUES ('20110917151313');

INSERT INTO schema_migrations (version) VALUES ('20110820183740');

INSERT INTO schema_migrations (version) VALUES ('20110820185201');

INSERT INTO schema_migrations (version) VALUES ('20110921175143');

INSERT INTO schema_migrations (version) VALUES ('20110921182806');