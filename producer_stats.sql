create or replace view haven_reports.producer_stats as
--Issued Policies
SELECT a.producerId as producerId, 
(a_party.firstName || ' ' || a_party.lastName) as 'Producer_Name',
a.agencyId, 
a.agencyNumber,
'Issued Policies' as Stat_Type,
Date(p.effectiveDate) as Stat_Date,
COUNT(DISTINCT p.policyNumber) as Stat_Value
FROM haven.policy p
JOIN haven.customer c ON c._id = p.customer_id 
JOIN haven.policy_agent pa ON pa.policy_id = p._id
JOIN haven.agent_hierarchy ah ON ah._id  = pa.agent_hierarchy_id
JOIN haven.agent_level al ON al.agent_hierarchy_id = ah._id
JOIN haven.agent a ON al.agent_id = a._id
left join haven.party a_party on a.party_id = a_party._id 
WHERE c.channel = 'CAS'
and p.workflowState in ('In Force', 'Terminated') AND p.workflowSubState != 'Not Taken' 
and (trim(a.agencyNumber) is not null and trim(a.agencyNumber)<> '' and LTRIM(a.agencyNumber, 'A') <> '000' and LTRIM(a.agencyNumber, 'A') <> 'TPD')
and a.producerId not like 'OLD-%'
GROUP BY Stat_Date, a.producerId, a_party.firstName, a_party.lastName,a.agencyId, a.agencyNumber 
--
UNION
--PERSONALIZED W/O QUOTE
SELECT
a.producerId as producerId, 
(a_party.firstName || ' ' || a_party.lastName) as 'Producer_Name',
a.agencyId, 
a.agencyNumber,
'Personalized W/O Quote' as Stat_Type,
Date(c.createdTime) as Stat_Date,
COUNT(DISTINCT p.customer_id) as Stat_Value
FROM haven.policy p
JOIN haven.customer c ON c._id = p.customer_id 
JOIN haven.policy_agent pa ON pa.policy_id = p._id
JOIN haven.agent_hierarchy ah ON ah._id  = pa.agent_hierarchy_id
JOIN haven.agent_level al ON al.agent_hierarchy_id = ah._id
JOIN haven.agent a ON al.agent_id = a._id
JOIN haven.application app ON p.application_id = app._id
JOIN haven.insurance_quotes iq ON p.customer_id = iq.customer_id
left join haven.party a_party on a.party_id = a_party._id 
WHERE c.channel = 'CAS'
and (app.isAgentAssistant = False OR app.isAgentAssistant IS NULL) 
and p.linkSentDate IS NOT NULL
and iq.premium IS NULL 
and (trim(a.agencyNumber) is not null and trim(a.agencyNumber)<> '' and LTRIM(a.agencyNumber, 'A') <> '000' and LTRIM(a.agencyNumber, 'A') <> 'TPD')
and a.producerId not like 'OLD-%'
group by Stat_Date, a.producerId, a_party.firstName, a_party.lastName,a.agencyId, a.agencyNumber 
--
UNION
--Personalized w/ Quote
SELECT 
a.producerId as producerId, 
(a_party.firstName || ' ' || a_party.lastName) as 'Producer_Name',
a.agencyId, 
a.agencyNumber,
'Personalized W/ Quote' as Stat_Type,
Date(c.createdTime) as Stat_Date,
COUNT(DISTINCT p.customer_id) as Stat_Value
FROM haven.policy p
JOIN haven.customer c ON c._id = p.customer_id 
JOIN haven.policy_agent pa ON pa.policy_id = p._id
JOIN haven.agent_hierarchy ah ON ah._id  = pa.agent_hierarchy_id
JOIN haven.agent_level al ON al.agent_hierarchy_id = ah._id
JOIN haven.agent a ON al.agent_id = a._id
JOIN haven.application app ON p.application_id = app._id
JOIN haven.insurance_quotes iq ON p.customer_id = iq.customer_id
left join haven.party a_party on a.party_id = a_party._id 
WHERE c.channel = 'CAS'
and (app.isAgentAssistant = False OR app.isAgentAssistant IS NULL) 
and p.linkSentDate IS NOT NULL
and iq.premium IS NOT NULL 
and (trim(a.agencyNumber) is not null and trim(a.agencyNumber)<> '' and LTRIM(a.agencyNumber, 'A') <> '000' and LTRIM(a.agencyNumber, 'A') <> 'TPD')
and a.producerId not like 'OLD-%'
group by Stat_Date, a.producerId, a_party.firstName, a_party.lastName,a.agencyId, a.agencyNumber 
--
UNION
--Generic Links
SELECT 
a.producerId as producerId, 
(a_party.firstName || ' ' || a_party.lastName) as 'Producer_Name',
a.agencyId, 
a.agencyNumber,
'Generic Links' as Stat_Type,
Date(c.createdTime) as Stat_Date,
COUNT(DISTINCT p.customer_id) as Stat_Value
FROM haven.policy p
JOIN haven.customer c ON c._id = p.customer_id 
JOIN haven.policy_agent pa ON pa.policy_id = p._id
JOIN haven.agent_hierarchy ah ON ah._id  = pa.agent_hierarchy_id
JOIN haven.agent_level al ON al.agent_hierarchy_id = ah._id
JOIN haven.agent a ON al.agent_id = a._id
JOIN haven.application app ON p.application_id = app._id
left join haven.party a_party on a.party_id = a_party._id 
WHERE c.channel = 'CAS'
and (app.isAgentAssistant = False OR app.isAgentAssistant IS NULL)
and p.linkSentDate IS NULL
and (trim(a.agencyNumber) is not null and trim(a.agencyNumber)<> '' and LTRIM(a.agencyNumber, 'A') <> '000' and LTRIM(a.agencyNumber, 'A') <> 'TPD')
and a.producerId not like 'OLD-%'
group by Stat_Date, a.producerId, a_party.firstName, a_party.lastName,a.agencyId, a.agencyNumber 
--
UNION
--Advisor Assisted
SELECT 
a.producerId as producerId, 
(a_party.firstName || ' ' || a_party.lastName) as 'Producer_Name',
a.agencyId, 
a.agencyNumber,
'Advisor Assisted' as Stat_Type,
Date(c.createdTime) as Stat_Date,
COUNT(DISTINCT p.customer_id) as Stat_Value
FROM haven.policy p
JOIN haven.customer c ON c._id = p.customer_id 
JOIN haven.policy_agent pa ON pa.policy_id = p._id
JOIN haven.agent_hierarchy ah ON ah._id  = pa.agent_hierarchy_id
JOIN haven.agent_level al ON al.agent_hierarchy_id = ah._id
JOIN haven.agent a ON al.agent_id = a._id
JOIN haven.application app ON p.application_id = app._id
left join haven.party a_party on a.party_id = a_party._id 
WHERE c.channel = 'CAS'
and app.isAgentAssistant = TRUE 
and (trim(a.agencyNumber) is not null and trim(a.agencyNumber)<> '' and LTRIM(a.agencyNumber, 'A') <> '000' and LTRIM(a.agencyNumber, 'A') <> 'TPD')
and a.producerId not like 'OLD-%'
group by Stat_Date, a.producerId, a_party.firstName, a_party.lastName,a.agencyId, a.agencyNumber 
--
UNION
--Submitted Applications
SELECT
a.producerId as producerId, 
(a_party.firstName || ' ' || a_party.lastName) as 'Producer_Name',
a.agencyId, 
a.agencyNumber,
'Submitted Applications' as Stat_Type,
Date(p.submittedAt) as Stat_Date,
COUNT(DISTINCT p.policyNumber) as Stat_Value
FROM haven.policy p
JOIN haven.customer c ON c._id = p.customer_id 
JOIN haven.policy_agent pa ON pa.policy_id = p._id
JOIN haven.agent_hierarchy ah ON ah._id  = pa.agent_hierarchy_id
JOIN haven.agent_level al ON al.agent_hierarchy_id = ah._id
JOIN haven.agent a ON al.agent_id = a._id
JOIN haven.party a_party ON a.party_id = a_party._id
JOIN haven.applicant apl ON p.insured_id = apl._id
JOIN haven.party insured ON apl.party_id = insured._id
WHERE c.channel = 'CAS'
and p.submittedAt is not null
AND UPPER(a_party.firstName || ' ' || a_party.lastName) <> UPPER(insured.firstName || ' ' || insured.lastName)
and (trim(a.agencyNumber) is not null and trim(a.agencyNumber)<> '' and LTRIM(a.agencyNumber, 'A') <> '000' and LTRIM(a.agencyNumber, 'A') <> 'TPD')
and a.producerId not like 'OLD-%'
GROUP BY Stat_Date, a.producerId, a_party.firstName, a_party.lastName,a.agencyId, a.agencyNumber 
--
UNION
--Sessions
SELECT 
a.producerId as producerId, 
(a_party.firstName || ' ' || a_party.lastName) as 'Producer_Name',
a.agencyId, 
a.agencyNumber,
'Sessions' as Stat_Type,
DATE(am.date) as Stat_Date,
cast(am.sessions as INT) as Stat_Value
FROM haven.agent a
join haven_analytics.ga_agent_metrics am on LTRIM(am.dimension1, 'A') = a.producerId
left join haven.party a_party on a.party_id = a_party._id 
where (trim(a.agencyNumber) is not null and trim(a.agencyNumber)<> '' and LTRIM(a.agencyNumber, 'A') <> '000' and LTRIM(a.agencyNumber, 'A') <> 'TPD')
and a.producerId not like 'OLD-%'
order by producerId, Stat_Date, Stat_Type;
COMMIT;