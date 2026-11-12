// Types for the mock Customer / Order Management System exposed over MCP.

type CustomerTier "GOLD"|"SILVER"|"STANDARD";
type Status "DELIVERED"|"DELAYED"|"IN_TRANSIT"|"CANCELLED";

type AccountManager record {|
    string name;
    string email;
|};

type OrderRecord record {|
    string orderId;
    string customerId;
    string orderDate;
    decimal orderValue;
    string currency;
    string expectedDeliveryDate;
    Status status;
    int delayDays;
    string currentEstimatedDeliveryDate?;
    string reason?;
    string lastUpdated;
|};

type CustomerRecord record {|
    string customerId;
    string name;
    CustomerTier tier;
    AccountManager accountManager;
    OrderRecord latestOrder;
|};

// ---- findCustomer result shapes ----

type CustomerFound record {|
    string customerId;
    string name;
    CustomerTier tier;
    AccountManager accountManager;
|};

type CustomerNotFound record {|
    boolean found = false;
    string message;
|};

type CustomerMatch record {|
    string customerId;
    string name;
|};

type AmbiguousCustomerMatch record {|
    CustomerMatch[] matches;
|};

// ---- getLatestOrder result shape ----

type LatestOrder record {|
    string orderId;
    string customerId;
    string orderDate;
    decimal orderValue;
    string currency;
    string expectedDeliveryDate;
|};

// ---- getOrderStatus result shape ----

type OrderStatus record {|
    string orderId;
    Status status;
    string expectedDeliveryDate;
    string currentEstimatedDeliveryDate?;
    int delayDays;
    string reason?;
    string lastUpdated;
|};
