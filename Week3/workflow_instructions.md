# Workflow Practice

This project introduces you to working with a relational database using **SQLite** and **Python**. You will use Pandas to connect to a database, create tables from CSV files, and write SQL queries to explore data—all inside a Jupyter Notebook.

The dataset used in this project comes from the [Bike Store Sample Database](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database) by Dillon Myrick. It models a fictional bicycle retail business with multiple stores, customers, products, and staff members. Each table connects through foreign keys such as `customer_id`, `store_id`, and `product_id`.

## Learning Outcomes

By completing this project, you will be able to:

- Connect to a SQLite database using Python  
- Load and write tables efficiently using Pandas  
- Execute SQL queries inside a Jupyter Notebook  
- Interpret query results returned as DataFrames  
- Work with a multi-table relational dataset  
- Follow a complete data workflow from setup to submission  

## Project Structure

```
data/  
 |--customers.csv  
 |--orders.csv  
 |--order_items.csv  
 |--products.csv  
 |--categories.csv  
 |--stores.csv  
 |--staffs.csv  
 |--brands.csv  
workflow_practice.ipynb  
workflow_instructions.md  
```

## Instructions

1. Open the `workflow_practice.ipynb` notebook. 
2. Follow the step-by-step directions inside the notebook.  
   You will:
   - Connect to a SQLite database using Python  
   - Load each CSV file into the database as a table using `to_sql()`  
   - Explore the tables and run SQL queries using `pd.read_sql()`  
   - Complete several SQL practice prompts directly in the notebook  
3. When you finish, save your completed notebook.  
4. Commit and push your work to your GitHub repository.  
