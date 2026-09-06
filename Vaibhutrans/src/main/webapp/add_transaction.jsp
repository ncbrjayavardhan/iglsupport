<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Transaction - Vaibhutrans</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            --glass-bg: rgba(255, 255, 255, 0.95);
        }
        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
            min-height: 100vh;
            color: #1e293b;
            font-family: 'Plus Jakarta Sans', sans-serif;
            padding-bottom: 20px;
        }
        .form-card {
            max-width: 750px;
            margin: 20px auto;
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            border-radius: 14px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 24px;
        }
        .form-title {
            font-weight: 800;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 22px;
        }
        .btn-gradient {
            background: var(--primary-gradient);
            color: white;
            border: none;
            font-weight: 600;
        }
        .btn-gradient:hover {
            color: white;
            opacity: 0.9;
        }
    </style>
</head>
<body>

<!-- Include Navbar -->
<jsp:include page="navbar.jsp"/>

<div class="container px-3">
    <div class="form-card">
        <div class="d-flex justify-content-between align-items-center mb-3 pb-2 border-bottom">
            <h3 class="form-title mb-0"><i class="fa fa-plus-circle me-2"></i>Add Single Transaction</h3>
            <!-- <a href="report" class="btn btn-light btn-sm"><i class="fa fa-arrow-left me-1"></i> Back to Report</a> -->
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger py-2 small"><i class="fa fa-exclamation-triangle me-1"></i> <%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("message") != null) { %>
            <div class="alert alert-success py-2 small"><i class="fa fa-check-circle me-1"></i> <%= request.getAttribute("message") %></div>
        <% } %>

        <form action="addTransaction" method="post">
            <div class="row g-3">
                <!-- UTR No -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">UTR No / Reference *</label>
                    <input type="text" name="utrNo" class="form-control form-control-sm" required placeholder="Enter UTR Number">
                </div>

                <!-- Transaction Date -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Transaction Date *</label>
                    <input type="date" name="transactionDate" class="form-control form-control-sm" required>
                </div>

                <!-- Debit Account -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Debit Account *</label>
                    <input type="text" name="debitAccount" class="form-control form-control-sm" required placeholder="Source Account Number">
                </div>

                <!-- Amount -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Amount (₹) *</label>
                    <input type="number" step="0.01" name="amount" class="form-control form-control-sm" required placeholder="0.00">
                </div>

                <!-- Beneficiary Account (Triggers lookup) -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Beneficiary Account *</label>
                    <div class="input-group input-group-sm">
                        <input type="text" id="benfAccount" name="benfAccount" class="form-control" required placeholder="Enter Account No" onblur="lookupBeneficiary()">
                        <button class="btn btn-outline-secondary" type="button" onclick="lookupBeneficiary()"><i class="fa fa-search"></i></button>
                    </div>
                    <div id="lookupStatus" class="form-text small text-info" style="font-size: 10.5px;"></div>
                </div>

                <!-- Payment Mode -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Payment Mode</label>
                    <select name="paymentMode" class="form-select form-select-sm">
                        <option value="NEFT">NEFT</option>
                        <option value="RTGS">RTGS</option>
                        <option value="IMPS">IMPS</option>
                        <option value="FT">FT (Internal)</option>
                    </select>
                </div>

                <!-- Beneficiary Name -->
                <!-- <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Beneficiary Name *</label>
                    <input type="text" id="benfName" name="benfName" class="form-control form-control-sm" required placeholder="Beneficiary Full Name">
                </div> -->
                <!-- Beneficiary Name with Autocomplete Datalist -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Beneficiary Name *</label>
                    <input type="text" id="benfName" name="benfName" class="form-control form-control-sm" required placeholder="Type or select Beneficiary Name" list="benfNameOptions" oninput="searchBeneficiaryNames(this.value)" onchange="lookupByName(this.value)">
                    <datalist id="benfNameOptions">
                        <!-- Populated dynamically via JS -->
                    </datalist>
                </div>

                <!-- Beneficiary IFSC -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Beneficiary IFSC *</label>
                    <input type="text" id="benfIfsc" name="benfIfsc" class="form-control form-control-sm" required placeholder="IFSC Code">
                </div>

                <!-- Beneficiary Bank -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Beneficiary Bank</label>
                    <input type="text" id="benfBank" name="benfBank" class="form-control form-control-sm" placeholder="Bank Name">
                </div>

                <!-- Beneficiary Branch -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Beneficiary Branch</label>
                    <input type="text" id="benfBranch" name="benfBranch" class="form-control form-control-sm" placeholder="Branch Name">
                </div>

                <!-- Status -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Status *</label>
                    <select name="status" class="form-select form-select-sm" required>
                        <option value="Successful/Paid">Successful/Paid</option>
                        <option value="Pending">Pending</option>
                        <option value="Failed">Failed</option>
                    </select>
                </div>

                <!-- Tally Ledger -->
                <!-- <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Tally Ledger</label>
                    <input type="text" name="tallyledger" class="form-control form-control-sm" placeholder="Ledger Name">
                </div> -->

                <!-- Project -->
                <!-- <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Project</label>
                    <input type="text" name="project" class="form-control form-control-sm" placeholder="Project Name">
                </div> -->
				<!-- Tally Ledger with Autocomplete Datalist -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Tally Ledger</label>
                    <input type="text" id="tallyledger" name="tallyledger" class="form-control form-control-sm" list="tallyledgerOptions" placeholder="Select or type new ledger...">
                    <datalist id="tallyledgerOptions">
                        <!-- Populated dynamically via JS -->
                    </datalist>
                </div>

                <!-- Project with Autocomplete Datalist -->
                <div class="col-md-6">
                    <label class="form-label fw-bold small text-muted">Project</label>
                    <input type="text" id="project" name="project" class="form-control form-control-sm" list="projectOptions" placeholder="Select or type new project...">
                    <datalist id="projectOptions">
                        <!-- Populated dynamically via JS -->
                    </datalist>
                </div>
                <!-- Narration -->
                <div class="col-12">
                    <label class="form-label fw-bold small text-muted">Narration</label>
                    <textarea name="narration" class="form-control form-control-sm" rows="2" placeholder="Narration"></textarea>
                </div>

                <div class="col-12 text-end mt-3">
                    <button type="submit" class="btn btn-gradient btn-sm px-4 py-2"><i class="fa fa-save me-1"></i> Save Transaction</button>
                </div>
            </div>
        </form>
    </div>
