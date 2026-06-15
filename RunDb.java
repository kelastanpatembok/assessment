import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class RunDb {
    public static void main(String[] args) throws Exception {
        String url = "jdbc:postgresql://localhost:5432/assessment";
        String user = "eko";
        String password = "";

        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {
             
            // Delete failed migration
            stmt.executeUpdate("DELETE FROM flyway_schema_history WHERE version = '9'");
            System.out.println("Cleaned up flyway_schema_history.");
        }
    }
}
