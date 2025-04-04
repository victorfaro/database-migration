set search_path = "public";

DROP TABLE IF EXISTS institutions;

CREATE TABLE public.institutions AS
SELECT 'higher_education_'::text || hem.id AS unique_id,
    hem.id AS source_id,
    hem.name,
    hem.state,
    hem.county,
    hem.city,
    hem.street,
    (hem.state || '-'::text) || hem.county AS state_county,
    (hem.state || '-'::text) || hem.city AS state_city,
    NULL::double precision AS population,
    'higher_education'::text AS source_table,
    'Higher Education'::text AS label
   FROM prod_education.ipeds_2022 hem
UNION ALL
 SELECT 'k12_'::text || k12.id AS unique_id,
    k12.id AS source_id,
    k12.name,
    k12.state,
    k12.county,
    k12.city,
    k12.street,
    (k12.state || '-'::text) || k12.county AS state_county,
    (k12.state || '-'::text) || k12.city AS state_city,
    NULLIF(k12.enrollment_total_students, 0::double precision) AS population,
    'k12_districts'::text AS source_table,
    'K12 District'::text AS label
   FROM prod_education.k12_districts k12
UNION ALL
 SELECT 'city_'::text || cty.stcntycity_fips_code AS unique_id,
    cty.stcntycity_fips_code AS source_id,
    cty.city_name AS name,
    cty.state,
    cty.county_name AS county,
    cty.city_name AS city,
    NULL::text AS street,
    (cty.state::text || '-'::text) || cty.county_name AS state_county,
    (cty.state::text || '-'::text) || cty.city_name AS state_city,
    NULLIF(cty.population::double precision, 0::double precision) AS population,
    'cities'::text AS source_table,
    'Municipality'::text AS label
   FROM prod_education.all_geo_transportation cty
  WHERE cty.stcntycity_fips_code IS NOT NULL
UNION ALL
 SELECT ac.unique_id,
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
    'County'::text AS label
   FROM prod_education.all_counties ac
  WHERE ac.unique_id IS NOT NULL
UNION ALL
 SELECT 'state_'::text || st.source_id AS unique_id,
    st.source_id::bigint AS source_id,
    st.name,
    st.state,
    NULL::text AS county,
    st.capital_city AS city,
    NULL::text AS street,
    NULL::text AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'states'::text AS source_table,
    'State'::text AS label
   FROM prod_education.states st
UNION ALL
 SELECT 'state_agency_'::text || sa.id AS unique_id,
    sa.id AS source_id,
    sa.name,
    sa.state,
    NULL::text AS county,
    NULL::text AS city,
    NULL::text AS street,
    NULL::text AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'state_agencies'::text AS source_table,
    'State Agency'::text AS label
   FROM prod_education.state_agencies sa
UNION ALL
 SELECT 'individual_unit_'::text || iu.new_individual_unit_id AS unique_id,
    iu.new_individual_unit_id::bigint AS source_id,
    iu.name_of_government AS name,
    iu.state,
    iu.county_name AS county,
    NULL::text AS city,
    NULL::text AS street,
    (iu.state || '-'::text) || iu.county_name AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'individual_units'::text AS source_table,
    'Special Districts'::text AS label
   FROM prod_education.individual_units iu
  WHERE iu.worksheet_code = '03'::text;
