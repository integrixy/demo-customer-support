// Mock MCP server representing an enterprise Customer and Order Management System.
// Exposes exactly the 3 tools the Customer Order Resolution Agent is allowed to use.

import ballerina/mcp;

configurable int mcpServerPort = 9092;

listener mcp:StreamableHttpListener mcpListener = check new (mcpServerPort);

@mcp:StreamableHttpServiceConfig {
    info: {
        name: "Customer Operations MCP Server",
        version: "1.0.0"
    },
    sessionMode: mcp:STATELESS
}
service mcp:StreamableHttpService /mcp on mcpListener {

    # Find a customer by name. Use this before customer-specific operations when you do
    # not already have a customer ID. Returns the customer ID, customer name, tier, and
    # account manager information.
    #
    # + customerName - The customer name or a recognizable customer identifier
    # + return - The matched customer, a not-found result, or a list of ambiguous matches
    @mcp:Tool {
        description: "Find a customer by name. Use this before customer-specific operations when " +
            "you do not already have a customer ID. Returns the customer ID, customer name, tier, " +
            "and account manager information."
    }
    isolated remote function findCustomer(string customerName) returns CustomerFound|CustomerNotFound|AmbiguousCustomerMatch {
        return findCustomerByName(customerName);
    }

    # Get the most recent order for a customer. Requires a valid customer ID. Returns
    # order ID, order date, value, currency, and expected delivery date.
    #
    # + customerId - The customer ID returned by findCustomer
    # + return - The customer's latest order, or an error if the customer ID is unknown
    @mcp:Tool {
        description: "Get the most recent order for a customer. Requires a valid customer ID. " +
            "Returns order ID, order date, value, currency, and expected delivery date."
    }
    isolated remote function getLatestOrder(string customerId) returns LatestOrder|error {
        CustomerRecord? customer = customersById[customerId];
        if customer is () {
            return error(string `No customer found for customer ID: ${customerId}`);
        }
        OrderRecord 'order = customer.latestOrder;
        return {
            orderId: 'order.orderId,
            customerId: 'order.customerId,
            orderDate: 'order.orderDate,
            orderValue: 'order.orderValue,
            currency: 'order.currency,
            expectedDeliveryDate: 'order.expectedDeliveryDate
        };
    }

    # Get the current order and shipment status for an order ID. Use this to determine
    # whether an order is delivered, in transit, delayed, or cancelled. If delayed, the
    # response contains the delay duration when available.
    #
    # + orderId - The order ID returned by getLatestOrder
    # + return - The order's current status, or an error if the order ID is unknown
    @mcp:Tool {
        description: "Get the current order and shipment status for an order ID. Use this to " +
            "determine whether an order is delivered, in transit, delayed, or cancelled. If " +
            "delayed, the response contains the delay duration when available."
    }
    isolated remote function getOrderStatus(string orderId) returns OrderStatus|error {
        foreach CustomerRecord customer in customersById {
            OrderRecord 'order = customer.latestOrder;
            if 'order.orderId == orderId {
                return {
                    orderId: 'order.orderId,
                    status: 'order.status,
                    expectedDeliveryDate: 'order.expectedDeliveryDate,
                    currentEstimatedDeliveryDate: 'order?.currentEstimatedDeliveryDate,
                    delayDays: 'order.delayDays,
                    reason: 'order?.reason,
                    lastUpdated: 'order.lastUpdated
                };
            }
        }
        return error(string `No order found for order ID: ${orderId}`);
    }
}
