-- 1) Create database and use it
CREATE DATABASE IF NOT EXISTS librarydb;
USE librarydb;

-- 2) Tables (books, members, borrowings)

-- Create `books` table
CREATE TABLE IF NOT EXISTS books (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(255) NOT NULL,
  published_year INT,
  genre VARCHAR(100),
  available_copies INT DEFAULT 0,
  total_copies INT DEFAULT 0
);

-- Create `members` table
CREATE TABLE IF NOT EXISTS members (
  member_id INT AUTO_INCREMENT PRIMARY KEY,
  member_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE,
  join_date DATE DEFAULT (CURRENT_DATE())
);

-- Create `borrowings` table (tracks when a member borrows a book)
CREATE TABLE IF NOT EXISTS borrowings (
  borrowing_id INT AUTO_INCREMENT PRIMARY KEY,
  book_id INT NOT NULL,
  member_id INT NOT NULL,
  borrow_date DATE NOT NULL DEFAULT (CURRENT_DATE()),
  due_date DATE,
  return_date DATE DEFAULT NULL,
  FOREIGN KEY (book_id) REFERENCES books(book_id),
  FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- 3) Sample data (so the views return something meaningful)
-- Insert sample books
INSERT INTO books (title, author, published_year, genre, available_copies, total_copies) VALUES
  ('Clean Code', 'Robert C. Martin', 2008, 'Programming', 2, 3),
  ('The Pragmatic Programmer', 'Andrew Hunt', 1999, 'Programming', 1, 2),
  ('Design Patterns', 'Erich Gamma', 1994, 'Programming', 0, 1),
  ('Norwegian Wood', 'Haruki Murakami', 1987, 'Fiction', 4, 4),
  ('Atomic Habits', 'James Clear', 2018, 'Self-help', 2, 3);

-- Insert sample members
INSERT INTO members (member_name, email, join_date) VALUES
  ('Alice Kumar', 'alice@example.com', '2024-06-12'),
  ('Rishabh Kushwaha', 'rbkush101@example.com', '2025-01-15'),
  ('Deepa Singh', 'deepa@example.com', '2025-08-30');

-- Insert sample borrowings
-- Note: return_date NULL means book is currently borrowed
INSERT INTO borrowings (book_id, member_id, borrow_date, due_date, return_date) VALUES
  (1, 1, '2025-09-20', '2025-10-04', NULL), -- Clean Code borrowed by Alice
  (2, 2, '2025-09-28', '2025-10-12', NULL), -- Pragmatic Programmer borrowed by Rishabh
  (3, 3, '2025-08-25', '2025-09-08', '2025-09-05'); -- Design Patterns was returned

-- 4) Views: drop-if-exists then create (safe for re-run)

-- View A: current_borrowings
-- Purpose: abstraction showing currently borrowed books with member details
DROP VIEW IF EXISTS current_borrowings;
CREATE VIEW current_borrowings AS
SELECT
  br.borrowing_id,
  b.book_id,
  b.title,
  b.author,
  m.member_id,
  m.member_name,
  br.borrow_date,
  br.due_date
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
JOIN members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL;

-- View B: active_members
-- Purpose: list members and how many books they currently have borrowed
DROP VIEW IF EXISTS active_members;
CREATE VIEW active_members AS
SELECT
  m.member_id,
  m.member_name,
  COUNT(br.borrowing_id) AS borrowed_books,
  MAX(br.borrow_date) AS last_borrow_date
FROM members m
LEFT JOIN borrowings br
  ON m.member_id = br.member_id AND br.return_date IS NULL
GROUP BY m.member_id, m.member_name;

-- View C: books_by_genre
-- Purpose: aggregated counts by genre (useful for dashboards)
DROP VIEW IF EXISTS books_by_genre;
CREATE VIEW books_by_genre AS
SELECT
  genre,
  COUNT(*) AS total_books,
  SUM(available_copies) AS available_copies
FROM books
GROUP BY genre;

-- View D: overdue_books
-- Purpose: list currently overdue borrowings and how many days overdue
DROP VIEW IF EXISTS overdue_books;
CREATE VIEW overdue_books AS
SELECT
  br.borrowing_id,
  b.book_id,
  b.title,
  m.member_id,
  m.member_name,
  br.borrow_date,
  br.due_date,
  DATEDIFF(CURRENT_DATE(), br.due_date) AS days_overdue
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
JOIN members m ON br.member_id = m.member_id
WHERE br.return_date IS NULL
  AND br.due_date < CURRENT_DATE();

-- View E: book_titles (simple, updatable view)
-- Purpose: demonstrate a simple view that is updatable because it references a single table and primary key
DROP VIEW IF EXISTS book_titles;
CREATE VIEW book_titles AS
SELECT book_id, title
FROM books;

-- View F: available_books (uses WITH CHECK OPTION to enforce view condition on writes)
-- Purpose: expose only books that have at least one available copy; any UPDATE/INSERT via view must satisfy available_copies > 0
DROP VIEW IF EXISTS available_books;
CREATE VIEW available_books AS
SELECT book_id, title, available_copies
FROM books
WHERE available_copies > 0
WITH CHECK OPTION;

-- 5) Usage examples (line-by-line queries you can run)

-- 1) See all current borrowings
SELECT * FROM current_borrowings;

-- 2) See active members and counts
SELECT * FROM active_members;

-- 3) See books aggregated by genre
SELECT * FROM books_by_genre;

-- 4) See overdue books (if any)
SELECT * FROM overdue_books;

-- 5) Update a book title through a simple updatable view
-- (Allowed because book_titles selects directly from books using primary key)
UPDATE book_titles
SET title = 'Clean Code (Updated)'
WHERE book_id = 1;

-- 6) Attempt to set available_copies to 0 via available_books (will fail because of WITH CHECK OPTION)
-- This statement is intentionally shown to illustrate WITH CHECK OPTION behavior
UPDATE available_books
SET available_copies = 0
WHERE book_id = 1;

-- 7) Clean up: if you want to drop views later, use the following (commented out by default)
-- DROP VIEW IF EXISTS current_borrowings;
-- DROP VIEW IF EXISTS active_members;
-- DROP VIEW IF EXISTS books_by_genre;
-- DROP VIEW IF EXISTS overdue_books;
-- DROP VIEW IF EXISTS book_titles;
-- DROP VIEW IF EXISTS available_books;

-- End of file
