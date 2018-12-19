--Policy Workflow State Time In Status
create or replace view haven_reports.policy_workflowState as
select p._id as policy_id, policyNumber, workflowState, Date(workflowStateUpdate) as workflowStateUpdateDt,  (CURRENT_DATE() - date(p.workflowStateUpdate)) as Time_In_Status
from haven.policy p 
JOIN haven.customer c ON c._id = p.customer_id
WHERE c.channel = 'CAS'
and p.policyNumber is not null
order by policyNumber;
COMMIT;