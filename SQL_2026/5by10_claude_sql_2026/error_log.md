# SQL Error Log

**Purpose:** a miss is only useful once it becomes a rule. Review this file on Day 7 and Day 14, and redo every query below from memory.

**Entry format:** `ID | what I predicted | what actually happened | rule number | why I missed it`

---

## Rules Learned (add a new rule only when a miss does not fit an existing one)

| # | Rule |
|---|---|
| 1 | `WHERE` keeps only TRUE rows. FALSE **and UNKNOWN** both remove the row. NULL comparisons never raise an error, they silently remove rows. |
| 2 | Aggregates (`SUM`, `AVG`, `COUNT(col)`, `MIN`, `MAX`) ignore NULLs, always, with no setting involved. `COUNT(*)` counts rows. `AVG` divides by the non-NULL count. |
| 3 | `GROUP BY` and `DISTINCT` keep **one NULL group/row**. `COUNT(DISTINCT col)` ignores it. `ORDER BY ... ASC` puts NULLs **first**. |
| 4 | Joins drop **every** row that fails to match: NULL keys **and** orphan keys. `LEFT JOIN ... WHERE right.key IS NULL` finds both. |
| 5 | Order of execution: `FROM → WHERE → GROUP BY → HAVING → window → SELECT → DISTINCT → ORDER BY → LIMIT`. Aliases don't exist until `SELECT`, so `WHERE` can't use them. |
| 6 | Row counts follow the **grain** of the FROM table. A one-to-many join multiplies the left rows (1 customer with 5 orders = 5 rows). Unmatched left rows still produce exactly 1 row. |
| 7 | In a `LEFT JOIN`, a filter on the right table in `WHERE` removes the unmatched rows (acts like an inner join). The same filter in `ON` keeps them. |
| 8 | Deduplicate to one row per entity BEFORE ranking, counting or summing. Make "one row = one order" true first. |
| 9 | Anti-joins: default to `NOT EXISTS`. With `LEFT JOIN ... IS NULL`, test the right table's KEY, never a nullable column. `NOT IN` fails when the subquery has a NULL, and also drops rows whose own key is NULL. |
| 10 | `CASE` is tested top to bottom and the first match wins. No `ELSE` returns NULL. A NULL row never matches a comparison, so test `IS NULL` explicitly and first. |
| 11 | Conditional aggregation: `SUM(CASE WHEN c THEN 1 ELSE 0 END)` or `COUNT(CASE WHEN c THEN 1 END)`. Ratios use `NULLIF(denominator, 0)`. |
| 12 | Window functions keep every row and run after `WHERE`, so `WHERE rn = 1` errors. Compute the window in a CTE, filter in the outer query. |
| 13 | `ROW_NUMBER` always breaks ties. `RANK` ties share a number and skip. `DENSE_RANK` ties share a number and don't skip. Add a unique tie-breaker (such as `row_id`) so results are deterministic. |
| 14 | Every dedup needs three decisions: the key (what makes rows "the same"), the winner rule (which copy stays), and a unique tie-breaker such as `row_id`. Keep `rn = 1`. |
| 15 | Never modify raw data to dedupe. Dedup is a `SELECT` or a view over raw. Verify with `COUNT(*) = COUNT(DISTINCT key)`. |
| 16 | `MAX()` plus join-back returns every row tied on the max, so it can return several rows per key. `ROW_NUMBER` guarantees exactly one. All patterns must use the same tie-breaker direction to agree. |

---

## Day 1 Misses

| ID | Predicted | Actual | Rule | Why I missed it |
|---|---|---|---|---|
| Q1 `customer_id = NULL` | Error | 0 rows, no error | 1 | Expected NULL misuse to fail loudly. It fails silently. |
| Q3 `COUNT(amount)` | 48 | 47 | 2 | Treated `COUNT(col)` like `COUNT(*)`. |
| Q4 `SUM/COUNT(*)` vs `AVG` | "Depends on DB settings" | a < b | 2 | Thought NULL handling was a setting. It is standard SQL behaviour. |
| Q6 `SUM` of a NULL amount | "Error, or NULL" | NULL | 2 | A whole-table aggregate needs no `GROUP BY`. |
| Q7 `GROUP BY city` | 5 rows, NULL in no group | 6 rows, NULL group has 1 | 3 | Thought `GROUP BY` drops NULLs. It keeps them as one group. |
| Q8 `JOIN` count | 47 | 46 | 4 | Caught the NULL key but missed the orphan (customer 99). |
| Q9 `NOT IN` with a NULL in the subquery | 15 | 0 | 1 | Knew the result is UNKNOWN, but believed UNKNOWN **keeps** the row. It removes it. |
| Q10 `NOT IN` with NULLs filtered out | 0 | 4 (ids 12 to 15) | 1 | Same inversion as Q9. Once the NULL is gone, `NOT IN` works normally. |
| E1 alias in `WHERE` | Works | Error: unknown column `gross` | 5 | `WHERE` runs before `SELECT`, so the alias doesn't exist yet. |

