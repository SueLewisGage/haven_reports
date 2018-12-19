--Stat Types Lookup Table
create table haven_reports.stat_types as
select distinct(ps.Stat_Type) from haven_reports.producer_stats ps
order by ps.Stat_Type;
COMMIT;