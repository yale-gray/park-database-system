-----------------------------------------
-- Query 1: Insert Visitor
-----------------------------------------

CREATE OR ALTER PROCEDURE InsertNewVisitor
    @person_id INT,
    @park_name NVARCHAR(100),
    @program_name NVARCHAR(100),
    @visit_date DATE,
    @accessibility_needs NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input parameters
    IF @person_id IS NULL OR @person_id <= 0
    BEGIN
        RAISERROR('Invalid person_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    IF @park_name IS NULL OR LTRIM(RTRIM(@park_name)) = ''
    BEGIN
        RAISERROR('Invalid park_name: cannot be null or empty.', 16, 1);
        RETURN;
    END

    IF @program_name IS NULL OR LTRIM(RTRIM(@program_name)) = ''
    BEGIN
        RAISERROR('Invalid program_name: cannot be null or empty.', 16, 1);
        RETURN;
    END

    IF @visit_date IS NULL
    BEGIN
        RAISERROR('Invalid visit_date: cannot be null.', 16, 1);
        RETURN;
    END

    -- Ensure the person exists
    IF NOT EXISTS (SELECT 1 FROM Person WHERE person_id = @person_id)
    BEGIN
        RAISERROR('The specified person_id does not exist in the Person table.', 16, 1);
        RETURN;
    END

    -- Ensure the park exists
    IF NOT EXISTS (SELECT 1 FROM National_Park WHERE park_name = @park_name)
    BEGIN
        RAISERROR('The specified park does not exist in the National_Park table.', 16, 1);
        RETURN;
    END

    -- Ensure the program exists under that park
    IF NOT EXISTS (
        SELECT 1 
        FROM Program 
        WHERE park_name = @park_name AND program_name = @program_name
    )
    BEGIN
        RAISERROR('The specified program does not exist for this park.', 16, 1);
        RETURN;
    END

    -- Ensure the person is not already a visitor
    IF EXISTS (SELECT 1 FROM Visitor WHERE person_id = @person_id)
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM Enrolled_in
            WHERE person_id = @person_id 
              AND park_name = @park_name 
              AND program_name = @program_name
        )
        BEGIN
            RAISERROR('This visitor is already enrolled in the specified program.', 16, 1);
            RETURN;
        END
    END

    -- If not already a visitor, insert into Visitor
    IF NOT EXISTS (SELECT 1 FROM Visitor WHERE person_id = @person_id)
        INSERT INTO Visitor (person_id) VALUES (@person_id);

    -- Ensure they aren’t already enrolled in another program on the same day (optional business rule)
    IF EXISTS (
        SELECT 1 
        FROM Enrolled_in 
        WHERE person_id = @person_id AND visit_date = @visit_date
    )
    BEGIN
        RAISERROR('This person already has an enrollment scheduled for the same date.', 16, 1);
        RETURN;
    END

    -- Insert enrollment record
    INSERT INTO Enrolled_in (person_id, park_name, program_name, visit_date, accessibility_needs)
    VALUES (@person_id, @park_name, @program_name, @visit_date, @accessibility_needs);

    -- Return success message
    SELECT CONCAT(
        'Success: Visitor (ID = ', @person_id, 
        ') enrolled in "', @program_name, 
        '" at park "', @park_name, '".'
    ) AS SuccessMessage;
END;
GO

-----------------------------------------
-- Query 2: Insert Ranger
-----------------------------------------

