import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Statement;
import java.util.Scanner;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;

public class Gray_Yale_IP_Task5b {
    // Database credentials
    final static String HOSTNAME = "gray0188.database.windows.net";
    final static String DBNAME = "cs-dsa-4513-sql-db";
    final static String USERNAME = "gray0188";
    final static String PASSWORD = "OkcThunder2025";
    // Database connection string
    final static String URL =
        String.format("jdbc:sqlserver://%s:1433;database=%s;user=%s;password=%s;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;",
            HOSTNAME, DBNAME, USERNAME, PASSWORD);
    // User input prompt
    final static String PROMPT =
    		"1) Insert New Visitor and Associate with Park Program\n" +
		    "2) Insert New Ranger and Assign to Team\n" +
		    "3) Insert New Ranger Team and Set Leader\n" +
		    "4) Insert New Donation from Donor\n" +
		    "5) Insert New Researcher and Associate with Teams\n" +
		    "6) Insert New Report from Ranger Team to Researcher\n" +
		    "7) Insert New Park Program for a Park\n" +
		    "8) Retrieve Emergency Contacts for a Person\n" +
		    "9) Retrieve Visitors Enrolled in a Specific Park Program\n" +
		    "10) Retrieve Park Programs Starting After a Given Date\n" +
		    "11) Retrieve Total and Average Anonymous Donations\n" +
		    "12) Retrieve Rangers in a Team with Certifications and Roles\n" +
		    "13) Retrieve All Individuals (Mailing List)\n" +
		    "14) Update Salary of Researchers Overseeing Multiple Teams\n" +
		    "15) Delete Inactive Visitors with Expired Park Passes\n" +
		    "16) Import New Ranger Teams from File\n" +
		    "17) Export Mailing Addresses to File\n" +
		    "18) Quit\n";

    public static void main(String[] args) throws SQLException {
    	
    	System.out.println("WELCOME TO THE NATIONAL PARK SERVICE SYSTEM DATABASE");
        
        final Scanner sc = new Scanner(System.in); // Scanner is used to collect the user input
        
        String option = ""; // Initialize user option selection as nothing
        
        while (!option.equals("18")) { // Loop for option selection
        
        	System.out.println(PROMPT); // Print the available options
            
        	option = sc.next(); // Read in the user option selection
            
        	switch (option) {
	            case "1" -> InsertNewVisitor(sc); // Query 1: Insert New Visitor
	            case "2" -> InsertNewRanger(sc); // Query 2: Insert New Ranger
	            case "3" -> InsertNewRangerTeam(sc); // Query 3: Insert New Ranger Team
	            case "4" -> InsertNewDonation(sc); // Query 4: Insert New Donation
	            case "5" -> InsertNewResearcher(sc); // Query 5: Insert New Researcher
	            case "6" -> InsertNewReport(sc); // Query 6: Insert New Report
	            case "7" -> InsertNewProgram(sc); // Query 7: Insert New Park Program
	            case "8" -> RetrieveEmergencyContacts(sc); // Query 8: Retrieve Emergency Contacts
	            case "9" -> RetrieveEnrolledVisitors(sc); // Query 9: Retrieve Enrolled Visitors
	            case "10" -> RetrieveParkProgramsAfterDate(sc); // Query 10: Retrieve Park Programs After Date
	            case "11" -> RetrieveAnonymousDonationsSummary(sc); // Query 11: Retrieve Anonymous Donations Summary
	            case "12" -> RetrieveRangersInTeam(sc); // Query 12: Retrieve Rangers in a Team
	            case "13" -> RetrieveMailingList(); // Query 13: Retrieve All Individuals (Mailing List)
	            case "14" -> UpdateResearchersSalary(); // Query 14: Update Salary of Researchers
	            case "15" -> DeleteInactiveVisitors(); // Query 15: Delete Inactive Visitors
	            case "16" -> ImportNewTeamsFromFile(sc); // Query 16: Import New Ranger Teams from File
	            case "17" -> ExportMailingAddressesToFile(sc); // Query 17: Export Mailing Addresses to File
	            case "18" -> System.out.println("Exiting program."); // Quit
	            default -> System.out.println("Invalid option. Please try again.");
        	}
        }
        sc.close(); // Close the scanner before exiting the application
    }
    
