# Socialdevflow SQL Analyzer

> Analyze, optimize, and convert SQL for Oracle 19c+ — directly inside Cursor.

[![GitHub](https://img.shields.io/badge/GitHub-socialdevflow%2Fsocialdevflow--sql--analyzer-181717?logo=github)](https://github.com/socialdevflow/socialdevflow-sql-analyzer)

Plugin ID: `socialdevflow-sql-analyzer`

Repository: [github.com/socialdevflow/socialdevflow-sql-analyzer](https://github.com/socialdevflow/socialdevflow-sql-analyzer)

Unofficial community plugin — not affiliated with or endorsed by Oracle Corporation.

## Install (Cursor)

```bash
git clone https://github.com/socialdevflow/socialdevflow-sql-analyzer.git
cd socialdevflow-sql-analyzer
bash scripts/install-plugin.sh
```

Then **Reload Window** (`Cmd+Shift+P` → Developer: Reload Window) and enable the plugin under **Cursor Settings → Plugins**.

Already cloned? Run `bash scripts/install-plugin.sh` from the repo root to copy the latest files into Cursor.

Slash commands appear as:

- `/socialdevflow-sql-analyzer:oracle-analyze`
- `/socialdevflow-sql-analyzer:oracle-convert`

Type `/social` or `/oracle` in Agent chat to search for them.

## What This Plugin Does

| Feature | How to Use |
|---------|-----------|
| 🔍 **Query Analyzer** | Run `/socialdevflow-sql-analyzer:oracle-analyze` or ask "analyze this Oracle query" |
| 📊 **Index Advisor** | Automatically triggered when analysis finds missing indexes |
| 🔄 **Dialect Converter** | Run `/socialdevflow-sql-analyzer:oracle-convert` or ask "convert this MySQL query to Oracle" |
| 📐 **Best Practices Rules** | Auto-applied when editing `.sql` or Liquibase migration files |

## Commands

### `/socialdevflow-sql-analyzer:oracle-analyze`
Analyzes any Oracle SQL query for:
- Full table scans and missing indexes
- Anti-patterns (`NOT IN`, `SELECT *`, correlated subqueries)
- NULL handling issues
- Pagination correctness (`ROWNUM` vs `FETCH FIRST`)
- Oracle 19c compatibility

Outputs an optimized rewrite + `CREATE INDEX` statements.

### `/socialdevflow-sql-analyzer:oracle-convert`
Converts SQL from **MySQL / PostgreSQL / SQLite / SQL Server** to Oracle 19c:
- Data type mapping (`VARCHAR` → `VARCHAR2`, `NOW()` → `SYSDATE`, etc.)
- Function translation (`IFNULL` → `NVL`, `GROUP_CONCAT` → `LISTAGG`, etc.)
- Upsert rewrite (`ON DUPLICATE KEY UPDATE` → `MERGE`)
- Pagination rewrite (`LIMIT` → `FETCH FIRST`)

## Skills

| Skill | Description |
|-------|-------------|
| `oracle-query-analyzer` | Static analysis of Oracle SQL queries |
| `oracle-index-advisor` | B-Tree, composite, FBI, and covering index recommendations |
| `oracle-dialect-converter` | Full MySQL/PostgreSQL/SQLite → Oracle 19c conversion reference |

## Rules

`oracle-sql-best-practices` — Auto-attached to `.sql` and Liquibase files:
- Enforces `VARCHAR2` over `VARCHAR`
- Naming conventions (tables, indexes, constraints, sequences)
- NULL safety patterns
- Spring Boot / JPA integration guidelines

## Example Usage

**Slow query:**
> "This query takes 30 seconds on our Oracle 19c database, can you help?"

**Migration:**
> "We're migrating from MySQL to Oracle. Convert this create table script."

**Code review:**
> "Review the SQL in this Spring Boot repository for Oracle best practices."

## Author

Socialdevflow — [info@socialdevflow.com](mailto:info@socialdevflow.com) · [GitHub](https://github.com/socialdevflow/socialdevflow-sql-analyzer)

## License

[MIT](LICENSE)
