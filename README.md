# SQL Advanced Data Analytics & Reports

This repository contains **SQL Server scripts** for advanced business reporting and analytics.  
It includes **Customer Report** and **Product Report** that provide insights into customer behavior, segmentation, and product performance.  

If you wish to check the **Exploratory Data Analysis (EDA)** done before creating these reports, please refer to this repository:  
👉 [EDA-Business-Reporting-SQL-Server](https://github.com/JitendraManasingh/EDA-Business-Reporting-SQL-Server-.git)

---

## 📊 Reports Included

### 1. Customer Report
- **Segments customers** into groups:
  - **VIP**: At least 12 months of history and spending > €5,000  
  - **Regular**: At least 12 months of history and spending ≤ €5,000  
  - **New**: Lifespan less than 12 months  
- **Key Metrics**:
  - Total orders  
  - Total sales  
  - Total quantity purchased  
  - Total products purchased  
  - Lifespan (in months)  
  - Recency (months since last order)  
  - Average order value (AOV)  
  - Average monthly spend  

📂 File: [`Customer_Report.sql`](Customer_Report.sql)

---

### 2. Product Report
- Provides insights into product-level performance:
  - Total sales by product  
  - Total quantity sold  
  - Number of unique customers  
  - Contribution % to overall revenue  
  - Product ranking by sales  

📂 File: [`Product_Report.sql`](Product_Report.sql)

---

## ⚙️ Tech Stack
- **SQL Server**
- **Data Warehouse Schema** (gold layer: `fact_sales`, `dim_customers`, `dim_products`)

---

## 🚀 How to Use
1. Clone this repository:
   ```bash
   git clone https://github.com/JitendraManasingh/SQL-Advanced-Data-Analytics-Reports.git
