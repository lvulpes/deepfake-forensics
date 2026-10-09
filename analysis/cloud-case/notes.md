
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

## Test run of Gemini with WireMCP

During the first test run Gemini exhausted it's requests per day limit while failing to read the pcap because it's seemingly too large.
Trying to run the test on a reduced pcap that only contains DNS traffic, which is the topic of the test run anyways.

First run, which failed:
│  Model                           Reqs  Input Tokens   Cache Reads Output Tokens
│  gemini-3.8-flash                  24       286,624       144,971           675
