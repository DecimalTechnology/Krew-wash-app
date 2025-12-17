# Backend Payment Response Format Issue

## Current Situation

Your backend is currently returning this response format:
```json
{
    "success": true,
    "paymentUrl": "https://secure.telr.com/gateway/process.html?o=46746958ACF7607EEAFA87308A5033484B237BA36E30FF8FA3353300BC7EC05A",
    "reference": "46746958ACF7607EEAFA87308A5033484B237BA36E30FF8FA3353300BC7EC05A"
}
```

## Problem

The **Telr Flutter SDK** requires a different format. According to Telr's official documentation, the SDK's `presentPayment()` method needs:
- `tokenUrl` - value from `_links.auth.href` 
- `orderUrl` - value from `_links.self.href`

## Required Backend Response Format

Your backend should return the response from Telr's `createOrder` API which includes the `_links` structure:

```json
{
    "success": true,
    "data": {
        "_links": {
            "auth": {
                "href": "https://your-backend.com/api/payments/token/..."
            },
            "self": {
                "href": "https://your-backend.com/api/payments/order/..."
            }
        },
        "reference": "46746958ACF7607EEAFA87308A5033484B237BA36E30FF8FA3353300BC7EC05A"
    }
}
```

Or alternatively, a simpler format:
```json
{
    "success": true,
    "tokenUrl": "https://your-backend.com/api/payments/token/...",
    "orderUrl": "https://your-backend.com/api/payments/order/...",
    "reference": "46746958ACF7607EEAFA87308A5033484B237BA36E30FF8FA3353300BC7EC05A"
}
```

## What the Code Currently Does

The Flutter app now:
1. ✅ Extracts `paymentUrl` and `reference` from the current response
2. ✅ Stores `reference` for booking creation
3. ✅ Tries to extract `tokenUrl` and `orderUrl` from multiple possible locations:
   - `data._links.auth.href` and `data._links.self.href` (Telr format)
   - `data.tokenUrl` and `data.orderUrl` (direct format)
   - `response.tokenUrl` and `response.orderUrl` (root level)
4. ⚠️ Shows an error if `tokenUrl` and `orderUrl` are not found

## Next Steps

### Option 1: Update Backend (Recommended)
Update your backend's `/payments/initialize` endpoint to return the Telr `createOrder` API response format with `_links` structure.

### Option 2: Backend Returns Both Formats
Have your backend return both formats:
```json
{
    "success": true,
    "paymentUrl": "https://secure.telr.com/gateway/process.html?o=...",
    "reference": "...",
    "data": {
        "_links": {
            "auth": {
                "href": "https://your-backend.com/api/payments/token/..."
            },
            "self": {
                "href": "https://your-backend.com/api/payments/order/..."
            }
        }
    }
}
```

### Option 3: Use Web View Instead of SDK
If you can't change the backend format, you could use a WebView to open the `paymentUrl` directly instead of using the Telr SDK. However, this would require significant code changes and you'd lose the benefits of the native SDK.

## Current Code Status

- ✅ Payment repository updated to send `totalPrice` instead of `amount`
- ✅ Payment provider extracts `paymentUrl` and `reference`
- ✅ Payment provider tries multiple formats to find `tokenUrl` and `orderUrl`
- ✅ Payment screen uses `reference` for booking creation
- ⚠️ Will show error if `tokenUrl`/`orderUrl` not found (backend needs to return them)

## Testing

After updating your backend:
1. The app will automatically detect `tokenUrl` and `orderUrl` from the response
2. The Telr SDK will launch successfully
3. The `reference` will be used for booking creation after payment success
