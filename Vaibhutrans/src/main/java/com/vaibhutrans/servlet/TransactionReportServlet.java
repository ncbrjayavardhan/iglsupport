package com.vaibhutrans.servlet;

import com.google.gson.Gson;
import com.vaibhutrans.dao.TransactionDAO;
import com.vaibhutrans.model.Transaction;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/report")
public class TransactionReportServlet extends HttpServlet {
    private TransactionDAO dao = new TransactionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("tallyheader".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                List<Map<String, String>> data = dao.getTallyHeaderData();
                out.print(new Gson().toJson(data));
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().print("[]");
            }
            return;
        }

        try {
            List<Transaction> list = dao.getAllTransactionsWithBankDetails();
            request.setAttribute("transactions", list);
            request.getRequestDispatcher("report.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Unable to load report.");
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        }
    }
}