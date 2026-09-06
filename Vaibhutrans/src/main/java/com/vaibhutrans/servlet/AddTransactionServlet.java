package com.vaibhutrans.servlet;

import com.vaibhutrans.dao.TransactionDAO;
import com.vaibhutrans.model.Transaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;

@WebServlet("/addTransaction")
public class AddTransactionServlet extends HttpServlet {
    private TransactionDAO dao = new TransactionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("add_transaction.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String utrNo = request.getParameter("utrNo");
            Date txDate = Date.valueOf(request.getParameter("transactionDate"));
            String debitAcc = request.getParameter("debitAccount");
            String benfAcc = request.getParameter("benfAccount");
            double amount = Double.parseDouble(request.getParameter("amount"));
            String paymentMode = request.getParameter("paymentMode");
            String status = request.getParameter("status");
            String narration = request.getParameter("narration");
            String tallyledger = request.getParameter("tallyledger");
            String project = request.getParameter("project");

            String benfName = request.getParameter("benfName");
            String benfIfsc = request.getParameter("benfIfsc");
            String benfBank = request.getParameter("benfBank");
            String benfBranch = request.getParameter("benfBranch");

            Transaction tx = new Transaction(utrNo, txDate, debitAcc, benfAcc, amount, paymentMode, status, narration, tallyledger, project);
            dao.saveSingleTransaction(tx, benfName, benfIfsc, benfBank, benfBranch);

            request.setAttribute("message", "Transaction added successfully!");
            request.getRequestDispatcher("add_transaction.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error saving transaction: " + e.getMessage());
            request.getRequestDispatcher("add_transaction.jsp").forward(request, response);
        }
    }
}