
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

The second test run used a narrower task and a subset of the full pcap. The outcome was that the LLM "cheated" by accessing the git history of the manual investigation and copied the results. It also exhausted the maximum requests per day and nearly exhausted the input token limit. The conclusion is that the LLM needs to run in a sandbox and the requests per day limit needs to be raised, if possible.

### Stats test run 2

``` terminal
│  gemini-3.5-flash-lite             15       820,143       626,118       3,517                                                                                                           │
│    ↳ main                          11       818,802       626,118       3,459                                                                                                           │
│    ↳ utility_router                 3         1,341             0       58                                                                                                           │
│    ↳ utility_summarizer             1             0             0       0                                                                                                           │
│  gemini-3.8-flash                  29     1,192,794       987,582       1,851                                                                                                           │
│    ↳ main                          29     1,192,794       987,582       1,851                                                                                                           │
│  To resume this session: gemini --resume d4ba8933-e4b8-4df8-910d-ab58f7381d6a  
```
