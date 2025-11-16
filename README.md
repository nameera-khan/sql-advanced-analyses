# Advanced Analyses of Retail Business Using SQL 

This repository is an extension of the sql-data-warehouse-project. It follows the gold layer from the existing warehouse; this layer consists of data cleaned and ready for analysis. 

The gold view layer consists of the following tables that follow a star scheme: 

![Sales schema](https://github.com/user-attachments/assets/27ed84aa-e3ff-48d8-b6be-c77460da43e4)

The analyses consists of a final customer and product report. This report elaborates on segmentations based on:
- Customer segments such as VIP, Regular and New customers 
- The customer's recent purchases
- Customer lifespan in months
- Total sales
- Total product revenue
- High performing products
- Mid performing products
- Low performers

```plaintext
advanced-analyses/
├── analyses/                                                  
│   ├── Introductory_analysis_sheet1.sql  
│   ├── Cumulative_analysis_sheet2.sql                  
│   ├── Performance_analysis_sheet3.sql               
│   ├── Part_to_whole_sheet4.sql          
│   ├── Data_segmentation_sheet5.sql
│   ├── Creating_customer_reports_sheet6.sql
│   └── Create_product_reports_sheet7.sql
│
├── README.md                # Project overview
├── LICENSE                  # MIT License
└── .gitignore              # Git ignore rules
``` 

## License 
This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution. 
