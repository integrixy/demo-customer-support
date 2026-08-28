// Seed data for the mock Customer / Order Management System.
//
// The account-manager email address is the same configurable demo mailbox for every
// customer (the display name still differs per customer) so the whole demo can send
// to one controlled inbox regardless of which customer is investigated.

configurable string demoMailbox = "wso2integrationdemos@gmail.com";

final map<CustomerRecord> & readonly customersById = {
    "CUST-1001": {
        customerId: "CUST-1001",
        name: "ACME Corporation",
        tier: "GOLD",
        accountManager: {name: "Sarah Miller", email: demoMailbox},
        latestOrder: {
            orderId: "ORD-78421",
            customerId: "CUST-1001",
            orderDate: "2026-08-15",
            orderValue: 2400.00,
            currency: "USD",
            expectedDeliveryDate: "2026-08-20",
            status: "DELAYED",
            delayDays: 7,
            currentEstimatedDeliveryDate: "2026-08-27",
            reason: "Carrier processing delay",
            lastUpdated: "2026-08-26T09:30:00Z"
        }
    },
    "CUST-1002": {
        customerId: "CUST-1002",
        name: "Globex Corporation",
        tier: "STANDARD",
        accountManager: {name: "David Lee", email: demoMailbox},
        latestOrder: {
            orderId: "ORD-78435",
            customerId: "CUST-1002",
            orderDate: "2026-08-18",
            orderValue: 950.00,
            currency: "USD",
            expectedDeliveryDate: "2026-08-23",
            status: "DELIVERED",
            delayDays: 0,
            lastUpdated: "2026-08-23T14:00:00Z"
        }
    },
    "CUST-1003": {
        customerId: "CUST-1003",
        name: "Initech",
        tier: "SILVER",
        accountManager: {name: "Maria Rodriguez", email: demoMailbox},
        latestOrder: {
            orderId: "ORD-78448",
            customerId: "CUST-1003",
            orderDate: "2026-08-17",
            orderValue: 1200.00,
            currency: "USD",
            expectedDeliveryDate: "2026-08-22",
            status: "DELAYED",
            delayDays: 3,
            currentEstimatedDeliveryDate: "2026-08-25",
            reason: "Regional distribution delay",
            lastUpdated: "2026-08-25T11:15:00Z"
        }
    },
    "CUST-1004": {
        customerId: "CUST-1004",
        name: "Umbrella Corporation",
        tier: "STANDARD",
        accountManager: {name: "Alex Chen", email: demoMailbox},
        latestOrder: {
            orderId: "ORD-78460",
            customerId: "CUST-1004",
            orderDate: "2026-08-19",
            orderValue: 680.00,
            currency: "USD",
            expectedDeliveryDate: "2026-08-24",
            status: "DELIVERED",
            delayDays: 0,
            lastUpdated: "2026-08-24T10:00:00Z"
        }
    },
    "CUST-1005": {
        customerId: "CUST-1005",
        name: "Stark Industries",
        tier: "GOLD",
        accountManager: {name: "Priya Nair", email: demoMailbox},
        latestOrder: {
            orderId: "ORD-78475",
            customerId: "CUST-1005",
            orderDate: "2026-08-10",
            orderValue: 5200.00,
            currency: "USD",
            expectedDeliveryDate: "2026-08-17",
            status: "DELAYED",
            delayDays: 9,
            currentEstimatedDeliveryDate: "2026-08-26",
            reason: "Customs clearance delay",
            lastUpdated: "2026-08-26T16:45:00Z"
        }
    },
    "CUST-1006": {
        customerId: "CUST-1006",
        name: "Wayne Enterprises",
        tier: "SILVER",
        accountManager: {name: "Jordan Blake", email: demoMailbox},
        latestOrder: {
            orderId: "ORD-78490",
            customerId: "CUST-1006",
            orderDate: "2026-08-22",
            orderValue: 1500.00,
            currency: "USD",
            expectedDeliveryDate: "2026-08-26",
            status: "DELAYED",
            delayDays: 1,
            currentEstimatedDeliveryDate: "2026-08-27",
            reason: "Minor warehouse delay",
            lastUpdated: "2026-08-27T08:00:00Z"
        }
    }
};

// A deliberately ambiguous pair, only reachable via a fuzzy "acme"-containing search
// that isn't an exact/prefix match for the real ACME record above. Demonstrates the
// "multiple matching customers" error path without affecting the deterministic main
// demo path (a literal "ACME" or "ACME Corporation" query always resolves cleanly).
final CustomerMatch[] & readonly ambiguousAcmeMatches = [
    {customerId: "CUST-2001", name: "ACME Corporation USA"},
    {customerId: "CUST-2002", name: "ACME Corporation Europe"}
];

final map<string[]> & readonly aliasesByCustomerId = {
    "CUST-1001": ["acme", "acme corporation"],
    "CUST-1002": ["globex", "globex corporation"],
    "CUST-1003": ["initech"],
    "CUST-1004": ["umbrella", "umbrella corporation"],
    "CUST-1005": ["stark", "stark industries"],
    "CUST-1006": ["wayne", "wayne enterprises"]
};

isolated function findCustomerByName(string customerName) returns CustomerFound|CustomerNotFound|AmbiguousCustomerMatch {
    string normalized = customerName.trim().toLowerAscii();

    foreach [string, string[]] [customerId, aliases] in aliasesByCustomerId.entries() {
        foreach string alias in aliases {
            if normalized == alias || alias.startsWith(normalized) || normalized.startsWith(alias) {
                CustomerRecord customer = customersById.get(customerId);
                return {
                    customerId: customer.customerId,
                    name: customer.name,
                    tier: customer.tier,
                    accountManager: customer.accountManager
                };
            }
        }
    }

    if normalized.includes("acme") {
        return {matches: ambiguousAcmeMatches};
    }

    return {found: false, message: "No matching customer found."};
}
