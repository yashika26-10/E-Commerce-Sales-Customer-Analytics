# E-Commerce Sales & Customer Analytics

An end-to-end data analytics project exploring e-commerce sales performance, customer purchasing behavior, and product trends using **MySQL and Power BI**.

## Project Overview

This project analyzes transactional e-commerce data to identify sales trends, understand customer behavior, evaluate product performance, and generate actionable business insights.

## Tools & Technologies

- **SQL:** MySQL, MySQL Workbench
- **Data Visualization:** Microsoft Power BI
- **Data Preparation:** Microsoft Excel
- **Version Control:** Git and GitHub

## Project Objectives

- Analyze overall sales and order performance.
- Identify top-performing products.
- Understand customer purchasing behavior.
- Evaluate country-wise sales performance.
- Analyze monthly and quarterly sales trends.
- Present findings through interactive Power BI dashboards.

## Repository Structure

```text
E-Commerce-Sales-Customer-Analytics/
│
├── Dashboard_Screenshots/
│
├── data/
│   └── raw/
│
├── insights/
│
├── processed/
│
├── Ecommerce_PowerBI.pbix
├── ecommerce_sql_exploration.sql
└── README.md
```

## Data Preparation

The original dataset was preserved separately from the processed dataset.

Data preparation included:
- Reviewing missing values.
- Checking invalid and negative quantities.
- Reviewing zero and invalid unit prices.
- Retaining valid transaction records.
- Preserving the original dataset separately.

**Business rule:** Records with `UnitPrice <= 0` are retained in the dataset but excluded from revenue-related KPI calculations.

## SQL Analysis

SQL analysis was performed using MySQL Workbench to explore:

- Overall sales and order performance.
- Customer-level purchasing patterns.
- Product-level sales performance.
- Country-wise sales distribution.
- Monthly sales trends.

The SQL queries are available in `ecommerce_sql_exploration.sql`.

## Power BI Dashboard

The interactive Power BI report contains four analytical pages:

1. Executive Overview
2. Customer Analysis
3. Product Performance Analysis
4. Sales Trends & Time Analysis

The `.pbix` file is available in the repository. Dashboard screenshots are available in the `Dashboard_Screenshots` folder.

## Key Business Insights

Business findings derived from the SQL analysis and Power BI dashboards will be documented here.

## Project Deliverables

- Original and processed datasets
- SQL exploration queries
- Interactive Power BI report
- Dashboard screenshots
- Business insights workbook

## Author

**Yashika Sharma**

GitHub: [yashika26-10](https://github.com/yashika26-10)
