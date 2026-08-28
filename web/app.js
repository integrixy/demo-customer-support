// Calls the customer-resolution-agent's web trigger: POST /api/customer/resolve.
// The agent app must be running (default http://localhost:9090) with CORS enabled, which
// web_service.bal already does.

const API_URL = "http://localhost:9090/api/customer/resolve";

const form = document.getElementById("issue-form");
const submitBtn = document.getElementById("submit-btn");
const resultEl = document.getElementById("result");
const errorEl = document.getElementById("error");
const errorTextEl = document.getElementById("error-text");
const emptyStateEl = document.getElementById("empty-state");

form.addEventListener("submit", async (event) => {
    event.preventDefault();

    resultEl.classList.remove("visible");
    errorEl.classList.remove("visible");
    emptyStateEl.classList.add("hidden");
    errorTextEl.textContent = "";
    setLoading(true);

    const payload = {
        customer: document.getElementById("customer").value,
        issue: document.getElementById("issue").value,
        calculateCompensation: document.getElementById("calculateCompensation").checked,
        sendEmail: document.getElementById("notifyAccountManager").checked
    };

    try {
        const response = await fetch(API_URL, {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify(payload)
        });

        const body = await response.json();

        if (!response.ok) {
            throw new Error(body.message || `Request failed with status ${response.status}`);
        }

        renderResult(body);
    } catch (err) {
        errorTextEl.textContent = err.message || "Something went wrong while resolving this case.";
        errorEl.classList.add("visible");
    } finally {
        setLoading(false);
    }
});

function setLoading(isLoading) {
    submitBtn.disabled = isLoading;
    submitBtn.classList.toggle("loading", isLoading);
    submitBtn.querySelector(".btn-label").textContent = isLoading ? "Investigating..." : "Investigate & Resolve";
}

function renderResult(resolution) {
    document.getElementById("r-customer").textContent = resolution.customer || "-";
    document.getElementById("r-order").textContent = resolution.orderId || "-";
    document.getElementById("r-credit").textContent =
        resolution.creditAmount !== undefined ? formatMoney(resolution.creditAmount) : "Not calculated";
    document.getElementById("r-reason").textContent = resolution.reason || "No further detail provided.";

    const notifiedEl = document.getElementById("r-notified");
    notifiedEl.innerHTML = "";
    const badge = document.createElement("span");
    if (resolution.sendEmail) {
        badge.className = "badge yes";
        badge.textContent = "Notified";
    } else {
        badge.className = "badge no";
        badge.textContent = "Not sent";
    }
    notifiedEl.appendChild(badge);

    resultEl.classList.add("visible");
}

function formatMoney(amount) {
    try {
        return new Intl.NumberFormat("en-US", {style: "currency", currency: "USD"}).format(amount);
    } catch {
        return `${amount}`;
    }
}
