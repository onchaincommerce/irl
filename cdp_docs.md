# Using docs with AI-powered IDEs

export const BASE_URL = 'https://mintlify-assets.b-cdn.net/coinbase/get-started/files';


AI-powered development tools can enhance your Coinbase Developer Platform (CDP) workflow by leveraging our documentation to generate accurate code and provide API insights.

This guide explores methods for integrating CDP docs with AI assistants:

* Quick copy-paste methods for immediate use
* Advanced MCP tooling for deeper integration
* AI-powered IDEs like Replit and Cursor that accelerate CDP development

## Per page

CDP documentation includes a contextual menu that provides quick access to AI-optimized content and direct integrations with popular AI tools.

On any page, select the **Copy page** dropdown found next to the document header to access these options:

<Frame>
  <img src="https://mintlify.s3.us-west-1.amazonaws.com/coinbase-prod/get-started/images/cdp-ai.png" alt="Copy page dropdown" />
</Frame>

### Available menu options

The contextual menu includes several integration options:

| Option                 | Description                                                                           |
| :--------------------- | :------------------------------------------------------------------------------------ |
| **Copy page**          | Copies the current page as Markdown for pasting as context into AI tools              |
| **View as Markdown**   | Opens the current page as Markdown                                                    |
| **Copy MCP Server**    | Copies the CDP MCP server URL (`https://docs.cdp.coinbase.com/mcp`) to your clipboard |
| **Connect to Cursor**  | Installs the CDP MCP server in Cursor                                                 |
| **Connect to VSCode**  | Installs the CDP MCP server in VSCode                                                 |
| **Open in ChatGPT**    | Creates a ChatGPT conversation with the current page as context                       |
| **Open in Claude**     | Creates a Claude conversation with the current page as context                        |
| **Open in Perplexity** | Creates a Perplexity conversation with the current page as context                    |

<Note>
  The **Connect to Cursor** and **Connect to VSCode** options provide one-click installation of the CDP MCP server, automatically configuring your IDE to access CDP documentation and APIs. You can also quickly copy the MCP server URL by clicking **Copy MCP Server URL** for manual configuration.
</Note>

## Per entire site

You can also view a concatenated version of the entire site by appending `/llms-full.txt` to the root path: [docs.cdp.coinbase.com/llms-full.txt](https://docs.cdp.coinbase.com/llms-full.txt).

## Model Context Protocol (MCP)

The Model Context Protocol (MCP) is an open protocol that creates standardized connections between AI applications and external services. CDP provides an MCP server that gives AI tools direct access to our documentation and API specifications, enabling them to understand Coinbase's capabilities when helping you write code.

### About the CDP MCP server

The MCP server exposes tools for AI applications to:

* Search CDP documentation for accurate information about APIs, SDKs, and best practices
* Provide context to AI assistants so they can generate code using correct CDP patterns and methods
* Answer technical questions about Coinbase's capabilities, authentication, error codes, and more
* Discover relevant endpoints and features across the entire documentation set

### Using the CDP MCP server

Connect the CDP MCP server to your preferred AI tools to access documentation and APIs directly within your development workflow.

#### Claude

To use the CDP MCP server with Claude:

<Steps>
  <Step title="Add the CDP MCP server to Claude">
    1. Navigate to the [Connectors](https://claude.ai/settings/connectors) page in Claude settings
    2. Select **Add custom connector**
    3. Add the following:
       * Name: `Coinbase Developer Platform`
       * URL: `https://docs.cdp.coinbase.com/mcp`
    4. Select **Add**
  </Step>

  <Step title="Access CDP docs in your chat">
    1. When using Claude, select the attachments button (the plus icon)
    2. Select the Coinbase Developer Platform connector
    3. Query Claude with CDP documentation as context
  </Step>
</Steps>

#### Cursor

To connect the CDP MCP server to Cursor, you can either use the automatic connection or configure it manually:

<Tabs>
  <Tab title="Automatic Connection">
    <Steps>
      <Step title="Use the Connect to Cursor option">
        1. On any CDP documentation page, select the **Copy page** dropdown next to the document header
        2. Select **Connect to Cursor**
        3. Cursor will automatically open with the CDP MCP server configured
      </Step>

      <Step title="Test the connection">
        In Cursor's chat, ask "What tools do you have available?" to verify that Cursor has access to CDP documentation search and any configured API endpoints.
      </Step>
    </Steps>
  </Tab>

  <Tab title="Manual Configuration">
    <Steps>
      <Step title="Open MCP settings">
        1. Use <kbd>Command</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> (<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> on Windows) to open the command palette
        2. Search for "Open MCP settings"
        3. Select **Open MCP settings** to open the `mcp.json` file
      </Step>

      <Step title="Configure the CDP server">
        In `mcp.json`, add the CDP configuration:

        ```json
        {
          "mcpServers": {
            "coinbase-cdp": {
              "url": "https://docs.cdp.coinbase.com/mcp"
            }
          }
        }
        ```
      </Step>

      <Step title="Test the connection">
        In Cursor's chat, ask "What tools do you have available?" to verify that Cursor has access to CDP documentation search and any configured API endpoints.
      </Step>
    </Steps>
  </Tab>
</Tabs>

See the [Model Context Protocol documentation](https://modelcontextprotocol.io/docs/tutorials/use-remote-mcp-server#connecting-to-a-remote-mcp-server) for additional configuration options.

<Note>
  Currently, the CDP MCP server only supports the `search` tool for querying documentation. Direct API execution is not yet available for the CDP docs.
</Note>

For more information, see the [Mintlify documentation](https://mintlify.com/docs/ai/model-context-protocol).

## AI-powered IDEs

Beyond providing documentation context, you can use specialized AI-powered IDEs that streamline CDP development:

### Replit

[Replit](https://replit.com/) is a cloud-based IDE that streamlines development. It allows developers to build in a Google docs-like environment, with pre-built templates for building websites, apps, and games. Its new AI agent can assist with several files at once, making development feel like a one-on-one conversation.

Coinbase has partnered with Replit to create [CDP SDK templates](https://replit.com/@CoinbaseDev) for you to use as a starting point. The [cdp-sdk python package](https://pypi.org/project/cdp-sdk/) is indexed and searchable from the Replit dependency tool.

### Cursor

A fork of VS Code, [Cursor](https://www.cursor.com/) is an AI-powered IDE that supports features such as AI code completion, natural language editing, and codebase context. Cursor Pro is free for the first two weeks after signup, with more powerful models.

We recommend starting your project on Replit, and then using [this guide](https://docs.replit.com/replit-workspace/ssh#connecting-to-your-repl) to open your project in Cursor so you can get the best of both worlds.

## What next?

Check out our [Quickstart](/get-started/quickstart) guide to get started.
