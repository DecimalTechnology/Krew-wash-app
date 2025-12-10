# Backend Payment Endpoint Implementation

## Quick Reference

Your backend needs to implement: `POST /api/v1/payments/initialize`

### Expected Request:
```json
POST /api/v1/payments/initialize
Headers: {
  "Content-Type": "application/json",
  "Authorization": "Bearer <user_token>"
}
Body: {
  "amount": 12.1,
  "currency": "AED",
  "bookingData": {
    "package": {...},
    "addOns": [...],
    "dates": [...],
    "vehicle": {...},
    "totalAmount": 12.1
  }
}
```

### Expected Response:
```json
{
  "success": true,
  "message": "Payment initialized successfully",
  "data": {
    "tokenUrl": "https://secure.telr.com/token/abc123...",
    "orderUrl": "https://secure.telr.com/order/xyz789..."
  }
}
```

## How to Get TokenURL and OrderURL from Telr

### Step 1: Call Telr API from Your Backend

You need to call Telr's API to create a payment order. The exact endpoint depends on Telr's API version.

### Step 2: Telr API Call (Example)

```javascript
// Node.js/Express example
const telrParams = {
  ivp_method: 'create',
  ivp_store: '25798', // Your store ID
  ivp_authkey: 'Nbsw5^mDR5@3m9Nc', // Your Telr key
  ivp_amount: '12.10',
  ivp_currency: 'AED',
  ivp_test: '1', // 1 for test, 0 for production
  ivp_cart: 'ORDER_123456', // Unique order reference
  ivp_desc: 'Car Wash Booking',
};

// Generate signature (MD5 hash)
const signature = generateMD5Signature(telrParams, telrKey);
telrParams.ivp_signature = signature;

// Call Telr API
const response = await axios.post(
  'https://secure.telr.com/gateway/order.json',
  telrParams
);

// Extract URLs from response
const tokenUrl = response.data.order.token;
const orderUrl = response.data.order.url;
```

### Step 3: Return URLs to Flutter App

Return the `tokenUrl` and `orderUrl` in the response so the Flutter app can use them with `TelrSdk.presentPayment()`.

## Telr API Documentation

For the exact API format, check:
- Telr Developer Portal: https://telr.com/support/knowledge-base/
- Telr API Documentation: Contact Telr support for API docs
- Email: support@telr.com

## Important Security Notes

1. **Never expose Telr credentials in the Flutter app**
2. **Always generate tokenURL/orderURL on the backend**
3. **Use HTTPS for all API calls**
4. **Validate and sanitize all input data**
5. **Store order references in your database**

## Testing

1. Use Telr test credentials (mode: "1")
2. Test with small amounts
3. Verify URLs are valid HTTPS URLs
4. Test the complete payment flow