CREATE OR ALTER PROCEDURE InsertNewRanger
    @person_id INT,
    @team_id INT,
    @start_date DATE,
    @status NVARCHAR(20),
    @certifications NVARCHAR(500) -- Comma-separated list
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @person_id IS NULL OR @person_id <= 0
    BEGIN
        RAISERROR('Invalid person_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    IF @team_id IS NULL OR @team_id <= 0
    BEGIN
        RAISERROR('Invalid team_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    IF @start_date IS NULL
    BEGIN
        RAISERROR('Invalid start_date: cannot be null.', 16, 1);
        RETURN;
    END

    IF @status IS NULL OR LTRIM(RTRIM(@status)) = ''
    BEGIN
        RAISERROR('Invalid status: cannot be null or empty.', 16, 1);
        RETURN;
    END

    -- Check existence of person and team
    IF NOT EXISTS (SELECT 1 FROM Person WHERE person_id = @person_id)
    BEGIN
        RAISERROR('Person does not exist in the database.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Ranger_Team WHERE team_id = @team_id)
    BEGIN
        RAISERROR('Ranger team does not exist.', 16, 1);
        RETURN;
    END

    -- Insert into Ranger if not exists
    IF NOT EXISTS (SELECT 1 FROM Ranger WHERE person_id = @person_id)
        INSERT INTO Ranger (person_id) VALUES (@person_id);

    -- Handle certifications (simplified with STRING_SPLIT)
    IF (@certifications IS NOT NULL AND LTRIM(RTRIM(@certifications)) <> '')
    BEGIN
        INSERT INTO Certification (person_id, certification_name)
        SELECT DISTINCT @person_id, LTRIM(RTRIM(value))
        FROM STRING_SPLIT(@certifications, ',')
        WHERE LTRIM(RTRIM(value)) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM Certification 
              WHERE person_id = @person_id 
              AND certification_name = LTRIM(RTRIM(value))
          );
    END

    -- Prevent duplicate team assignment
    IF EXISTS (SELECT 1 FROM Member_of WHERE person_id = @person_id)
    BEGIN
        RAISERROR('This ranger is already assigned to a ranger team.', 16, 1);
        RETURN;
    END

    -- Insert into Member_of
    INSERT INTO Member_of (person_id, team_id, start_date, status, years_of_service, is_leader)
    VALUES (@person_id, @team_id, @start_date, @status, 0, 0);

    -- Return success
    SELECT CONCAT(
        'Success: Ranger (ID=', @person_id,
        ') assigned to team ', @team_id,
        ' with status "', @status, '". Certifications added if provided.'
    ) AS SuccessMessage;
END;
GO

-----------------------------------------
-- Query 3: Insert Ranger Team
-----------------------------------------

CREATE OR ALTER PROCEDURE InsertNewRangerTeam
    @focus_area NVARCHAR(100),
    @formation_date DATE,
    @leader_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate inputs
    IF @focus_area IS NULL OR LTRIM(RTRIM(@focus_area)) = ''
    BEGIN
        RAISERROR('Invalid focus_area: cannot be null or empty.', 16, 1);
        RETURN;
    END

    IF @formation_date IS NULL
    BEGIN
        RAISERROR('Invalid formation_date: cannot be null.', 16, 1);
        RETURN;
    END

    IF @leader_id IS NULL OR @leader_id <= 0
    BEGIN
        PRINT 'No valid leader ID provided. Proceeding with NULL leader.';
        SET @leader_id = NULL;
    END

    -- Prevent duplicate focus area names
    IF EXISTS (SELECT 1 FROM Ranger_Team WHERE focus_area = @focus_area)
    BEGIN
        RAISERROR('A ranger team with this focus area already exists.', 16, 1);
        RETURN;
    END

    -- Insert new ranger team
    INSERT INTO Ranger_Team (focus_area, formation_date)
    VALUES (@focus_area, @formation_date);

    DECLARE @team_id INT = (SELECT MAX(team_id) FROM Ranger_Team);

    SELECT CONCAT(
        'Success: New ranger team (ID=', @team_id, 
        ') created for focus area "', @focus_area, 
        '". Leader assignment skipped.'
    ) AS SuccessMessage;
END;
GO

-----------------------------------------
-- Query 4: Insert New Donation from a Donor
-----------------------------------------

CREATE OR ALTER PROCEDURE InsertNewDonation
    @person_id INT,
    @donation_date DATE,
    @amount DECIMAL(12, 2),
    @campaign_name NVARCHAR(100),
    @check_number INT = NULL,
    @card_type NVARCHAR(20) = NULL,
    @last_four_digits INT = NULL,
    @expiration_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input parameters
    IF @person_id IS NULL OR @person_id <= 0
    BEGIN
        RAISERROR('Invalid person_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    IF @donation_date IS NULL
    BEGIN
        RAISERROR('Invalid donation_date: cannot be null.', 16, 1);
        RETURN;
    END

    IF @amount IS NULL OR @amount <= 0
    BEGIN
        RAISERROR('Invalid amount: must be greater than zero.', 16, 1);
        RETURN;
    END

    IF @campaign_name IS NULL OR LTRIM(RTRIM(@campaign_name)) = ''
    BEGIN
        RAISERROR('Invalid campaign_name: cannot be null or empty.', 16, 1);
        RETURN;
    END

    -- Ensure donor exists
    IF NOT EXISTS (SELECT 1 FROM Donor WHERE person_id = @person_id)
    BEGIN
        RAISERROR('Donor does not exist. The person must be registered as a donor first.', 16, 1);
        RETURN;
    END

    -- Prevent duplicate donations on the same date and amount
    IF EXISTS (
        SELECT 1 FROM Donation
        WHERE person_id = @person_id AND donation_date = @donation_date AND amount = @amount
    )
    BEGIN
        RAISERROR('Duplicate donation detected for this donor with the same date and amount.', 16, 1);
        RETURN;
    END

    -- Insert into Donation table
    INSERT INTO Donation (person_id, donation_date, amount, campaign_name)
    VALUES (@person_id, @donation_date, @amount, @campaign_name);

    -- Determine payment method (Check or Card)
    IF @check_number IS NOT NULL
    BEGIN
        INSERT INTO Check_Donation (check_number, person_id, donation_date, amount)
        VALUES (@check_number, @person_id, @donation_date, @amount);
    END
    ELSE IF @card_type IS NOT NULL AND @last_four_digits IS NOT NULL AND @expiration_date IS NOT NULL
    BEGIN
        INSERT INTO Card_Donation (card_type, last_four_digits, expiration_date, person_id, donation_date, amount)
        VALUES (@card_type, @last_four_digits, @expiration_date, @person_id, @donation_date, @amount);
    END
    ELSE
    BEGIN
        RAISERROR('Invalid payment method: provide either check_number or full card details.', 16, 1);
        RETURN;
    END

    -- Return success message
    SELECT CONCAT(
        'Success: Donation of $', @amount, ' from donor (ID=', @person_id, 
        ') added to campaign "', @campaign_name, '".'
    ) AS SuccessMessage;
END;
GO


-----------------------------------------
-- Query 5: Insert Researcher
-----------------------------------------

CREATE OR ALTER PROCEDURE InsertNewResearcher
    @person_id INT,
    @research_field NVARCHAR(100),
    @hire_date DATE,
    @salary INT,
    @team_ids NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @person_id IS NULL OR @person_id <= 0
    BEGIN
        RAISERROR('Invalid person_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    IF @research_field IS NULL OR LTRIM(RTRIM(@research_field)) = ''
    BEGIN
        RAISERROR('Invalid research_field: cannot be null or empty.', 16, 1);
        RETURN;
    END

    IF @hire_date IS NULL
    BEGIN
        RAISERROR('Invalid hire_date: cannot be null.', 16, 1);
        RETURN;
    END

    IF @salary IS NULL OR @salary <= 0
    BEGIN
        RAISERROR('Invalid salary: must be greater than zero.', 16, 1);
        RETURN;
    END

    IF @team_ids IS NULL OR LTRIM(RTRIM(@team_ids)) = ''
    BEGIN
        RAISERROR('Invalid team_ids: at least one team ID must be provided.', 16, 1);
        RETURN;
    END

    -- Ensure person exists
    IF NOT EXISTS (SELECT 1 FROM Person WHERE person_id = @person_id)
    BEGIN
        RAISERROR('Specified person does not exist in the Person table.', 16, 1);
        RETURN;
    END

    -- Prevent duplicate researcher entry
    IF EXISTS (SELECT 1 FROM Researcher WHERE person_id = @person_id)
    BEGIN
        RAISERROR('This person is already registered as a Researcher.', 16, 1);
        RETURN;
    END

    -- Insert researcher record
    INSERT INTO Researcher (person_id, research_field, hire_date, salary)
    VALUES (@person_id, @research_field, @hire_date, @salary);

    -- Associate researcher with one or more ranger teams
    DECLARE @team_id NVARCHAR(20);
    DECLARE @pos INT;

    WHILE LEN(@team_ids) > 0
    BEGIN
        SET @pos = CHARINDEX(',', @team_ids);
        IF @pos > 0
        BEGIN
            SET @team_id = LTRIM(RTRIM(LEFT(@team_ids, @pos - 1)));
            SET @team_ids = SUBSTRING(@team_ids, @pos + 1, LEN(@team_ids) - @pos);
        END
        ELSE
        BEGIN
            SET @team_id = LTRIM(RTRIM(@team_ids));
            SET @team_ids = '';
        END

        IF NOT EXISTS (SELECT 1 FROM Ranger_Team WHERE team_id = @team_id)
        BEGIN
            RAISERROR('One or more provided team IDs do not exist in Ranger_Team.', 16, 1);
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM Oversees
            WHERE person_id = @person_id AND team_id = @team_id
        )
        BEGIN
            RAISERROR('Researcher is already overseeing one of the provided teams.', 16, 1);
            RETURN;
        END

        INSERT INTO Oversees (person_id, team_id, report_date, report_summary)
        VALUES (@person_id, @team_id, @hire_date, 'Initial oversight report pending.');
    END

    -- Return success message
    SELECT CONCAT(
        'Success: Researcher (ID=', @person_id, 
        ') added and assigned to provided ranger team(s).'
    ) AS SuccessMessage;
END;
GO


-----------------------------------------
-- Query 6: Insert Report
-----------------------------------------

CREATE OR ALTER PROCEDURE InsertNewReport
    @person_id INT,
    @team_id INT,
    @report_date DATE,
    @report_summary NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @person_id IS NULL OR @person_id <= 0
    BEGIN
        RAISERROR('Invalid person_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    IF @team_id IS NULL OR @team_id <= 0
    BEGIN
        RAISERROR('Invalid team_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    IF @report_date IS NULL
    BEGIN
        RAISERROR('Invalid report_date: cannot be null.', 16, 1);
        RETURN;
    END

    IF @report_summary IS NULL OR LTRIM(RTRIM(@report_summary)) = ''
    BEGIN
        RAISERROR('Invalid report_summary: cannot be null or empty.', 16, 1);
        RETURN;
    END

    -- Ensure researcher exists
    IF NOT EXISTS (SELECT 1 FROM Researcher WHERE person_id = @person_id)
    BEGIN
        RAISERROR('The specified researcher does not exist in the Researcher table.', 16, 1);
        RETURN;
    END

    -- Ensure ranger team exists and is overseen by the researcher
    IF NOT EXISTS (SELECT 1 FROM Ranger_Team WHERE team_id = @team_id)
    BEGIN
        RAISERROR('The specified ranger team does not exist in the Ranger_Team table.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Oversees WHERE person_id = @person_id AND team_id = @team_id)
    BEGIN
        RAISERROR('This researcher does not oversee the specified ranger team.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Oversees WHERE person_id = @person_id AND team_id = @team_id AND report_date = @report_date)
    BEGIN
        RAISERROR('A report for this ranger team and researcher already exists on this date.', 16, 1);
        RETURN;
    END

    -- Insert report
    INSERT INTO Oversees (person_id, team_id, report_date, report_summary)
    VALUES (@person_id, @team_id, @report_date, @report_summary);
   
    -- Return success message
    SELECT CONCAT(
        'Success: Report submitted by ranger team (ID=', @team_id, 
        ') to researcher (ID=', @person_id, 
        ') on ', CONVERT(VARCHAR(10), @report_date, 120), '.'
    ) AS SuccessMessage;
END;
GO


-----------------------------------------
-- Query 7: Insert Program
-----------------------------------------

CREATE OR ALTER PROCEDURE InsertNewProgram
    @park_name NVARCHAR(100),
    @program_name NVARCHAR(100),
    @type NVARCHAR(50),
    @start_date DATE,
    @duration_hours INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @park_name IS NULL OR LTRIM(RTRIM(@park_name)) = ''
    BEGIN
        RAISERROR('Invalid park_name: cannot be null or empty.', 16, 1);
        RETURN;
    END

    IF @program_name IS NULL OR LTRIM(RTRIM(@program_name)) = ''
    BEGIN
        RAISERROR('Invalid program_name: cannot be null or empty.', 16, 1);
        RETURN;
    END

    IF @type IS NULL OR LTRIM(RTRIM(@type)) = ''
    BEGIN
        RAISERROR('Invalid type: must be specified.', 16, 1);
        RETURN;
    END

    IF @start_date IS NULL
    BEGIN
        RAISERROR('Invalid start_date: cannot be null.', 16, 1);
        RETURN;
    END

    IF @duration_hours IS NULL OR @duration_hours <= 0
    BEGIN
        RAISERROR('Invalid duration_hours: must be greater than zero.', 16, 1);
        RETURN;
    END

    -- Ensure park exists
    IF NOT EXISTS (SELECT 1 FROM National_Park WHERE park_name = @park_name)
    BEGIN
        RAISERROR('The specified park does not exist in the National_Park table.', 16, 1);
        RETURN;
    END

    -- Prevent duplicate program names within the same park
    IF EXISTS (SELECT 1 FROM Program WHERE park_name = @park_name AND program_name = @program_name)
    BEGIN
        RAISERROR('A program with this name already exists for the specified park.', 16, 1);
        RETURN;
    END

    -- Ensure start_date is not in the past
    IF @start_date < GETDATE()
    BEGIN
        RAISERROR('Invalid start_date: program cannot start in the past.', 16, 1);
        RETURN;
    END

    -- Insert new program
    INSERT INTO Program (park_name, program_name, type, start_date, duration_hours)
    VALUES (@park_name, @program_name, @type, @start_date, @duration_hours);

    -- Return success message
    SELECT CONCAT(
        'Success: Program "', @program_name, '" added to park "', @park_name, 
        '" with start date ', CONVERT(VARCHAR(10), @start_date, 120), 
        ' and duration ', @duration_hours, ' hours.'
    ) AS SuccessMessage;
END;
GO

-----------------------------------------
-- Query 8: Retrieve Emergency Contacts
-----------------------------------------

CREATE OR ALTER PROCEDURE RetrieveEmergencyContacts
    @person_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @person_id IS NULL OR @person_id <= 0
    BEGIN
        RAISERROR('Invalid person_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    -- Ensure person exists
    IF NOT EXISTS (SELECT 1 FROM Person WHERE person_id = @person_id)
    BEGIN
        RAISERROR('The specified person does not exist in the Person table.', 16, 1);
        RETURN;
    END

    -- Ensure emergency contacts exist for the person
    IF NOT EXISTS (SELECT 1 FROM Emergency_Contact WHERE person_id = @person_id)
    BEGIN
        RAISERROR('This person does not have any emergency contacts on record.', 16, 1);
        RETURN;
    END

    -- Retrieve emergency contacts
    SELECT 
        ec.contact_name AS [Contact Name],
        ec.relationship AS [Relationship],
        ec.phone_number AS [Phone Number]
    FROM Emergency_Contact ec
    WHERE ec.person_id = @person_id
    ORDER BY ec.contact_name;
END;
GO


-----------------------------------------
-- Query 9: Retrieve Enrolled Visitors
-----------------------------------------

CREATE OR ALTER PROCEDURE RetrieveEnrolledVisitors
    @park_name NVARCHAR(100),
    @program_name NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @park_name IS NULL OR LTRIM(RTRIM(@park_name)) = ''
    BEGIN
        RAISERROR('Invalid park_name: cannot be null or empty.', 16, 1);
        RETURN;
    END

    IF @program_name IS NULL OR LTRIM(RTRIM(@program_name)) = ''
    BEGIN
        RAISERROR('Invalid program_name: cannot be null or empty.', 16, 1);
        RETURN;
    END

    -- Ensure park exists
    IF NOT EXISTS (SELECT 1 FROM National_Park WHERE park_name = @park_name)
    BEGIN
        RAISERROR('The specified park does not exist in the National_Park table.', 16, 1);
        RETURN;
    END

    -- Ensure program exists for the park
    IF NOT EXISTS (SELECT 1 FROM Program WHERE park_name = @park_name AND program_name = @program_name)
    BEGIN
        RAISERROR('The specified program does not exist for the given park.', 16, 1);
        RETURN;
    END

    -- Ensure there are enrolled visitors
    IF NOT EXISTS (SELECT 1 FROM Enrolled_in WHERE park_name = @park_name AND program_name = @program_name)
    BEGIN
        RAISERROR('No visitors are currently enrolled in this program.', 16, 1);
        RETURN;
    END

    -- Retrieve enrolled visitors
    SELECT 
        p.person_id AS [Visitor ID],
        CONCAT(p.firstname, ' ', p.lastname) AS [Visitor Name],
        e.visit_date AS [Visit Date],
        e.accessibility_needs AS [Accessibility Needs]
    FROM Enrolled_in e
    INNER JOIN Person p ON e.person_id = p.person_id
    WHERE e.park_name = @park_name AND e.program_name = @program_name
    ORDER BY p.lastname, p.firstname;
END;
GO


-----------------------------------------
-- Query 10: Retrieve Park Programs After Date
-----------------------------------------

CREATE OR ALTER PROCEDURE RetrieveParkProgramsAfterDate
    @park_name NVARCHAR(100),
    @given_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @park_name IS NULL OR LTRIM(RTRIM(@park_name)) = ''
    BEGIN
        RAISERROR('Invalid park_name: cannot be null or empty.', 16, 1);
        RETURN;
    END

    IF @given_date IS NULL
    BEGIN
        RAISERROR('Invalid given_date: cannot be null.', 16, 1);
        RETURN;
    END

    -- Ensure park exists
    IF NOT EXISTS (SELECT 1 FROM National_Park WHERE park_name = @park_name)
    BEGIN
        RAISERROR('The specified park does not exist in the National_Park table.', 16, 1);
        RETURN;
    END

    -- Ensure there are programs for the park
    IF NOT EXISTS (SELECT 1 FROM Program WHERE park_name = @park_name)
    BEGIN
        RAISERROR('No programs exist for the specified park.', 16, 1);
        RETURN;
    END

    -- Ensure there are programs after the given date
    IF NOT EXISTS (SELECT 1 FROM Program WHERE park_name = @park_name AND start_date > @given_date)
    BEGIN
        RAISERROR('No programs found that start after the specified date.', 16, 1);
        RETURN;
    END

    -- Retrieve programs starting after the given date
    SELECT 
        program_name AS [Program Name],
        type AS [Program Type],
        start_date AS [Start Date],
        duration_hours AS [Duration (Hours)]
    FROM Program
    WHERE park_name = @park_name AND start_date > @given_date
    ORDER BY start_date ASC;
END;
GO


-----------------------------------------
-- Query 11: Retrieve Anonymous Donations
-----------------------------------------

CREATE OR ALTER PROCEDURE RetrieveAnonymousDonationsSummary
    @month INT,
    @year INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @month IS NULL OR @month < 1 OR @month > 12
    BEGIN
        RAISERROR('Invalid month: must be between 1 and 12.', 16, 1);
        RETURN;
    END

    IF @year IS NULL OR @year < 1900
    BEGIN
        RAISERROR('Invalid year: must be a valid year greater than 1900.', 16, 1);
        RETURN;
    END

    -- Ensure there are anonymous donors
    IF NOT EXISTS (SELECT 1 FROM Donor WHERE anonymity_preference = 1)
    BEGIN
        RAISERROR('No anonymous donors exist in the Donor table.', 16, 1);
        RETURN;
    END

    -- Ensure there are anonymous donations for the specified month and year
    IF NOT EXISTS (
        SELECT 1
        FROM Donation d
        INNER JOIN Donor dn ON d.person_id = dn.person_id
        WHERE dn.anonymity_preference = 1
        AND MONTH(d.donation_date) = @month
        AND YEAR(d.donation_date) = @year
    )
    BEGIN
        RAISERROR('No anonymous donations found for the specified month and year.', 16, 1);
        RETURN;
    END

    -- Retrieve summary of anonymous donations
    SELECT 
        YEAR(d.donation_date) AS [Donation Year],
        MONTH(d.donation_date) AS [Donation Month],
        SUM(d.amount) AS [Total Donation],
        AVG(d.amount) AS [Average Donation],
        COUNT(*) AS [Number of Donations]
    FROM Donation d
    INNER JOIN Donor dn ON d.person_id = dn.person_id
    WHERE dn.anonymity_preference = 1
      AND MONTH(d.donation_date) = @month
      AND YEAR(d.donation_date) = @year
    GROUP BY YEAR(d.donation_date), MONTH(d.donation_date)
    ORDER BY [Total Donation] DESC;
END;
GO

-----------------------------------------
-- Query 12: Retrieve Rangers in Team
-----------------------------------------

CREATE OR ALTER PROCEDURE RetrieveRangersInTeam
    @team_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate parameters
    IF @team_id IS NULL OR @team_id <= 0
    BEGIN
        RAISERROR('Invalid team_id: must be a positive integer.', 16, 1);
        RETURN;
    END

    -- Ensure ranger team exists
    IF NOT EXISTS (SELECT 1 FROM Ranger_Team WHERE team_id = @team_id)
    BEGIN
        RAISERROR('The specified ranger team does not exist in the Ranger_Team table.', 16, 1);
        RETURN;
    END

    -- Ensure there are rangers assigned to the team
    IF NOT EXISTS (SELECT 1 FROM Member_of WHERE team_id = @team_id)
    BEGIN
        RAISERROR('No rangers are currently assigned to this team.', 16, 1);
        RETURN;
    END

    -- Retrieve rangers in the specified team
    SELECT 
        p.person_id AS [Ranger ID],
        CONCAT(p.firstname, ' ', p.lastname) AS [Ranger Name],
        ISNULL(c.certification_name, 'None') AS [Certification],
        m.years_of_service AS [Years of Service],
        CASE WHEN m.is_leader = 1 THEN 'Leader' ELSE 'Member' END AS [Role]
    FROM Member_of m
    INNER JOIN Person p ON m.person_id = p.person_id
    LEFT JOIN Certification c ON p.person_id = c.person_id
    WHERE m.team_id = @team_id
    ORDER BY [Role] DESC, [Years of Service] DESC, [Ranger Name];
END;
GO


-----------------------------------------
-- Query 13: Retrieve All Individuals
-----------------------------------------

CREATE OR ALTER PROCEDURE RetrieveAllIndividuals
AS
BEGIN
    SET NOCOUNT ON;

    -- Ensure there are individuals in the Person table
    IF NOT EXISTS (SELECT 1 FROM Person)
    BEGIN
        RAISERROR('No individuals exist in the Person table.', 16, 1);
        RETURN;
    END

    -- Retrieve all individuals with contact details and subscription status
    SELECT 
        p.person_id AS [Person ID],
        CONCAT(p.firstname, ' ', p.lastname) AS [Full Name],
        ISNULL(ph.phone_number, 'N/A') AS [Phone Number],
        ISNULL(e.email_address, 'N/A') AS [Email Address],
        CASE 
            WHEN p.subscribed = 1 THEN 'Subscribed'
            ELSE 'Not Subscribed'
        END AS [Newsletter Status],
        p.city AS [City],
        p.state AS [State]
    FROM Person p
    LEFT JOIN Phone ph ON p.person_id = ph.person_id
    LEFT JOIN Email e ON p.person_id = e.person_id
    ORDER BY p.lastname, p.firstname;
END;
GO


-----------------------------------------
-- Query 14: Update Researchers Salary
-----------------------------------------

CREATE OR ALTER PROCEDURE UpdateResearchersSalary
AS
BEGIN
    SET NOCOUNT ON;

    -- Ensure there are researchers in the Researcher table
    IF NOT EXISTS (SELECT 1 FROM Researcher)
    BEGIN
        RAISERROR('No researchers found in the Researcher table.', 16, 1);
        RETURN;
    END

    -- Ensure there are researchers overseeing more than one ranger team
    IF NOT EXISTS (
        SELECT person_id
        FROM Oversees
        GROUP BY person_id
        HAVING COUNT(DISTINCT team_id) > 1
    )
    BEGIN
        RAISERROR('No researchers oversee more than one ranger team.', 16, 1);
        RETURN;
    END

    -- Update salary by 3 percent for researchers overseeing more than one ranger team
    UPDATE Researcher
    SET salary = salary * 1.03
    WHERE person_id IN (
        SELECT person_id
        FROM Oversees
        GROUP BY person_id
        HAVING COUNT(DISTINCT team_id) > 1
    );

    -- Return updated researchers with new salaries
    SELECT 
        r.person_id AS [Researcher ID],
        CONCAT(p.firstname, ' ', p.lastname) AS [Researcher Name],
        r.salary AS [New Salary]
    FROM Researcher r
    INNER JOIN Person p ON r.person_id = p.person_id
    WHERE r.person_id IN (
        SELECT person_id
        FROM Oversees
        GROUP BY person_id
        HAVING COUNT(DISTINCT team_id) > 1
    );
END;
GO

-----------------------------------------
-- Query 15: Delete Inactive Visitors
-----------------------------------------

CREATE   PROCEDURE DeleteInactiveVisitors
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete park passes for visitors who are not enrolled and whose passes are expired
    DELETE FROM Park_Pass
    WHERE person_id IN (
        SELECT v.person_id
        FROM Visitor v
        LEFT JOIN Enrolled_in e ON v.person_id = e.person_id
        WHERE e.person_id IS NULL
          AND v.person_id IN (
              SELECT person_id FROM Park_Pass WHERE expiration_date < GETDATE()
          )
    );

    -- Delete visitors who now have no enrollments and no passes
    DELETE FROM Visitor
    WHERE person_id NOT IN (SELECT person_id FROM Enrolled_in)
      AND person_id NOT IN (SELECT person_id FROM Park_Pass);

    DECLARE @deleted INT = @@ROWCOUNT;

    SELECT CONCAT(@deleted, ' visitor(s) deleted who had expired passes and no enrollments.') AS ResultMessage;
END;
GO
