Why?
    a. Introduction to topic
        Olist as an example of e-commerce in Brazil
        We want to have a look at how Olist is doing in Brazil by looking at a dataset containing data from 2016 to 2018 containing order status, price, payment and freight performance to customer location, product attributes and finally reviews written by customers.
    b. Problem
        Attracting more sellers to expand business
    c. Target group/stakeholder
        Sales development

What?
    a. Data catalog
        i. Number of data sets
            10
        ii. Number of columns and rows
            see ER-diagram
        iii. Data model (ER-diagram)
            insert ER-diagram
        iv. Column definitions
            see external file "column_descriptions" in Google Drive
        v. Data types (int, float etc.)
            string
            float
            integer
            timestamp
            (boolean)
        vi. Dimensions/Measures
            time/date (d)
            payment value (m)
            payment type (d)
            lat/long (d)
            zip code (d)
            city/state (d)
            count of sellers (m)
            count of products (m)
            product category (d)
            processing time (m)
        vii. Data Quality (Outliers, null values etc.)
            - order_items_dataset: outliers in "price" and "freight_value" with extremely high values which is unusual
            - order_payments_dataset: outliers in "payment_sequential" with high numbers (usually paid by voucher) which is unusual and "payment_value" with high and low numbers (0 or close to 0 which got paid) which is unusual
            - orders_dataset: some null-values but negligible, estimated delivery dates are high
            - products_dataset: high values in weight which is unusual regarding the product category (e.g. health_beauty)
    b. Objective
        i. Questions
            - Which sellers segments should we focus on based on the product price and the frequency of the products sold?
            - For which product types are sellers to be added?
            - In which region should we add more sellers?
        ii. Hypotheses
            - Adding more sellers in an area would lead to a decrease in delivery time thus leading to better review scores.
        iii. Assumptions
            - review scores are lower the longer the delivery takes
            - the higher the seller/customer-ratio the higher the review scores
    c. Deliverables
        i. Project scope (in/out)
            - In: most successful products regarding sales numbers, discover areas with just a few sellers, evaluate review scores in terms of product categories and area, analyze correlation between seller/customer-ratio, delivery time and review scores
            - Out: customer segmentation, marketing funnel analysis
        ii. Minimum viable product (MVP)
            Identify the geographical regions where sellers matching the necessary profile have to be added to

How? - Project Management
    a. Team
        i. Relative skill ranking of each team member
            see KPI sheet
        ii. Responsibilities
            see KPI sheet
        iii. Mandatory Protocol*
            daily
        iv. Process to track progress
            Trello, protocol
    b. Technologies/Tools
        i. Excel/Google Sheets
            not going to use
        ii. Python
        iii. SQL Database
        iv. Tableau
        v. Kanban
    c. Execution
        i. Prioritisation**
            EDA, develop KPIs, seller segmentation, find correlations, showcase it (plotting/Tableau), create dashboard
        ii. Timeline
            see Trello
        iii. Milestones
            1st: creating the project plan (identify problems)
            2nd: EDA, develop KPIs, seller segmentation
            3rd: find correlations, dashboard
            4th: final presentation
        iv. Deadlines
            til every stakeholder meeting (9th, 16th, 23rd, 27th of January)
        v. Blockers
        vi. Risks
            time management
        vii. Answer: How do you ensure success?
            daily standup meeting, progress tracking, regular feedback from stakeholder, scope management

* This entails that you note down key discussion points in order to keep track of ideas within the team and talks with the stakeholders.
** Ensure that you take at least 1 day to plan your execution after a shallow dive of the data to help you brainstorm and not get tunnel visioned. Document this process as well.