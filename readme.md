# Olist E-Commerce Data Analytics Project

An end-to-end SQL data analysis project exploring customer purchasing behaviors, sales trends, delivery metrics, and customer segmentation using the Brazilian Olist E-Commerce dataset.

## 📊 Project Overview & Business Insights
This project answers critical e-commerce performance questions using structural SQL queries to extract data-driven marketing and operational metrics.

### Key Executive Insights
* **Top Spender:** The highest-value customer generated a total lifetime purchase value of **$13,440.00**.
* **Order Status Metrics:** The platform maintains an exceptionally low order cancellation rate of **0.01%** (0.0063% raw value).
* **Logistical Variations:** Average delivery times vary drastically by geographic region. Far-northern states like **Roraima (RR)** and **Amapá (AP)** experience the slowest shipping averages (**28 days**), whereas southern logistics hubs like São Paulo maintain significantly faster delivery windows.
* **Customer Retention:** RFM segmentation successfully isolated champion repeat buyers (e.g., Customer `8d50f5eadf...` with **14 unique orders** and a recency window of **16 days**), alongside "at-risk" historic buyers who have not returned to ship in over 600 days.

---

## 🛠️ Repository Folder Structure
To ensure reproducibility, this repository is organized into standard data engineering directories:

| Directory / File | Description |
| :--- | :--- |
| `sql/` | Contains numbered, individual `.sql` query files for Questions 1-15. |
| `schema/` | Houses the `create_tables.sql` script detailing the baseline database schema layout. |
| `docs/` | Contains the final comprehensive business report document and the Entity-Relationship (ER) Diagram image. |
| `screenshots/` | Holds verified screenshots of successful query execution grids from the SQL environment. |
| `README.md` | This file—providing a direct administrative overview of the analytics portfolio. |

---

## ⚠️ Data Limitations & Challenges
* **Question 14 Omission:** Question 14 (*"Is delivery delay associated with lower review scores?"*) could not be resolved analytically. A comprehensive review of `INFORMATION_SCHEMA.COLUMNS` and the source source material verified that no customer satisfaction fields (`review_score` or equivalent) or independent review datasets were provided in the operational practice schema. This limitation was fully documented to preserve data integrity.

---

## ⚙️ How to Run These Queries
1. Clone this repository to your local terminal environment.
2. Ensure you have **Microsoft SQL Server** (or a comparable relational engine like PostgreSQL) running locally.
3. Execute the base table configuration file inside the `/schema/` directory to construct your source tables.
4. Open any numbered query from the `/sql/` directory and execute the script directly inside your management client interface.