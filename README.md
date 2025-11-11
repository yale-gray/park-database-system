# National Park Service System (NPSS) Database Project

## Overview
This project implements a comprehensive SQL Server–based database system for managing the operations of a fictional National Park Service System (NPSS). The system supports a variety of entities and relationships including people, rangers, researchers, donors, and visitors, as well as programs, donations, and ranger teams.  

The project demonstrates full-stack database interaction through stored procedures (SQL) and a Java command-line interface (CLI) for data entry, retrieval, and reporting. It was completed as part of the CS 4513 Database Management Systems course.

---

## Repository Contents

| File | Description |
|------|--------------|
| **Gray_Yale_IP_REPORT.pdf** | Final project report containing design documentation, ER diagrams, relational schemas, indexing and file organization decisions, and query analysis. |
| **Gray_Yale_IP_Task4.sql** | SQL script defining all table schemas, foreign key constraints, and non-clustered indexes implemented in Microsoft Azure SQL. |
| **Gray_Yale_IP_Task5a.sql** | SQL script containing 15 stored procedures for insertion, retrieval, update, and deletion operations on the NPSS database. Each procedure includes validation and exception handling. |
| **Gray_Yale_IP_Task5b.java** | Java source file that connects to the Azure SQL database via JDBC. It provides a command-line interface for executing the 15 stored procedures defined in Task 5a, along with two file-based operations (import/export). |

---

## Database Architecture

The database models multiple roles and interactions among people involved in park management.  
Key entities include:

- **Person** – Core entity containing demographic and contact information.  
- **Visitor, Ranger, Researcher, Donor** – Specialized subtypes of Person.  
- **Ranger_Team** – Organizational units within parks.  
- **Program** – Educational or service-based park initiatives.  
- **Donation, Check_Donation, Card_Donation** – Donation management structure with transaction-level detail.  
- **Member_of, Oversees, Enrolled_in** – Relationship tables modeling team assignments, research oversight, and visitor participation.  

---

## Features Implemented

### 1. SQL Stored Procedures (Task 5a)
The system implements 15 fully functional stored procedures with input validation, constraint checks, and descriptive error handling.

- **Insert Operations (Queries 1–7)**: Add visitors, rangers, ranger teams, donations, researchers, reports, and park programs.  
- **Retrieve Operations (Queries 8–13)**: Retrieve emergency contacts, enrolled visitors, park programs, donations, and personnel.  
- **Update and Delete Operations (Queries 14–15)**: Adjust researcher salaries and remove inactive visitors.  

Each stored procedure has been tested with representative datasets to ensure logical consistency and referential integrity.

### 2. Java CLI Application (Task 5b)
A text-based application written in Java enables users to:

- Select from 18 available options (15 stored queries + 2 file-based utilities + exit).  
- Input relevant data through standard input.  
- View execution results or SQL Server–raised exceptions directly in the console.  
- Import new ranger teams from a text file and export mailing lists to a file for offline use.  

The application uses **JDBC** to connect to **Microsoft Azure SQL Database** with encrypted credentials and proper exception handling.

### 3. File-Based Operations
Two additional functionalities extend the system:
- **ImportNewRangerTeams**: Reads a `.txt` file containing team information and populates the `Ranger_Team` table using the existing insertion procedure.  
- **ExportMailingAddresses**: Writes subscriber contact information to a `.txt` file using data from the `Person`, `Email`, and `Phone` tables.

---

## Indexing and File Organization

All indexing and storage strategies were selected based on query frequency and access patterns analyzed during project design:

- **Heap** organization for insertion-heavy tables such as `Person`, `Phone`, and `Email`.  
- **B+ Tree** indexing for range-based queries (e.g., `Program`, `Donation`, `Ranger_Team`).  
- **Hash-based** organization for random lookups (e.g., `Check_Donation`, `Visitor`).  

These design choices are justified in detail in the accompanying report.

---

## Setup and Execution

### Prerequisites
- Microsoft SQL Server or Azure SQL Database  
- Java 17 or later  
- SQL Server JDBC Driver  

### Steps
1. Run `Gray_Yale_IP_Task4.sql` to create all tables and indexes.  
2. Run `Gray_Yale_IP_Task5a.sql` to create all stored procedures.  
3. Compile and execute `Gray_Yale_IP_Task5b.java`.  
4. Follow the on-screen menu to interact with the database.

Example compilation:
```bash
javac Gray_Yale_IP_Task5b.java
java Gray_Yale_IP_Task5b
