---
name: oracle-query-analyzer
description: >
  Analyze an Oracle SQL query for performance issues, anti-patterns, and correctness.
  Use when: reviewing a slow query, before running EXPLAIN PLAN, auditing legacy SQL,
  or when the agent detects a SELECT/UPDATE/DELETE/INSERT in an Oracle context.
  Outputs a structured report: issues found, severity, root cause, and recommended fix.
---

# Oracle Query Analyzer

## Purpose
Perform deep static analysis of Oracle SQL queries to identify performance problems, correctness issues, and Oracle-specific anti-patterns — without needing a live database connection.

## When to Invoke
- User pastes a SQL query and asks "why is this slow?" or "how can I optimize this?"
- User has an Oracle PL/SQL block with embedded SQL
- Agent detects `.sql` files or SQL strings in a Java/Spring Boot project targeting Oracle
- User says "analyze this query", "review my SQL", or "check this Oracle query"

## Analysis Checklist

### 1. Full Table Scans
Check for:
- `WHERE` clause on unindexed columns
- Functions applied to indexed columns: `UPPER(col) = ...`, `TO_DATE(col, ...)`, `TRUNC(col)`
- Implicit type conversions (VARCHAR2 compared to NUMBER)
- `LIKE '%prefix'` — leading wildcard disables index

### 2. Join Issues
- Missing join condition → Cartesian product risk
- Non-equi joins that prevent index use
- Joining on columns with different data types
- Missing indexes on foreign key columns

### 3. Oracle Anti-Patterns
- `SELECT *` in production code
- `NOT IN` with subquery (use `NOT EXISTS` instead — NULL-safe and faster)
- `OR` in WHERE clause splitting index range scans (consider UNION ALL)
- `ROWNUM` in wrong position (filter before ORDER BY)
- Using `MINUS` instead of `NOT EXISTS` for large sets
- `DISTINCT` masking missing join conditions

### 4. Subquery Issues
- Correlated subquery in SELECT list (runs once per row)
- Subquery in WHERE that can be rewritten as JOIN
- Scalar subquery returning >1 row at runtime risk

### 5. Pagination Pattern
- `ROWNUM` pagination (Oracle 11g style) vs `FETCH FIRST n ROWS ONLY` (Oracle 12c+)
- Missing ORDER BY before ROWNUM filter

### 6. NULL Handling
- Comparisons using `= NULL` instead of `IS NULL`
- `COUNT(col)` vs `COUNT(*)` difference
- NVL vs COALESCE vs NVL2 correctness

## Output Format

Respond with a structured analysis:

```
## Oracle Query Analysis

### Original Query
[paste query here]

### Issues Found

| # | Severity | Issue | Location | Impact |
|---|----------|-------|----------|--------|
| 1 | 🔴 HIGH   | Full table scan on ORDERS.CUSTOMER_ID | WHERE clause | Full scan on large table |
| 2 | 🟡 MEDIUM | SELECT * used | SELECT list | Over-fetching columns |
| 3 | 🟢 LOW    | NVL can be COALESCE | Line 4 | Minor: style/portability |

### Detailed Recommendations

#### Issue 1: Full Table Scan
**Root Cause:** `WHERE customer_id = :p1` — no index on CUSTOMER_ID column.
**Fix:**
CREATE INDEX IDX_ORDERS_CUST_ID ON ORDERS(CUSTOMER_ID);

#### Issue 2: SELECT *
**Root Cause:** Fetches all columns including LOB columns unnecessarily.
**Fix:** List only required columns explicitly.

### Optimized Query
[rewritten query with fixes applied]

### Summary
- Issues: X high, Y medium, Z low
- Estimated improvement: [qualitative: significant / moderate / minor]
```

## Oracle 19c Specific Checks
- Verify compatibility with Oracle 19c syntax
- Note deprecated features (e.g., `CONNECT BY` can be replaced with recursive CTE in 12c+)
- Highlight features available in 19c: `LISTAGG OVERFLOW`, `Approximate Query Processing`, `Real-Time Statistics`
