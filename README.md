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

Then:

1. **Reload Window** — `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows/Linux) → **Developer: Reload Window**
2. **Enable the plugin** — **Cursor Settings → Plugins** → turn on **Socialdevflow SQL Analyzer** (`socialdevflow-sql-analyzer`)

Already cloned? Run `bash scripts/install-plugin.sh` from the repo root to copy the latest files into Cursor.

### Slash commands (Agent chat)

Use **Agent** mode (not Ask). Type `/` and search `oracle`.

| Purpose | Try first in menu | Full form (also valid) |
|---------|-------------------|------------------------|
| Analyze Oracle SQL | `/oracle-analyze` | `/socialdevflow-sql-analyzer:oracle-analyze` |
| Convert to Oracle 19c | `/oracle-convert` | `/socialdevflow-sql-analyzer:oracle-convert` |

**Skills** (always registered when the plugin loads — good fallback):

| Purpose | Skill slash |
|---------|-------------|
| Query analysis | `/oracle-query-analyzer` |
| Index advice | `/oracle-index-advisor` |
| Dialect conversion | `/oracle-dialect-converter` |

### Troubleshooting: command not found

1. Re-install: `bash scripts/install-plugin.sh` from this repo (installs to `~/.cursor/plugins/local/socialdevflow-sql-analyzer`).
2. **Reload Window** (`Cmd+Shift+P` → Developer: Reload Window).
3. **Cursor Settings → Plugins** → enable **Socialdevflow SQL Analyzer**.
4. In Agent chat, search `/oracle-convert` (short name) — not only the long `socialdevflow-sql-analyzer:` prefix.
5. If commands still missing, use skill slash `/oracle-dialect-converter` or plain language: *"convert this MySQL query to Oracle 19c"*.

Verify load: **Help → Toggle Developer Tools → Console**, filter `socialdevflow` — you should see `loadUserLocalPlugin socialdevflow-sql-analyzer loaded`.

## What This Plugin Does

| Feature | How to Use |
|---------|-----------|
| 🔍 **Query Analyzer** | `/socialdevflow-sql-analyzer:oracle-analyze` (or `/oracle-analyze`) — or ask *"analyze this Oracle query"* |
| 📊 **Index Advisor** | Runs automatically during analysis when missing indexes are found |
| 🔄 **Dialect Converter** | `/socialdevflow-sql-analyzer:oracle-convert` (or `/oracle-convert`) — or ask *"convert this MySQL query to Oracle"* |
| 📐 **Best Practices Rules** | Auto-attached when editing `.sql` or Liquibase migration files |

## Commands

Details for each slash command (use the **full** form if the short alias is not listed).

### `/socialdevflow-sql-analyzer:oracle-analyze` · `/oracle-analyze`
Analyzes any Oracle SQL query for:
- Full table scans and missing indexes
- Anti-patterns (`NOT IN`, `SELECT *`, correlated subqueries)
- NULL handling issues
- Pagination correctness (`ROWNUM` vs `FETCH FIRST`)
- Oracle 19c compatibility

Outputs an optimized rewrite + `CREATE INDEX` statements.

### `/socialdevflow-sql-analyzer:oracle-convert` · `/oracle-convert`
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
