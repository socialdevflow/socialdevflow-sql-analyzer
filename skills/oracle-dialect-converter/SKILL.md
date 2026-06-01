---
name: oracle-dialect-converter
description: >
  Convert SQL from MySQL, PostgreSQL, SQLite, or SQL Server to valid Oracle 19c syntax.
  Use when: user is migrating a project to Oracle, has a query written for another database,
  or asks to "convert this to Oracle SQL". Outputs corrected Oracle SQL with change notes.
---

# Oracle Dialect Converter

## Purpose
Translate SQL queries from other database dialects to correct, idiomatic Oracle 19c SQL. Explain every change made and flag any behavior differences the developer must be aware of.

## When to Invoke
- User says "convert this MySQL query to Oracle"
- User is migrating from MySQL/PostgreSQL/SQLite/SQL Server to Oracle
- Query contains non-Oracle syntax (detected by keywords, functions, or data types)
- Spring Boot Liquibase migration scripts need Oracle equivalents

## Conversion Reference Tables

### Data Types

| Source | Oracle 19c Equivalent | Notes |
|--------|----------------------|-------|
| `INT` / `INTEGER` | `NUMBER(10)` | Oracle NUMBER is universal |
| `BIGINT` | `NUMBER(19)` | |
| `VARCHAR(n)` | `VARCHAR2(n)` | Always use VARCHAR2, not VARCHAR |
| `TEXT` | `CLOB` | For large text |
| `TINYINT(1)` / `BOOLEAN` | `NUMBER(1)` | Oracle has no BOOLEAN in SQL (only PL/SQL) |
| `DATETIME` | `DATE` | Oracle DATE includes time |
| `TIMESTAMP` | `TIMESTAMP` | Supported |
| `AUTO_INCREMENT` | `GENERATED ALWAYS AS IDENTITY` | Oracle 12c+; or use SEQUENCE |
| `BLOB` | `BLOB` | Same |
| `DOUBLE` / `FLOAT` | `BINARY_DOUBLE` / `NUMBER` | |
| `TINYTEXT`, `MEDIUMTEXT` | `CLOB` | |
| `JSON` | `CLOB CHECK (col IS JSON)` | Oracle 19c JSON type or CLOB with constraint |

### Functions

| MySQL / PostgreSQL | Oracle 19c |
|-------------------|-----------|
| `NOW()` | `SYSDATE` or `SYSTIMESTAMP` |
| `CURDATE()` | `TRUNC(SYSDATE)` |
| `DATE_FORMAT(col, '%Y-%m-%d')` | `TO_CHAR(col, 'YYYY-MM-DD')` |
| `STR_TO_DATE('2024-01-01', '%Y-%m-%d')` | `TO_DATE('2024-01-01', 'YYYY-MM-DD')` |
| `IFNULL(a, b)` | `NVL(a, b)` |
| `COALESCE(a, b, c)` | `COALESCE(a, b, c)` ✅ same |
| `IF(cond, a, b)` | `CASE WHEN cond THEN a ELSE b END` |
| `GROUP_CONCAT(col)` | `LISTAGG(col, ',') WITHIN GROUP (ORDER BY col)` |
| `LIMIT n` | `FETCH FIRST n ROWS ONLY` (12c+) or `WHERE ROWNUM <= n` |
| `LIMIT offset, n` | `OFFSET offset ROWS FETCH NEXT n ROWS ONLY` |
| `ILIKE` (PostgreSQL) | `UPPER(col) LIKE UPPER(:val)` or `REGEXP_LIKE(col, val, 'i')` |
| `CONCAT_WS(',', a, b)` | `a \|\| ',' \|\| b` |
| `SUBSTRING(col, 1, 5)` | `SUBSTR(col, 1, 5)` |
| `LENGTH(col)` | `LENGTH(col)` ✅ same |
| `CHAR_LENGTH(col)` | `LENGTH(col)` |
| `RAND()` | `DBMS_RANDOM.VALUE` |
| `UUID()` | `SYS_GUID()` |
| `UNIX_TIMESTAMP()` | `(SYSDATE - DATE '1970-01-01') * 86400` |
| `DATEDIFF(a, b)` | `TRUNC(a) - TRUNC(b)` |
| `DATE_ADD(d, INTERVAL n DAY)` | `d + n` |
| `YEAR(col)` | `EXTRACT(YEAR FROM col)` |
| `MONTH(col)` | `EXTRACT(MONTH FROM col)` |
| `LPAD(col, 5, '0')` | `LPAD(col, 5, '0')` ✅ same |

### DDL Differences

| MySQL | Oracle 19c |
|-------|-----------|
| `AUTO_INCREMENT` | `GENERATED ALWAYS AS IDENTITY` |
| `ENGINE=InnoDB` | *(remove — no equivalent)* |
| `DEFAULT CHARSET=utf8mb4` | *(remove — set at DB level)* |
| `TINYINT(1)` | `NUMBER(1)` |
| `IF NOT EXISTS` in CREATE TABLE | Not natively supported; wrap in PL/SQL |
| Backtick identifiers `` `col` `` | Double-quote identifiers `"col"` (or no quotes if standard names) |

### DML Differences

| MySQL | Oracle 19c |
|-------|-----------|
| `INSERT IGNORE` | `INSERT INTO ... (SELECT ... WHERE NOT EXISTS (...))` |
| `ON DUPLICATE KEY UPDATE` | `MERGE INTO ... USING ... ON (...) WHEN MATCHED THEN UPDATE WHEN NOT MATCHED THEN INSERT` |
| `REPLACE INTO` | `MERGE` statement |
| `TRUNCATE TABLE t` | `TRUNCATE TABLE t` ✅ same |

## Output Format

```
## Dialect Conversion: MySQL → Oracle 19c

### Original Query (MySQL)
[original]

### Converted Query (Oracle 19c)
[converted]

### Changes Made

| # | Original | Oracle Equivalent | Reason |
|---|----------|-------------------|--------|
| 1 | `NOW()` | `SYSDATE` | Oracle uses SYSDATE for current date+time |
| 2 | `LIMIT 10` | `FETCH FIRST 10 ROWS ONLY` | Oracle 12c+ pagination syntax |
| 3 | `IFNULL(x, y)` | `NVL(x, y)` | Oracle NVL equivalent |

### ⚠️ Behavior Differences to Note
[List any semantic differences, e.g., NULL handling, date precision, string comparison]

### Liquibase Note (if applicable)
[If this is for Spring Boot/Liquibase, provide changeSet wrapper]
```