</div>

 <!-- AJAX Lookup Script -->
 <script>
    // 1. Existing Account Lookup (When typing Account No)
    function lookupBeneficiary() {
        const accNo = document.getElementById("benfAccount").value.trim();
        const statusDiv = document.getElementById("lookupStatus");
        if (!accNo) return;

        statusDiv.innerText = "Checking existing records & suggestions...";

        fetch('${pageContext.request.contextPath}/lookupBeneficiary?account=' + encodeURIComponent(accNo))
            .then(response => response.json())
            .then(data => {
                if (data.found) {
                    document.getElementById("benfName").value = data.benfName || "";
                    document.getElementById("benfIfsc").value = data.benfIfsc || "";
                    document.getElementById("benfBank").value = data.benfBank || "";
                    document.getElementById("benfBranch").value = data.benfBranch || "";
                    statusDiv.innerHTML = "<span class='text-success'><i class='fa fa-check-circle me-1'></i> Beneficiary details found and autofilled!</span>";
                } else {
                    statusDiv.innerHTML = "<span class='text-warning'><i class='fa fa-info-circle me-1'></i> Account not found. Enter details manually.</span>";
                }
            })
            .catch(err => console.error("Lookup error:", err));

        // Fetch Tally Ledger and Project Suggestions for this account
        fetch('${pageContext.request.contextPath}/beneficiarySuggestions?account=' + encodeURIComponent(accNo))
            .then(response => response.json())
            .then(data => {
                const tallyList = document.getElementById("tallyledgerOptions");
                const projectList = document.getElementById("projectOptions");
                
                tallyList.innerHTML = "";
                projectList.innerHTML = "";

                if (data.tallyledgers) {
                    data.tallyledgers.forEach(item => {
                        const opt = document.createElement("option");
                        opt.value = item;
                        tallyList.appendChild(opt);
                    });
                }

                if (data.projects) {
                    data.projects.forEach(item => {
                        const opt = document.createElement("option");
                        opt.value = item;
                        projectList.appendChild(opt);
                    });
                }
            })
            .catch(err => console.error("Suggestions error:", err));
    }

    // 2. Beneficiary Name Search Suggestions
    function searchBeneficiaryNames(query) {
        if (!query || query.trim().length < 2) return;

        fetch('${pageContext.request.contextPath}/beneficiaryNameSearch?q=' + encodeURIComponent(query.trim()))
            .then(response => response.json())
            .then(names => {
                const list = document.getElementById("benfNameOptions");
                list.innerHTML = "";
                names.forEach(name => {
                    const opt = document.createElement("option");
                    opt.value = name;
                    list.appendChild(opt);
                });
            })
            .catch(err => console.error("Name search error:", err));
    }

    // 3. Autofill Account No & IFSC when a Beneficiary Name is selected
    function lookupByName(name) {
        if (!name || name.trim() === "") return;

        fetch('${pageContext.request.contextPath}/beneficiaryNameSearch?exact=' + encodeURIComponent(name.trim()))
            .then(response => response.json())
            .then(data => {
                if (data.found) {
                    document.getElementById("benfAccount").value = data.benfAccount || "";
                    document.getElementById("benfIfsc").value = data.benfIfsc || "";
                    document.getElementById("benfBank").value = data.benfBank || "";
                    document.getElementById("benfBranch").value = data.benfBranch || "";
                    
                    // Automatically trigger suggestions for Tally Ledger/Project using the resolved account number
                    lookupBeneficiary();
                }
            })
            .catch(err => console.error("Name lookup error:", err));
    }
