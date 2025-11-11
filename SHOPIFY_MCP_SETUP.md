# Shopify MCP Setup for Claude Code

## Overview
This document describes the Model Context Protocol (MCP) integration between Claude Code and your Shopify stores.

## Connected Stores

### Caia's Cookies
- **Store Domain**: caias-cookies.myshopify.com
- **MCP Server Name**: `caias-cookies-store`
- **Status**: ✅ Connected and configured

## MCP Servers Installed

### 1. Shopify Dev MCP (`shopify-dev-mcp`)
**Purpose**: Documentation, API learning, and development assistance

**Capabilities**:
- Search Shopify.dev documentation
- Explore GraphQL schemas (Admin API, Storefront API, etc.)
- Get up-to-date API instructions
- Validate theme files with Shopify Theme Check
- Learn about Shopify APIs interactively

**Use Cases**:
- "How do I create a product variant using GraphQL?"
- "Show me the Shopify Admin API schema for orders"
- "Validate my Liquid theme files"

### 2. Caia's Cookies Store MCP (`caias-cookies-store`)
**Purpose**: Direct store management and operations

**Capabilities** (70+ tools including):
- **Products**: Create, update, delete, list products and variants
- **Orders**: View, update, fulfill orders
- **Customers**: Manage customer data
- **Inventory**: Track and update inventory levels
- **Themes**: List, download, and modify theme files
- **Collections**: Manage product collections
- **Discounts**: Create and manage discount codes
- **Analytics**: Access store analytics and reports

**Use Cases**:
- "List all products in Caia's Cookies store"
- "Update the price of product XYZ"
- "Download the current active theme"
- "Show me today's orders"

## Configuration Location

Configuration file: `/root/.claude.json`

The MCP servers are configured in the project-specific settings under:
```json
"projects": {
  "/home/user/Dessert-Hub-Website": {
    "mcpServers": { ... }
  }
}
```

## How to Use MCP Tools in Claude Code

MCP tools are automatically available when you interact with Claude Code. You can:

1. **Ask questions about Shopify**: "What GraphQL query do I use to get product details?"
2. **Request store operations**: "List all products from Caia's Cookies"
3. **Make changes**: "Update the description of product ID 12345"
4. **Download and edit themes**: "Get the current theme files for Caia's Cookies"

Claude Code will automatically use the appropriate MCP server to fulfill your requests.

## Adding Additional Stores

To add more Shopify stores:

1. Create a custom app in the store's Shopify Admin:
   - Settings → Apps and sales channels → Develop apps
   - Create an app and configure API scopes
   - Install the app
   - Get the Admin API access token (starts with `shpat_`)

2. Add to `/root/.claude.json` under `mcpServers`:
```json
"your-store-name": {
  "command": "npx",
  "args": ["-y", "@ajackus/shopify-mcp-server"],
  "env": {
    "SHOPIFY_STORE_DOMAIN": "your-store.myshopify.com",
    "SHOPIFY_ACCESS_TOKEN": "shpat_your_token_here"
  }
}
```

3. Restart Claude Code for changes to take effect

## API Scopes Configured

The following scopes are recommended for full functionality:
- `read_products` & `write_products`
- `read_themes` & `write_themes`
- `read_orders` & `write_orders`
- `read_customers` & `write_customers`
- `read_inventory` & `write_inventory`

## Security Notes

- Access tokens are stored locally in `/root/.claude.json`
- Tokens have the permissions defined by the API scopes
- Keep your access tokens secure and never commit them to version control
- You can revoke access tokens in Shopify Admin at any time

## Troubleshooting

### MCP Server Not Responding
- Ensure Node.js and npx are installed
- Check that the access token is valid (starts with `shpat_`)
- Verify the store domain is correct (format: `store-name.myshopify.com`)

### Permission Errors
- Check that the custom app has the necessary API scopes
- Reinstall the app if scopes were changed

### Need to Update Access Token
- Uninstall and reinstall the custom app in Shopify Admin
- Update the token in `/root/.claude.json`

## Resources

- [Shopify Dev MCP Documentation](https://shopify.dev/docs/apps/build/devmcp)
- [Shopify Admin API Reference](https://shopify.dev/docs/api/admin)
- [Custom Apps Guide](https://shopify.dev/docs/apps/build/authentication-authorization/access-tokens/generate-app-access-tokens-admin)

---

**Last Updated**: 2025-11-11
**Configuration Version**: 1.0
