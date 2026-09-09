package com.vaibhutrans.servlet;

import com.google.gson.Gson;
import com.vaibhutrans.config.DBConnection;
import com.vaibhutrans.dao.PayRegisterDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

@WebServlet("/pay-register")
@MultipartConfig(
        maxFileSize = 50 * 1024 * 1024,
        maxRequestSize = 60 * 1024 * 1024
)
public class PayRegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private final PayRegisterDAO dao = new PayRegisterDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("getMasterData".equals(action)) {
            fetchMasterDataJson(request, response);
        } else if ("getTransactionDetails".equals(action)) {
            fetchTransactionDetailsJson(request, response);
        } 
        else {
            loadRecords(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("upload".equals(action)) {
            uploadExcel(request, response);
        } else if ("updateStatus".equals(action)) {
            updatePaymentStatus(request, response);
        } else if ("updateRowStatus".equals(action)) {
            handleRowStatusUpdate(request, response);
        } else {
            loadRecords(request, response);
        }
    }
    
    private void updatePaymentStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String cluster = request.getParameter("uploadCluster");
            String month = request.getParameter("uploadMonth");
            String yearString = request.getParameter("uploadYear");
            Part filePart = request.getPart("excelFile");

            if (cluster == null || cluster.trim().isEmpty() ||
                month == null || month.trim().isEmpty() ||
                yearString == null || yearString.trim().isEmpty()) {
                request.setAttribute("error", "Please select cluster, month, and year.");
                request.getRequestDispatcher("/payment_status_update.jsp").forward(request, response);
                return;
            }

            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("error", "Please select an Excel file.");
                request.getRequestDispatcher("/payment_status_update.jsp").forward(request, response);
                return;
            }

            String fileName = filePart.getSubmittedFileName();
            if (fileName == null || (!fileName.toLowerCase().endsWith(".xlsx") && !fileName.toLowerCase().endsWith(".xls"))) {
                request.setAttribute("error", "Please upload a valid Excel file (.xlsx or .xls).");
                request.getRequestDispatcher("/payment_status_update.jsp").forward(request, response);
                return;
            }

            int year = Integer.parseInt(yearString.trim());
            int updatedCount;

            try (InputStream inputStream = filePart.getInputStream()) {
                updatedCount = dao.updateDbStatusBatch(inputStream, cluster, month, year);
            }

            request.setAttribute("message", updatedCount + " record(s) updated successfully for Cluster-" + cluster + " (" + month + "/" + year + ").");
            request.getRequestDispatcher("/payment_status_update.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error updating payment status: " + e.getMessage());
            request.getRequestDispatcher("/payment_status_update.jsp").forward(request, response);
        }
    }

    private void fetchMasterDataJson(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String cluster = request.getParameter("cluster");
        String month = request.getParameter("month");
        String year = request.getParameter("year");

        try (Connection con = DBConnection.getConnection()) {
            List<Map<String, Object>> masterRecords = dao.getRecords(
                con, 
                cluster, 
                null, 
                null, 
                null, 
                null, 
                null,
                month, 
                year
            );
            out.print(new Gson().toJson(masterRecords));
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    private void uploadExcel(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String cluster = request.getParameter("uploadCluster");
            String month = request.getParameter("uploadMonth");
            String yearString = request.getParameter("uploadYear");
            Part filePart = request.getPart("excelFile");

            if (cluster == null || cluster.trim().isEmpty()) {
                request.setAttribute("error", "Please select cluster.");
                request.getRequestDispatcher("/payregister_upload.jsp").forward(request, response);
                return;
            }

            if (month == null || month.trim().isEmpty()) {
                request.setAttribute("error", "Please select month.");
                request.getRequestDispatcher("/payregister_upload.jsp").forward(request, response);
                return;
            }

            if (yearString == null || yearString.trim().isEmpty()) {
                request.setAttribute("error", "Please select year.");
                request.getRequestDispatcher("/payregister_upload.jsp").forward(request, response);
                return;
            }

            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("error", "Please select an Excel file.");
                request.getRequestDispatcher("/payregister_upload.jsp").forward(request, response);
                return;
            }

            String fileName = filePart.getSubmittedFileName();
            if (fileName == null || (!fileName.toLowerCase().endsWith(".xlsx") && !fileName.toLowerCase().endsWith(".xls"))) {
                request.setAttribute("error", "Please upload a valid Excel file (.xlsx or .xls).");
                request.getRequestDispatcher("/payregister_upload.jsp").forward(request, response);
                return;
            }

            int year = Integer.parseInt(yearString.trim());
            int count;

            try (InputStream inputStream = filePart.getInputStream()) {
                count = dao.uploadExcel(inputStream, fileName, cluster, month, year);
            }

            request.setAttribute("message", count + " records loaded successfully for Cluster-" + cluster + " (" + month + "/" + year + ")");
            request.setAttribute("selectedCluster", cluster);
            request.setAttribute("selectedMonth", month.toUpperCase());
            request.setAttribute("selectedYear", yearString);

            loadRecords(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error uploading file: " + e.getMessage());
            request.getRequestDispatcher("/payregister_upload.jsp").forward(request, response);
        }
    }

    private void loadRecords(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String cluster = request.getParameter("cluster");
        String[] zones = request.getParameterValues("zone");
        String[] circles = request.getParameterValues("circle");
        String[] divisions = request.getParameterValues("division");
        String[] designations = request.getParameterValues("designation");
        String[] dbStatuses = request.getParameterValues("dbStatus");
        String month = request.getParameter("month");
        String year = request.getParameter("year");

        if (cluster == null) {
            Object value = request.getAttribute("selectedCluster");
            cluster = (value != null) ? value.toString() : "";
        }

        if (month == null) {
            Object value = request.getAttribute("selectedMonth");
            if (value != null) month = value.toString();
        }

        if (year == null) {
            Object value = request.getAttribute("selectedYear");
            if (value != null) year = value.toString();
        }

        zones = cleanArray(zones);
        circles = cleanArray(circles);
        divisions = cleanArray(divisions);
        designations = cleanArray(designations);
        dbStatuses = cleanArray(dbStatuses);

        try (Connection con = DBConnection.getConnection()) {
            
            List<Map<String, Object>> records = dao.getRecords(con, cluster, zones, circles, divisions, designations, dbStatuses, month, year);
            Map<String, Double> summaryMap = dao.getReportSummary(con, cluster, zones, circles, divisions, designations, dbStatuses, month, year);

            List<String> zoneList = dao.getDistinctEmployeeMasterOptions(con, "ZONE", cluster, null, null, null);
            List<String> circleList = dao.getDistinctEmployeeMasterOptions(con, "CIRCLE", cluster, zones, null, null);
            List<String> divisionList = dao.getDistinctEmployeeMasterOptions(con, "DIV", cluster, zones, circles, null);
            List<String> designationList = dao.getDistinctEmployeeMasterOptions(con, "DESIGNATION", cluster, zones, circles, divisions);
            List<String> dbStatusList = dao.getDistinctPayRegisterDbStatuses(con, cluster, month, year);

            List<Map<String, String>> companyBankList = dao.getCompanyBankDetails(con);

            request.setAttribute("records", records);
            request.setAttribute("summaryMap", summaryMap);
            request.setAttribute("zoneList", zoneList);
            request.setAttribute("circleList", circleList);
            request.setAttribute("divisionList", divisionList);
            request.setAttribute("designationList", designationList);
            request.setAttribute("dbStatusList", dbStatusList);
            request.setAttribute("companyBankList", companyBankList);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Database connection/query error: " + e.getMessage());
        }

        request.setAttribute("selectedCluster", cluster == null ? "" : cluster.trim());
        request.setAttribute("selectedZones", zones != null ? Arrays.asList(zones) : null);
        request.setAttribute("selectedCircles", circles != null ? Arrays.asList(circles) : null);
        request.setAttribute("selectedDivisions", divisions != null ? Arrays.asList(divisions) : null);
        request.setAttribute("selectedDesignations", designations != null ? Arrays.asList(designations) : null);
        request.setAttribute("selectedDbStatuses", dbStatuses != null ? Arrays.asList(dbStatuses) : null);
        request.setAttribute("selectedMonth", month == null ? "" : month.trim());
        request.setAttribute("selectedYear", year == null ? "" : year.trim());

        request.getRequestDispatcher("/payregister_report.jsp").forward(request, response);
    }

    private String[] cleanArray(String[] array) {
        if (array == null || array.length == 0) return null;
        List<String> valid = new ArrayList<>();
        for (String s : array) {
            if (s != null && !s.trim().isEmpty()) {
                valid.add(s.trim());
            }
        }
        return valid.isEmpty() ? null : valid.toArray(new String[0]);
    }
    
    private void handleRowStatusUpdate(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String empCode = request.getParameter("empCode");
        String newStatus = request.getParameter("newStatus");
        String cluster = request.getParameter("cluster");
        String month = request.getParameter("month");
        String year = request.getParameter("year");

        if (empCode == null || newStatus == null || empCode.trim().isEmpty() || newStatus.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Missing required parameters.\"}");
            return;
        }

        try {
            boolean updated = dao.updateSingleRecordStatus(empCode, newStatus, cluster, month, year);
            if (updated) {
                out.print("{\"success\":true,\"newStatus\":\"" + newStatus + "\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"success\":false,\"message\":\"Record not found or unchanged.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
    
    private void fetchTransactionDetailsJson(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String empCode = request.getParameter("empCode");
        String payMonth = request.getParameter("payMonth");
        String payYear = request.getParameter("payYear");

        try (Connection con = DBConnection.getConnection()) {
            // Universal Oracle-compatible query using a subquery and ROWNUM
            String sql = "SELECT utr_no, tx_date FROM (" +
                         "  SELECT t.utr_no, TO_CHAR(t.transaction_date, 'YYYY-MM-DD') AS tx_date " +
                         "  FROM pay_register p " +
                         "  JOIN transactions t ON TRIM(p.account_no) = TRIM(t.benf_account) " +
                         "  WHERE p.code = ? AND p.pay_month = ? AND p.pay_year = ? " +
                         "    AND t.utr_no IS NOT NULL " +
                         "  ORDER BY t.transaction_date DESC" +
                         ") WHERE ROWNUM = 1";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, empCode);
                ps.setString(2, payMonth);
                ps.setInt(3, Integer.parseInt(payYear != null && !payYear.trim().isEmpty() ? payYear : "2026"));
                
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String utr = rs.getString("utr_no");
                        String date = rs.getString("tx_date");
                        out.print("{\"utr_no\":\"" + (utr != null ? utr : "-") + "\", \"transaction_date\":\"" + (date != null ? date : "-") + "\"}");
                    } else {
                        out.print("{\"utr_no\":\"-\", \"transaction_date\":\"-\"}");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"utr_no\":\"-\", \"transaction_date\":\"-\"}");
        }
    }
}