Good. Now let me apply the humanizer properly to the README.

---

**Draft rewrite:**

```markdown
# The Discount Trap
### Are promotions growing revenue — or training customers to never pay full price?

**Industry:** Retail / E-commerce  
**Tool:** Microsoft SQL Server (T-SQL)  
**Data:** Synthetic dataset generated to match a realistic retail schema (1,200 customers, 10 product categories)

---

## Business Context

Every retailer runs promotions. The logic is simple: discounts drive volume, volume drives revenue. But there's a version of this story that quietly goes wrong. When promotions run too frequently or too broadly, some customers start to figure out that waiting for a discount is the smarter play. They stop buying at full price. They hold out. They look retained in your dashboards, but the margin tells a different story.

This project set out to answer one question:

> **Which customers are buying predominantly or exclusively during promotions, and what is the true margin cost of their "loyalty"?**

Four queries were built to dig into this:
1. Classify every customer by their promotion dependency ratio
2. Calculate the revenue and margin economics of each buyer segment
3. Detect whether each customer's promo dependency is getting better or worse over time
4. Identify which product categories are most exposed to discounting

---

## What the Data Reveals

### Query 1 — Customer Classification

Customers were split into four segments based on what share of their orders happened during an active promotion:

| Segment | Threshold | Customers |
|---|---|---|
| Full-Price | < 20% promo orders | 982 |
| Mixed | 20–50% promo orders | 172 |
| Promo-Heavy | 50–80% promo orders | 31 |
| Promo-Only | > 80% promo orders | 15 |

982 of 1,200 customers sit in the Full-Price bucket. Only 46 customers are genuinely promo-dependent.

### Query 2 — Segment Economics

| Segment | Customers | Net Revenue | Total Discounts | Gross Margin % |
|---|---|---|---|---|
| Full-Price | 982 | £1,873,885 | £15,241 | 39.5% |
| Mixed | 172 | £344,790 | £16,854 | 37.2% |
| Promo-Heavy | 31 | £24,605 | £2,068 | 33.9% |
| Promo-Only | 15 | £3,453 | £589 | 31.0% |

The margin gap is real but not as dramatic as expected. Full-Price buyers sit at 39.5% gross margin versus 31.0% for Promo-Only, an 8.5 point difference. The bigger story is volume: 982 Full-Price customers generate over £1.87M in net revenue, while all 46 promo-dependent customers combined generate under £28,000.

### Query 3 — Trend Detection

Using `FIRST_VALUE` and `LAST_VALUE` window functions to track each customer's running promo ratio across their order history, three patterns came up:

- **Increasingly Promo-Dependent:** Customers who started at full price but have been drifting toward promo purchases over time
- **Decreasingly Promo-Dependent:** Customers who started with a promo purchase but have since shifted toward paying full price. This is the commercially valuable direction.
- **Stable:** Customers with consistent behaviour either way

Worth noting: a meaningful group of customers is actually moving away from promo dependency over time. That's an easy signal to miss if you're only looking at current segment totals.

### Query 4 — Category Exposure

| Category | Promo Dependence % | Full-Price Margin % | Realised Margin % | Rank |
|---|---|---|---|---|
| Footwear | 9.87% | 43.1% | 41.8% | 1 |
| Pet Supplies | 9.69% | 39.3% | 37.9% | 2 |
| Electronics | 9.67% | 28.1% | 26.7% | 3 |
| Accessories | 9.44% | 55.5% | 54.6% | 4 |
| Sports & Outdoors | 9.41% | 38.2% | 36.9% | 5 |
| Beauty | 9.27% | 56.3% | 55.5% | 6 |
| Apparel | 9.13% | 46.6% | 45.5% | 7 |
| Books | 8.76% | 33.9% | 32.6% | 8 |
| Toys & Games | 8.59% | 43.6% | 42.7% | 9 |
| Home & Kitchen | 8.10% | 42.4% | 41.3% | 10 |

This is the most interesting output of the four. Every single category sits within a 1.77 percentage point range. Ten categories with completely different price sensitivities and buying behaviours, and the promo dependence rates are nearly identical across all of them.

---

## Business Recommendation

The original hypothesis was that promotions were building up a margin problem through promo-dependent customers. The data only partially supports this.

The margin gap exists, but the promo-dependent population is small. 46 customers out of 1,200 is not a crisis. The more interesting finding is in Query 4.

When every category lands at roughly the same promo dependence rate regardless of its margin profile, that usually points to one of two things:

1. Promotions are being applied at the store level rather than by category. Broad "% off everything" events rather than targeted discounting calibrated to where it actually makes commercial sense.
2. Or this is a deliberate strategy that has been tested and found to work better than targeted discounting.

The data cannot tell you which. To find out, you'd review historical promotional briefs. If discounts are consistently store-wide, the first interpretation holds and a more surgical approach is worth testing.

One finding holds either way: Electronics needs attention. It has the lowest full-price margin in the dataset at 28.1%, and the third-highest promo dependence rate. It is the least able to absorb discounting, and currently one of the most exposed to it.

---

## SQL Concepts Demonstrated

- Common Table Expressions (CTEs) for multi-stage logic across classification and aggregation
- Window functions: `SUM() OVER()`, `FIRST_VALUE()`, `LAST_VALUE()` with `ROWS BETWEEN` framing
- Running ratio calculation for trend detection across order history
- `RANK() OVER()` for category league table ranking
- `NULLIF()` for divide-by-zero protection
- `CAST` for integer division handling
- Multi-table JOINs across 5 related tables
- Conditional aggregation with `COUNT(CASE WHEN...)`
- `COUNT(DISTINCT ...)` within grouped joins to avoid row multiplication
```

