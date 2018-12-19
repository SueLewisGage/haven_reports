---Policy Data for Coverpath Agency Report
DROP Table IF EXISTS haven_reports.policy_report;
create table IF NOT EXISTS haven_reports.policy_report as
Select * from haven_reports.policy_report_view;
COMMIT;