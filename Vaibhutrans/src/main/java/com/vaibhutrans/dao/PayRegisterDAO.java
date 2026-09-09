package com.vaibhutrans.dao;

import com.vaibhutrans.config.DBConnection;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class PayRegisterDAO {

    private static final String TABLE_NAME = "PAY_REGISTER";

    private static final String[] DB_COLUMNS = {
        "SN", "CODE", "EMP_NAME", "FATHER_HUSBAND_NAME", "GENDER", "DOJ", "DOR", "DOB", "NOTICE_PERIOD", "PAN",
        "EMAIL", "PAY_MODE", "BANK_NAME", "BANK_BRANCH", "IFSC", "BANK_REF_NO", "CHEQUE_NO", "CHEQUE_DATE", "ACCOUNT_NO", "ACCOUNT_NAME",
        "AADHAAR", "PF_NO", "PF_DATE", "UAN", "ESI_NO", "ESI_DATE", "ESI_OFFICE", "BRANCH_CODE", "BRANCH", "CATEGORY",
        "DESIGNATION", "DEPARTMENT", "SCALE", "SHIFT", "WORK_LOCATION", "PHONE", "MOBILE", "INTERNAL_ID", "ADDRESS_PERM", "ADDRESS_CORRES",
        "TOTAL_DAYS", "WK_OFF", "HOLIDAY", "MAX_WORK_DAYS", "MAX_PAYABLE_DAYS", "ABS_LWP", "NET_PAID_DAYS_1", "TOTAL_LVS", "PRESENT_DAYS",
        "TOTAL_BILLED_ACT", "MANNUAL_BILLED_ACT", "PROBE_BILLED_ACT", "AUTO_OCR_ACT", "SPOOF_OCR_ACT", "COLLECTION_ACT", "CTC1_ACT", "CTC_ACT",
        "CURRENT_GROSS1_ACT", "CURRENT_GROSS2_ACT", "CURRENT_GROSS3_ACT", "CURRENT_GROSS4_ACT", "CURRENT_GROSS5_ACT", "CURRENT_GROSS6_ACT",
        "BASIC_SALARY_ACT", "HRA_ACT", "GROSS_SALARY_ACT", "PF_ACT", "ESI_ACT", "PROFESSIONAL_TAX_ACT", "NET_SALARY_ACT", "PF_EDLI_CHARGES_ACT",
        "SALARY_HRA_EXEMPT_ACT", "NET_PAID_DAYS_ACT", "TELEPHONE_CHARGES_ACT", "CONVEYANCE_ACT", "STAFF_LABOUR_WELFARE_ACT", "TOTAL_TCS_ACT",
        "GROSS_EARNING_ACT", "BASIC_SALARY", "HRA", "GROSS_EARNING", "PF", "ESI", "PROFESSIONAL_TAX", "GROSS_DEDUCTION", "NET_AMT_PAYABLE",
        "GROSS_EARNING_2", "PENSION_CONT", "EPF_DIFF", "EMPLOYER_PF_CONT", "EMPLOYER_ESI_CONT", "TOTAL_BILLED", "MANNUAL_BILLED",
        "PROBE_BILLED", "AUTO_OCR", "SPOOF_OCR", "COLLECTION", "CTC1", "CTC", "CURRENT_GROSS1", "CURRENT_GROSS2", "CURRENT_GROSS3",
        "CURRENT_GROSS4", "CURRENT_GROSS5", "CURRENT_GROSS6", "GROSS_SALARY", "NET_SALARY", "PF_EDLI_CHARGES", "SALARY_HRA_EXEMPT",
        "NET_PAID_DAYS_2", "TELEPHONE_CHARGES", "CONVEYANCE", "STAFF_LABOUR_WELFARE", "TOTAL_TCS", "TOTAL_CTC_SALARY", "SIGNATURE", "REMARK"
    };

    private static final String[][] DB_COLUMN_ALIASES = {
        {"S_N", "SN", "SL_NO", "SERIAL_NO"},
        {"CODE", "EMP_CODE", "EMPLOYEE_CODE"},
        {"NAME", "EMP_NAME", "EMPLOYEE_NAME", "NAME_OF_EMPLOYEE"},
        {"FATHER_S_HUSBAND_S_NAME", "FATHERS_HUSBANDS_NAME", "FATHER_HUSBAND_NAME", "F_H_NAME", "FATHER_NAME"},
        {"GENDER", "SEX"},
        {"DOJ", "DATE_OF_JOINING"},
        {"DOR", "DATE_OF_RELIEVING"},
        {"DOB", "DATE_OF_BIRTH"},
        {"NOTICE_PERIOD"},
        {"PAN", "PAN_NO"},
        {"EMAIL", "E_MAIL"},
        {"PAY_MODE", "PAYMENT_MODE"},
        {"BANK_NAME"},
        {"BANK_BRANCH", "BRANCH_NAME"},
        {"IFSC", "IFSC_CODE"},
        {"BANK_REF_NO", "BANK_REFERENCE_NO"},
        {"CHEQUE_NO", "CHEQUE_NUMBER"},
        {"CHEQUE_DATE"},
        {"A_C_NO", "ACCOUNT_NO", "ACCOUNT_NUMBER", "ACC_NO"},
        {"NAME_AS_PER_A_C", "ACCOUNT_NAME", "NAME_AS_PER_BANK"},
        {"AADHAAR", "AADHAR", "AADHAAR_NO"},
        {"PF_NO", "PF_NUMBER"},
        {"PF_DATE"},
        {"UAN", "UAN_NO"},
        {"ESI_NO", "ESI_NUMBER"},
        {"ESI_DATE"},
        {"ESI_OFFICE"},
        {"BRANCH_CODE"},
        {"BRANCH"},
        {"CATEGORY"},
        {"DESIGNATION"},
        {"DEPARTMENT"},
        {"SCALE"},
        {"SHIFT"},
        {"WORK_LOCATION", "LOCATION"},
        {"PHONE", "PHONE_NO"},
        {"MOBILE", "MOBILE_NO"},
        {"INTERNAL_ID"},
        {"ADDRESS_PERM", "PERMANENT_ADDRESS"},
        {"ADDRESS_CORRES", "CORRESPONDENCE_ADDRESS"},
        {"TOTAL_DAYS"},
        {"WK_OFF", "WEEK_OFF"},
        {"HOLIDAY", "HOLIDAYS"},
        {"MAX_WORK_DAYS", "MAX_WORKING_DAYS"},
        {"MAX_PAYABLE_DAYS"},
        {"ABS_LWP", "ABSENT_LWP", "LWP"},
        {"NET_PAID_DAYS"},
        {"TOTAL_LVS", "TOTAL_LEAVES"},
        {"PRESENT_DAYS"},
        {"TOTAL_BILLED_ACTUAL", "TOTAL_BILLED_ACT"},
        {"MANNUAL_BILLED_ACTUAL", "MANNUAL_BILLED_ACT", "MANUAL_BILLED_ACTUAL"},
        {"PROBE_BILLED_ACTUAL", "PROBE_BILLED_ACT"},
        {"AUTO_OCR_ACTUAL", "AUTO_OCR_ACT"},
        {"SPOOF_OCR_ACTUAL", "SPOOF_OCR_ACT"},
        {"COLLECTION_ACTUAL", "COLLECTION_ACT"},
        {"CTC_1_ACTUAL", "CTC1_ACTUAL", "CTC1_ACT"},
        {"CTC_ACTUAL", "CTC_ACT"},
        {"CURRENT_GROSS_1_ACTUAL", "CURRENT_GROSS1_ACTUAL"},
        {"CURRENT_GROSS_2_ACTUAL", "CURRENT_GROSS2_ACTUAL"},
        {"CURRENT_GROSS_3_ACTUAL", "CURRENT_GROSS3_ACTUAL"},
        {"CURRENT_GROSS_4_ACTUAL", "CURRENT_GROSS4_ACTUAL"},
        {"CURRENT_GROSS_5_ACTUAL", "CURRENT_GROSS5_ACTUAL"},
        {"CURRENT_GROSS_6_ACTUAL", "CURRENT_GROSS6_ACTUAL"},
        {"BASIC_SALARY_ACTUAL", "BASIC_ACTUAL"},
        {"HRA_ACTUAL"},
        {"GROSS_SALARY_ACTUAL"},
        {"PF_ACTUAL"},
        {"ESI_ACTUAL"},
        {"PROFESSIONAL_TAX_ACTUAL", "PT_ACTUAL"},
        {"NET_SALARY_ACTUAL"},
        {"PF_EDLI_CHARGES_ACTUAL"},
        {"SALARY_FOR_HRA_EXEMPT_ACTUAL", "SALARY_HRA_EXEMPT_ACTUAL"},
        {"NET_PAID_DAYS_ACTUAL"},
        {"TELEPHONE_CHARGES_ACTUAL"},
        {"CONVEYANCE_ACTUAL"},
        {"STAFF_LABOUR_WELFARE_ACTUAL", "STAFF_AND_LABOUR_WELFARE_ACTUAL"},
        {"TOTAL_TCS_ACTUAL"},
        {"GROSS_EARNING_ACTUAL"},
        {"BASIC_SALARY", "BASIC"},
        {"HRA"},
        {"GROSS_EARNING"},
        {"PF"},
        {"ESI"},
        {"PROFESSIONAL_TAX", "PT"},
        {"GROSS_DEDUCTION", "TOTAL_DEDUCTION"},
        {"NET_AMT_PAYABLE", "NET_AMOUNT_PAYABLE"},
        {"GROSS_EARNING"},
        {"PENSION_CONT", "PENSION_CONTRIBUTION"},
        {"EPF_DIFF", "EPF_DIFFERENCE"},
        {"TOTAL_EMPLOYER_S_PF_CONT", "EMPLOYER_PF_CONT", "TOTAL_EMPLOYERS_PF_CONT"},
        {"EMPLOYER_S_ESI_CONT", "EMPLOYER_ESI_CONT", "EMPLOYERS_ESI_CONT"},
        {"TOTAL_BILLED"},
        {"MANNUAL_BILLED", "MANUAL_BILLED"},
        {"PROBE_BILLED"},
        {"AUTO_OCR"},
        {"SPOOF_OCR"},
        {"COLLECTION"},
        {"CTC_1", "CTC1"},
        {"CTC"},
        {"CURRENT_GROSS_1", "CURRENT_GROSS1"},
        {"CURRENT_GROSS_2", "CURRENT_GROSS2"},
        {"CURRENT_GROSS_3", "CURRENT_GROSS3"},
        {"CURRENT_GROSS_4", "CURRENT_GROSS4"},
        {"CURRENT_GROSS_5", "CURRENT_GROSS5"},
        {"CURRENT_GROSS_6", "CURRENT_GROSS6"},
        {"GROSS_SALARY"},
        {"NET_SALARY"},
        {"PF_EDLI_CHARGES"},
        {"SALARY_FOR_HRA_EXEMPT", "SALARY_HRA_EXEMPT"},
        {"NET_PAID_DAYS"},
        {"TELEPHONE_CHARGES"},
        {"CONVEYANCE"},
        {"STAFF_LABOUR_WELFARE", "STAFF_AND_LABOUR_WELFARE"},
        {"TOTAL_TCS"},
        {"TOTAL_CTC_SALARY"},
        {"SIGN", "SIGNATURE"},
        {"REMARK", "REMARKS"}
    };

    public int uploadExcel(
            InputStream inputStream,
            String fileName,
            String cluster,
            String month,
            int year) throws Exception {

        cluster = cluster.trim();
        month = month.trim().toUpperCase(Locale.ENGLISH);

        if (!cluster.equals("5") && !cluster.equals("8") && !cluster.equals("9") && !cluster.equals("12")) {
            throw new IllegalArgumentException("Invalid cluster: " + cluster);
        }

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                deleteExisting(con, cluster, month, year);

                Workbook workbook = WorkbookFactory.create(inputStream);
                Sheet sheet = workbook.getSheetAt(0);
                DataFormatter formatter = new DataFormatter();

                Row headerRow = sheet.getRow(3);
                if (headerRow == null) {
                    throw new Exception("Excel header row (row 4) not found.");
                }

                int[] colIndices = mapHeaderIndices(headerRow, formatter);
                String sql = buildInsertSQL();

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    int totalLoaded = 0;

                    for (int rowIndex = 4; rowIndex <= sheet.getLastRowNum(); rowIndex++) {
                        Row row = sheet.getRow(rowIndex);
                        if (isEmptyRow(row)) {
                            continue;
                        }

                        String sn = getCellValueByIndex(row, colIndices[0], formatter);
                        String code = getCellValueByIndex(row, colIndices[1], formatter);

                        if (isBlank(sn) && isBlank(code)) {
                            continue;
                        }

                        int parameterIndex = 1;
                        for (int i = 0; i < DB_COLUMNS.length; i++) {
                            String value = getCellValueByIndex(row, colIndices[i], formatter);
                            ps.setString(parameterIndex++, value);
                        }

                        ps.setString(parameterIndex++, cluster);
                        ps.setString(parameterIndex++, month);
                        ps.setInt(parameterIndex++, year);
                        ps.setString(parameterIndex++, fileName);

                        ps.addBatch();
                        totalLoaded++;

                        if (totalLoaded % 500 == 0) {
                            ps.executeBatch();
                        }
                    }

                    ps.executeBatch();
                    con.commit();
                    return totalLoaded;
                }
            } catch (Exception e) {
                con.rollback();
                throw e;
            }
        }
    }

    private int[] mapHeaderIndices(Row headerRow, DataFormatter formatter) {
        int totalExcelCols = headerRow.getLastCellNum();
        String[] excelHeaders = new String[totalExcelCols];

        for (int c = 0; c < totalExcelCols; c++) {
            Cell cell = headerRow.getCell(c, Row.RETURN_BLANK_AS_NULL);
            if (cell != null) {
                excelHeaders[c] = normalizeHeader(formatter.formatCellValue(cell));
            } else {
                excelHeaders[c] = "";
            }
        }

        int[] colMap = new int[DB_COLUMNS.length];
        Arrays.fill(colMap, -1);
        boolean[] usedExcelCols = new boolean[totalExcelCols];

        for (int dbIdx = 0; dbIdx < DB_COLUMNS.length; dbIdx++) {
            String[] aliases = DB_COLUMN_ALIASES[dbIdx];
            int matchIdx = -1;

            for (int exIdx = 0; exIdx < totalExcelCols; exIdx++) {
                if (usedExcelCols[exIdx] || excelHeaders[exIdx].isEmpty()) {
                    continue;
                }
                for (String alias : aliases) {
                    if (excelHeaders[exIdx].equals(alias)) {
                        matchIdx = exIdx;
                        break;
                    }
                }
                if (matchIdx != -1) {
                    break;
                }
            }

            if (matchIdx != -1) {
                colMap[dbIdx] = matchIdx;
                usedExcelCols[matchIdx] = true;
            }
        }

        return colMap;
    }

    private String getCellValueByIndex(Row row, int colIndex, DataFormatter formatter) {
        if (row == null || colIndex < 0) {
            return null;
        }
        Cell cell = row.getCell(colIndex, Row.RETURN_BLANK_AS_NULL);
        if (cell == null) {
            return null;
        }
        String value = formatter.formatCellValue(cell);
        if (value == null) {
            return null;
        }
        value = value.trim();
        return value.isEmpty() ? null : value;
    }

    private void deleteExisting(Connection con, String cluster, String month, int year) throws Exception {
        String sql = "DELETE FROM PAY_REGISTER WHERE CLUSTER_NAME = ? AND PAY_MONTH = ? AND PAY_YEAR = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, cluster);
            ps.setString(2, month);
            ps.setInt(3, year);
            ps.executeUpdate();
        }
    }

    private String buildInsertSQL() {
        StringBuilder sql = new StringBuilder();
        sql.append("INSERT INTO PAY_REGISTER (");
        for (String column : DB_COLUMNS) {
            sql.append(column).append(",");
        }
        sql.append("CLUSTER_NAME, PAY_MONTH, PAY_YEAR, SOURCE_FILE) VALUES (");
        int totalColumns = DB_COLUMNS.length + 4;
        for (int i = 0; i < totalColumns; i++) {
            sql.append("?");
            if (i < totalColumns - 1) {
                sql.append(",");
            }
        }
        sql.append(")");
        return sql.toString();
    }

    private String normalizeHeader(String value) {
        if (value == null) {
            return "";
        }
        return value.toUpperCase(Locale.ENGLISH)
                    .replaceAll("[^A-Z0-9]+", "_")
                    .replaceAll("_+", "_")
                    .replaceAll("^_|_$", "");
    }

    private boolean isEmptyRow(Row row) {
        if (row == null) {
            return true;
        }
        DataFormatter formatter = new DataFormatter();
        for (int i = 0; i < row.getLastCellNum(); i++) {
            Cell cell = row.getCell(i, Row.RETURN_BLANK_AS_NULL);
            if (cell != null) {
                String value = formatter.formatCellValue(cell);
                if (value != null && !value.trim().isEmpty()) {
                    return false;
                }
            }
        }
        return true;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
    
    
    /* 1. getRecords using shared Connection (Keeps table empty on initial load) */
    public List<Map<String, Object>> getRecords(
            Connection con,
            String cluster,
            String[] zones,
            String[] circles,
            String[] divisions,
            String[] designations,
            String[] dbStatuses,
            String month,
            String year) throws Exception {

        List<Map<String, Object>> records = new ArrayList<>();
        
        boolean hasCluster = (cluster != null && !cluster.trim().isEmpty());
        boolean hasMonth = (month != null && !month.trim().isEmpty());
        boolean hasYear = (year != null && !year.trim().isEmpty());
        boolean hasZones = (zones != null && zones.length > 0);
        boolean hasCircles = (circles != null && circles.length > 0);
        boolean hasDivisions = (divisions != null && divisions.length > 0);
        boolean hasDesignations = (designations != null && designations.length > 0);
        boolean hasDbStatuses = (dbStatuses != null && dbStatuses.length > 0);

        if (!hasCluster && !hasMonth && !hasYear && !hasZones && !hasCircles && !hasDivisions && !hasDesignations && !hasDbStatuses) {
            return records;
        }

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("P.*, ");
        sql.append("COALESCE(EM.EMP_NAME, P.EMP_NAME) AS JOINED_EMP_NAME, ");
        sql.append("COALESCE(EM.ACCOUNT_NO, P.ACCOUNT_NO) AS JOINED_ACCOUNT_NO, ");
        sql.append("COALESCE(EM.BANK_NAME, P.BANK_NAME) AS JOINED_BANK_NAME, ");
        sql.append("COALESCE(EM.BRANCH_NAME, P.BANK_BRANCH) AS JOINED_BANK_BRANCH, ");
        sql.append("COALESCE(EM.IFSC, P.IFSC) AS JOINED_IFSC, ");
        sql.append("COALESCE(EM.ZONE, P.BRANCH) AS JOINED_ZONE, ");
        sql.append("COALESCE(EM.CIRCLE, P.CATEGORY) AS JOINED_CIRCLE, ");
        sql.append("COALESCE(EM.DIV, P.DEPARTMENT) AS JOINED_DIV, ");
        sql.append("COALESCE(EM.DESIGNATION, P.DESIGNATION) AS JOINED_DESIGNATION, ");
        sql.append("P.DB_STATUS AS JOINED_DB_STATUS, ");
        sql.append("T.UTR_NO AS JOINED_UTR_NO, ");
        sql.append("T.TRANSACTION_DATE AS JOINED_TRANSACTION_DATE ");
        sql.append("FROM PAY_REGISTER P ");
        sql.append("LEFT JOIN EMPLOYEE_MASTER EM ON P.CODE = EM.EMP_CODE ");
        sql.append("LEFT JOIN TRANSACTIONS T ON P.ACCOUNT_NO = T.BENF_ACCOUNT ");
        sql.append("AND (T.AMOUNT = TO_NUMBER(REGEXP_REPLACE(P.NET_SALARY_ACT, '[^0-9.]', '')) OR T.AMOUNT = TO_NUMBER(REGEXP_REPLACE(P.TOTAL_TCS_ACT, '[^0-9.]', ''))) ");
        sql.append("AND T.NARRATION LIKE '%' || P.PAY_MONTH || '%' ");
        sql.append("WHERE 1=1 ");

        List<Object> parameters = new ArrayList<>();

        if (hasCluster) {
            sql.append("AND (P.CLUSTER_NAME = ? OR EM.CLU_NAME = ? OR EM.CLU_NAME = ?) ");
            parameters.add(cluster.trim());
            parameters.add(cluster.trim());
            parameters.add("Cluster-" + cluster.trim());
        }

        if (hasZones) {
            sql.append("AND (");
            for (int i = 0; i < zones.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("P.BRANCH = ? OR EM.ZONE = ?");
                parameters.add(zones[i].trim());
                parameters.add(zones[i].trim());
            }
            sql.append(") ");
        }

        if (hasCircles) {
            sql.append("AND (");
            for (int i = 0; i < circles.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("P.CATEGORY = ? OR EM.CIRCLE = ?");
                parameters.add(circles[i].trim());
                parameters.add(circles[i].trim());
            }
            sql.append(") ");
        }

        if (hasDivisions) {
            sql.append("AND (");
            for (int i = 0; i < divisions.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("P.DEPARTMENT = ? OR EM.DIV = ?");
                parameters.add(divisions[i].trim());
                parameters.add(divisions[i].trim());
            }
            sql.append(") ");
        }

        if (hasDesignations) {
            sql.append("AND (");
            for (int i = 0; i < designations.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("P.DESIGNATION = ? OR EM.DESIGNATION = ?");
                parameters.add(designations[i].trim());
                parameters.add(designations[i].trim());
            }
            sql.append(") ");
        }

        if (hasDbStatuses) {
            sql.append("AND P.DB_STATUS IN (");
            for (int i = 0; i < dbStatuses.length; i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
                parameters.add(dbStatuses[i].trim());
            }
            sql.append(") ");
        }

        if (hasMonth) {
            sql.append("AND P.PAY_MONTH = ? ");
            parameters.add(month.trim().toUpperCase(Locale.ENGLISH));
        }

        if (hasYear) {
            sql.append("AND P.PAY_YEAR = ? ");
            parameters.add(Integer.parseInt(year.trim()));
        }

        sql.append("ORDER BY P.ID ASC");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                int columnCount = meta.getColumnCount();

                while (rs.next()) {
                    Map<String, Object> record = new LinkedHashMap<>();
                    
                    for (int i = 1; i <= columnCount; i++) {
                        String columnName = meta.getColumnName(i).toUpperCase(Locale.ENGLISH);

                        if (columnName.equals("ID")
                                || columnName.equals("SOURCE_FILE")
                                || columnName.equals("LOADED_AT")
                                || columnName.startsWith("JOINED_")) {
                            continue;
                        }

                        if (columnName.equals("EMP_NAME")) {
                            record.put(columnName, rs.getObject("JOINED_EMP_NAME"));
                        } else if (columnName.equals("ACCOUNT_NO")) {
                            record.put(columnName, rs.getObject("JOINED_ACCOUNT_NO"));
                        } else if (columnName.equals("BANK_NAME")) {
                            record.put(columnName, rs.getObject("JOINED_BANK_NAME"));
                        } else if (columnName.equals("BANK_BRANCH")) {
                            record.put(columnName, rs.getObject("JOINED_BANK_BRANCH"));
                        } else if (columnName.equals("IFSC")) {
                            record.put(columnName, rs.getObject("JOINED_IFSC"));
                        } else if (columnName.equals("BRANCH")) {
                            record.put(columnName, rs.getObject("JOINED_ZONE"));
                        } else if (columnName.equals("CATEGORY")) {
                            record.put(columnName, rs.getObject("JOINED_CIRCLE"));
                        } else if (columnName.equals("DEPARTMENT")) {
                            record.put(columnName, rs.getObject("JOINED_DIV"));
                        } else if (columnName.equals("DESIGNATION")) {
                            record.put(columnName, rs.getObject("JOINED_DESIGNATION"));
                        } else {
                            record.put(columnName, rs.getObject(i));
                        }
                    }

                    record.put("DB_STATUS", rs.getObject("JOINED_DB_STATUS"));
                    record.put("UTR_NO", rs.getObject("JOINED_UTR_NO"));
                    record.put("TRANSACTION_DATE", rs.getObject("JOINED_TRANSACTION_DATE"));
                    records.add(record);
                }
            }
        }
        return records;
    }

    public List<Map<String, Object>> getRecords(
            Connection con,
            String cluster,
            String[] zones,
            String[] circles,
            String[] divisions,
            String[] designations,
            String month,
            String year) throws Exception {
        return getRecords(con, cluster, zones, circles, divisions, designations, null, month, year);
    }

    /* 2. getReportSummary using shared Connection (Always calculates metrics) */
    public Map<String, Double> getReportSummary(
            Connection con,
            String cluster,
            String[] zones,
            String[] circles,
            String[] divisions,
            String[] designations,
            String[] dbStatuses,
            String month,
            String year) throws Exception {

        Map<String, Double> summary = new LinkedHashMap<>();
        summary.put("SUM_CTC1_ACT", 0.0);
        summary.put("SUM_CTC_ACT", 0.0);
        summary.put("SUM_TOTAL_TCS_ACT", 0.0);
        summary.put("SUM_NET_AMT_PAYABLE", 0.0);
        summary.put("SUM_TOTAL_BILLED_ACT", 0.0);
        summary.put("SUM_MANNUAL_BILLED_ACT", 0.0);
        summary.put("SUM_PROBE_BILLED_ACT", 0.0);
        summary.put("SUM_AUTO_OCR_ACT", 0.0);
        summary.put("SUM_ALLOW_AMT", 0.0);
        summary.put("SUM_HOLD_AMT", 0.0);
        summary.put("SUM_PAID_AMT", 0.0);

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("SUM(TO_NUMBER(REGEXP_REPLACE(P.CTC1_ACT, '[^0-9.]', ''))) AS SUM_CTC1_ACT, ");
        sql.append("SUM(TO_NUMBER(REGEXP_REPLACE(P.CTC_ACT, '[^0-9.]', ''))) AS SUM_CTC_ACT, ");
        sql.append("SUM(TO_NUMBER(REGEXP_REPLACE(P.TOTAL_TCS_ACT, '[^0-9.]', ''))) AS SUM_TOTAL_TCS_ACT, ");
        sql.append("SUM(TO_NUMBER(REGEXP_REPLACE(P.NET_AMT_PAYABLE, '[^0-9.]', ''))) AS SUM_NET_AMT_PAYABLE, ");
        sql.append("SUM(TO_NUMBER(REGEXP_REPLACE(P.TOTAL_BILLED_ACT, '[^0-9.]', ''))) AS SUM_TOTAL_BILLED_ACT, ");
        sql.append("SUM(TO_NUMBER(REGEXP_REPLACE(P.MANNUAL_BILLED_ACT, '[^0-9.]', ''))) AS SUM_MANNUAL_BILLED_ACT, ");
        sql.append("SUM(TO_NUMBER(REGEXP_REPLACE(P.PROBE_BILLED_ACT, '[^0-9.]', ''))) AS SUM_PROBE_BILLED_ACT, ");
        sql.append("SUM(TO_NUMBER(REGEXP_REPLACE(P.AUTO_OCR_ACT, '[^0-9.]', ''))) AS SUM_AUTO_OCR_ACT, ");
        sql.append("SUM(CASE WHEN UPPER(TRIM(P.DB_STATUS)) = 'ALLOW' THEN (TO_NUMBER(REGEXP_REPLACE(COALESCE(P.TOTAL_TCS_ACT, '0'), '[^0-9.]', '')) + TO_NUMBER(REGEXP_REPLACE(COALESCE(P.NET_AMT_PAYABLE, '0'), '[^0-9.]', ''))) ELSE 0 END) AS SUM_ALLOW_AMT, ");
        sql.append("SUM(CASE WHEN UPPER(TRIM(P.DB_STATUS)) IN ('HOLD', 'LEFT') THEN (TO_NUMBER(REGEXP_REPLACE(COALESCE(P.TOTAL_TCS_ACT, '0'), '[^0-9.]', '')) + TO_NUMBER(REGEXP_REPLACE(COALESCE(P.NET_AMT_PAYABLE, '0'), '[^0-9.]', ''))) ELSE 0 END) AS SUM_HOLD_AMT, ");
        sql.append("SUM(CASE WHEN UPPER(TRIM(P.DB_STATUS)) = 'PAID' THEN (TO_NUMBER(REGEXP_REPLACE(COALESCE(P.TOTAL_TCS_ACT, '0'), '[^0-9.]', '')) + TO_NUMBER(REGEXP_REPLACE(COALESCE(P.NET_AMT_PAYABLE, '0'), '[^0-9.]', ''))) ELSE 0 END) AS SUM_PAID_AMT ");
        sql.append("FROM PAY_REGISTER P ");
        sql.append("LEFT JOIN EMPLOYEE_MASTER EM ON P.CODE = EM.EMP_CODE ");
        sql.append("WHERE 1=1 ");

        List<Object> parameters = new ArrayList<>();

        if (cluster != null && !cluster.trim().isEmpty()) {
            sql.append("AND (P.CLUSTER_NAME = ? OR EM.CLU_NAME = ? OR EM.CLU_NAME = ?) ");
            parameters.add(cluster.trim());
            parameters.add(cluster.trim());
            parameters.add("Cluster-" + cluster.trim());
        }

        if (zones != null && zones.length > 0) {
            sql.append("AND (");
            for (int i = 0; i < zones.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("P.BRANCH = ? OR EM.ZONE = ?");
                parameters.add(zones[i].trim());
                parameters.add(zones[i].trim());
            }
            sql.append(") ");
        }

        if (circles != null && circles.length > 0) {
            sql.append("AND (");
            for (int i = 0; i < circles.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("P.CATEGORY = ? OR EM.CIRCLE = ?");
                parameters.add(circles[i].trim());
                parameters.add(circles[i].trim());
            }
            sql.append(") ");
        }

        if (divisions != null && divisions.length > 0) {
            sql.append("AND (");
            for (int i = 0; i < divisions.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("P.DEPARTMENT = ? OR EM.DIV = ?");
                parameters.add(divisions[i].trim());
                parameters.add(divisions[i].trim());
            }
            sql.append(") ");
        }

        if (designations != null && designations.length > 0) {
            sql.append("AND (");
            for (int i = 0; i < designations.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("P.DESIGNATION = ? OR EM.DESIGNATION = ?");
                parameters.add(designations[i].trim());
                parameters.add(designations[i].trim());
            }
            sql.append(") ");
        }

        if (dbStatuses != null && dbStatuses.length > 0) {
            sql.append("AND P.DB_STATUS IN (");
            for (int i = 0; i < dbStatuses.length; i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
                parameters.add(dbStatuses[i].trim());
            }
            sql.append(") ");
        }

        if (month != null && !month.trim().isEmpty()) {
            sql.append("AND P.PAY_MONTH = ? ");
            parameters.add(month.trim().toUpperCase(Locale.ENGLISH));
        }

        if (year != null && !year.trim().isEmpty()) {
            sql.append("AND P.PAY_YEAR = ? ");
            parameters.add(Integer.parseInt(year.trim()));
        }

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < parameters.size(); i++) {
                ps.setObject(i + 1, parameters.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    summary.put("SUM_CTC1_ACT", rs.getDouble("SUM_CTC1_ACT"));
                    summary.put("SUM_CTC_ACT", rs.getDouble("SUM_CTC_ACT"));
                    summary.put("SUM_TOTAL_TCS_ACT", rs.getDouble("SUM_TOTAL_TCS_ACT"));
                    summary.put("SUM_NET_AMT_PAYABLE", rs.getDouble("SUM_NET_AMT_PAYABLE"));
                    summary.put("SUM_TOTAL_BILLED_ACT", rs.getDouble("SUM_TOTAL_BILLED_ACT"));
                    summary.put("SUM_MANNUAL_BILLED_ACT", rs.getDouble("SUM_MANNUAL_BILLED_ACT"));
                    summary.put("SUM_PROBE_BILLED_ACT", rs.getDouble("SUM_PROBE_BILLED_ACT"));
                    summary.put("SUM_AUTO_OCR_ACT", rs.getDouble("SUM_AUTO_OCR_ACT"));
                    summary.put("SUM_ALLOW_AMT", rs.getDouble("SUM_ALLOW_AMT"));
                    summary.put("SUM_HOLD_AMT", rs.getDouble("SUM_HOLD_AMT"));
                    summary.put("SUM_PAID_AMT", rs.getDouble("SUM_PAID_AMT"));
                }
            }
        }

        return summary;
    }

    public List<String> getDistinctEmployeeMasterOptions(
            Connection con,
            String columnName,
            String cluster,
            String[] zones,
            String[] circles,
            String[] divisions) throws Exception {

        List<String> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DISTINCT ").append(columnName)
           .append(" FROM EMPLOYEE_MASTER WHERE ").append(columnName).append(" IS NOT NULL ");

        List<String> params = new ArrayList<>();

        if (cluster != null && !cluster.trim().isEmpty()) {
            sql.append("AND (CLU_NAME = ? OR CLU_NAME = ?) ");
            params.add(cluster.trim());
            params.add("Cluster-" + cluster.trim());
        }

        if (zones != null && zones.length > 0) {
            sql.append("AND ZONE IN (");
            for (int i = 0; i < zones.length; i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
                params.add(zones[i].trim());
            }
            sql.append(") ");
        }

        if (circles != null && circles.length > 0) {
            sql.append("AND CIRCLE IN (");
            for (int i = 0; i < circles.length; i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
                params.add(circles[i].trim());
            }
            sql.append(") ");
        }

        if (divisions != null && divisions.length > 0) {
            sql.append("AND DIV IN (");
            for (int i = 0; i < divisions.length; i++) {
                if (i > 0) sql.append(",");
                sql.append("?");
                params.add(divisions[i].trim());
            }
            sql.append(") ");
        }

        sql.append("ORDER BY ").append(columnName).append(" ASC");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String val = rs.getString(1);
                    if (val != null && !val.trim().isEmpty()) {
                        list.add(val.trim());
                    }
                }
            }
        }
        return list;
    }

    public List<Map<String, String>> getCompanyBankDetails(Connection con) throws Exception {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT COMPANY_NAME, BANK, ACCOUNT_NUMBER FROM COMPANY_BANK_DETAILS ORDER BY COMPANY_NAME, BANK ASC";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, String> item = new LinkedHashMap<>();
                item.put("company_name", rs.getString("COMPANY_NAME") != null ? rs.getString("COMPANY_NAME").trim() : "");
                item.put("bank", rs.getString("BANK") != null ? rs.getString("BANK").trim() : "");
                item.put("account_number", rs.getString("ACCOUNT_NUMBER") != null ? rs.getString("ACCOUNT_NUMBER").trim() : "");
                list.add(item);
            }
        }
        return list;
    }
    
    public List<String> getDistinctPayRegisterDbStatuses(
            Connection con,
            String cluster,
            String month,
            String year) throws Exception {

        List<String> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT DISTINCT DB_STATUS FROM PAY_REGISTER WHERE DB_STATUS IS NOT NULL ");

        List<Object> params = new ArrayList<>();

        if (cluster != null && !cluster.trim().isEmpty()) {
            sql.append("AND CLUSTER_NAME = ? ");
            params.add(cluster.trim());
        }

        if (month != null && !month.trim().isEmpty()) {
            sql.append("AND PAY_MONTH = ? ");
            params.add(month.trim().toUpperCase(Locale.ENGLISH));
        }

        if (year != null && !year.trim().isEmpty()) {
            sql.append("AND PAY_YEAR = ? ");
            params.add(Integer.parseInt(year.trim()));
        }

        sql.append("ORDER BY DB_STATUS ASC");

        try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String val = rs.getString(1);
                    if (val != null && !val.trim().isEmpty()) {
                        list.add(val.trim());
                    }
                }
            }
        }
        return list;
    }
    
    public int updateDbStatusBatch(
            InputStream inputStream,
            String cluster,
            String month,
            int year) throws Exception {

        cluster = cluster.trim();
        month = month.trim().toUpperCase(Locale.ENGLISH);

        Workbook workbook = WorkbookFactory.create(inputStream);
        Sheet sheet = workbook.getSheetAt(0);
        DataFormatter formatter = new DataFormatter();

        int headerRowIndex = -1;
        int codeCol = -1;
        int statusCol = -1;

        for (int r = 0; r <= Math.min(10, sheet.getLastRowNum()); r++) {
            Row row = sheet.getRow(r);
            if (row == null) continue;

            for (int c = 0; c < row.getLastCellNum(); c++) {
                Cell cell = row.getCell(c, Row.RETURN_BLANK_AS_NULL);
                if (cell != null) {
                    String header = normalizeHeader(formatter.formatCellValue(cell));
                    if (codeCol == -1 && (header.equals("CODE") || header.equals("EMPCODE") || header.equals("EMP_CODE") || header.equals("EMPLOYEE_CODE"))) {
                        codeCol = c;
                    }
                    if (statusCol == -1 && (header.equals("DB_STATUS") || header.equals("STATUS") || header.equals("PAYMENT_STATUS") || header.equals("DBSTATUS"))) {
                        statusCol = c;
                    }
                }
            }
            if (codeCol != -1 && statusCol != -1) {
                headerRowIndex = r;
                break;
            }
        }

        if (headerRowIndex == -1 || codeCol == -1 || statusCol == -1) {
            throw new Exception("Required columns ('code' and 'db_status') not found in the uploaded sheet header.");
        }

        String updateSql = "UPDATE PAY_REGISTER SET DB_STATUS = ? " +
                           "WHERE CODE = ? AND CLUSTER_NAME = ? AND PAY_MONTH = ? AND PAY_YEAR = ?";

        int updatedCount = 0;

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(updateSql)) {
                for (int r = headerRowIndex + 1; r <= sheet.getLastRowNum(); r++) {
                    Row row = sheet.getRow(r);
                    if (row == null || isEmptyRow(row)) continue;

                    String code = getCellValueByIndex(row, codeCol, formatter);
                    String dbStatus = getCellValueByIndex(row, statusCol, formatter);

                    if (isBlank(code) || isBlank(dbStatus)) continue;

                    ps.setString(1, dbStatus.trim());
                    ps.setString(2, code.trim());
                    ps.setString(3, cluster);
                    ps.setString(4, month);
                    ps.setInt(5, year);

                    ps.addBatch();
                    updatedCount++;

                    if (updatedCount % 500 == 0) {
                        ps.executeBatch();
                    }
                }

                int[] batchResults = ps.executeBatch();
                con.commit();

                int actualRowsAffected = 0;
                for (int res : batchResults) {
                    if (res > 0) actualRowsAffected += res;
                    else if (res == PreparedStatement.SUCCESS_NO_INFO) actualRowsAffected++;
                }
                return actualRowsAffected;

            } catch (Exception e) {
                con.rollback();
                throw e;
            }
        }
    }
    
    public boolean updateSingleRecordStatus(
            String empCode, 
            String status, 
            String cluster, 
            String month, 
            String year) throws Exception {

        StringBuilder sql = new StringBuilder("UPDATE PAY_REGISTER SET DB_STATUS = ? WHERE CODE = ?");
        List<Object> params = new ArrayList<>();
        params.add(status.trim());
        params.add(empCode.trim());

        if (cluster != null && !cluster.trim().isEmpty()) {
            sql.append(" AND CLUSTER_NAME = ?");
            params.add(cluster.trim());
        }
        if (month != null && !month.trim().isEmpty()) {
            sql.append(" AND PAY_MONTH = ?");
            params.add(month.trim().toUpperCase(Locale.ENGLISH));
        }
        if (year != null && !year.trim().isEmpty()) {
            sql.append(" AND PAY_YEAR = ?");
            params.add(Integer.parseInt(year.trim()));
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            return ps.executeUpdate() > 0;
        }
    }
}