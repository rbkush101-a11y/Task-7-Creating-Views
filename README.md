# Task-7-Creating-Views
Learn to create and use views

## Description
This project contains SQL scripts to create and use views for a Library database. Views were created to simplify complex queries and demonstrate abstraction and security.

## Files
- views.sql: Contains CREATE VIEW queries

## Interview Questions & Answers (Quick Guide)

1. What is a view?
- A stored query that acts like a virtual table.

2. Can we update data through a view?
- Only if it’s a simple view without joins or aggregations.

3. What is a materialized view?
- A view that stores actual query results.

4. Difference between view and table?
- Tables store data, views store queries.

5. How to drop a view?
- DROP VIEW view_name;

6. Why use views?
- Abstraction, security, reusability.

7. Can we create indexed views?
- Yes, but only in certain RDBMS (e.g., SQL Server).

8. How to secure data using views?
- Restrict columns or rows via WHERE clause.

9. Limitations of views?
- Read-only restrictions, performance, cannot store indexes (except materialized views).

10. WITH CHECK OPTION?
- Ensures updated data still satisfies view conditions.
