
# LLM investigation Cloud Case

## Setup

### WireMCP

``` terminal
git clone git@github.com:0xKoda/WireMCP.git
cd WireMCP
npm install
node index.js
```

In the config of the LLM of your choice put
``` json
{
  "mcpServers": {
    "wiremcp": {
      "command": "node",
      "args": [
        "/ABSOLUTE_PATH_TO/WireMCP/index.js"
      ]
    }
  }
}
```

### Gemini CLI

``` terminal
npm install -g @google/gemini-cli
gemini # Runs the Gemini CLI client
/mcp # lists available MCP services, verify that WireMCP is loaded
```
