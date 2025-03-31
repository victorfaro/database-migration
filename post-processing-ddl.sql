DROP TABLE view_smart_col_by_user;

create view public.view_power_users as
with
  smart_column_counts as (
    select
      u.email,
      count(cc.id) as smart_column_count
    from
      mock_custom_columns cc
      join mock_workspaces mw on mw.id = cc.workspace_id
      join mock_user u on u.auth0_id = mw.user_id
    where
      u.email !~~ '%nationgraph.com'::text
    group by
      u.email
  ),
  enrichment_counts as (
    select
      e.user_email as email,
      count(e.id) as enrichment_count
    from
      mock_enrichment e
    where
      e.user_email !~~ '%nationgraph.com'::text
    group by
      e.user_email
  ),
  workspace_counts as (
    select
      u.email,
      count(w.id) as workspace_count
    from
      mock_workspaces w
      join mock_user u on u.auth0_id = w.user_id
    where
      u.email !~~ '%nationgraph.com'::text
    group by
      u.email
  )
select
  COALESCE(sc.email, COALESCE(ec.email, wc.email)) as email,
  COALESCE(sc.smart_column_count, 0::bigint) as smart_column_count,
  COALESCE(ec.enrichment_count, 0::bigint) as enrichment_count,
  COALESCE(wc.workspace_count, 0::bigint) as workspace_count
from
  smart_column_counts sc
  full join enrichment_counts ec on sc.email = ec.email
  full join workspace_counts wc on COALESCE(sc.email, ec.email) = wc.email
order by
  (COALESCE(sc.smart_column_count, 0::bigint)) desc,
  (COALESCE(ec.enrichment_count, 0::bigint)) desc,
  (COALESCE(wc.workspace_count, 0::bigint)) desc;