---

**What still reads as AI-generated?**
- "Worth noting:" reads like a signpost
- "This is the most interesting output" is a filler opinion with no real punch behind it
- The recommendation section is still a bit formal and structured in a way that feels assembled rather than written
- "One finding holds either way" is a mild transition tell

**Final version:**

```markdown
# The Discount Trap
### Are promotions growing revenue, or training customers to never pay full price?

**Industry:** Retail / E-commerce  
**Tool:** Microsoft SQL Server (T-SQL)  
**Data:** Synthetic dataset generated to match a realistic retail schema (1,200 customers, 10 product categories)

---

## Business Context

Every retailer runs promotions. The logic is simple: discounts drive volume, volume drives revenue. But there is a version of this story that quietly goes wrong. When promotions run too frequently or too broadly, some customers start to figure out that waiting for a discount is the smarter play. They stop buying at full price. They look retained in your dashboards, but the margin tells a different story.

This project set out to answer one question:

> **Which customers are buying predominantly or exclusively during promotions, and what is the true margin cost of their "loyalty"?**

Four queries were built:
1. Classify every customer by their promotion dependency ratio
2. Calculate the revenue and margin economics of each buyer segment
3. Detect whether each customer's promo dependency is getting better or worse over time
4. Identify which product categories are most exposed to discounting

---

## What the Data Reveals

### Query 1 — Customer Classification

Customers were split into four segments based on what share of their orders happened during an active promotion:

| Segment | Threshold | Customers |
|---|---|---|
| Full-Price | < 20% promo orders | 982 |
| Mixed | 20–50% promo orders | 172 |
| Promo-Heavy | 50–80% promo orders | 31 |
| Promo-Only | > 80% promo orders | 15 |

982 of 1,200 customers are in the Full-Price bucket. Only 46 are genuinely promo-dependent.

### Query 2 — Segment Economics

| Segment | Customers | Net Revenue | Total Discounts | Gross Margin % |
|---|---|---|---|---|
| Full-Price | 982 | £1,873,885 | £15,241 | 39.5% |
| Mixed | 172 | £344,790 | £16,854 | 37.2% |
| Promo-Heavy | 31 | £24,605 | £2,068 | 33.9% |
| Promo-Only | 15 | £3,453 | £589 | 31.0% |

The margin gap is real but not as dramatic as expected. Full-Price buyers sit at 39.5% gross margin versus 31.0% for Promo-Only, an 8.5 point difference. The more striking number is volume: 982 Full-Price customers generate over £1.87M in net revenue, while all 46 promo-dependent customers combined come in under £28,000.

### Query 3 — Trend Detection

Using `FIRST_VALUE` and `LAST_VALUE` window functions to track each customer's running promo ratio across their order history, three patterns came up:

- **Increasingly Promo-Dependent:** Customers who started at full price but have been drifting toward promo purchases over time
- **Decreasingly Promo-Dependent:** Customers who started with a promo purchase but have since shifted toward paying full price. This is the commercially valuable direction.
- **Stable:** Customers with consistent behaviour either way

A meaningful group of customers is actually moving away from promo dependency over time. That signal is easy to miss if you only look at current segment totals.

### Query 4 — Category Exposure

| Category | Promo Dependence % | Full-Price Margin % | Realised Margin % | Rank |
|---|---|---|---|---|
| Footwear | 9.87% | 43.1% | 41.8% | 1 |
| Pet Supplies | 9.69% | 39.3% | 37.9% | 2 |
| Electronics | 9.67% | 28.1% | 26.7% | 3 |
| Accessories | 9.44% | 55.5% | 54.6% | 4 |
| Sports & Outdoors | 9.41% | 38.2% | 36.9% | 5 |
| Beauty | 9.27% | 56.3% | 55.5% | 6 |
| Apparel | 9.13% | 46.6% | 45.5% | 7 |
| Books | 8.76% | 33.9% | 32.6% | 8 |
| Toys & Games | 8.59% | 43.6% | 42.7% | 9 |
| Home & Kitchen | 8.10% | 42.4% | 41.3% | 10 |

Ten categories with completely different price sensitivities and buying behaviours, and the promo dependence rates sit within a 1.77 percentage point range across all of them. That kind of uniformity is worth pausing on.

---

## Business Recommendation

The original hypothesis was that promotions were building a margin problem through promo-dependent customers. The data only partially backs this up.

The margin gap is real, but 46 promo-dependent customers out of 1,200 is not a crisis. The more uncomfortable finding is the category uniformity in Query 4.

When Accessories (55% margin) and Electronics (28% margin) have nearly identical promo dependence rates, something is off. Categories with thin margins should arguably run fewer, shallower promotions than high-margin ones. The fact that they don't points to one of two things: either promotions are being applied at the store level as broad "% off everything" events rather than calibrated by category, or this is a deliberate strategy that has been tested and found to produce better overall conversion than targeted discounting.

The data cannot tell you which. You'd need to look at the promotional briefs. If discounts are consistently store-wide, the first interpretation holds and a category-targeted approach is worth testing.

Regardless of which interpretation is correct, Electronics is the one category that warrants immediate attention. Lowest full-price margin in the dataset at 28.1%, third-highest promo dependence rate. It is the least able to absorb discounting and currently one of the most exposed.

---

## SQL Concepts Demonstrated

- Common Table Expressions (CTEs) for multi-stage logic across classification and aggregation
- Window functions: `SUM() OVER()`, `FIRST_VALUE()`, `LAST_VALUE()` with `ROWS BETWEEN` framing
- Running ratio calculation for trend detection across order history
- `RANK() OVER()` for category league table ranking
- `NULLIF()` for divide-by-zero protection
- `CAST` for integer division handling
- Multi-table JOINs across 5 related tables
- Conditional aggregation with `COUNT(CASE WHEN...)`
- `COUNT(DISTINCT ...)` within grouped joins to avoid row multiplication
```
