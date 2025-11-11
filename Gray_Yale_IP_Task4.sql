-- Person table
CREATE TABLE Person (
    person_id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    firstname NVARCHAR(50) NOT NULL,
    lastname NVARCHAR(50) NOT NULL,
    middle_initial NVARCHAR(10),
    dob DATE NOT NULL,
    gender NVARCHAR(20),
    street NVARCHAR(100),
    city NVARCHAR(50),
    state NVARCHAR(50),
    postal_code NVARCHAR(10),
    subscribed BIT
);
GO

-- Phone table
CREATE TABLE Phone (
    person_id INT NOT NULL FOREIGN KEY REFERENCES Person(person_id),
    phone_number NVARCHAR(20) NOT NULL,
    PRIMARY KEY (person_id, phone_number)
);
GO

-- Email table
CREATE TABLE Email (
    person_id INT NOT NULL FOREIGN KEY REFERENCES Person(person_id),
    email_address NVARCHAR(100) NOT NULL,
    PRIMARY KEY (person_id, email_address)
);
GO

-- Emergency_Contact table
CREATE TABLE Emergency_Contact (
    person_id INT NOT NULL FOREIGN KEY REFERENCES Person(person_id),
    contact_name NVARCHAR(100) NOT NULL,
    relationship NVARCHAR(50),
    phone_number NVARCHAR(20),
    PRIMARY KEY (person_id, contact_name)
);
GO

-- Visitor table
CREATE TABLE Visitor (
    person_id INT PRIMARY KEY FOREIGN KEY REFERENCES Person(person_id)
);
GO

-- Ranger table
CREATE TABLE Ranger (
    person_id INT PRIMARY KEY FOREIGN KEY REFERENCES Person(person_id)
);
GO

-- Researcher table
CREATE TABLE Researcher (
    person_id INT PRIMARY KEY FOREIGN KEY REFERENCES Person(person_id),
    research_field NVARCHAR(100),
    hire_date DATE,
    salary INT
);
GO

-- Donor table
CREATE TABLE Donor (
    person_id INT PRIMARY KEY FOREIGN KEY REFERENCES Person(person_id),
    anonymity_preference BIT
);
GO

-- National_Park table
CREATE TABLE National_Park (
    park_name NVARCHAR(100) PRIMARY KEY CLUSTERED,
    street NVARCHAR(100),
    city NVARCHAR(50),
    state NVARCHAR(50),
    postal_code NVARCHAR(10),
    establishment_date DATE,
    capacity INT
);
GO

-- Conservation_Project table
CREATE TABLE Conservation_Project (
    project_id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    name NVARCHAR(100),
    start_date DATE,
    budget INT,
    park_name NVARCHAR(100) FOREIGN KEY REFERENCES National_Park(park_name)
);
GO

-- Ranger_Team table
CREATE TABLE Ranger_Team (
    team_id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    focus_area NVARCHAR(100),
    formation_date DATE
);
GO

-- Member_of table
CREATE TABLE Member_of (
    person_id INT FOREIGN KEY REFERENCES Ranger(person_id),
    team_id INT FOREIGN KEY REFERENCES Ranger_Team(team_id),
    start_date DATE,
    status NVARCHAR(20),
    years_of_service INT,
    is_leader BIT,
    PRIMARY KEY (person_id, team_id)
);
GO

-- Operates_in table
CREATE TABLE Operates_in (
    team_id INT FOREIGN KEY REFERENCES Ranger_Team(team_id),
    park_name NVARCHAR(100) FOREIGN KEY REFERENCES National_Park(park_name),
    PRIMARY KEY (team_id, park_name)
);
GO

-- Oversees table
CREATE TABLE Oversees (
    person_id INT FOREIGN KEY REFERENCES Researcher(person_id),
    team_id INT FOREIGN KEY REFERENCES Ranger_Team(team_id),
    report_date DATE,
    report_summary NVARCHAR(MAX),
    PRIMARY KEY (person_id, team_id, report_date)
);
GO

-- Certification table
CREATE TABLE Certification (
    person_id INT FOREIGN KEY REFERENCES Ranger(person_id),
    certification_name NVARCHAR(100),
    PRIMARY KEY (person_id, certification_name)
);
GO

-- Mwntorship table
CREATE TABLE Mentorship (
    mentor_id INT FOREIGN KEY REFERENCES Ranger(person_id),
    mentee_id INT FOREIGN KEY REFERENCES Ranger(person_id),
    mentorship_start_date DATE,
    PRIMARY KEY (mentor_id, mentee_id)
);
GO

-- Program table
CREATE TABLE Program (
    park_name NVARCHAR(100) FOREIGN KEY REFERENCES National_Park(park_name),
    program_name NVARCHAR(100),
    type NVARCHAR(50),
    start_date DATE,
    duration_hours INT,
    PRIMARY KEY CLUSTERED (park_name, program_name)
);
GO

-- Enrolled_in table
CREATE TABLE Enrolled_in (
    person_id INT FOREIGN KEY REFERENCES Visitor(person_id),
    park_name NVARCHAR(100),
    program_name NVARCHAR(100),
    visit_date DATE,
    accessibility_needs NVARCHAR(200),
    PRIMARY KEY (person_id, park_name, program_name),
    FOREIGN KEY (park_name, program_name) REFERENCES Program(park_name, program_name)
);
GO

-- Park_Pass table
CREATE TABLE Park_Pass (
    pass_id INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    type NVARCHAR(50),
    expiration_date DATE,
    person_id INT FOREIGN KEY REFERENCES Visitor(person_id)
);
GO

-- Donation table
CREATE TABLE Donation (
    person_id INT FOREIGN KEY REFERENCES Donor(person_id),
    donation_date DATE,
    amount INT,
    campaign_name NVARCHAR(100),
    PRIMARY KEY (person_id, donation_date, amount)
);
GO

-- Check_Donation. table
CREATE TABLE Check_Donation (
    check_number INT PRIMARY KEY,
    person_id INT,
    donation_date DATE,
    amount INT,
    FOREIGN KEY (person_id, donation_date, amount)
        REFERENCES Donation(person_id, donation_date, amount)
);
GO

-- Card_Donation table
CREATE TABLE Card_Donation (
    card_type NVARCHAR(50),
    last_four_digits INT,
    expiration_date DATE,
    person_id INT,
    donation_date DATE,
    amount INT,
    PRIMARY KEY (person_id, donation_date, amount),
    FOREIGN KEY (person_id, donation_date, amount)
        REFERENCES Donation(person_id, donation_date, amount)
);
GO