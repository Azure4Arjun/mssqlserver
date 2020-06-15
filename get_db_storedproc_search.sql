SELECT *
FROM sys.procedures
WHERE object_definition(object_id) LIKE '%xxx%'
