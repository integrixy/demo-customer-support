
type CompensationResult record {|
    boolean eligible;
    decimal creditAmount;
    string reason;
|};

public type CustomerIssueRequest record {|
    string customer;
    string issue;
    boolean calculateCompensation;
    boolean sendEmail;
|};

public type CustomerIssueResponse record {|
    string customer;
    string orderId;
    int creditAmount;
    string reason;
    boolean sendEmail;
|};
