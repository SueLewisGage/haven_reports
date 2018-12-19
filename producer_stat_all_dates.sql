--Producer Stats for All Dates
DROP Table IF EXISTS haven_reports.producer_stat_all_dates;
create table IF NOT EXISTS haven_reports.producer_stat_all_dates as
select pd.agencyNumber, pd.Agency_Name, pd.producerId, pd.Producer_Name, pd.CAL_DT, pd.Stat_Type, nvl(ps.Stat_Value,0) as Stat_Value
from haven_reports.producer_stat_dates pd
left join haven_reports.producer_stats ps on ps.producerId = pd.producerId and ps.Stat_Type = pd.Stat_Type and ps.Stat_Date = pd.CAL_DT
order by pd.Producer_Name, pd.CAL_DT desc, pd.Stat_Type;
COMMIT;