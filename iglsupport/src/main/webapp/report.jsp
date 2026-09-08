<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    String currentUser = (String) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("loginpage.jsp?msg=session_expired");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Reading & Invoice Progress Report</title>
    <style>
        body {
		    margin: 10px;
		    padding: 0;
		    background-color: #f4f6f9;
            font-family: Arial, Helvetica, sans-serif;
		}
		.report-card {
		    padding: 12px;
            background-color: #ffffff;
            border-radius: 6px;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
		}
		.report-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        } 
		.table-responsive {
		    overflow-x: auto;
		    -webkit-overflow-scrolling: touch;
		    margin-top: 10px;
		    border: 1px solid #cbd5e1;
		    border-radius: 4px;
		}
		.mobile-scroll-hint {
		    display: none;
		    font-size: 11px;
		    color: #64748b;
		    text-align: right;
		    margin-bottom: 5px;
		    font-style: italic;
		}
		@media (max-width: 768px) {
		    .mobile-scroll-hint {
		        display: block;
		    }
		    .report-header {
		        flex-direction: column;
		        align-items: flex-start;
		        gap: 10px;
		    }
		}
        h2 {
            margin: 0;
            color: #2c3e50;
            font-size: 20px;
        }
        .btn {
            padding: 6px 14px;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 13px;
            display: inline-block;
        }
        .btn-refresh { background-color: #3498db; }
        .btn-refresh:hover { background-color: #2980b9; }
        .btn-dash { background-color: #6c757d; margin-right: 5px; }
        .btn-dash:hover { background-color: #5a6268; }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            text-align: center;
        }
        th, td {
            border: 1px solid #c8d1dc;
            padding: 8px 9px;
            white-space: nowrap;
        }
        th {
            background-color: #1f4e78;
            color: #ffffff;
            font-weight: 600;
            vertical-align: middle;
            position: relative;
        }
        .filter-header-cell {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 5px;
        }
        .filter-label {
            font-size: 13px;
            font-weight: 600;
            color: #ffffff;
            letter-spacing: 0.3px;
        }
        .pill-select {
            background-color: #ffffff;
            color: #1f4e78;
            border: 1px solid #ffffff;
            border-radius: 16px;
            padding: 2px 8px;
            font-size: 11px;
            font-weight: bold;
            outline: none;
            cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.18);
            max-width: 130px;
            text-align: center;
            transition: all 0.2s ease-in-out;
        }
        .pill-select:focus, .pill-select:hover {
            border-color: #ffc107;
            box-shadow: 0 0 0 2px rgba(255, 193, 7, 0.4);
        }
        .custom-dropdown {
            position: relative;
            display: inline-block;
        }
        .custom-dropdown-btn {
            background-color: #ffffff;
            color: #1f4e78;
            border: 1px solid #ffffff;
            border-radius: 16px;
            padding: 3px 10px;
            font-size: 11px;
            font-weight: bold;
            outline: none;
            cursor: pointer;
            box-shadow: 0 1px 3px rgba(0,0,0,0.18);
            text-align: center;
            min-width: 75px;
        }
        .custom-dropdown-btn:hover {
            border-color: #ffc107;
            box-shadow: 0 0 0 2px rgba(255, 193, 7, 0.4);
        }
        .custom-dropdown-menu {
            display: none;
            position: absolute;
            top: 100%;
            left: 50%;
            transform: translateX(-50%);
            background-color: #ffffff;
            min-width: 160px;
            box-shadow: 0 8px 16px rgba(0,0,0,0.2);
            border-radius: 8px;
            z-index: 1005;
            border: 1px solid #cbd5e1;
            padding: 5px 0;
            margin-top: 4px;
            text-align: left;
        }
        .custom-dropdown-menu.show {
            display: block;
        }
        .custom-option {
            padding: 8px 12px;
            font-size: 12px;
            font-weight: 600;
            color: #1e293b;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }
        .custom-option:hover {
            background-color: #f1f5f9;
        }
        .legend-container {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 12px;
            font-size: 12px;
            font-weight: 600;
            color: #495057;
            background: #f8fafc;
            padding: 8px 12px;
            border-radius: 6px;
            border: 1px solid #e2e8f0;
            width: fit-content;
        }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .legend-box {
            width: 14px;
            height: 14px;
            border-radius: 3px;
            display: inline-block;
            flex-shrink: 0;
        }
        .box-low { background-color: #ffd1dc; border: 1px solid #f5c6cb; }
        .box-medium { background-color: #ffe5b4; border: 1px solid #ffeeba; }
        .box-high { background-color: #d4edda; border: 1px solid #c3e6cb; }

        tbody tr:nth-child(even) { background-color: #f8fafc; }
        tbody tr:hover { background-color: #eef2f7; }

        .ga-cell, .city-cell, .state-cell {
            text-align: center;
            font-weight: 600;
            color: #2d3748;
        }
        td.merged-cell {
            text-align: center;
            vertical-align: middle;
            font-weight: 700;
            color: #1f4e78;
            background-color: #ffffff !important;
        }
        .status-running { color: #d9534f; font-weight: 600; }
        .status-completed { color: #27ae60; font-weight: 600; }
        .diff-positive { color: #27ae60; font-weight: bold; }
        .diff-negative { color: #c0392b; font-weight: bold; }
        .total-row {
            font-weight: bold;
            background-color: #d9e1f2 !important;
            color: #000;
        }
        .diff-row {
            font-weight: bold;
            background-color: #fce4d6 !important;
            color: #000;
        }
        .no-data-alert {
            padding: 15px 20px;
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            border-radius: 4px;
            margin-top: 15px;
            font-size: 14px;
        }
        .pill-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 12px;
            text-align: center;
        }
        .badge-low { background-color: #ffd1dc; color: #900c3f; border: 1px solid #f5c6cb; }
        .badge-medium { background-color: #ffe5b4; color: #b78103; border: 1px solid #ffeeba; }
        .badge-high { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    </style>
</head>
<body>

<div class="report-card">
    <div class="report-header">
        <h2>Daily Progress &amp; Invoice Reconciliation Report</h2>
    </div>

    <div class="legend-container" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px; width: 100%; box-sizing: border-box;">
        <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap;">
            <span><strong>Billed % Ranges:</strong></span>
            <div class="legend-item"><span class="legend-box box-low"></span> &lt; 50.00% (Low)</div>
            <div class="legend-item"><span class="legend-box box-medium"></span> 50.00% - 85.00% (Medium)</div>
            <div class="legend-item"><span class="legend-box box-high"></span> &gt; 85.00% (High)</div>
        </div>
        <div>
            <a href="dashboard.jsp" class="btn btn-dash">Dashboard</a>
            <a href="${pageContext.request.contextPath}/ReportServlet" class="btn btn-refresh">Refresh</a>
        </div>
    </div>

    <c:choose>
        <c:when test="${hasData}">
            <div class="mobile-scroll-hint">&larr; Swipe horizontally to view all columns &rarr;</div>
            <div class="table-responsive">
                <table id="reportTable">
                    <thead>
                        <tr>
                            <th>
                                <div class="filter-header-cell">
                                    <span class="filter-label">State</span>
                                    <select id="stateFilter" class="pill-select" onchange="onStateChange()">
                                        <option value="ALL">All States</option>
                                    </select>
                                </div>
                            </th>
                            <th>
                                <div class="filter-header-cell">
                                    <span class="filter-label">City</span>
                                    <select id="cityFilter" class="pill-select" onchange="onCityChange()">
                                        <option value="ALL">All Cities</option>
                                    </select>
                                </div>
                            </th>
                            <th>
                                <div class="filter-header-cell">
                                    <span class="filter-label">GA</span>
                                    <select id="gaFilter" class="pill-select" onchange="onGaChange()">
                                        <option value="ALL">All GA</option>
                                    </select>
                                </div>
                            </th>
                            <th>
                                <div class="filter-header-cell">
                                    <span class="filter-label">Portion</span>
                                    <select id="portionFilter" class="pill-select" onchange="applyFilters()">
                                        <option value="ALL">All</option>
                                    </select>
                                </div>
                            </th>
                            <th>Total <br> Data</th>
                            <th>
                                <div class="filter-header-cell">
                                    <span class="filter-label">Schedule</span>
                                    <select id="scheduleFilter" class="pill-select" onchange="applyFilters()">
                                        <option value="ALL">All</option>
                                    </select>
                                </div>
                            </th>
                            <th>Today <br> Reading</th>
                            <th>Today <br> Inv</th>
                            <th>Yesterday <br> Reading</th>
                            <th>Yesterday <br> Inv</th>
                            <th>Till Y'day <br> Read</th>
                            <th>Till Y'day <br> Inv</th>
                            <th>Total <br> Reading</th>
                            <th>Total <br> Inv</th>
                            <th>Unbilled</th>
                            <th>
                                <div class="filter-header-cell">
                                    <span class="filter-label">Billed %</span>
                                    <div class="custom-dropdown">
                                        <button type="button" id="billedFilterBtn" class="custom-dropdown-btn" onclick="toggleBilledDropdown(event)">All</button>
                                        <div id="billedDropdownMenu" class="custom-dropdown-menu">
                                            <div class="custom-option" onclick="selectBilledOption('ALL', 'All')">All</div>
                                            <div class="custom-option" onclick="selectBilledOption('LOW', '< 50%')">
                                                <span class="legend-box box-low"></span> &lt; 50%
                                            </div>
                                            <div class="custom-option" onclick="selectBilledOption('MEDIUM', '50% - 85%')">
                                                <span class="legend-box box-medium"></span> 50% - 85%
                                            </div>
                                            <div class="custom-option" onclick="selectBilledOption('HIGH', '> 85%')">
                                                <span class="legend-box box-high"></span> &gt; 85%
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </th>
                            <th>
                                <div class="filter-header-cell">
                                    <span class="filter-label">Status</span>
                                    <select id="statusFilter" class="pill-select" onchange="applyFilters()">
                                        <option value="ALL">All</option>
                                        <option value="Running">Running</option>
                                        <option value="Completed">Completed</option>
                                    </select>
                                </div>
                            </th>
                            <th>PerDay <br> Target</th>
                            <th>Diff <br>(Today - Target)</th>
                        </tr>
                    </thead>
                    <tbody id="reportTableBody">
                        <c:forEach var="item" items="${reportList}">
                            <tr class="data-row" 
                                data-state="${item.state}"
                                data-city="${item.city}"
                                data-ga="${item.gaName}"
                                data-portion="${item.portionId}"
                                data-schedule="${item.schedule}"
                                data-status="${item.status}"
                                data-totaldata="${item.totalData != null ? item.totalData : 0}"
                                data-todayread="${item.todayReading}"
                                data-todayinv="${item.todayInv}"
                                data-ydayread="${item.yesterdayReading}"
                                data-ydayinv="${item.yesterdayInv}"
                                data-tillydayread="${item.tillYdayRead}"
                                data-tillydayinv="${item.tillYdayInv}"
                                data-totalread="${item.totalReading}"
                                data-totalinv="${item.totalInv}"
                                data-unbilled="${item.unbilled}"
                                data-billedpct="${item.billedPercent}"
                                data-target="${item.perDayTarget != null ? item.perDayTarget : 0}"
                                data-diff="${item.diff != null ? item.diff : 0}"
                                data-hasdiff="${item.diff != null ? 'true' : 'false'}">

                                <td class="state-cell">${item.state}</td>
                                <td class="city-cell">${item.city}</td>
                                <td class="ga-cell">${item.gaName}</td>
                                <td>
                                    <a href="javascript:void(0);" onclick="openPortionModal(${item.portionId})" style="color: #1f4e78; font-weight: bold; text-decoration: underline;">
                                        ${item.portionId}
                                    </a>
                                </td>
                                <td>${item.totalData != null ? item.totalData : '-'}</td>
                                <td>${item.schedule}</td>
                                <td>${item.todayReading}</td>
                                <td>${item.todayInv}</td>
                                <td>${item.yesterdayReading}</td>
                                <td>${item.yesterdayInv}</td>
                                <td>${item.tillYdayRead}</td>
                                <td>${item.tillYdayInv}</td>
                                <td>${item.totalReading}</td>
                                <td>${item.totalInv}</td>
                                <td>${item.unbilled}</td>
                                <td>
                                    <c:set var="bPct" value="${item.billedPercent}" />
                                    <span class="pill-badge <c:choose><c:when test='${bPct < 50}'>badge-low</c:when><c:when test='${bPct >= 50 && bPct <= 85}'>badge-medium</c:when><c:otherwise>badge-high</c:otherwise></c:choose>">
                                        <fmt:formatNumber value="${bPct}" maxFractionDigits="2" minFractionDigits="2"/>%
                                    </span>
                                </td>
                                <td>
                                    <span class="${item.status eq 'Completed' ? 'status-completed' : 'status-running'}">
                                        ${item.status}
                                    </span>
                                </td>
                                <td>${item.perDayTarget != null ? item.perDayTarget : '-'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.diff != null}">
                                            <span class="${item.diff >= 0 ? 'diff-positive' : 'diff-negative'}">
                                                <c:if test="${item.diff > 0}">+</c:if>${item.diff}
                                            </span>
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                    <tfoot>
                        <tr class="total-row">
                            <td style="text-align: right;" colspan="4">Total</td>
                            <td id="totData">-</td>
                            <td>-</td>
                            <td id="totTodayRead">0</td>
                            <td id="totTodayInv">0</td>
                            <td id="totYdayRead">0</td>
                            <td id="totYdayInv">0</td>
                            <td id="totTillYdayRead">0</td>
                            <td id="totTillYdayInv">0</td>
                            <td id="totTotalRead">0</td>
                            <td id="totTotalInv">0</td>
                            <td id="totUnbilled">0</td>
                            <td>
                                <span id="totBilledPct">0.00%</span>
                            </td>
                            <td>-</td>
                            <td id="totTarget">-</td>
                            <td id="totDiff">-</td>
                        </tr>
                        <tr class="diff-row">
                            <td style="text-align: center;" colspan="6">Variance (Reading - Invoice)</td>
                            <td>-</td>
                            <td id="varToday">0</td>
                            <td>-</td>
                            <td id="varYday">0</td>
                            <td>-</td>
                            <td id="varTillYday">0</td>
                            <td>-</td>
                            <td id="varTotal">0</td>
                            <td colspan="5">-</td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="no-data-alert">
                <strong>Notice:</strong> ${message}
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Portion Details Modal Popup -->
<div id="portionModal" style="display:none; position:fixed; z-index:2000; left:0; top:0; width:100%; height:100%; background-color:rgba(0,0,0,0.5);">
    <div style="background-color:#ffffff; margin:10% auto; padding:20px; border-radius:8px; width:90%; max-width:600px; box-shadow:0 4px 12px rgba(0,0,0,0.2);">
        <div style="display:flex; justify-content:space-between; align-items:center; border-bottom:1px solid #e2e8f0; padding-bottom:10px; margin-bottom:15px;">
            <h3 style="margin:0; color:#1f4e78; font-size:18px;">Portion Details Breakdown (PID: <span id="modalPortionId"></span>)</h3>
            <button onclick="closePortionModal()" style="background:none; border:none; font-size:18px; cursor:pointer; font-weight:bold;">&times;</button>
        </div>
        
        <div style="margin-bottom: 15px; display:flex; gap:15px; font-size:13px; font-weight:600; background:#f8fafc; padding:10px; border-radius:6px; border:1px solid #e2e8f0;">
            <div>Today's Readings: <span id="modalTodayTotal" style="color:#27ae60;">0</span></div>
            <div>Yesterday's Readings: <span id="modalYdayTotal" style="color:#3498db;">0</span></div>
            <div>Total  Readings: <span id="modalScheduleTotal" style="color:#2c3e50;">0</span></div>
        </div>
        
        <div style="max-height:300px; overflow-y:auto;">
            <table style="width:100%; border-collapse:collapse; font-size:12px;">
                <thead>
                    <tr style="background:#1f4e78; color:white;">
                        <th style="padding:6px; border:1px solid #cbd5e1;">Meter Reader ID</th>
                        <th style="padding:6px; border:1px solid #cbd5e1;">User Name</th>
                        <th style="padding:6px; border:1px solid #cbd5e1;">Today's Count</th>
                        <th style="padding:6px; border:1px solid #cbd5e1;">Yesterday's Count</th>
                        <th style="padding:6px; border:1px solid #cbd5e1;">Total Count</th>
                    </tr>
                </thead>
                <tbody id="modalReaderTableBody">
                    <!-- Populated dynamically -->
                </tbody>
            </table>
        </div>

        <div style="text-align:right; margin-top:15px;">
            <button onclick="closePortionModal()" class="btn btn-dash" style="background-color:#64748b;">Close</button>
        </div>
    </div>
</div>

<script>
var allRowElements = [];
var selectedBilledFilter = "ALL";

function initData() {
    allRowElements = Array.from(document.querySelectorAll(".data-row")).map(function(row) {
        return {
            element: row,
            state: (row.getAttribute("data-state") || "").trim(),
            city: (row.getAttribute("data-city") || "").trim(),
            ga: (row.getAttribute("data-ga") || "").trim(),
            portion: (row.getAttribute("data-portion") || "").trim(),
            schedule: (row.getAttribute("data-schedule") || "").trim(),
            status: (row.getAttribute("data-status") || "").trim(),
            totalData: parseInt(row.getAttribute("data-totaldata")) || 0,
            todayRead: parseInt(row.getAttribute("data-todayread")) || 0,
            todayInv: parseInt(row.getAttribute("data-todayinv")) || 0,
            ydayRead: parseInt(row.getAttribute("data-ydayread")) || 0,
            ydayInv: parseInt(row.getAttribute("data-ydayinv")) || 0,
            tillYdayRead: parseInt(row.getAttribute("data-tillydayread")) || 0,
            tillYdayInv: parseInt(row.getAttribute("data-tillydayinv")) || 0,
            totalRead: parseInt(row.getAttribute("data-totalread")) || 0,
            totalInv: parseInt(row.getAttribute("data-totalinv")) || 0,
            unbilled: parseInt(row.getAttribute("data-unbilled")) || 0,
            billedPct: parseFloat(row.getAttribute("data-billedpct")) || 0,
            target: parseInt(row.getAttribute("data-target")) || 0,
            diff: parseInt(row.getAttribute("data-diff")) || 0,
            hasDiff: row.getAttribute("data-hasdiff") === "true"
        };
    });

    updateStateDropdown();
    updateCityDropdown();
    updateGaDropdown();
    updatePortionDropdown();
    updateScheduleDropdown();
    applyFilters();
}

function toggleBilledDropdown(event) {
    event.stopPropagation();
    var menu = document.getElementById("billedDropdownMenu");
    menu.classList.toggle("show");
}

function selectBilledOption(val, labelText) {
    selectedBilledFilter = val;
    document.getElementById("billedFilterBtn").innerText = labelText;
    document.getElementById("billedDropdownMenu").classList.remove("show");
    applyFilters();
}

window.addEventListener("click", function(event) {
    if (!event.target.closest('.custom-dropdown')) {
        var menu = document.getElementById("billedDropdownMenu");
        if (menu && menu.classList.contains("show")) {
            menu.classList.remove("show");
        }
    }
});

function onStateChange() {
    document.getElementById("cityFilter").value = "ALL";
    document.getElementById("gaFilter").value = "ALL";
    document.getElementById("portionFilter").value = "ALL";
    document.getElementById("scheduleFilter").value = "ALL";

    updateCityDropdown();
    updateGaDropdown();
    updatePortionDropdown();
    updateScheduleDropdown();
    applyFilters();
}

function onCityChange() {
    document.getElementById("gaFilter").value = "ALL";
    document.getElementById("portionFilter").value = "ALL";
    document.getElementById("scheduleFilter").value = "ALL";

    updateGaDropdown();
    updatePortionDropdown();
    updateScheduleDropdown();
    applyFilters();
}

function onGaChange() {
    document.getElementById("portionFilter").value = "ALL";
    document.getElementById("scheduleFilter").value = "ALL";

    updatePortionDropdown();
    updateScheduleDropdown();
    applyFilters();
}

function updateStateDropdown() {
    var stateSelect = document.getElementById("stateFilter");
    var currentState = stateSelect.value;
    var uniqueStates = Array.from(new Set(allRowElements.map(r => r.state).filter(s => s && s !== "-"))).sort();
    
    stateSelect.innerHTML = '<option value="ALL">All States</option>';
    uniqueStates.forEach(function(st) {
        var opt = document.createElement("option");
        opt.value = st;
        opt.textContent = st;
        stateSelect.appendChild(opt);
    });
    if (uniqueStates.includes(currentState)) {
        stateSelect.value = currentState;
    }
}

function updateCityDropdown() {
    var selectedState = document.getElementById("stateFilter").value;
    var citySelect = document.getElementById("cityFilter");
    var currentCity = citySelect.value;

    var validRows = allRowElements.filter(function(r) {
        return (selectedState === "ALL" || r.state === selectedState);
    });

    var uniqueCities = Array.from(new Set(validRows.map(r => r.city).filter(c => c && c !== "-"))).sort();
    
    citySelect.innerHTML = '<option value="ALL">All Cities</option>';
    uniqueCities.forEach(function(city) {
        var opt = document.createElement("option");
        opt.value = city;
        opt.textContent = city;
        citySelect.appendChild(opt);
    });

    if (uniqueCities.includes(currentCity)) {
        citySelect.value = currentCity;
    } else {
        citySelect.value = "ALL";
    }
}

function updateGaDropdown() {
    var selectedState = document.getElementById("stateFilter").value;
    var selectedCity = document.getElementById("cityFilter").value;
    var gaSelect = document.getElementById("gaFilter");
    var currentGa = gaSelect.value;

    var validRows = allRowElements.filter(function(r) {
        return (selectedState === "ALL" || r.state === selectedState) &&
               (selectedCity === "ALL" || r.city === selectedCity);
    });

    var uniqueGAs = Array.from(new Set(validRows.map(r => r.ga).filter(g => g && g !== "-"))).sort();
    
    gaSelect.innerHTML = '<option value="ALL">All GA</option>';
    uniqueGAs.forEach(function(ga) {
        var opt = document.createElement("option");
        opt.value = ga;
        opt.textContent = ga;
        gaSelect.appendChild(opt);
    });

    if (uniqueGAs.includes(currentGa)) {
        gaSelect.value = currentGa;
    } else {
        gaSelect.value = "ALL";
    }
}

function updatePortionDropdown() {
    var selectedState = document.getElementById("stateFilter").value;
    var selectedCity = document.getElementById("cityFilter").value;
    var selectedGa = document.getElementById("gaFilter").value;
    var portionSelect = document.getElementById("portionFilter");
    var currentPortion = portionSelect.value;

    var validRows = allRowElements.filter(function(r) {
        return (selectedState === "ALL" || r.state === selectedState) &&
               (selectedCity === "ALL" || r.city === selectedCity) &&
               (selectedGa === "ALL" || r.ga === selectedGa);
    });

    var uniquePortions = Array.from(new Set(validRows.map(r => r.portion).filter(Boolean)))
                              .sort(function(a, b) { return a - b; });

    portionSelect.innerHTML = '<option value="ALL">All</option>';
    uniquePortions.forEach(function(p) {
        var opt = document.createElement("option");
        opt.value = p;
        opt.textContent = p;
        portionSelect.appendChild(opt);
    });

    if (uniquePortions.includes(currentPortion)) {
        portionSelect.value = currentPortion;
    } else {
        portionSelect.value = "ALL";
    }
}

function updateScheduleDropdown() {
    var selectedState = document.getElementById("stateFilter").value;
    var selectedCity = document.getElementById("cityFilter").value;
    var selectedGa = document.getElementById("gaFilter").value;
    var scheduleSelect = document.getElementById("scheduleFilter");
    var currentSchedule = scheduleSelect.value;

    var validRows = allRowElements.filter(function(r) {
        return (selectedState === "ALL" || r.state === selectedState) &&
               (selectedCity === "ALL" || r.city === selectedCity) &&
               (selectedGa === "ALL" || r.ga === selectedGa);
    });

    var uniqueSchedules = Array.from(new Set(validRows.map(r => r.schedule).filter(s => s && s !== "-"))).sort();
    
    scheduleSelect.innerHTML = '<option value="ALL">All</option>';
    uniqueSchedules.forEach(function(s) {
        var opt = document.createElement("option");
        opt.value = s;
        opt.textContent = s;
        scheduleSelect.appendChild(opt);
    });

    if (uniqueSchedules.includes(currentSchedule)) {
        scheduleSelect.value = currentSchedule;
    } else {
        scheduleSelect.value = "ALL";
    }
}

function mergeHierarchyCells() {
    var visibleRows = allRowElements.map(r => r.element)
                                    .filter(el => el.style.display !== "none");
    
    allRowElements.forEach(function(r) {
        for (var c = 0; c < 3; c++) {
            var cell = r.element.cells[c];
            if (cell) {
                cell.rowSpan = 1;
                cell.style.display = "";
                cell.classList.remove("merged-cell");
            }
        }
    });

    var i = 0;
    while (i < visibleRows.length) {
        var firstRow = visibleRows[i];
        var currentState = firstRow.getAttribute("data-state");
        var spanCount = 1;

        var j = i + 1;
        while (j < visibleRows.length && visibleRows[j].getAttribute("data-state") === currentState) {
            visibleRows[j].cells[0].style.display = "none";
            spanCount++;
            j++;
        }
        if (spanCount > 1) {
            firstRow.cells[0].rowSpan = spanCount;
            firstRow.cells[0].classList.add("merged-cell");
        }
        i = j;
    }

    i = 0;
    while (i < visibleRows.length) {
        var firstRow = visibleRows[i];
        var currentState = firstRow.getAttribute("data-state");
        var currentCity = firstRow.getAttribute("data-city");
        var spanCount = 1;

        var j = i + 1;
        while (j < visibleRows.length && 
               visibleRows[j].getAttribute("data-state") === currentState && 
               visibleRows[j].getAttribute("data-city") === currentCity) {
            visibleRows[j].cells[1].style.display = "none";
            spanCount++;
            j++;
        }
        if (spanCount > 1) {
            firstRow.cells[1].rowSpan = spanCount;
            firstRow.cells[1].classList.add("merged-cell");
        }
        i = j;
    }

    i = 0;
    while (i < visibleRows.length) {
        var firstRow = visibleRows[i];
        var currentCity = firstRow.getAttribute("data-city");
        var currentGa = firstRow.getAttribute("data-ga");
        var spanCount = 1;

        var j = i + 1;
        while (j < visibleRows.length && 
               visibleRows[j].getAttribute("data-city") === currentCity && 
               visibleRows[j].getAttribute("data-ga") === currentGa) {
            visibleRows[j].cells[2].style.display = "none";
            spanCount++;
            j++;
        }
        if (spanCount > 1) {
            firstRow.cells[2].rowSpan = spanCount;
            firstRow.cells[2].classList.add("merged-cell");
        }
        i = j;
    }
}

function applyFilters() {
    var vState = document.getElementById("stateFilter").value;
    var vCity = document.getElementById("cityFilter").value;
    var vGa = document.getElementById("gaFilter").value;
    var vPortion = document.getElementById("portionFilter").value;
    var vSchedule = document.getElementById("scheduleFilter").value;
    var vStatus = document.getElementById("statusFilter").value;

    var sumTotalData = 0;
    var sumTodayRead = 0;
    var sumTodayInv = 0;
    var sumYdayRead = 0;
    var sumYdayInv = 0;
    var sumTillYdayRead = 0;
    var sumTillYdayInv = 0;
    var sumTotalRead = 0;
    var sumTotalInv = 0;
    var sumUnbilled = 0;
    var sumTarget = 0;
    var sumDiff = 0;
    var hasTargetCount = 0;

    allRowElements.forEach(function(row) {
        var matchState = (vState === "ALL" || row.state === vState);
        var matchCity = (vCity === "ALL" || row.city === vCity);
        var matchGa = (vGa === "ALL" || row.ga === vGa);
        var matchPortion = (vPortion === "ALL" || row.portion === vPortion);
        var matchSchedule = (vSchedule === "ALL" || row.schedule === vSchedule);
        var matchStatus = (vStatus === "ALL" || row.status === vStatus);

        var matchBilled = true;
        if (selectedBilledFilter === "LOW") {
            matchBilled = (row.billedPct < 50.0);
        } else if (selectedBilledFilter === "MEDIUM") {
            matchBilled = (row.billedPct >= 50.0 && row.billedPct <= 85.0);
        } else if (selectedBilledFilter === "HIGH") {
            matchBilled = (row.billedPct > 85.0);
        }

        if (matchState && matchCity && matchGa && matchPortion && matchSchedule && matchBilled && matchStatus) {
            row.element.style.display = "";
            sumTotalData += row.totalData;
            sumTodayRead += row.todayRead;
            sumTodayInv += row.todayInv;
            sumYdayRead += row.ydayRead;
            sumYdayInv += row.ydayInv;
            sumTillYdayRead += row.tillYdayRead;
            sumTillYdayInv += row.tillYdayInv;
            sumTotalRead += row.totalRead;
            sumTotalInv += row.totalInv;
            sumUnbilled += row.unbilled;

            if (row.target > 0) {
                sumTarget += row.target;
                hasTargetCount++;
            }
            if (row.hasDiff) {
                sumDiff += row.diff;
            }
        } else {
            row.element.style.display = "none";
        }
    });

    mergeHierarchyCells();

    document.getElementById("totData").innerText = sumTotalData > 0 ? sumTotalData : "-";
    document.getElementById("totTodayRead").innerText = sumTodayRead;
    document.getElementById("totTodayInv").innerText = sumTodayInv;
    document.getElementById("totYdayRead").innerText = sumYdayRead;
    document.getElementById("totYdayInv").innerText = sumYdayInv;
    document.getElementById("totTillYdayRead").innerText = sumTillYdayRead;
    document.getElementById("totTillYdayInv").innerText = sumTillYdayInv;
    document.getElementById("totTotalRead").innerText = sumTotalRead;
    document.getElementById("totTotalInv").innerText = sumTotalInv;
    document.getElementById("totUnbilled").innerText = sumUnbilled;

    var totalBilledPct = sumTotalData > 0 ? ((sumTotalRead / sumTotalData) * 100.0) : 0.0;
    document.getElementById("totBilledPct").innerText = totalBilledPct.toFixed(2) + "%";

    document.getElementById("totTarget").innerText = sumTarget > 0 ? sumTarget : "-";

    var totDiffElem = document.getElementById("totDiff");
    if (hasTargetCount > 0) {
        var prefix = sumDiff > 0 ? "+" : "";
        totDiffElem.className = sumDiff >= 0 ? "diff-positive" : "diff-negative";
        totDiffElem.innerText = prefix + sumDiff;
    } else {
        totDiffElem.className = "";
        totDiffElem.innerText = "-";
    }

    document.getElementById("varToday").innerText = sumTodayRead - sumTodayInv;
    document.getElementById("varYday").innerText = sumYdayRead - sumYdayInv;
    document.getElementById("varTillYday").innerText = sumTillYdayRead - sumTillYdayInv;
    document.getElementById("varTotal").innerText = sumTotalRead - sumTotalInv;
}

/* function openPortionModal(pid) {
    document.getElementById("modalPortionId").innerText = pid;
    document.getElementById("modalTodayTotal").innerText = "...";
    document.getElementById("modalYdayTotal").innerText = "...";
    document.getElementById("modalScheduleTotal").innerText = "...";
    document.getElementById("modalReaderTableBody").innerHTML = '<tr><td colspan="5" style="text-align:center; padding:15px;">Loading details...</td></tr>';
    
    document.getElementById("portionModal").style.display = "block";

    fetch('ReportServlet?action=portionDetails&pid=' + pid)
        .then(function(response) { return response.json(); })
        .then(function(data) {
            if (data.error) {
                alert(data.error);
                closePortionModal();
                return;
            }

            document.getElementById("modalTodayTotal").innerText = data.todayReadings;
            document.getElementById("modalYdayTotal").innerText = data.ydayReadings;
            document.getElementById("modalScheduleTotal").innerText = data.totalScheduleReadings;

            var tbody = document.getElementById("modalReaderTableBody");
            tbody.innerHTML = "";

            if (data.readers && data.readers.length > 0) {
                data.readers.forEach(function(item) {
                    // Hyperlink implementation for meter reader ID (userId) pointing to the daily report servlet
                    var userIdLink = '<a href="MeterReaderDailyReportServlet?userId=' + encodeURIComponent(item.userId) + 
                                     '&userName=' + encodeURIComponent(item.userName) + 
                                     '&gaName=' + encodeURIComponent(item.gaName) + 
                                     '&portionNo=' + encodeURIComponent(item.portionNo) + 
                                     '&scheduleStart=' + encodeURIComponent(item.scheduleStart) + 
                                     '&scheduleEnd=' + encodeURIComponent(item.scheduleEnd) + 
                                     '" target="_blank">' + item.userId + '</a>';

                    var tr = document.createElement("tr");
                    tr.innerHTML = '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center;">' + userIdLink + '</td>' +
                                   '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center;">' + item.userName + '</td>' +
                                   '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center;">' + item.todayCount + '</td>' +
                                   '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center;">' + item.ydayCount + '</td>' +
                                   '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center; font-weight:bold;">' + item.totalCount + '</td>';
                    tbody.appendChild(tr);
                });
            } else {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:15px; color:#64748b;">No reader records found for this portion schedule.</td></tr>';
            }
        })
        .catch(function(err) {
            console.error("Error fetching portion details:", err);
            alert("Failed to load details.");
            closePortionModal();
        });
} */

function openPortionModal(pid) {
    document.getElementById("modalPortionId").innerText = pid;
    document.getElementById("modalTodayTotal").innerText = "...";
    document.getElementById("modalYdayTotal").innerText = "...";
    document.getElementById("modalScheduleTotal").innerText = "...";
    document.getElementById("modalReaderTableBody").innerHTML = '<tr><td colspan="5" style="text-align:center; padding:15px;">Loading details...</td></tr>';
    
    document.getElementById("portionModal").style.display = "block";

    fetch('ReportServlet?action=portionDetails&pid=' + pid)
        .then(function(response) { return response.json(); })
        .then(function(data) {
            if (data.error) {
                alert(data.error);
                closePortionModal();
                return;
            }

            document.getElementById("modalTodayTotal").innerText = data.todayReadings;
            document.getElementById("modalYdayTotal").innerText = data.ydayReadings;
            document.getElementById("modalScheduleTotal").innerText = data.totalScheduleReadings;

            var tbody = document.getElementById("modalReaderTableBody");
            tbody.innerHTML = "";

            if (data.readers && data.readers.length > 0) {
                data.readers.forEach(function(item) {
                    // Explicitly construct URL containing userId, userName, gaName, portionNo, scheduleStart, scheduleEnd
                    var userIdLink = '<a href="MeterReaderDailyReportServlet?userId=' + encodeURIComponent(item.userId || '') + 
                                     '&userName=' + encodeURIComponent(item.userName || '') + 
                                     '&gaName=' + encodeURIComponent(item.gaName || '') + 
                                     '&portionNo=' + encodeURIComponent(item.portionNo || '') + 
                                     '&scheduleStart=' + encodeURIComponent(item.scheduleStart || '') + 
                                     '&scheduleEnd=' + encodeURIComponent(item.scheduleEnd || '') + 
                                     '" target="_blank">' + item.userId + '</a>';

                    var tr = document.createElement("tr");
                    tr.innerHTML = '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center;">' + userIdLink + '</td>' +
                                   '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center;">' + item.userName + '</td>' +
                                   '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center;">' + item.todayCount + '</td>' +
                                   '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center;">' + item.ydayCount + '</td>' +
                                   '<td style="padding:6px; border:1px solid #cbd5e1; text-align:center; font-weight:bold;">' + item.totalCount + '</td>';
                    tbody.appendChild(tr);
                });
            } else {
                tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; padding:15px; color:#64748b;">No reader records found for this portion schedule.</td></tr>';
            }
        })
        .catch(function(err) {
            console.error("Error fetching portion details:", err);
            alert("Failed to load details.");
            closePortionModal();
        });
}

function closePortionModal() {
    document.getElementById("portionModal").style.display = "none";
}

window.onclick = function(event) {
    var modal = document.getElementById("portionModal");
    if (event.target == modal) {
        closePortionModal();
    }
}

document.addEventListener("DOMContentLoaded", function() {
    if (document.getElementById("reportTable")) {
        initData();
    }
});
</script>

</body>
</html>
