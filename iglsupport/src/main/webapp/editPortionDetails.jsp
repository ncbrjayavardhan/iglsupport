<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Portion Details</title>
    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            margin: 25px;
            background-color: #f4f6f9;
        }
        .form-card {
            max-width: 500px;
            margin: 40px auto;
            background-color: #ffffff;
            border-radius: 6px;
            padding: 25px 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h2 {
            margin-top: 0;
            color: #1f4e78;
            font-size: 20px;
            border-bottom: 2px solid #eef2f5;
            padding-bottom: 10px;
        }
        .form-group {
            margin-bottom: 16px;
        }
        label {
            display: block;
            margin-bottom: 6px;
            font-size: 13px;
            font-weight: 600;
            color: #495057;
        }
        input[type="text"], input[type="number"], input[type="date"] {
            width: 100%;
            padding: 8px 10px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            font-size: 13px;
            box-sizing: border-box;
            outline: none;
        }
        input:focus {
            border-color: #1f4e78;
        }
        input[readonly] {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
        .btn-group {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }
        .btn {
            padding: 8px 18px;
            border: none;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
        }
        .btn-save { background-color: #28a745; color: white; }
        .btn-save:hover { background-color: #218838; }
        .btn-cancel { background-color: #6c757d; color: white; }
        .btn-cancel:hover { background-color: #5a6268; }
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
            font-size: 13px;
        }
    </style>
</head>
<body>

<div class="form-card">
    <h2>Edit Portion: ${detail.pid} (${detail.gaName})</h2>

    <c:if test="${param.msg eq 'error'}">
        <div class="alert-danger">Failed to save changes. Please check input values.</div>
    </c:if>

    <form action="PortionDetailsServlet" method="post">
        <div class="form-group">
            <label>Portion ID (PID)</label>
            <input type="number" name="pid" value="${detail.pid}" readonly />
        </div>

        <div class="form-group">
            <label>Total Data (Target Count)</label>
            <input type="number" name="totalData" value="${detail.totalData}" placeholder="e.g. 1500" />
        </div>

        <div class="form-group">
            <label>Start Date</label>
            <input type="date" name="startDate" value="${detail.startDate}" required />
        </div>

        <div class="form-group">
            <label>End Date</label>
            <input type="date" name="endDate" value="${detail.endDate}" required />
        </div>

        <div class="btn-group">
            <a href="PortionDetailsServlet" class="btn btn-cancel">Cancel</a>
            <button type="submit" class="btn btn-save">Save Changes</button>
        </div>
    </form>
</div>

</body>
</html>