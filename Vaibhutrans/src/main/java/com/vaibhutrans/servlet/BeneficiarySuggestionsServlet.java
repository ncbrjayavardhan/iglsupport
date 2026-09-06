package com.vaibhutrans.servlet;

import com.google.gson.Gson;
import com.vaibhutrans.dao.TransactionDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/beneficiarySuggestions")
public class BeneficiarySuggestionsServlet extends HttpServlet {
    private TransactionDAO dao = new TransactionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String account = request.getParameter("account");

        try {
            Map<String, List<String>> suggestions = dao.getSuggestionsByBeneficiary(account);
            PrintWriter out = response.getWriter();
            out.print(new Gson().toJson(suggestions));
            out.flush();
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}