set search_path = "public";

DROP TABLE IF EXISTS app.institutions;

CREATE TABLE app.institutions AS
select
  'higher_education_'::text || hem.id as unique_id,
  hem.id as source_id,
  hem.name,
  hem.state,
  hem.county,
  hem.city,
  hem.street,
  (hem.state || '-'::text) || hem.county as state_county,
  (hem.state || '-'::text) || hem.city as state_city,
  hem.population,
  'higher_education'::text as source_table,
  'Higher Education'::text as label
from
  ipeds_2022 hem
union all
select
  'k12_'::text || k12.id as unique_id,
  k12.id as source_id,
  k12.name,
  k12.state,
  k12.county,
  k12.city,
  k12.street,
  (k12.state || '-'::text) || k12.county as state_county,
  (k12.state || '-'::text) || k12.city as state_city,
  NULLIF(
    k12.enrollment_total_students,
    0::double precision
  ) as population,
  'k12_districts'::text as source_table,
  'K12 District'::text as label
from
  k12_districts k12
union all
select
  'city_'::text || cty.stcntycity_fips_code as unique_id,
  cty.stcntycity_fips_code as source_id,
  cty.city_name as name,
  cty.state,
  cty.county_name as county,
  cty.city_name as city,
  null::text as street,
  (cty.state::text || '-'::text) || cty.county_name as state_county,
  (cty.state::text || '-'::text) || cty.city_name as state_city,
  NULLIF(
    cty.population::double precision,
    0::double precision
  ) as population,
  'cities'::text as source_table,
  'Municipality'::text as label
from
  all_geo_transportation cty
where
  cty.stcntycity_fips_code is not null
union all
select
  ac.unique_id,
  ac.source_id,
  ac.name,
  ac.state,
  ac.county,
  ac.city,
  ac.street,
  ac.state_county,
  ac.state_city,
  ac.population,
  ac.source_table,
  'County'::text as label
from
  all_counties ac
where
  ac.unique_id is not null
union all
select
  'state_'::text || st.source_id as unique_id,
  st.source_id::bigint as source_id,
  st.name,
  st.state,
  null::text as county,
  st.capital_city as city,
  null::text as street,
  null::text as state_county,
  null::text as state_city,
  st.population,
  'states'::text as source_table,
  'State'::text as label
from
  states st
union all
select
  'state_agency_'::text || sa.id as unique_id,
  sa.id as source_id,
  sa.name,
  sa.state,
  sa.county,
  sa.city,
  sa.street,
  (sa.state || '-'::text) || sa.county as state_county,
  (sa.state || '-'::text) || sa.city as state_city,
  sa.population,
  'state_agencies'::text as source_table,
  'State Agency'::text as label
from
  state_agencies sa
union all
select
  'individual_unit_'::text || iu.new_individual_unit_id as unique_id,
  iu.new_individual_unit_id::bigint as source_id,
  iu.name_of_government as name,
  iu.state,
  iu.county_name as county,
  null::text as city,
  null::text as street,
  (iu.state || '-'::text) || iu.county_name as state_county,
  null::text as state_city,
  null::double precision as population,
  'individual_units'::text as source_table,
  'Special District'::text as label
from
  individual_units iu
where
  iu.worksheet_code = '03'::text;
