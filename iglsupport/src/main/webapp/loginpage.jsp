<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Random" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login</title>
<style>
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
    .captcha-container {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 8px;
    }
    .captcha-box {
        background-color: #f8fafc;
        padding: 10px;
        border-radius: 6px;
        font-weight: bold;
        color: #1e293b;
        text-align: center;
        letter-spacing: 1.5px;
        border: 1px solid #cbd5e1;
        flex-grow: 1;
        font-size: 15px;
    }
    /* Modern, polished refresh button style */
    .btn-refresh-captcha {
        background-color: #f1f5f9;
        color: #475569;
        border: 1px solid #cbd5e1;
        padding: 0 12px;
        border-radius: 6px;
        cursor: pointer;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
    }
    .btn-refresh-captcha:hover {
        background-color: #e2e8f0;
        color: #0f172a;
        border-color: #94a3b8;
    }
    .btn-refresh-captcha svg {
        width: 18px;
        height: 18px;
        fill: currentColor;
        transition: transform 0.3s ease;
    }
    .btn-refresh-captcha:hover svg {
        transform: rotate(180deg); /* Smooth spin effect on hover */
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
        // Generate random math CAPTCHA with multiple operations (+, -, *, /)
        Random random = new Random();
        int operatorType = random.nextInt(4);
        int num1 = 0, num2 = 0, captchaAnswer = 0;
        String operatorSymbol = "";

        switch (operatorType) {
            case 0: // Addition
                num1 = random.nextInt(15) + 1;
                num2 = random.nextInt(15) + 1;
                captchaAnswer = num1 + num2;
                operatorSymbol = "+";
                break;
            case 1: // Subtraction
                num1 = random.nextInt(15) + 5;
                num2 = random.nextInt(num1) + 1;
                captchaAnswer = num1 - num2;
                operatorSymbol = "-";
                break;
            case 2: // Multiplication
                num1 = random.nextInt(9) + 1;
                num2 = random.nextInt(9) + 1;
                captchaAnswer = num1 * num2;
                operatorSymbol = "×";
                break;
            case 3: // Division
                num2 = random.nextInt(9) + 1;
                int multiplier = random.nextInt(9) + 1;
                num1 = num2 * multiplier;
                captchaAnswer = num1 / num2;
                operatorSymbol = "÷";
                break;
        }
        
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
            <label for="captcha">Solve the CAPTCHA</label>
            <div class="captcha-container">
                <div class="captcha-box"><%= num1 %> <%= operatorSymbol %> <%= num2 %> = ?</div>
                <!-- Clean professional SVG Refresh Icon with a subtle rotation animation effect on hover -->
                <button type="button" class="btn-refresh-captcha" onclick="refreshCaptcha()" title="Refresh CAPTCHA">
                    <svg viewBox="0 0 24 24">
                        <path d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
                    </svg>
                </button>
            </div>
            <input type="number" id="captcha" name="captcha" placeholder="Enter answer" required autocomplete="off" />
        </div>

        <button type="submit" class="btn-submit">Login</button>
    </form>
</div>

<script>
    function refreshCaptcha() {
        window.location.reload();
    }
</script>

</body>
</html>