## Retest (R1 to R6) Misses

| ID | Predicted | Actual | Rule | Why I missed it |
|---|---|---|---|---|
| R3 `GROUP BY city ORDER BY city LIMIT 1` | Bengaluru, 2 | NULL, 1 | 3 | Forgot the NULL group exists, and that ascending order puts it first. |
| R4 `LEFT JOIN ... WHERE c.customer_id IS NULL` | 0 | 2 | 4 | Forgot orders 1041 (NULL key) and 1042 (orphan) have no customer. |
| R6 fix for E1 | One fix given | Two fixes asked | 5 | Gave the repeat-the-expression fix only. Second fix is a subquery or CTE (see below). |

### R6 Both Fixes

```sql
-- Fix 1: repeat the expression, because WHERE cannot see the alias
SELECT amount * 1.18 AS gross FROM orders WHERE amount * 1.18 > 20000;

-- Fix 2: wrap it, so the alias exists before the outer WHERE runs
SELECT gross FROM (SELECT amount * 1.18 AS gross FROM orders) t WHERE gross > 20000;
```

## Repair Drill (D1 to D5) Misses

| ID | Predicted | Actual | Rule | Why I missed it |
|---|---|---|---|---|
| D1 `COUNT(DISTINCT city), COUNT(*)` over `SELECT DISTINCT city` | 5, 5 | 5, 6 | 3 | `DISTINCT` keeps one NULL row. `COUNT(*)` counts it, `COUNT(DISTINCT city)` skips it. |
| D2 `customers LEFT JOIN orders` | 15 | 50 | 6 | Counted the customers. Rows multiply per matching order: 46 matches + 4 unmatched. |
| D3 `orders LEFT JOIN customers WHERE city = 'Pune'` | 3 | 8 | 6, 7 | 3 is the number of Pune **customers**. The FROM table is orders, so I count Pune **orders**. |
| D4 same filter placed in `ON` | 3 | 48 | 7 | An `ON` filter never removes left rows. Only the right-side columns become NULL. |
| D5 `customers LEFT JOIN orders WHERE o.order_id IS NULL` | 0 | 4 | 4 | After a left join, unmatched left rows have NULL in every right column. |

## Day 2 and Day 3 Misses

| ID | Predicted | Actual | Rule | Why I missed it |
|---|---|---|---|---|
| C3 join sentence | "Left join keeps all left rows" | Also needs a unique right key so rows aren't multiplied | 6 | Only considered losing rows, not multiplying them |
| A3(a) unmatched orders | Orphans only, `IS NOT NULL` filter kept | 2 rows (NULL key and orphan) | 1, 4, 9 | The `IS NOT NULL` filter excluded the NULL-key order. `NOT IN` can't return it either |
| B2 second most recent order | Ranked raw rows, customer 2 returned 1039 | Customer 2 should return 1031 | 8 | Duplicate rows of the latest order counted as a second order |
| B3 top 2 per city with ties | `ROW_NUMBER`, raw rows | `RANK` after dedup | 8, 13 | Wrong function for ties, and duplicates appeared twice in the top 2 |
| C2 raw vs dedup completed sales | `count(c.*)`, join with no `ON`, unfiltered raw side | Two same-grain CTEs joined on city | 6, 8 | Tried one tangled query instead of two comparable summaries |

## Day 4 Misses

| ID | Predicted | Actual | Rule | Why I missed it |
|---|---|---|---|---|
| B2 sentence | Not written | Returns several rows per order when copies tie on the max date | 16 | Skipped the explanation, which is the actual lesson |
| C1 view | `FROM order`, no `order_date`, no uniqueness test | `FROM orders` (`order` is a reserved word); keep `order_date`; run `COUNT(*) = COUNT(DISTINCT order_id)` | 15 | Typo plus dropped a column downstream queries need |
| C3 output | Two columns both named `status`, latest before first | Alias `first_status`, `latest_status`; first copy tie-break `row_id ASC` | 14 | Unlabelled columns are unreadable; "first" needs its own consistent tie-breaker |

---

## Score History

| Session | Score | Notes |
|---|---|---|
| Day 1 predictions | 4 / 13 | Rules 1 to 5 introduced |
| Day 1 retest R1 to R6 | 3 / 5 correct, R6 half | Rules 3 and 4 still shaky |
| Day 1 repair drill D1 to D5 | 0 / 5 | Rules 6 and 7 added. Trace row counts by hand before predicting |
| Day 2 submissions | All submitted queries correct | Missing traces and a few items |
| Day 3 submissions | A2, B1, C1 correct. B2, B3, C2 need dedup first | Rule 8 added |
| Day 4 submissions | A1 to B4 correct. C1 syntax error, C3 unlabelled | Rules 14 to 16 added |