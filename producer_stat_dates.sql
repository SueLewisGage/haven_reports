--Producer Stat Dates
create or replace view haven_reports.producer_stat_dates as
select pl.agencyNumber, pl.producerId, pl.Producer_Name, pl.Agency_Name, cal.CAL_DT, st.Stat_Type 
from haven_reports.producer_list pl,
(select CAL_DT from drc.CAL_VW where CAL_DT >='07/24/2016') cal,
(select Stat_Type from haven_reports.stat_types) st
where cal.CAL_DT <> '0001-01-01'
order by pl.producerId, cal.CAL_DT, st.Stat_Type ;
COMMIT;