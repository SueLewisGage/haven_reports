--Producer List
create or replace view haven_reports.producer_list as
select ag.agencyNumber,
ag.producerId,
(UPPER(a_party.firstName) || ' ' || UPPER(a_party.lastName)) as 'Producer_Name',
RTRIM(av.AGY_NM) as Agency_Name
from  haven.agent ag 
join haven.party a_party on ag.party_id = a_party._id 
LEFT JOIN teradata.PDCR_DEMOGRAPHICS_VW pd ON LTRIM(LTRIM(pd.BUSINESS_PARTNER_ID,'A'),'0') = LTRIM(ag.producerId,'0')
LEFT JOIN teradata_cmn.AGY_CLOSE_MERGE_DATA_VW av ON pd.HOME_AGY_ID = av.AGY_ID
where (trim(ag.agencyNumber) is not null and trim(ag.agencyNumber)<> '' and LTRIM(ag.agencyNumber, 'A') <> '000' and LTRIM(ag.agencyNumber, 'A') <> 'TPD')
and ag.producerId not like 'OLD-%'
order by Producer_Name;
COMMIT;