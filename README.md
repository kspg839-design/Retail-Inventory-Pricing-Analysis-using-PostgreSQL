# 📊 Retail Inventory & Pricing Analysis using PostgreSQL

## 🧠 Project Overview

This project focuses on analyzing a retail dataset (Zepto-like quick commerce data) to uncover insights related to inventory management, pricing strategy, and stock optimization.

The goal is to simulate real-world business analysis by solving practical problems using SQL and deriving actionable insights.

---

## 🎯 Business Objectives

This project answers key business questions such as:

* Which categories are at risk of stockout and potential lost sales?
* Which products are over-discounted but still not selling (dead inventory)?
* How does product variety compare with stock availability?
* Which products are inefficient in terms of weight-to-value ratio?
* What is the distribution of premium vs value products in inventory?
* Do discounts actually help in reducing stock levels?

---

## 🛠️ Tools & Technologies

* PostgreSQL
* SQL (CTEs, Window Functions, Aggregations, CASE statements)

---

## 🧹 Data Cleaning

* Removed invalid records (zero/negative price and weight)
* Handled missing values and inconsistencies
* Validated pricing and stock-related fields

---

## ⚙️ Feature Engineering

Created derived metrics to enhance analysis:

* `current_inventory_value` = price × available quantity
* `value_per_kg` = price efficiency based on product weight
* Stock segmentation (Out of Stock, Low Stock, In Stock)
* Price segmentation (Premium, Mid-range, Value)
* Inventory risk classification using window functions

---

## 📊 Key Analysis Performed

### 🔴 Stockout & Risk Analysis

* Identified categories with very low stock (≤1 unit)
* Highlighted potential lost sales due to stock unavailability

---

### 🟠 Over-Discounting Detection

* Found products with high discounts but still high stock
* Indicated ineffective pricing strategies and dead inventory

---

### 🟡 Product Assortment Analysis

* Compared product variety vs average stock per category
* Detected shallow inventory depth

---

### 🟢 Logistics Efficiency (Value per KG)

* Measured revenue generated per unit weight
* Identified inefficient heavy products

---

### 🔵 Pricing Strategy Analysis

* Segmented products into Premium, Mid-range, and Value
* Evaluated overall inventory distribution

---

### 🟣 Discount vs Demand Analysis

* Used correlation analysis to measure impact of discounts on stock
* Found very weak relationship between discount and sales effectiveness

---

## 🧠 Key Insights

* Several categories face stockout risk, leading to potential revenue loss
* Discounts alone are not effective in clearing inventory
* High product variety does not always translate to better availability
* Some heavy products generate low value, impacting delivery efficiency
* Business is more focused on value products rather than premium items
* Pricing strategy needs optimization based on demand

---

## 📈 Advanced SQL Techniques Used

* Common Table Expressions (CTEs)
* Window Functions (`NTILE`, `RANK`)
* Aggregations (`SUM`, `AVG`, `COUNT`)
* Conditional logic using `CASE`
* Correlation analysis (`CORR`)

---

## 💼 Resume Highlight

* Performed end-to-end retail data analysis using PostgreSQL
* Solved real-world business problems related to inventory and pricing
* Applied advanced SQL techniques to derive actionable insights

---

## 🚀 Future Improvements

* Build an interactive Power BI dashboard
* Add time-based analysis (if data available)
* Implement predictive models for demand forecasting

---

## 🤝 Conclusion

This project demonstrates how SQL can be used not just for querying data, but for solving real business problems and supporting data-driven decision-making.

