---
name: oracle-convert
description: Convert a SQL query from MySQL, PostgreSQL, or SQLite to Oracle 19c syntax
---

# /socialdevflow-sql-analyzer:oracle-convert — Convert SQL to Oracle 19c

## Steps

1. Ask the user to paste the SQL query to convert. If a query is already selected or in context, use it directly.

2. Detect the source dialect automatically from syntax clues:
   - `AUTO_INCREMENT`, backticks, `NOW()`, `LIMIT` → MySQL
   - `SERIAL`, `RETURNING`, `ILIKE`, `::type` → PostgreSQL
   - `AUTOINCREMENT`, `INTEGER PRIMARY KEY` → SQLite
   - `IDENTITY`, `TOP n`, `GETDATE()` → SQL Server
   - If unclear, ask the user which database the query came from.

3. Invoke the `oracle-dialect-converter` skill to produce the Oracle 19c equivalent.

4. Output:
   - Original query
   - Converted Oracle query
   - Table of all changes made with explanations
   - Any behavioral differences to be aware of

5. If the query is a `CREATE TABLE`, also offer:
   - Sequence + trigger pattern (for Oracle 11g compatibility)
   - `GENERATED ALWAYS AS IDENTITY` version (Oracle 12c+)

6. Ask: "Should I also wrap this in a Liquibase changeset with `dbms=oracle` condition?"
