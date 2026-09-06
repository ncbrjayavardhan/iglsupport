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
import java.util.Map;

@WebServlet("/lookupBeneficiary")
public class LookupBeneficiaryServlet extends HttpServlet {
    private TransactionDAO dao = new TransactionDAO();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String account = request.getParameter("account");
        Map<String, Object> result = new HashMap<>();

        try {
            BankDetail bd = dao.getBankDetailByAccount(account);
            if (bd != null) {
                result.put("found", true);
                result.put("benfName", bd.getBenfName());
                result.put("benfIfsc", bd.getBenfIfsc());
                result.put("benfBank", bd.getBenfBank());
                result.put("benfBranch", bd.getBenfBranch());
            } else {
                result.put("found", false);
            }
        } catch (Exception e) {
            result.put("found", false);
        }

        PrintWriter out = response.getWriter();
        out.print(new Gson().toJson(result));
        out.flush();
    }
}