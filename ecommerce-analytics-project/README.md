# Ecommerce Analytics Project

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Complete-success.svg)]()

## Table of Contents

- [Overview](#overview)
- [Business Questions](#business-questions)
- [Dataset](#dataset)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Setup](#setup)
- [Pipeline](#pipeline)
- [Key Insights](#key-insights)
- [Skills Demonstrated](#skills-demonstrated)
- [Reproducibility](#reproducibility)
- [Possible Improvements](#possible-improvements)
- [License](#license)
- [Author](#author)

## Overview

This project analyzes user behavior in an ecommerce platform to uncover patterns in customer interactions, identify conversion bottlenecks, and evaluate product performance.

The main goal is not only to build a dashboard, but to simulate a real-world analytics workflow where raw event-level data is transformed into business insights that can support decision-making.

The project follows an end-to-end pipeline:

Raw Data → Data Cleaning → Exploratory Analysis → SQL Storage → Power BI Dashboard

Special focus is placed on understanding the conversion funnel, user activity patterns, and identifying opportunities to improve revenue and engagement.

## Business Questions

The analysis addresses key questions relevant to ecommerce teams:

- When are users most active on the platform?
- Which product categories generate the highest engagement?
- What percentage of product views convert into purchases?
- How do user sessions behave over time?
- Which brands dominate interactions and purchases?

Understanding these patterns enables ecommerce companies to optimize:

- Product placement
- Marketing strategies
- Conversion funnel performance
- Customer engagement initiatives

## Dataset

The project utilizes the **Ecommerce Events History dataset** from Kaggle.

**Dataset Source:** [Kaggle Ecommerce Events History](https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-cosmetics-shop)

**Original File:** `2019-Oct.csv`  
**Size:** ~9GB

Due to GitHub file size limitations, the complete dataset is not included in this repository. Instead, a sample dataset (100k rows) is provided to enable full pipeline execution for testing purposes.

### Dataset Schema

| Column | Description |
|--------|-------------|
| `event_time` | Timestamp of the event |
| `event_type` | Event type (view, cart, purchase) |
| `product_id` | Product identifier |
| `category_id` | Product category identifier |
| `category_code` | Human-readable category name |
| `brand` | Product brand |
| `price` | Product price |
| `user_id` | User identifier |
| `user_session` | Session identifier |

## Project Structure

```
ecommerce-analytics-project/
│
├── data_sample/
│   ├── events_tiny.csv      # Sample raw data (100k rows)
│   └── clean_data.csv       # Processed clean data
│
├── notebooks/
│   ├── 01_data_cleaning.ipynb   # Data preprocessing notebook
│   ├── 02_exploration.ipynb     # Exploratory data analysis
│   └── 03_sql_checks.ipynb      # SQL validation queries
│
├── scripts/
│   ├── 01_filter_data.py        # Data filtering script
│   ├── 01b_create_tiny.py       # Sample creation script
│   ├── 02_data_cleaning.py      # Data cleaning script
│   └── 03_load_sqlite.py        # Database loading script
│
├── powerBI/
│   └── ecommerce.pbit           # Power BI dashboard template
│
├── sql/
│   └── ecommerce.db             # SQLite database
│
└── README.md
```

## Tech Stack

- **Python**: pandas, numpy, matplotlib, seaborn
- **SQL**: SQLite for analytical queries
- **Business Intelligence**: Power BI for interactive visualization
- **Tools**: Jupyter Notebook for analysis

## Setup

### Prerequisites

- Python 3.8 or higher
- Jupyter Notebook
- Power BI Desktop (for dashboard visualization)
- Git (for cloning the repository)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd ecommerce-analytics-project
   ```

2. Create a virtual environment (recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install pandas numpy matplotlib seaborn jupyter
   ```

### Data Preparation

The repository includes a sample dataset for immediate testing. For the full analysis:

1. Download the complete dataset from Kaggle
2. Place `2019-Oct.csv` in a `data/` directory
3. Execute the filtering scripts:
   ```bash
   python scripts/01_filter_data.py
   python scripts/01b_create_tiny.py
   ```

## Pipeline

The project implements a realistic analytics pipeline:

### 1. Data Filtering

Filter the raw dataset to create a manageable subset.

**Script:** [scripts/01_filter_data.py](scripts/01_filter_data.py)

### 2. Dataset Sampling

Generate a smaller dataset for rapid experimentation.

**Script:** [scripts/01b_create_tiny.py](scripts/01b_create_tiny.py)

### 3. Data Cleaning

Clean the raw data using pandas operations:

- Handle missing values
- Format columns appropriately
- Process timestamps
- Filter invalid records

**Script:** [scripts/02_data_cleaning.py](scripts/02_data_cleaning.py)  
**Notebook:** [notebooks/01_data_cleaning.ipynb](notebooks/01_data_cleaning.ipynb)

### 4. Exploratory Data Analysis

Analyze patterns in the cleaned data:

- User activity patterns
- Category popularity metrics
- Event type distribution
- Session behavior analysis

**Notebook:** [notebooks/02_exploration.ipynb](notebooks/02_exploration.ipynb)

### 5. SQL Integration

Load cleaned data into SQLite database for analytical queries.

**Script:** [scripts/03_load_sqlite.py](scripts/03_load_sqlite.py)  
**Database:** [sql/ecommerce.db](sql/ecommerce.db)  
**Validation:** [notebooks/03_sql_checks.ipynb](notebooks/03_sql_checks.ipynb)

### 6. Power BI Dashboard

Interactive visualization of analytical results.

**File:** [powerBI/ecommerce.pbit](powerBI/ecommerce.pbit)

**Features:**
- Activity trend analysis
- Category engagement metrics
- Conversion behavior insights
- Brand performance dashboards


## Key Insights

- **Conversion rate is low (~1.6%)**, indicating potential friction in the purchase funnel. This suggests opportunities for UX optimization or pricing adjustments.

- **User activity peaks between mid-morning and early afternoon**, highlighting optimal time windows for promotions and marketing campaigns.

- **A small number of categories drive the majority of revenue**, with electronics (especially smartphones) dominating performance.

- **Some products show high visibility but low conversion rates**, indicating potential issues such as pricing, competition, or product positioning.

- **Cart abandonment is significant**, suggesting possible improvements in checkout experience or incentives to complete purchases..

## Skills Demonstrated

This project showcases essential data analytics competencies:

- Data preprocessing with Python (pandas)
- Exploratory data analysis techniques
- SQL database integration and querying
- Business-oriented analytical thinking
- Data visualization with Power BI
- End-to-end analytics workflow implementation
- Analytical thinking and business insight generation

## Reproducibility

The project is fully reproducible using the included sample dataset:

1. Execute the cleaning pipeline
2. Run exploratory analysis notebooks
3. Load data into SQLite
4. Connect Power BI to the database

For complete analysis with full data, obtain the Kaggle dataset and follow the setup instructions.

## Possible Improvements

Potential extensions for future development:

- Advanced conversion funnel modeling
- Purchase prediction using machine learning
- Customer segmentation analysis
- Multi-month trend analysis
- Automated ETL pipeline implementation

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Author

**Adrián Pañeda**  
Data Analytics Portfolio Project

For questions or contributions, please open an issue in the repository.