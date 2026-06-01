---
name: oracle-analyze
description: Analyze an Oracle SQL query for performance issues and get optimization recommendations
---

# /socialdevflow-sql-analyzer:oracle-analyze — Analyze Oracle SQL Query

## Steps

1. Ask the user to paste the SQL query they want to analyze. If a query is already in context (selected text or recent message), use it directly.

2. Ask for optional context if not already known:
   - Approximate table size (small/medium/large)
   - Oracle version (default: 19c)
   - Is this OLTP or reporting/batch?

3. Invoke the `oracle-query-analyzer` skill to perform full static analysis.

4. If the analysis finds missing indexes, automatically invoke the `oracle-index-advisor` skill to generate `CREATE INDEX` statements.

5. Present the complete report:
   - Issues table (severity, location, impact)
   - Optimized query rewrite
   - Index recommendations with DDL
   - Summary of expected improvements

6. Ask: "Would you like me to convert this to a Liquibase changeset for your Spring Boot project?"
