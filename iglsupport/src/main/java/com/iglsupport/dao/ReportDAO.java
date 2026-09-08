package com.iglsupport.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import com.iglsupport.config.DBConnection;
import com.iglsupport.model.ReportDTO;

public class ReportDAO {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd-MM-yyyy");

    public static List<ReportDTO> getDailyReport(Integer userGid, Integer userVid) {
        return getDailyReport(userGid, userVid, null);
    }

    private static String getRoleContext(Integer vid) {
        return "";
    }

    public static List<ReportDTO> getDailyReport(Integer userGid, Integer userVid, String userRole) {
        List<ReportDTO> reportList = new ArrayList<>();
        String gaNameFilter = null;

        if (userGid != null && userGid > 0) {
            String gaQuery = "SELECT name FROM ga WHERE gid = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement pst = conn.prepareStatement(gaQuery)) {
                pst.setInt(1, userGid);
                try (ResultSet rs = pst.executeQuery()) {
                    if (rs.next()) {
                        gaNameFilter = rs.getString("name");
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ")
           .append("    pd.state, ")
           .append("    pd.city, ")
           .append("    g.name AS ga_name, ")
           .append("    p.pid AS portion_id, ")
           .append("    p.inv_status, ")
           .append("    pd.total_data, ")
           .append("    pd.start_date, ")
           .append("    pd.end_date, ")
           .append("    COALESCE(r_today.cnt, 0) AS today_reading, ")
           .append("    COALESCE(r_yday_exact.cnt, 0) AS yday_reading, ")
           .append("    COALESCE(r_yday.cnt, 0) AS till_yday_reading ")
           .append("FROM portion p ")
           .append("JOIN ga g ON p.gid = g.gid ")
           .append("LEFT JOIN portion_details pd ON p.pid = pd.pid ")
           .append("LEFT JOIN (" )
           .append("    SELECT r.pid, COUNT(r.id) AS cnt ")
           .append("    FROM readings r ")
           .append("    JOIN portion_details d ON r.pid = d.pid ")
           .append("    WHERE DATE(r.reading_date) = CURRENT_DATE() ")
           .append("      AND (d.start_date IS NULL OR DATE(r.reading_date) >= d.start_date) ")
           .append("      AND (d.end_date IS NULL OR DATE(r.reading_date) <= d.end_date) ")
           .append("    GROUP BY r.pid ")
           .append(") r_today ON p.pid = r_today.pid ")
           .append("LEFT JOIN (" )
           .append("    SELECT r.pid, COUNT(r.id) AS cnt ")
           .append("    FROM readings r ")
           .append("    JOIN portion_details d ON r.pid = d.pid ")
           .append("    WHERE DATE(r.reading_date) = CURRENT_DATE() - INTERVAL 1 DAY ")
           .append("      AND (d.start_date IS NULL OR DATE(r.reading_date) >= d.start_date) ")
           .append("      AND (d.end_date IS NULL OR DATE(r.reading_date) <= d.end_date) ")
           .append("    GROUP BY r.pid ")
           .append(") r_yday_exact ON p.pid = r_yday_exact.pid ")
           .append("LEFT JOIN (" )
           .append("    SELECT r.pid, COUNT(r.id) AS cnt ")
           .append("    FROM readings r ")
           .append("    JOIN portion_details d ON r.pid = d.pid ")
           .append("    WHERE DATE(r.reading_date) < CURRENT_DATE() ")
           .append("      AND (d.start_date IS NULL OR DATE(r.reading_date) >= d.start_date) ")
           .append("      AND (d.end_date IS NULL OR DATE(r.reading_date) <= d.end_date) ")
           .append("    GROUP BY r.pid ")
           .append(") r_yday ON p.pid = r_yday.pid ")
           .append("WHERE p.inv_status = 1 ");

        boolean restrictVid = !"Admin".equalsIgnoreCase(userRole) && userVid != null;
        if (restrictVid) {
            sql.append(" AND p.vid = ? ");
        }

        if (gaNameFilter != null) {
            sql.append(" AND pd.city = ? ");
        }

        sql.append(" ORDER BY pd.state ASC, pd.city ASC, g.name ASC, p.pid ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(sql.toString())) {

            int paramIdx = 1;
            if (restrictVid) {
                pst.setInt(paramIdx++, userVid);
            }
            if (gaNameFilter != null) {
                pst.setString(paramIdx++, gaNameFilter);
            }

            try (ResultSet rs = pst.executeQuery()) {
                LocalDate today = LocalDate.now();

                while (rs.next()) {
                    ReportDTO row = new ReportDTO();
                    String state = rs.getString("state");
                    String city = rs.getString("city");
                    String gaName = rs.getString("ga_name");
                    int pid = rs.getInt("portion_id");
                    int invStatus = rs.getInt("inv_status");

                    row.setState(state != null ? state : "-");
                    row.setCity(city != null ? city : "-");
                    row.setGaName(gaName != null ? gaName : "-");
                    row.setPortionId(pid);

                    Integer totalData = (rs.getObject("total_data") != null) ? rs.getInt("total_data") : null;
                    row.setTotalData(totalData);

                    Date sDate = rs.getDate("start_date");
                    Date eDate = rs.getDate("end_date");
                    LocalDate startDate = (sDate != null) ? sDate.toLocalDate() : null;
                    LocalDate endDate = (eDate != null) ? eDate.toLocalDate() : null;

                    row.setStartDate(startDate);
                    row.setEndDate(endDate);

                    if (startDate != null && endDate != null) {
                        row.setSchedule(startDate.format(DATE_FORMATTER) + " to " + endDate.format(DATE_FORMATTER));
                    } else {
                        row.setSchedule("-");
                    }

                    int todayRead = rs.getInt("today_reading");
                    int ydayRead = rs.getInt("yday_reading");
                    int tillYdayRead = rs.getInt("till_yday_reading");

                    int[] invCounts = getInvoiceCounts(conn, pid, startDate, endDate);
                    int todayInv = invCounts[0];
                    int ydayInv = invCounts[1];
                    int tillYdayInv = invCounts[2];

                    int totalRead = todayRead + tillYdayRead;
                    int totalInv = todayInv + tillYdayInv;
                    int unbilled = (totalData != null) ? Math.max(0, totalData - totalRead) : 0;
                    double billedPercent = (totalData != null && totalData > 0) ? ((double) totalRead / totalData) * 100.0 : 0.0;

                    row.setTodayReading(todayRead);
                    row.setYesterdayReading(ydayRead);
                    row.setTodayInv(todayInv);
                    row.setYesterdayInv(ydayInv);
                    row.setTillYdayRead(tillYdayRead);
                    row.setTillYdayInv(tillYdayInv);
                    row.setTotalReading(totalRead);
                    row.setTotalInv(totalInv);
                    row.setUnbilled(unbilled);
                    row.setBilledPercent(Math.round(billedPercent * 100.0) / 100.0);

                    if (endDate != null && today.isAfter(endDate)) {
                        row.setStatus("Completed");
                    } else if (invStatus == 1 && endDate == null) {
                        row.setStatus("Completed");
                    } else {
                        row.setStatus("Running");
                    }

                    if (totalData != null && startDate != null && endDate != null) {
                        long totalDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;
                        if (totalDays > 0) {
                            int perDayTarget = (int) Math.ceil((double) totalData / totalDays);
                            row.setPerDayTarget(perDayTarget);
                            row.setDiff(perDayTarget - todayRead);
                        }
                    }

                    reportList.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reportList;
    }

    private static int[] getInvoiceCounts(Connection conn, int pid, LocalDate startDate, LocalDate endDate) {
        int[] counts = new int[]{0, 0, 0};
        String targetTable = "invoice_" + pid;

        String checkTableSql = "SELECT COUNT(*) FROM information_schema.tables " +
                               "WHERE table_schema = DATABASE() AND table_name = ?";

        try (PreparedStatement checkPst = conn.prepareStatement(checkTableSql)) {
            checkPst.setString(1, targetTable);
            try (ResultSet checkRs = checkPst.executeQuery()) {
                if (checkRs.next() && checkRs.getInt(1) > 0) {
                    StringBuilder invSql = new StringBuilder();
                    invSql.append("SELECT ")
                          .append("  SUM(CASE WHEN DATE(inv_date) = CURRENT_DATE() THEN 1 ELSE 0 END) AS today_inv, ")
                          .append("  SUM(CASE WHEN DATE(inv_date) = CURRENT_DATE() - INTERVAL 1 DAY THEN 1 ELSE 0 END) AS yday_inv, ")
                          .append("  SUM(CASE WHEN DATE(inv_date) < CURRENT_DATE() THEN 1 ELSE 0 END) AS till_yday_inv ")
                          .append("FROM `").append(targetTable).append("` ")
                          .append("WHERE active = 1 ");

                    if (startDate != null) {
                        invSql.append(" AND DATE(inv_date) >= '").append(Date.valueOf(startDate)).append("' ");
                    }
                    if (endDate != null) {
                        invSql.append(" AND DATE(inv_date) <= '").append(Date.valueOf(endDate)).append("' ");
                    }

                    try (PreparedStatement invPst = conn.prepareStatement(invSql.toString());
                         ResultSet invRs = invPst.executeQuery()) {
                        if (invRs.next()) {
                            counts[0] = invRs.getInt("today_inv");
                            counts[1] = invRs.getInt("yday_inv");
                            counts[2] = invRs.getInt("till_yday_inv");
                        }
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error reading " + targetTable + ": " + e.getMessage());
        }
        return counts;
    }

//    public static String getPortionDrilldownDetails(int pid) {
//        int todayReadings = 0;
//        int ydayReadings = 0;
//        int totalScheduleReadings = 0;
//        
//        StringBuilder readersJson = new StringBuilder();
//        readersJson.append("[");
//
//        String query = "SELECT " +
//                       "    r.userId, " +
//                       "    u.name AS user_name, " +
//                       "    d.ga AS gaName, " +
//                       "    d.pid AS portionId, " +
//                       "    d.start_date AS scheduleStart, " +
//                       "    d.end_date AS scheduleEnd, " +
//                       "    SUM(CASE WHEN DATE(r.reading_date) = CURRENT_DATE() THEN 1 ELSE 0 END) AS today_cnt, " +
//                       "    SUM(CASE WHEN DATE(r.reading_date) = CURRENT_DATE() - INTERVAL 1 DAY THEN 1 ELSE 0 END) AS yday_cnt, " +
//                       "    COUNT(r.id) AS total_cnt " +
//                       "FROM readings r " +
//                       "JOIN portion_details d ON r.pid = d.pid " +
//                       "LEFT JOIN user u ON r.userId = u.userId " +
//                       "WHERE r.pid = ? " +
//                       "  AND (d.start_date IS NULL OR DATE(r.reading_date) >= d.start_date) " +
//                       "  AND (d.end_date IS NULL OR DATE(r.reading_date) <= d.end_date) " +
//                       "GROUP BY r.userId, u.name, d.ga, d.pid, d.start_date, d.end_date";
//
//        try (Connection conn = DBConnection.getConnection();
//             PreparedStatement pst = conn.prepareStatement(query)) {
//            pst.setInt(1, pid);
//            try (ResultSet rs = pst.executeQuery()) {
//                boolean first = true;
//                while (rs.next()) {
//                    String readerId = rs.getString("userId");
//                    String userName = rs.getString("user_name");
//                    String gaName = rs.getString("gaName");
//                    int portionNo = rs.getInt("portionId");
//                    String scheduleStart = rs.getString("scheduleStart");
//                    String scheduleEnd = rs.getString("scheduleEnd");
//                    
//                    int tCnt = rs.getInt("today_cnt");
//                    int yCnt = rs.getInt("yday_cnt");
//                    int totCnt = rs.getInt("total_cnt");
//
//                    todayReadings += tCnt;
//                    ydayReadings += yCnt;
//                    totalScheduleReadings += totCnt;
//
//                    if (!first) {
//                        readersJson.append(",");
//                    }
//                    readersJson.append("{")
//                               .append("\"userId\":\"").append(readerId != null ? readerId.replace("\"", "\\\"") : "N/A").append("\",")
//                               .append("\"userName\":\"").append(userName != null ? userName.replace("\"", "\\\"") : "N/A").append("\",")
//                               .append("\"gaName\":\"").append(gaName != null ? gaName.replace("\"", "\\\"") : "").append("\",")
//                               .append("\"portionNo\":").append(portionNo).append(",")
//                               .append("\"scheduleStart\":\"").append(scheduleStart != null ? scheduleStart : "").append("\",")
//                               .append("\"scheduleEnd\":\"").append(scheduleEnd != null ? scheduleEnd : "").append("\",")
//                               .append("\"todayCount\":").append(tCnt).append(",")
//                               .append("\"ydayCount\":").append(yCnt).append(",")
//                               .append("\"totalCount\":").append(totCnt)
//                               .append("}");
//                    first = false;
//                }
//            }
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//        readersJson.append("]");
//
//        StringBuilder jsonResponse = new StringBuilder();
//        jsonResponse.append("{")
//                    .append("\"portionId\":").append(pid).append(",")
//                    .append("\"todayReadings\":").append(todayReadings).append(",")
//                    .append("\"ydayReadings\":").append(ydayReadings).append(",")
//                    .append("\"totalScheduleReadings\":").append(totalScheduleReadings).append(",")
//                    .append("\"readers\":").append(readersJson.toString())
//                    .append("}");
//
//        return jsonResponse.toString();
//    }
    public static String getPortionDrilldownDetails(int pid) {
        int todayReadings = 0;
        int ydayReadings = 0;
        int totalScheduleReadings = 0;
        
        StringBuilder readersJson = new StringBuilder();
        readersJson.append("[");

        String query = "SELECT " +
                       "    r.userId AS userId, " +
                       "    u.name AS user_name, " +
                       "    d.ga AS gaName, " +
                       "    d.pid AS portionId, " +
                       "    d.start_date AS scheduleStart, " +
                       "    d.end_date AS scheduleEnd, " +
                       "    SUM(CASE WHEN DATE(r.reading_date) = CURRENT_DATE() THEN 1 ELSE 0 END) AS today_cnt, " +
                       "    SUM(CASE WHEN DATE(r.reading_date) = CURRENT_DATE() - INTERVAL 1 DAY THEN 1 ELSE 0 END) AS yday_cnt, " +
                       "    COUNT(r.id) AS total_cnt " +
                       "FROM readings r " +
                       "JOIN portion_details d ON r.pid = d.pid " +
                       "LEFT JOIN user u ON r.userId = u.userId " +
                       "WHERE r.pid = ? " +
                       "  AND (d.start_date IS NULL OR DATE(r.reading_date) >= d.start_date) " +
                       "  AND (d.end_date IS NULL OR DATE(r.reading_date) <= d.end_date) " +
                       "GROUP BY r.userId, u.name, d.ga, d.pid, d.start_date, d.end_date";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, pid);
            try (ResultSet rs = pst.executeQuery()) {
                boolean first = true;
                while (rs.next()) {
                    String readerId = rs.getString("userId");
                    String userName = rs.getString("user_name");
                    String gaName = rs.getString("gaName");
                    int portionNo = rs.getInt("portionId");
                    String scheduleStart = rs.getString("scheduleStart");
                    String scheduleEnd = rs.getString("scheduleEnd");
                    
                    int tCnt = rs.getInt("today_cnt");
                    int yCnt = rs.getInt("yday_cnt");
                    int totCnt = rs.getInt("total_cnt");

                    todayReadings += tCnt;
                    ydayReadings += yCnt;
                    totalScheduleReadings += totCnt;

                    if (!first) {
                        readersJson.append(",");
                    }
                    readersJson.append("{")
                               .append("\"userId\":\"").append(readerId != null ? readerId.replace("\"", "\\\"") : "N/A").append("\",")
                               .append("\"userName\":\"").append(userName != null ? userName.replace("\"", "\\\"") : "N/A").append("\",")
                               .append("\"gaName\":\"").append(gaName != null ? gaName.replace("\"", "\\\"") : "").append("\",")
                               .append("\"portionNo\":").append(portionNo).append(",")
                               .append("\"scheduleStart\":\"").append(scheduleStart != null ? scheduleStart : "").append("\",")
                               .append("\"scheduleEnd\":\"").append(scheduleEnd != null ? scheduleEnd : "").append("\",")
                               .append("\"todayCount\":").append(tCnt).append(",")
                               .append("\"ydayCount\":").append(yCnt).append(",")
                               .append("\"totalCount\":").append(totCnt)
                               .append("}");
                    first = false;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        readersJson.append("]");

        StringBuilder jsonResponse = new StringBuilder();
        jsonResponse.append("{")
                    .append("\"portionId\":").append(pid).append(",")
                    .append("\"todayReadings\":").append(todayReadings).append(",")
                    .append("\"ydayReadings\":").append(ydayReadings).append(",")
                    .append("\"totalScheduleReadings\":").append(totalScheduleReadings).append(",")
                    .append("\"readers\":").append(readersJson.toString())
                    .append("}");

        return jsonResponse.toString();
    }

    public List<ReportDTO> getDailyReportForMeterReader(String userId, String startDate, String endDate) {
        List<ReportDTO> dailyList = new ArrayList<>();
        String query = "SELECT DATE(reading_date) as r_date, COUNT(*) as reading_count " +
                       "FROM readings " +
                       "WHERE userId = ? AND DATE(reading_date) BETWEEN ? AND LEAST(?, CURDATE()) " +
                       "GROUP BY DATE(reading_date) ORDER BY r_date ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setString(1, userId);
            pstmt.setString(2, startDate);
            pstmt.setString(3, endDate);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ReportDTO dto = new ReportDTO();
                    String rawDate = rs.getString("r_date");
                    if (rawDate != null && rawDate.length() >= 10) {
                        String[] parts = rawDate.split("-"); 
                        if (parts.length == 3) {
                            dto.setReadingDate(parts[2] + "-" + parts[1] + "-" + parts[0]);
                        } else {
                            dto.setReadingDate(rawDate);
                        }
                    } else {
                        dto.setReadingDate(rawDate);
                    }
                    dto.setReadingCount(rs.getInt("reading_count"));
                    dailyList.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return dailyList;
    }
    
//    public List<ReportDTO> getReadingsMapForDate(String userId, String targetDate) {
//        List<ReportDTO> locationList = new ArrayList<>();
//        
//        // Uses STR_TO_DATE to cleanly accept the 'dd-MM-yyyy' parameter format passed from the date link
//        String query = "SELECT r.lat, r.lon FROM readings r " +
//                       "JOIN portion_details p ON r.pid = p.pid " +
//                       "WHERE r.userId = ? " +
//                       "  AND DATE(r.reading_date) = STR_TO_DATE(?, '%d-%m-%Y') " +
//                       "  AND (p.start_date IS NULL OR DATE(r.reading_date) >= p.start_date) " +
//                       "  AND (p.end_date IS NULL OR DATE(r.reading_date) <= p.end_date)";
//        
//        try (Connection conn = DBConnection.getConnection();
//             PreparedStatement pstmt = conn.prepareStatement(query)) {
//            pstmt.setString(1, userId);
//            pstmt.setString(2, targetDate);
//            
//            try (ResultSet rs = pstmt.executeQuery()) {
//                while (rs.next()) {
//                    ReportDTO dto = new ReportDTO();
//                    dto.setLat(rs.getDouble("lat"));
//                    dto.setLon(rs.getDouble("lon"));
//                    locationList.add(dto);
//                }
//            }
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//        return locationList;
//    }
    
    public List<ReportDTO> getReadingsMapForDate(String userId, String targetDate) {
        List<ReportDTO> locationList = new ArrayList<>();
        
        // Select r.reading_date as well so we can sort and display time on the map
        String query = "SELECT r.lat, r.lon, r.reading_date FROM readings r " +
                       "JOIN portion_details p ON r.pid = p.pid " +
                       "WHERE r.userId = ? " +
                       "  AND DATE(r.reading_date) = STR_TO_DATE(?, '%d-%m-%Y') " +
                       "  AND (p.start_date IS NULL OR DATE(r.reading_date) >= p.start_date) " +
                       "  AND (p.end_date IS NULL OR DATE(r.reading_date) <= p.end_date) " +
                       "ORDER BY r.reading_date ASC"; // Ensures chronological ordering
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setString(1, userId);
            pstmt.setString(2, targetDate);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ReportDTO dto = new ReportDTO();
                    dto.setLat(rs.getDouble("lat"));
                    dto.setLon(rs.getDouble("lon"));
                    dto.setReadingDate(rs.getString("reading_date")); // Reusing readingDate to hold the timestamp string
                    locationList.add(dto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return locationList;
    }
}