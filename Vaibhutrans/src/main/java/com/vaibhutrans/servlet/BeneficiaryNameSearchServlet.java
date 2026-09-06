package com.vaibhutrans.servlet;

import com.google.gson.Gson;
import com.vaibhutrans.dao.TransactionDAO;
import com.vaibhutrans.model.BankDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/beneficiaryNameSearch")
public class BeneficiaryNameSearchServlet extends HttpServlet {
    private TransactionDAO dao = new TransactionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String query = request.getParameter("q");
        String exactName = request.getParameter("exact");
        PrintWriter out = response.getWriter();

        try {
            if (exactName != null && !exactName.trim().isEmpty()) {
                // Return account details for exact name selection
                BankDetail bd = dao.getBankDetailByName(exactName);
                Map<String, Object> result = new HashMap<>();
                if (bd != null) {
                    result.put("found", true);
                    result.put("benfAccount", bd.getBenfAccount());
                    result.put("benfIfsc", bd.getBenfIfsc());
                    result.put("benfBank", bd.getBenfBank());
                    result.put("benfBranch", bd.getBenfBranch());
                } else {
                    result.put("found", false);
                }
                out.print(new Gson().toJson(result));
            } else if (query != null && !query.trim().isEmpty()) {
                // Return list of name suggestions matching query
                List<String> names = dao.searchBeneficiaryNames(query);
                out.print(new Gson().toJson(names));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            out.flush();
        }
    }
}