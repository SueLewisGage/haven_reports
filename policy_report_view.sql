create or replace view haven_reports.policy_report_view as
SELECT DISTINCT
pl.Agency_Name,
pl.Producer_Name,
(insured.firstName || ' ' || insured.lastName) as insured_name,
DATE(p.submittedAt) as submittedAt,
date(p.effectiveDate) as effectiveDate,
p.policyNumber,
Case  
	WHEN p.workflowSubState in ('Amendment Insured Signature Complete')
	Then 'Amendment Process Insured'
	when p.workflowSubState in ('Amendment Signatures Complete','Waiting For Amendment Signatures') 
	Then 'Amendment Process Owner'
	when p.workflowSubState in ('Waiting for Acceptance','Waiting for Application Acceptance') 
	Then 'Awaiting Acceptance'
	when p.workflowSubState in ('Awaiting APS') 
	Then 'Awaiting APS'
	when p.workflowSubState in ('Waiting for Issue Acceptance','Waiting for Policy Acceptance') 
	Then 'Awaiting Final Acceptance'
	when p.workflowSubState in ('Final Review','Final Underwriting') 
	Then 'Awaiting Final UW'
	when p.workflowSubState in ('Waiting for Labs') 
	Then 'Awaiting Medical'
	when p.workflowSubState in ('Issuing Policy','Pending Policy Docs')
	Then 'Awaiting Policy Docs'
	when p.workflowSubState in ('Determine Underwriting Class') 
	Then 'Awaiting Results'
	when p.workflowSubState in ('Waiting for Signature') 
	Then 'Awaiting Signature'
	when p.workflowSubState in ('Initial Underwriting') 
	Then 'Awaiting UW'
	when p.workflowSubState in ('Canceled','Cancelled - Free Look','No Labs','Not Accepted','Not Taken','Ran out of Time','Rescinded','With Haven Option','With TLIC','Without TLIC')
	Then 'Cancelled'
	when p.workflowSubState in ('Free Look Period','Issued') 
	Then 'Completed'
	when p.workflowSubState in ('Uninsurable')
	Then 'Declined'
	when p.workflowSubState in ('Correcting License','Retrying MVR') 
	Then 'Drivers License Check'
	when p.workflowSubState in ('Gathering Data') 
	Then 'Gathering Data'
	when p.workflowSubState in ('Checking ID','Checking Insured ID','Checking Owner ID','Correcting SSN','Verifying') 
	Then 'ID Check'
	when p.workflowSubState in ('Correcting Insured SSN') 
	Then 'ID Failure'
	when p.workflowSubState in ('Lapsed') 
	Then 'Lapsed'
	when p.workflowSubState in ('Filling Out','Link Sent') 
	Then 'Pre-Submit'
	when p.workflowSubState in ('Require Reflexive Data') 
	Then 'Reflexive Questions'
	when p.workflowSubState in ('With Vantage Option') 
	Then 'Rejected'
	when p.workflowSubState in ('Verifying Eligibility') 
	Then 'Verify Citizenship'
	else p.workflowSubState
END as Status,
date(p.workflowStateUpdate) as workflowStateUpdate,
(CURRENT_DATE() - date(p.workflowStateUpdate)) as Time_In_Status,
i_add.state as 'Insured State',
p.finalRateClass,
case p.finalRateClass
	WHEN NULL THEN 'No Rating'
	WHEN '1' THEN 'Ultra Preferred'
	WHEN '2' THEN 'Select Preferred'
	WHEN '3'THEN 'Standard'
	WHEN '4'THEN 'Select Tobacco'
	WHEN '5'THEN 'Standard Tobacco'
	WHEN '90'THEN 'Bypass Knockout'
	WHEN '99'THEN 'Knockout'
	WHEN '998'THEN 'Decline With Vantage'
	WHEN '999'THEN 'Decline'
	WHEN '9997'THEN 'Reject with Haven'
	WHEN '9998'THEN 'Reject with Vantage'
	WHEN '9999'THEN 'Reject'
	else 'Unknown' 
END as rate_class,
p.faceAmount,
pb.base as Premium,
p.term,
date(p.paramedScheduledDate) as ExamScheduledDate,
ag.agencyId, 
ag.agencyNumber,  
LTRIM(ag.producerId,'0') as ProducerID
FROM haven.policy p
	JOIN haven.customer c ON c._id = p.customer_id
	LEFT JOIN haven.policy_agent pa ON pa.policy_id = p._id
	LEFT JOIN haven.agent_hierarchy ah ON ah._id = pa.agent_hierarchy_id
	LEFT JOIN haven.agent_level al ON al.agent_hierarchy_id = ah._id
	LEFT JOIN haven.agent ag ON al.agent_id = ag._id
	LEFT JOIN haven.party a_party ON ag.party_id = a_party._id
	LEFT JOIN haven.applicant a ON p.insured_id = a._id
	LEFT JOIN haven.party insured on a.party_id = insured._id
	LEFT JOIN haven.premium_breakdown pb ON p.premiumBreakdown_id = pb._id
	LEFT JOIN haven.address i_add ON insured.residentialAddress_id = i_add._id
	left join haven_reports.producer_list pl on pl.producerId = ag.producerId
WHERE c.channel = 'CAS'
and p.policyNumber is not null
and (LTRIM(isnull(ag.agencyNumber,''), 'A') <> '000' and LTRIM(isnull(ag.agencyNumber,''), 'A') <> 'TPD')
order by agency_name, producer_name, insured_name,  p.policyNumber;
COMMIT;