import java.sql.*;
import java.util.Scanner;

public class AlumniLoginSystem {

    static final String URL = "jdbc:mysql://localhost:3306/AlumniDB";
    static final String USER = "root";
    static final String PASSWORD = "root";

    static Scanner sc = new Scanner(System.in);

    public static void main(String[] args) {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Connected to AlumniDB!");

            while (true) {
                System.out.println("\n1. Register");
                System.out.println("2. Login");
                System.out.println("3. Exit");
                System.out.print("Choose: ");
                int choice = sc.nextInt();
                sc.nextLine();

                if (choice == 1) register(conn);
                else if (choice == 2) login(conn);
                else break;
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ================= REGISTER =================
    static void register(Connection conn) throws SQLException {
        System.out.print("Enter Name: ");
        String name = sc.nextLine();

        System.out.print("Enter Email: ");
        String email = sc.nextLine();

        System.out.print("Enter Password: ");
        String password = sc.nextLine();

        System.out.print("Enter Role (student/alumni): ");
        String role = sc.nextLine();

        String query = "INSERT INTO Users(full_name, email, password_hash, role) VALUES (?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(query);

        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, password);
        ps.setString(4, role);

        ps.executeUpdate();
        System.out.println("Registration Successful!");
    }

    // ================= LOGIN =================
    static void login(Connection conn) throws SQLException {
        System.out.print("Enter Email: ");
        String email = sc.nextLine();

        System.out.print("Enter Password: ");
        String password = sc.nextLine();

        String query = "SELECT * FROM Users WHERE email=? AND password_hash=?";
        PreparedStatement ps = conn.prepareStatement(query);

        ps.setString(1, email);
        ps.setString(2, password);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            int userId = rs.getInt("user_id");
            System.out.println("Login Successful!");

            userMenu(conn, userId);
        } else {
            System.out.println("Invalid Credentials!");
        }
    }

    // ================= USER MENU =================
    static void userMenu(Connection conn, int userId) throws SQLException {
        while (true) {
            System.out.println("\n1. View Profile");
            System.out.println("2. Update Profile");
            System.out.println("3. Delete Account");
            System.out.println("4. Logout");
            System.out.print("Choose: ");

            int choice = sc.nextInt();
            sc.nextLine();

            if (choice == 1) viewProfile(conn, userId);
            else if (choice == 2) updateProfile(conn, userId);
            else if (choice == 3) {
                deleteAccount(conn, userId);
                break;
            } else break;
        }
    }

    // ================= VIEW =================
    static void viewProfile(Connection conn, int userId) throws SQLException {
        String query = "SELECT * FROM Users WHERE user_id=?";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setInt(1, userId);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            System.out.println("\n--- PROFILE ---");
            System.out.println("Name: " + rs.getString("full_name"));
            System.out.println("Email: " + rs.getString("email"));
            System.out.println("Branch: " + rs.getString("branch"));
            System.out.println("Company: " + rs.getString("current_company"));
        }
    }

    // ================= UPDATE =================
    static void updateProfile(Connection conn, int userId) throws SQLException {
        System.out.print("Enter New Company: ");
        String company = sc.nextLine();

        System.out.print("Enter New Designation: ");
        String designation = sc.nextLine();

        String query = "UPDATE Users SET current_company=?, designation=? WHERE user_id=?";
        PreparedStatement ps = conn.prepareStatement(query);

        ps.setString(1, company);
        ps.setString(2, designation);
        ps.setInt(3, userId);

        ps.executeUpdate();
        System.out.println("Profile Updated!");
    }

    // ================= DELETE =================
    static void deleteAccount(Connection conn, int userId) throws SQLException {
        String query = "DELETE FROM Users WHERE user_id=?";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setInt(1, userId);

        ps.executeUpdate();
        System.out.println("Account Deleted!");
    }
}

