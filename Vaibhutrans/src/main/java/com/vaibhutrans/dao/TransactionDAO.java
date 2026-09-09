package com.vaibhutrans.dao;

import com.vaibhutrans.config.DBConnection;
import com.vaibhutrans.model.Transaction;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

public class TransactionDAO {

    public void saveTransactionsBatch(List<Transaction> list) throws SQLException {
        String sql = "MERGE INTO transactions t USING DUAL ON (t.utr_no = ?) " +
                     "WHEN MATCHED THEN UPDATE SET t.transaction_date=?, t.debit_account=?, t.benf_account=?, " +
                     "t.amount=?, t.payment_mode=?, t.status=?, t.narration=?, t.tallyledger=?, t.project=? " +
                     "WHEN NOT MATCHED THEN INSERT (utr_no, transaction_date, debit_account, benf_account, " +
                     "amount, payment_mode, status, narration, tallyledger, project) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            conn.setAutoCommit(false);
            for (Transaction tx : list) {
                // 1. ON Clause Parameter
                ps.setString(1, tx.getUtrNo());
                
                // UPDATE Bindings (2 - 10)
                ps.setDate(2, tx.getTransactionDate());
                ps.setString(3, tx.getDebitAccount());
                ps.setString(4, tx.getBenfAccount());
                ps.setDouble(5, tx.getAmount());
                ps.setString(6, tx.getPaymentMode());
                ps.setString(7, tx.getStatus());
                ps.setString(8, tx.getNarration());
                ps.setString(9, tx.getTallyledger());
                ps.setString(10, tx.getProject());

                // INSERT Bindings (11 - 20)
                ps.setString(11, tx.getUtrNo());
                ps.setDate(12, tx.getTransactionDate());
                ps.setString(13, tx.getDebitAccount());
                ps.setString(14, tx.getBenfAccount());
                ps.setDouble(15, tx.getAmount());
                ps.setString(16, tx.getPaymentMode());
                ps.setString(17, tx.getStatus());
                ps.setString(18, tx.getNarration());
                ps.setString(19, tx.getTallyledger());
                ps.setString(20, tx.getProject());

                ps.addBatch();
            }
            ps.executeBatch();
            conn.commit();
        }
    }

    public List<Transaction> getAllTransactionsWithBankDetails() throws SQLException {
        List<Transaction> list = new ArrayList<>();
        String sql = "SELECT t.*, b.benf_name, b.benf_ifsc, b.benf_branch, b.benf_bank " +
                     "FROM transactions t LEFT JOIN bank_details b ON t.benf_account = b.benf_account " +
                     "ORDER BY t.transaction_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Transaction tx = new Transaction(
                    rs.getString("utr_no"),
                    rs.getDate("transaction_date"),
                    rs.getString("debit_account"),
                    rs.getString("benf_account"),
                    rs.getDouble("amount"),
                    rs.getString("payment_mode"),
                    rs.getString("status"),
                    rs.getString("narration"),
                    rs.getString("tallyledger"),
                    rs.getString("project")
                );
                tx.setBenfName(rs.getString("benf_name"));
                tx.setBenfIfsc(rs.getString("benf_ifsc"));
                tx.setBenfBranch(rs.getString("benf_branch"));
                tx.setBenfBank(rs.getString("benf_bank"));
                list.add(tx);
            }
        }
        return list;
    }

    public Transaction getTransactionByUtr(String utrNo) throws SQLException {
        String sql = "SELECT t.*, b.benf_name, b.benf_ifsc, b.benf_branch, b.benf_bank " +
                     "FROM transactions t LEFT JOIN bank_details b ON t.benf_account = b.benf_account " +
                     "WHERE t.utr_no = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, utrNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Transaction tx = new Transaction(
                        rs.getString("utr_no"),
                        rs.getDate("transaction_date"),
                        rs.getString("debit_account"),
                        rs.getString("benf_account"),
                        rs.getDouble("amount"),
                        rs.getString("payment_mode"),
                        rs.getString("status"),
                        rs.getString("narration"),
                        rs.getString("tallyledger"),
                        rs.getString("project")
                    );
                    tx.setBenfName(rs.getString("benf_name"));
                    tx.setBenfIfsc(rs.getString("benf_ifsc"));
                    tx.setBenfBranch(rs.getString("benf_branch"));
                    tx.setBenfBank(rs.getString("benf_bank"));
                    return tx;
                }
            }
        }
        return null;
    }

    public boolean updateTransaction(Transaction tx) throws SQLException {
        String sql = "UPDATE transactions SET transaction_date=?, debit_account=?, benf_account=?, " +
                     "amount=?, payment_mode=?, status=?, narration=?, tallyledger=?, project=? WHERE utr_no=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, tx.getTransactionDate());
            ps.setString(2, tx.getDebitAccount());
            ps.setString(3, tx.getBenfAccount());
            ps.setDouble(4, tx.getAmount());
            ps.setString(5, tx.getPaymentMode());
            ps.setString(6, tx.getStatus());
            ps.setString(7, tx.getNarration());
            ps.setString(8, tx.getTallyledger());
            ps.setString(9, tx.getProject());
            ps.setString(10, tx.getUtrNo());

            return ps.executeUpdate() > 0;
        }
    }
    
 // Check BANK_DETAILS for existing beneficiary autofill
    public com.vaibhutrans.model.BankDetail getBankDetailByAccount(String benfAccount) throws SQLException {
        String sql = "SELECT * FROM bank_details WHERE benf_account = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, benfAccount);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    com.vaibhutrans.model.BankDetail bd = new com.vaibhutrans.model.BankDetail();
                    bd.setBenfAccount(rs.getString("benf_account"));
                    bd.setBenfName(rs.getString("benf_name"));
                    bd.setBenfIfsc(rs.getString("benf_ifsc"));
                    bd.setBenfBranch(rs.getString("benf_branch"));
                    bd.setBenfBank(rs.getString("benf_bank"));
                    return bd;
                }
            }
        }
        return null;
    }

    // Save single transaction (inserts into transactions and optionally updates/inserts bank_details if new)
    public void saveSingleTransaction(Transaction tx, String benfName, String benfIfsc, String benfBank, String benfBranch) throws SQLException {
        String txSql = "MERGE INTO transactions t USING DUAL ON (t.utr_no = ?) " +
                       "WHEN MATCHED THEN UPDATE SET t.transaction_date=?, t.debit_account=?, t.benf_account=?, " +
                       "t.amount=?, t.payment_mode=?, t.status=?, t.narration=?, t.tallyledger=?, t.project=? " +
                       "WHEN NOT MATCHED THEN INSERT (utr_no, transaction_date, debit_account, benf_account, " +
                       "amount, payment_mode, status, narration, tallyledger, project) " +
                       "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        String bankSql = "MERGE INTO bank_details b USING DUAL ON (b.benf_account = ?) " +
                         "WHEN MATCHED THEN UPDATE SET b.benf_name=?, b.benf_ifsc=?, b.benf_branch=?, b.benf_bank=? " +
                         "WHEN NOT MATCHED THEN INSERT (benf_account, benf_name, benf_ifsc, benf_branch, benf_bank) " +
                         "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            // 1. Save/Update Transaction
            try (PreparedStatement ps = conn.prepareStatement(txSql)) {
                ps.setString(1, tx.getUtrNo());
                ps.setDate(2, tx.getTransactionDate());
                ps.setString(3, tx.getDebitAccount());
                ps.setString(4, tx.getBenfAccount());
                ps.setDouble(5, tx.getAmount());
                ps.setString(6, tx.getPaymentMode());
                ps.setString(7, tx.getStatus());
                ps.setString(8, tx.getNarration());
                ps.setString(9, tx.getTallyledger());
                ps.setString(10, tx.getProject());

                ps.setString(11, tx.getUtrNo());
                ps.setDate(12, tx.getTransactionDate());
                ps.setString(13, tx.getDebitAccount());
                ps.setString(14, tx.getBenfAccount());
                ps.setDouble(15, tx.getAmount());
                ps.setString(16, tx.getPaymentMode());
                ps.setString(17, tx.getStatus());
                ps.setString(18, tx.getNarration() != null ? tx.getNarration() : tx.getNarration());
                ps.setString(19, tx.getTallyledger());
                ps.setString(20, tx.getProject());
                ps.executeUpdate();
            }

            // 2. Save/Update Bank Details (if beneficiary info provided)
            if (tx.getBenfAccount() != null && !tx.getBenfAccount().trim().isEmpty()) {
                try (PreparedStatement psBank = conn.prepareStatement(bankSql)) {
                    psBank.setString(1, tx.getBenfAccount());
                    psBank.setString(2, benfName);
                    psBank.setString(3, benfIfsc);
                    psBank.setString(4, benfBranch);
                    psBank.setString(5, benfBank);

                    psBank.setString(6, tx.getBenfAccount());
                    psBank.setString(7, benfName);
                    psBank.setString(8, benfIfsc);
                    psBank.setString(9, benfBranch);
                    psBank.setString(10, benfBank);
                    psBank.executeUpdate();
                }
            }

            conn.commit();
        }
    }
 // Fetch unique Tally Ledgers and Projects associated ONLY with the given beneficiary account
    public Map<String, List<String>> getSuggestionsByBeneficiary(String benfAccount) throws SQLException {
        Map<String, List<String>> suggestions = new HashMap<>();
        List<String> ledgers = new ArrayList<>();
        List<String> projects = new ArrayList<>();

        String sqlBeneficiaryLedger = "SELECT DISTINCT tallyledger FROM transactions WHERE benf_account = ? AND tallyledger IS NOT NULL AND LENGTH(TRIM(tallyledger)) > 0";
        String sqlBeneficiaryProject = "SELECT DISTINCT project FROM transactions WHERE benf_account = ? AND project IS NOT NULL AND LENGTH(TRIM(project)) > 0";

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Fetch Tally Ledgers exclusively for this beneficiary
            try (PreparedStatement ps = conn.prepareStatement(sqlBeneficiaryLedger)) {
                ps.setString(1, benfAccount);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String val = rs.getString(1);
                        if (val != null && !val.trim().isEmpty()) {
                            ledgers.add(val.trim());
                        }
                    }
                }
            }

            // 2. Fetch Projects exclusively for this beneficiary
            try (PreparedStatement psProj = conn.prepareStatement(sqlBeneficiaryProject)) {
                psProj.setString(1, benfAccount);
                try (ResultSet rsProj = psProj.executeQuery()) {
                    while (rsProj.next()) {
                        String val = rsProj.getString(1);
                        if (val != null && !val.trim().isEmpty()) {
                            projects.add(val.trim());
                        }
                    }
                }
            }
        }

        suggestions.put("tallyledgers", ledgers);
        suggestions.put("projects", projects);
        return suggestions;
    }
    
 // Fetch beneficiary name suggestions from BANK_DETAILS
    public List<String> searchBeneficiaryNames(String query) throws SQLException {
        List<String> names = new ArrayList<>();
        String sql = "SELECT DISTINCT benf_name FROM bank_details WHERE UPPER(benf_name) LIKE UPPER(?) AND benf_name IS NOT NULL AND LENGTH(TRIM(benf_name)) > 0 ORDER BY benf_name ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + query + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("benf_name");
                    if (name != null && !name.trim().isEmpty()) {
                        names.add(name.trim());
                    }
                }
            }
        }
        return names;
    }

    // Fetch bank details by exact beneficiary name
    public com.vaibhutrans.model.BankDetail getBankDetailByName(String benfName) throws SQLException {
        String sql = "SELECT * FROM bank_details WHERE UPPER(benf_name) = UPPER(?) AND ROWNUM = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, benfName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    com.vaibhutrans.model.BankDetail bd = new com.vaibhutrans.model.BankDetail();
                    bd.setBenfAccount(rs.getString("benf_account"));
                    bd.setBenfName(rs.getString("benf_name"));
                    bd.setBenfIfsc(rs.getString("benf_ifsc"));
                    bd.setBenfBranch(rs.getString("benf_branch"));
                    bd.setBenfBank(rs.getString("benf_bank"));
                    return bd;
                }
            }
        }
        return null;
    }
    
 // Add inside TransactionDAO.java
    public List<Map<String, String>> getTallyHeaderData() throws SQLException {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT DISTINCT benf_account, tallyledger,project FROM transactions ORDER BY benf_account ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, String> row = new java.util.LinkedHashMap<>();
                row.put("benf_account", rs.getString("benf_account") != null ? rs.getString("benf_account").trim() : "");
                row.put("tallyledger", rs.getString("tallyledger") != null ? rs.getString("tallyledger").trim() : "");
                row.put("project", rs.getString("project") != null ? rs.getString("project").trim() : "");
                list.add(row);
            }
        }
        return list;
    }
}