
isolated function calculateCompensation(decimal orderValue, int delayDays) returns CompensationResult {
    int percent = delayDays > 5 ? 10 : (delayDays >= 2 ? 5 : 0);
    decimal creditAmount = orderValue * percent / 100;
    CompensationResult ret = {
        eligible: percent > 0,
        creditAmount: creditAmount,
        reason: "Shipment Delay"
    };
    return ret;
}
