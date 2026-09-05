<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Random" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login</title>
<style>
    /* body {
        font-family: Arial, sans-serif;
        background-color: rgb(2, 6, 25);
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
    }
    .login-card {
        background: #ffffff;
        padding: 30px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        width: 320px;
    } */
    body {
            font-family: Arial, sans-serif;
            background-color: rgb(2, 6, 25);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 15px;
            box-sizing: border-box;
        }
        .login-card {
            background: #ffffff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 340px;
            box-sizing: border-box;
        }
    .login-card h2 {
        margin-top: 0;
        text-align: center;
        color: #333;
    }
    .form-group {
        margin-bottom: 16px;
    }
    .form-group label {
        display: block;
        margin-bottom: 6px;
        color: #555;
        font-size: 14px;
    }
    .form-group input {
        width: 100%;
        padding: 9px;
        box-sizing: border-box;
        border: 1px solid #ccc;
        border-radius: 4px;
    }
    .captcha-box {
        background-color: #f1f3f5;
        padding: 8px;
        border-radius: 4px;
        font-weight: bold;
        color: #2c3e50;
        text-align: center;
        letter-spacing: 1px;
        margin-bottom: 6px;
        border: 1px dashed #cbd5e1;
    }
    .btn-submit {
        width: 100%;
        padding: 10px;
        background-color: #007bff;
        border: none;
        color: #fff;
        font-size: 15px;
        font-weight: bold;
        border-radius: 4px;
        cursor: pointer;
    }
    .btn-submit:hover {
        background-color: #0056b3;
    }
    .error-msg {
        background-color: #ffe6e6;
        color: #d93025;
        padding: 10px;
        border-radius: 4px;
        margin-bottom: 15px;
        font-size: 13px;
        text-align: center;
        border: 1px solid #f5c6cb;
    }
</style>
</head>
<body>

<div class="login-card">
    <h2>Sign In</h2>
    
    <%
        String msg = request.getParameter("msg");
        if ("logged_out".equals(msg)) {
    %>
        <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 13px; text-align: center; border: 1px solid #c3e6cb;">
            You have successfully logged out.
        </div>
    <%
        } else if ("session_expired".equals(msg)) {
    %>
        <div style="background-color: #fff3cd; color: #856404; padding: 10px; border-radius: 4px; margin-bottom: 15px; font-size: 13px; text-align: center; border: 1px solid #ffeeba;">
            Your session has expired due to inactivity. Please log in again.
        </div>
    <%
        }
    %>

    <%-- Error message display --%>
    <%
        String errorMessage = (String) request.getAttribute("errorMessage");
        if (errorMessage != null && !errorMessage.isEmpty()) {
    %>
        <div class="error-msg"><%= errorMessage %></div>
    <%
        }
    %>

    <%
        // Generate random math CAPTCHA numbers (e.g. between 1 and 10)
        Random random = new Random();
        int num1 = random.nextInt(9) + 1;
        int num2 = random.nextInt(9) + 1;
        int captchaAnswer = num1 + num2;
        
        // Store answer in session for backend validation in LoginServlet
        session.setAttribute("expectedCaptcha", captchaAnswer);
    %>

    <form action="LoginServlet" method="POST">
        <div class="form-group">
            <label for="userId">User ID</label>
            <input type="text" id="userId" name="userId" required autocomplete="off" />
        </div>

        <div class="form-group">
            <label for="pwd">Password</label>
            <input type="password" id="pwd" name="pwd" required />
        </div>

        <div class="form-group">
            <label for="captcha">Solve the Math CAPTCHA</label>
            <div class="captcha-box"><%= num1 %> + <%= num2 %> = ?</div>
            <input type="number" id="captcha" name="captcha" placeholder="Enter answer" required autocomplete="off" />
        </div>

        <button type="submit" class="btn-submit">Login</button>
    </form>
</div>

</body>
</html>