</script>
<!--<script>


function lookupBeneficiary() {
    const accNo = document.getElementById("benfAccount").value.trim();
    const statusDiv = document.getElementById("lookupStatus");
    if (!accNo) return;

    statusDiv.innerText = "Checking existing records & suggestions...";

    // 1. Fetch Beneficiary Details & Suggestions simultaneously
    fetch('${pageContext.request.contextPath}/lookupBeneficiary?account=' + encodeURIComponent(accNo))
        .then(response => response.json())
        .then(data => {
            if (data.found) {
                document.getElementById("benfName").value = data.benfName || "";
                document.getElementById("benfIfsc").value = data.benfIfsc || "";
                document.getElementById("benfBank").value = data.benfBank || "";
                document.getElementById("benfBranch").value = data.benfBranch || "";
                statusDiv.innerHTML = "<span class='text-success'><i class='fa fa-check-circle me-1'></i> Beneficiary details found and autofilled!</span>";
            } else {
                statusDiv.innerHTML = "<span class='text-warning'><i class='fa fa-info-circle me-1'></i> Account not found. Enter details manually.</span>";
            }
        })
        .catch(err => console.error("Lookup error:", err));

    // 2. Fetch Tally Ledger and Project Suggestions for this Beneficiary
    fetch('${pageContext.request.contextPath}/beneficiarySuggestions?account=' + encodeURIComponent(accNo))
        .then(response => response.json())
        .then(data => {
            const tallyList = document.getElementById("tallyledgerOptions");
            const projectList = document.getElementById("projectOptions");
            
            tallyList.innerHTML = "";
            projectList.innerHTML = "";

            if (data.tallyledgers) {
                data.tallyledgers.forEach(item => {
                    const opt = document.createElement("option");
                    opt.value = item;
                    tallyList.appendChild(opt);
                });
            }

            if (data.projects) {
                data.projects.forEach(item => {
                    const opt = document.createElement("option");
                    opt.value = item;
                    projectList.appendChild(opt);
                });
            }
        })
        .catch(err => console.error("Suggestions error:", err));
}


    function lookupBeneficiary2() {
        const accNo = document.getElementById("benfAccount").value.trim();
        const statusDiv = document.getElementById("lookupStatus");
        if (!accNo) return;

        statusDiv.innerText = "Checking existing records...";

        fetch('${pageContext.request.contextPath}/lookupBeneficiary?account=' + encodeURIComponent(accNo))
            .then(response => response.json())
            .then(data => {
                if (data.found) {
                    document.getElementById("benfName").value = data.benfName || "";
                    document.getElementById("benfIfsc").value = data.benfIfsc || "";
                    document.getElementById("benfBank").value = data.benfBank || "";
                    document.getElementById("benfBranch").value = data.benfBranch || "";
                    statusDiv.innerHTML = "<span class='text-success'><i class='fa fa-check-circle me-1'></i> Beneficiary details found and autofilled!</span>";
                } else {
                    statusDiv.innerHTML = "<span class='text-warning'><i class='fa fa-info-circle me-1'></i> Account not found in records. Please enter details manually.</span>";
                }
            })
            .catch(err => {
                console.error("Lookup error:", err);
                statusDiv.innerText = "";
            });
    }
</script> -->
</body>
</html>