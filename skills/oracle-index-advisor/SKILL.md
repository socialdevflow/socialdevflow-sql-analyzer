---
name: oracle-index-advisor
description: >
  Recommend Oracle indexes for a given query or table schema.
  Use when: user asks "what index should I create?", "why is my query slow?",
  or when oracle-query-analyzer identifies a missing index.
  Outputs CREATE INDEX statements with rationale.
---

# Oracle Index Advisor

## Purpose
Generate precise Oracle `CREATE INDEX` statements based on query patterns, table schema, and Oracle optimizer behavior. Explain *why* each index helps and what trade-offs it introduces.

## When to Invoke
- User asks "what index should I add for this query?"
- Query analysis found full table scans or missing indexes
- User is designing a new table and wants indexing guidance
- User has slow reports or batch jobs on Oracle 19c

## Inputs to Gather
Before advising, ask for (or extract from context):
1. The SQL query (required)
2. Table DDL / column definitions (optional but improves advice)
3. Table size estimate (small <10K, medium 10K-1M, large >1M rows)
4. Query frequency (one-time, frequent OLTP, nightly batch)
5. Existing indexes (if known)

## Index Type Decision Guide

### B-Tree Index (Default)
Best for:
- High-cardinality columns (unique or near-unique values)
- Equality: `WHERE col = :val`
- Range: `WHERE col BETWEEN :a AND :b`
- Sorting: `ORDER BY col`

```sql
CREATE INDEX IDX_<TABLE>_<COL> ON <TABLE>(<COL>);
```

### Composite Index
Best for multi-column WHERE clauses.
**Column order rule**: most selective (highest cardinality) + equality columns first, range column last.

```sql
-- Query: WHERE status = 'ACTIVE' AND created_date > SYSDATE - 30
-- status = equality, created_date = range → status first
CREATE INDEX IDX_ORDERS_STATUS_DATE ON ORDERS(STATUS, CREATED_DATE);
```

### Function-Based Index (FBI)
Use when query applies function to indexed column:

```sql
-- Query: WHERE UPPER(email) = UPPER(:p1)
CREATE INDEX IDX_CUST_EMAIL_UPPER ON CUSTOMERS(UPPER(EMAIL));
```

### Bitmap Index
**Only for Data Warehouse / low-cardinality columns**. Never use on OLTP tables (causes lock contention).

```sql
-- DWH only: gender, status, region with <100 distinct values
CREATE BITMAP INDEX IDX_SALES_REGION ON SALES_FACT(REGION);
```

### Partial Index (Oracle 12c+)
Index subset of rows to reduce index size:

```sql
-- Only index PENDING orders (most queries filter on this status)
CREATE INDEX IDX_ORDERS_PENDING ON ORDERS(ORDER_ID) WHERE STATUS = 'PENDING';
```

### Covering Index (Index-Only Scan)
Include all columns a query needs to avoid table access:

```sql
-- Query: SELECT ORDER_ID, TOTAL FROM ORDERS WHERE CUSTOMER_ID = :p1
-- Include TOTAL in index so Oracle never touches the table
CREATE INDEX IDX_ORDERS_CUST_COVERING ON ORDERS(CUSTOMER_ID, ORDER_ID, TOTAL);
```

## Output Format

```
## Oracle Index Recommendations

### Query
[query]

### Recommended Indexes

#### Index 1 — Critical (addresses full table scan)
**Type:** Composite B-Tree
**Rationale:** Query filters on (STORE_ID, STATUS) in WHERE clause. STORE_ID has high cardinality; STATUS is equality predicate. Composite index eliminates full table scan on 5M-row table.

CREATE INDEX IDX_ORDERS_STORE_STATUS
  ON ORDERS(STORE_ID, STATUS)
  TABLESPACE INDX;

**Expected improvement:** Full scan → Index Range Scan. Estimated 95%+ I/O reduction.

#### Index 2 — Optional (covering index for SELECT columns)
**Type:** Covering Index
**Rationale:** Adding ORDER_TOTAL to the index allows index-only scan, avoiding row fetch.

CREATE INDEX IDX_ORDERS_STORE_STATUS_COVERING
  ON ORDERS(STORE_ID, STATUS, ORDER_TOTAL)
  TABLESPACE INDX;

**Trade-off:** Larger index size (+~20%). Worthwhile if this query runs >100x/day.

### Indexes to Drop (if any)
[List redundant indexes that would be superseded]

### Maintenance Notes
- Rebuild after bulk loads: ALTER INDEX IDX_ORDERS_STORE_STATUS REBUILD;
- Monitor with: SELECT * FROM V$OBJECT_USAGE WHERE INDEX_NAME = 'IDX_ORDERS_STORE_STATUS';
- Enable monitoring: ALTER INDEX IDX_ORDERS_STORE_STATUS MONITORING USAGE;
```

## Oracle 19c Index Features
- **Automatic Indexing**: Note if the table might benefit from Oracle 19c's Auto Indexing feature
- **Invisible Indexes**: Suggest testing with `INVISIBLE` before enabling in production
- **Index Compression**: Mention for composite indexes on repeated leading column values
