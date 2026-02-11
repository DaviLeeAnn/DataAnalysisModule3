# Superstore Sales Workflow Tutorial

This project is designed to simulate a real-world data analytics workflow from start to finish. Using a retail sales dataset, you’ll step into the role of a data analyst preparing data for insight — learning how to clean, model, query, and visualize information using tools common in the field: Python, Pandas, SQLite, and Seaborn.

The lesson emphasizes both technical and conceptual understanding. As you move through the notebook, you’ll explore how relational database design helps reduce redundancy, enforce consistency, and make analysis more powerful. You’ll also practice writing SQL queries and turning those results into compelling visual stories.

By the end, you’ll have a working SQLite database, a polished Entity Relationship Diagram (ERD), and a collection of visualizations that connect the data to real business questions — demonstrating your ability to think through an analytical process from raw data to insight.

## Repository Structure
```
DA_M3_W4_Workflow/
│
├── data/
│   └── superstore_sales.csv
│
├── notebooks/
│   └── superstore_sales_tutorial.ipynb
│
├── images/
│   └── placeholder.png     ← Save your actual ERD in this directory
│
├── requirements.txt
│
└── wk4_workflow_instructions.md

```

## Overview

In this tutorial, you’ll work directly with the popular [**Superstore Sales Dataset**](https://www.kaggle.com/datasets/ishanshrivastava28/superstore-sales) - a rich, multi-dimensional dataset published on Kaggle by *Ishan Shrivastava*. This dataset simulates real retail sales and contains information about orders, products, customers, and shipping details across multiple regions and time periods. It’s widely used for practicing data analysis, visualization, and business intelligence workflows.

You’ll begin by inspecting and cleaning the raw CSV file, ensuring that data types, formatting, and consistency are correct. Next, you’ll identify repeating entities (such as customers, orders, and products) and design an **Entity Relationship Diagram (ERD)** to represent how those entities connect. Once your design is finalized, you’ll create an **SQLite database** using Python and Pandas, splitting the dataset into properly structured tables.

With your database complete, you’ll practice writing **SQL queries** to explore sales performance across different dimensions - such as customer categories, product profitability, and regional sales. Finally, you’ll visualize your findings using **Matplotlib** and **Seaborn**, transforming your SQL results into clear, engaging graphics.

This project mirrors a real-world data workflow: from *raw CSV → relational design → SQL analysis → visualization*. It reinforces good data practices, storytelling with visuals, and the ability to turn raw information into meaningful insights.


## Getting Started
1. Create and activate a virtual environment
```
# windows
python -m venv venv
source venv/Scripts/activate 

# mac/linux
python3 -m venv venv
source venv/bin/activate

```
2. Install requirements.txt file
```
pip install requirements.txt
```
3. Open the superstore_sales_workflow notebook
4. Follow along the video tutorial
5. Complete the additional prompts for queries and visualizations after completing the tutorial.
6. Save your ERD into the images folder
7. Save, add, commit, and push changes to github before submitting repository link in OpenClass. 


---

*Parts of this project, including instructional text, example code, and documentation, were developed with the assistance of AI tools (such as ChatGPT) to support clarity, structure, and learning outcomes. All content has been reviewed, tested, and adapted by the instructor to ensure accuracy, educational value, and alignment with course objectives. Students are encouraged to use AI responsibly — as a supplement for understanding and exploration, not as a substitute for original work or critical thinking.*