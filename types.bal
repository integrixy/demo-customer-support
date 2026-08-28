// Types for the mock Customer / Order Management System exposed over MCP.

# Service tiers recognized by the mock CRM.
public type CustomerTier "GOLD"|"SILVER"|"STANDARD";

# The account manager assigned to a customer.
public type AccountManager record {|
    string name;
    string email;
|};

# An order, embedded under its owning customer in the seed data.
public type OrderRecord record {|
    string orderId;
    string customerId;
    string orderDate;
    decimal orderValue;
    string currency;
    string expectedDeliveryDate;
    "DELIVERED"|"DELAYED"|"IN_TRANSIT"|"CANCELLED" status;
    int delayDays;
    string currentEstimatedDeliveryDate?;
    string reason?;
    string lastUpdated;
|};

# A customer record in the mock CRM, including its most recent order.
public type CustomerRecord record {|
    string customerId;
    string name;
    CustomerTier tier;
    AccountManager accountManager;
    OrderRecord latestOrder;
|};

// ---- findCustomer result shapes ----

public type CustomerFound record {|
    string customerId;
    string name;
    CustomerTier tier;
    AccountManager accountManager;
|};

public type CustomerNotFound record {|
    boolean found = false;
    string message;
|};

public type CustomerMatch record {|
    string customerId;
    string name;
|};

public type AmbiguousCustomerMatch record {|
    CustomerMatch[] matches;
|};

// ---- getLatestOrder result shape ----

public type LatestOrder record {|
    string orderId;
    string customerId;
    string orderDate;
    decimal orderValue;
    string currency;
    string expectedDeliveryDate;
|};

// ---- getOrderStatus result shape ----

public type OrderStatus record {|
    string orderId;
    "DELIVERED"|"DELAYED"|"IN_TRANSIT"|"CANCELLED" status;
    string expectedDeliveryDate;
    string currentEstimatedDeliveryDate?;
    int delayDays;
    string reason?;
    string lastUpdated;
|};