 // Query 1 — Insert a new visitor and associate them with one or more park programs
    private static void InsertNewVisitor(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter Visitor ID (Person ID): ");
            int personId = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter park name: ");
            String parkName = sc.nextLine();

            System.out.print("Enter program name: ");
            String programName = sc.nextLine();

            System.out.print("Enter visit date (YYYY-MM-DD): ");
            String visitDate = sc.nextLine();

            System.out.print("Enter accessibility needs (or 'None'): ");
            String accessibility = sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call InsertNewVisitor(?,?,?,?,?)}")) {
                cs.setInt(1, personId);
                cs.setString(2, parkName);
                cs.setString(3, programName);
                cs.setString(4, visitDate);
                cs.setString(5, accessibility);

                cs.execute();

                System.out.println("Visitor inserted successfully and associated with program");
            }

        } catch (SQLException e) {
            System.out.println("Error inserting visitor: " + e.getMessage());
        }
    }
    
    // Query 2: Insert New Ranger
    private static void InsertNewRanger(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter Ranger person ID: ");
            int personId = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter team ID: ");
            int teamId = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter start date (YYYY-MM-DD): ");
            String startDate = sc.nextLine();

            System.out.print("Enter status (Active/Inactive): ");
            String status = sc.nextLine();

            System.out.print("Enter certifications (comma-separated or leave blank): ");
            String certifications = sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call InsertNewRanger(?,?,?,?,?)}")) {
                cs.setInt(1, personId);
                cs.setInt(2, teamId);
                cs.setString(3, startDate);
                cs.setString(4, status);
                cs.setString(5, certifications);

                cs.execute();
                System.out.println("Ranger inserted successfully and assigned to team.");
            }

        } catch (SQLException e) {
            System.out.println("Error inserting ranger: " + e.getMessage());
        }
    }
    
    // Query 3: Insert New Ranger Team
    private static void InsertNewRangerTeam(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter focus area: ");
            sc.nextLine();
            String focusArea = sc.nextLine();

            System.out.print("Enter formation date (YYYY-MM-DD): ");
            String formationDate = sc.nextLine();

            System.out.print("Enter leader ID: ");
            int leaderId = sc.nextInt();
            sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call InsertNewRangerTeam(?,?,?)}")) {
                cs.setString(1, focusArea);
                cs.setString(2, formationDate);
                cs.setInt(3, leaderId);

                cs.execute();
                System.out.println("Ranger team inserted successfully.");
            }

        } catch (SQLException e) {
            System.out.println("Error inserting ranger team: " + e.getMessage());
        }
    }
    
    // Query 4: Insert New Donation
    private static void InsertNewDonation(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter donor person ID: ");
            int personId = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter donation date (YYYY-MM-DD): ");
            String donationDate = sc.nextLine();

            System.out.print("Enter amount: ");
            double amount = sc.nextDouble();
            sc.nextLine();

            System.out.print("Enter campaign name: ");
            String campaignName = sc.nextLine();

            System.out.print("Enter check number (or 0 if not applicable): ");
            int checkNumber = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter card type (or 'NULL'): ");
            String cardType = sc.nextLine();

            System.out.print("Enter last four digits (or 0 if not applicable): ");
            int lastFour = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter expiration date (YYYY-MM-DD or leave blank): ");
            String expDate = sc.nextLine();
            if (expDate.isBlank()) expDate = null;
            // Prepare and execute stored procedur
            try (CallableStatement cs = conn.prepareCall("{call InsertNewDonation(?,?,?,?,?,?,?,?)}")) {
                cs.setInt(1, personId);
                cs.setString(2, donationDate);
                cs.setDouble(3, amount);
                cs.setString(4, campaignName);
                cs.setInt(5, checkNumber);
                cs.setString(6, cardType);
                cs.setInt(7, lastFour);
                cs.setString(8, expDate);

                cs.execute();
                System.out.println("Donation inserted successfully.");
            }

        } catch (SQLException e) {
            System.out.println("Error inserting donation: " + e.getMessage());
        }
    }
    
    // Query 5: Insert New Researcher
    private static void InsertNewResearcher(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect users input
            System.out.print("Enter Researcher person ID: ");
            int personId = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter research field: ");
            String researchField = sc.nextLine();

            System.out.print("Enter hire date (YYYY-MM-DD): ");
            String hireDate = sc.nextLine();

            System.out.print("Enter salary: ");
            int salary = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter associated team IDs (comma-separated): ");
            String teamIds = sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call InsertNewResearcher(?,?,?,?,?)}")) {
                cs.setInt(1, personId);
                cs.setString(2, researchField);
                cs.setString(3, hireDate);
                cs.setInt(4, salary);
                cs.setString(5, teamIds);

                cs.execute();
                System.out.println("Researcher inserted successfully and assigned to teams.");
            }

        } catch (SQLException e) {
            System.out.println("Error inserting researcher: " + e.getMessage());
        }
    }
    
    // Query 6: Insert New Report
    private static void InsertNewReport(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter researcher ID: ");
            int researcherId = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter ranger team ID: ");
            int teamId = sc.nextInt();
            sc.nextLine();

            System.out.print("Enter report date (YYYY-MM-DD): ");
            String reportDate = sc.nextLine();

            System.out.print("Enter report summary: ");
            String summary = sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call InsertNewReport(?,?,?,?)}")) {
                cs.setInt(1, researcherId);
                cs.setInt(2, teamId);
                cs.setString(3, reportDate);
                cs.setString(4, summary);

                cs.execute();
                System.out.println("Report inserted successfully.");
            }

        } catch (SQLException e) {
            System.out.println("Error inserting report: " + e.getMessage());
        }
    }
    
    // Query 7: Insert New Program
    private static void InsertNewProgram(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter park name: ");
            sc.nextLine();
            String parkName = sc.nextLine();

            System.out.print("Enter program name: ");
            String programName = sc.nextLine();

            System.out.print("Enter type: ");
            String type = sc.nextLine();

            System.out.print("Enter start date (YYYY-MM-DD): ");
            String startDate = sc.nextLine();

            System.out.print("Enter duration in hours: ");
            int duration = sc.nextInt();
            sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call InsertNewProgram(?,?,?,?,?)}")) {
                cs.setString(1, parkName);
                cs.setString(2, programName);
                cs.setString(3, type);
                cs.setString(4, startDate);
                cs.setInt(5, duration);

                cs.execute();
                System.out.println("Park program inserted successfully.");
            }

        } catch (SQLException e) {
            System.out.println("Error inserting program: " + e.getMessage());
        }
    }
    
    // Query 8: Retrieve Emergency Contacts
    private static void RetrieveEmergencyContacts(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter person ID: ");
            int personId = sc.nextInt();
            sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call RetrieveEmergencyContacts(?)}")) {
                cs.setInt(1, personId);

                boolean hasResult = cs.execute();

                // Process result set
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        System.out.println("\n--- Emergency Contacts ---");
                        // Print the header
                        System.out.printf("%-20s %-15s %-15s%n", "Contact Name", "Relationship", "Phone Number");
                        // Print the data
                        while (rs.next()) {
                            String name = rs.getString("Contact Name");
                            String relation = rs.getString("Relationship");
                            String phone = rs.getString("Phone Number");
                            System.out.printf("%-20s %-15s %-15s%n", name, relation, phone);
                        }
                    }
                } else {
                    System.out.println("No contacts found for this person.");
                }

            }

        } catch (SQLException e) {
            System.out.println("Error retrieving emergency contacts: " + e.getMessage());
        }
    }
    
    // Query 9: Retrieve Enrolled Visitors
    private static void RetrieveEnrolledVisitors(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter park name: ");
            sc.nextLine();
            String parkName = sc.nextLine();

            System.out.print("Enter program name: ");
            String programName = sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call RetrieveEnrolledVisitors(?,?)}")) {
                cs.setString(1, parkName);
                cs.setString(2, programName);

                boolean hasResult = cs.execute();

                // Process result set
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        System.out.println("\n--- Enrolled Visitors ---");
                        // Print the header
                        System.out.printf("%-10s %-25s %-15s %-25s%n", "Visitor ID", "Visitor Name", "Visit Date", "Accessibility Needs");
                        // Print the data
                        while (rs.next()) {
                            int id = rs.getInt("Visitor ID");
                            String name = rs.getString("Visitor Name");
                            String date = rs.getString("Visit Date");
                            String access = rs.getString("Accessibility Needs");
                            System.out.printf("%-10d %-25s %-15s %-25s%n", id, name, date, access);
                        }
                    }
                } else {
                    System.out.println("No enrolled visitors found for the specified program.");
                }

            }

        } catch (SQLException e) {
            System.out.println("Error retrieving enrolled visitors: " + e.getMessage());
        }
    }
    
    // Query 10: Retrieve Park Programs after Date
    private static void RetrieveParkProgramsAfterDate(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter park name: ");
            sc.nextLine();
            String parkName = sc.nextLine();

            System.out.print("Enter comparison date (YYYY-MM-DD): ");
            String date = sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call RetrieveParkProgramsAfterDate(?,?)}")) {
                cs.setString(1, parkName);
                cs.setString(2, date);

                boolean hasResult = cs.execute();

                // Process result set
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        System.out.println("\n--- Park Programs After " + date + " ---");
                        // Print the header
                        System.out.printf("%-25s %-20s %-15s %-15s%n",  "Program Name", "Program Type", "Start Date", "Duration (Hours)");
                        // Print the data
                        while (rs.next()) {
                            String progName = rs.getString("Program Name");
                            String type = rs.getString("Program Type");
                            String start = rs.getString("Start Date");
                            int duration = rs.getInt("Duration (Hours)");
                            System.out.printf("%-25s %-20s %-15s %-15d%n", progName, type, start, duration);
                        }
                    }
                } else {
                    System.out.println("No programs found that start after the given date.");
                }

            }

        } catch (SQLException e) {
            System.out.println("Error retrieving park programs: " + e.getMessage());
        }
    }
    
    // Query 11: Retrieve Anonymous Donations Summary
    private static void RetrieveAnonymousDonationsSummary(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter month (1–12): ");
            int month = sc.nextInt();

            System.out.print("Enter year (e.g., 2025): ");
            int year = sc.nextInt();
            sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call RetrieveAnonymousDonationsSummary(?,?)}")) {
                cs.setInt(1, month);
                cs.setInt(2, year);

                boolean hasResult = cs.execute();

                // Process result set
                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        System.out.println("\n--- Anonymous Donations Summary ---");
                        // Print header
                        System.out.printf("%-15s %-15s %-20s %-20s %-15s%n", "Year", "Month", "Total Donation", "Average Donation", "Donations Count");
                        // Print all data
                        while (rs.next()) {
                            int dYear = rs.getInt("Donation Year");
                            int dMonth = rs.getInt("Donation Month");
                            double total = rs.getDouble("Total Donation");
                            double avg = rs.getDouble("Average Donation");
                            int count = rs.getInt("Number of Donations");
                            System.out.printf("%-15d %-15d %-20.2f %-20.2f %-15d%n", dYear, dMonth, total, avg, count);
                        }
                    }
                } else {
                    System.out.println("No anonymous donations found for the given month and year.");
                }

            }

        } catch (SQLException e) {
            System.out.println("Error retrieving anonymous donation summary: " + e.getMessage());
        }
    }
    
    // Query 12: Retrieve Rangers in Team
    private static void RetrieveRangersInTeam(Scanner sc) {
        try (Connection conn = DriverManager.getConnection(URL)) {

            // Collect user input
            System.out.print("Enter team ID: ");
            int teamId = sc.nextInt();
            sc.nextLine();

            // Prepare and execute stored procedure
            try (CallableStatement cs = conn.prepareCall("{call RetrieveRangersInTeam(?)}")) {
                cs.setInt(1, teamId);

                boolean hasResult = cs.execute();

                if (hasResult) {
                    try (ResultSet rs = cs.getResultSet()) {
                        System.out.println("\n--- Rangers in Team " + teamId + " ---");
                        // Print the header
                        System.out.printf("%-10s %-25s %-25s %-20s %-10s%n", "Ranger ID", "Ranger Name", "Certification", "Years of Service", "Role");
                        // Print the data
                        while (rs.next()) {
                            int rangerId = rs.getInt("Ranger ID");
                            String rangerName = rs.getString("Ranger Name");
                            String cert = rs.getString("Certification");
                            int years = rs.getInt("Years of Service");
                            String role = rs.getString("Role");
                            System.out.printf("%-10d %-25s %-25s %-20d %-10s%n",
                                    rangerId, rangerName, cert, years, role);
                        }
                    }
                } else {
                    System.out.println("No rangers found for the given team.");
                }

            }

        } catch (SQLException e) {
            System.out.println("Error retrieving rangers: " + e.getMessage());
        }
    }
    
    // Query 13: Retrieve all Individuals
    private static void RetrieveMailingList() {
        try (Connection conn = DriverManager.getConnection(URL);
             CallableStatement cs = conn.prepareCall("{call RetrieveAllIndividuals()}")) {
            // Execute stored procedure
            boolean hasResult = cs.execute();
            // Process result set
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    System.out.println("\n--- Mailing List ---");
                    // Print the header
                    System.out.printf("%-10s %-25s %-20s %-30s %-15s %-15s%n", "Person ID", "Full Name", "Phone", "Email", "City", "State");
                    // Print the data
                    while (rs.next()) {
                        int id = rs.getInt("Person ID");
                        String name = rs.getString("Full Name");
                        String phone = rs.getString("Phone Number");
                        String email = rs.getString("Email Address");
                        String city = rs.getString("City");
                        String state = rs.getString("State");
                        // Format and print each record
                        System.out.printf("%-10d %-25s %-20s %-30s %-15s %-15s%n",
                                id, name, phone, email, city, state);
                    }
                }
            } else {
                System.out.println("No individuals found in the database.");
            }

        } catch (SQLException e) {
            System.out.println("Error retrieving mailing list: " + e.getMessage());
        }
    }

    
    // Query 14: Update researchers salary
        private static void UpdateResearchersSalary() {
        try (Connection conn = DriverManager.getConnection(URL);
             CallableStatement cs = conn.prepareCall("{call UpdateResearchersSalary()}")) {
            // Execute stored procedure
            boolean hasResult = cs.execute();
            // Process result set
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    System.out.println("\n--- Researchers With Updated Salaries ---");
                    System.out.printf("%-15s %-25s %-15s%n", "Researcher ID", "Researcher Name", "New Salary");
                    // Print the data
                    while (rs.next()) {
                        int id = rs.getInt("Researcher ID");
                        String name = rs.getString("Researcher Name");
                        double salary = rs.getDouble("New Salary");
                        System.out.printf("%-15d %-25s %-15.2f%n", id, name, salary);
                    }
                }
            } else {
                System.out.println("No researchers met the criteria for a salary update.");
            }

        } catch (SQLException e) {
            System.out.println("Error updating researcher salaries: " + e.getMessage());
        }
    }

    
    // Query 15: Delete inactive visitors
    private static void DeleteInactiveVisitors() {
        try (Connection conn = DriverManager.getConnection(URL);
             CallableStatement cs = conn.prepareCall("{call DeleteInactiveVisitors()}")) {
            // Execute stored procedure
            boolean hasResult = cs.execute();
            // Process result set
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    System.out.println("\n--- Deletion Summary ---");
                    while (rs.next()) {
                        String msg = rs.getString("ResultMessage");
                        System.out.println(msg);
                    }
                }
            } else {
                System.out.println("No inactive visitors were deleted.");
            }

        } catch (SQLException e) {
            System.out.println("Error deleting inactive visitors: " + e.getMessage());
        }
    }
    
    // Case 16: 
    private static void ImportNewTeamsFromFile(Scanner sc) {
        System.out.print("Enter input file name (e.g., teams.txt): ");
        sc.nextLine(); // clear buffer
        String fileName = sc.nextLine();
        // Read from file and insert teams
        try (Connection conn = DriverManager.getConnection(URL);
             BufferedReader reader = new BufferedReader(new FileReader(fileName))) {

            String line;
            int count = 0;

            System.out.println("\nImporting new ranger teams...\n");
            // Read each line from the file
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split(",");
                if (parts.length != 3) { // Each line must have exactly 3 parts
                    System.out.println("Skipping invalid line: " + line);
                    continue;
                }
                // Parse team details
                String focusArea = parts[0].trim();
                String formationDate = parts[1].trim();
                int leaderId;
                // Validate leader ID
                try {
                    leaderId = Integer.parseInt(parts[2].trim());
                } catch (NumberFormatException e) {
                    System.out.println("Invalid leader ID in line: " + line);
                    continue;
                }
                // Call stored procedure to insert the team
                try (CallableStatement cs = conn.prepareCall("{call InsertNewRangerTeam(?,?,?)}")) {
                    cs.setString(1, focusArea);
                    cs.setString(2, formationDate);
                    cs.setInt(3, leaderId);
                    cs.execute();
                    count++;
                } catch (SQLException e) {
                    System.out.println("Failed to insert team: " + e.getMessage());
                }
            }

            System.out.println("\nImport complete. " + count + " teams inserted.");

        } catch (IOException e) {
            System.out.println("Error reading file: " + e.getMessage());
        } catch (SQLException e) {
            System.out.println("Database error during import: " + e.getMessage());
        }
    }

    private static void ExportMailingAddressesToFile(Scanner sc) {
        System.out.print("Enter output file name (e.g., output.txt): ");
        sc.nextLine(); // clear buffer
        String filePath = sc.nextLine();
        // Export mailing list to file
        try (Connection conn = DriverManager.getConnection(URL);
             CallableStatement cs = conn.prepareCall("{call RetrieveAllIndividuals()}");
             BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            // Execute stored procedure
            boolean hasResult = cs.execute();

            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    writer.write("Person ID,Full Name,Phone,Email,City,State\n"); // header
                    // Write each record to the file
                    while (rs.next()) {
                        int id = rs.getInt("Person ID");
                        String name = rs.getString("Full Name");
                        String phone = rs.getString("Phone Number");
                        String email = rs.getString("Email Address");
                        String city = rs.getString("City");
                        String state = rs.getString("State");
                        // Format and write each record
                        writer.write(String.format("%d,%s,%s,%s,%s,%s\n",
                                id, name, phone, email, city, state));
                    }
                    System.out.println("Mailing list successfully exported to: " + filePath);
                }
            } else {
                System.out.println("No mailing list data found to export.");
            }

        } catch (SQLException e) {
            System.out.println("Database error while exporting mailing list: " + e.getMessage());
        } catch (IOException e) {
            System.out.println("File writing error: " + e.getMessage());
        }
    }
    
}