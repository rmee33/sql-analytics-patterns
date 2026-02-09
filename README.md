# SQL Analytics Patterns

## Overview
This repository contains reusable SQL patterns commonly used in analytics,
reporting, and data-quality workflows. The examples focus on clarity,
correctness, and real-world applicability rather than database-specific
optimizations.

The goal of this repository is to demonstrate how SQL can be used to:
- explore and summarize data
- identify data quality issues
- handle duplicates
- perform row-level analytics using window functions

All examples use simple, synthetic tables and are intended to be readable
and easy to adapt to other contexts.

---

## Topics Covered

### Joins
Examples of inner and outer joins used to:
- combine related tables
- identify missing or orphaned records
- preserve unmatched records for analysis

### Aggregations
Common aggregation patterns including:
- totals and averages
- grouping by time periods
- filtering aggregated results using HAVING

### Window Functions
Analytical queries that operate across related rows without collapsing data:
- ranking and ordering
- running totals
- identifying most recent records

### Deduplication
Techniques for:
- identifying duplicate records
- flagging duplicates using window functions
- safely removing duplicates when appropriate

### Data Quality Checks
Basic validation queries used to:
- detect nulls in key fields
- identify invalid values
- check referential integrity
- monitor record counts

---

## Repository Structure

