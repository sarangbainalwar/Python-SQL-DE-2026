create DATABASE de_company_db;

\dt   

select table_name from information_schema.tables
where table_schema = 'public'