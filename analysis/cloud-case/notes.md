
# Results

Stage 1 is complete. At first glance the AI produced the same evidence as the human investigation. See lessons learned segment for improvements before running stage 2. The below results will also be kept in the workdir so that the LLM can see it's previous results to avoid overlap and help contextual understanding. 

## AI produced timeline 

### Stage 1
Timeline of Events: Source Image Investigation

Event 1: Web Search for Stefan Löfven
frame number: 125961
client mac: 08:00:27:d4:c0:18
client ip: 10.0.2.15
remote ip: 2.23.172.105
time: Sep 23, 2026 10:20:21.646058500 UTC (124.827336300 s)
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://www.bing.com/search?q=stefan+l%C3%B6fven&cvid=ffc581f5d00e41149665997955e1b051&gs_lcrp=EgRlZGdlKgYIABBFGDkyBggAEEUYOdIBCDM1ODNqMGo3qAIAsAIA&FORM=ANNTA1&PC=U531

Event 2: Image Search for Stefan Löfven
frame number: 129093
client mac: 08:00:27:d4:c0:18
client ip: 10.0.2.15
remote ip: 2.23.172.105
time: Sep 23, 2026 10:20:28.086571900 UTC (131.267849700 s)
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://www.bing.com/images/search?q=stefan+l%c3%b6fven&FORM=HDRSC3

Event 3: Download of Source Image of Stefan Löfven
frame number: 147449
client mac: 08:00:27:d4:c0:18
client ip: 10.0.2.15
remote ip: 172.105.80.31
time: Sep 23, 2026 10:20:45.449779300 UTC (148.631057100 s)
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://www.document.no/wp-content/uploads/2019/01/td82c1cc.jpg
bytes downloaded: 228238
image path: cloud-llm-investigation-2/td82c1cc.jpg

Event 4: Web Search for Volodymyr Zelenskyy
frame number: 148377
client mac: 08:00:27:d4:c0:18
client ip: 10.0.2.15
remote ip: 2.23.172.105
time: Sep 23, 2026 10:21:00.396037800 UTC (163.577315600 s)
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://www.bing.com/search?q=volodymyr+zelenskyy&cvid=8bfab82eaa234590b917ae387d9c8989&gs_lcrp=EgRlZGdlKgYIABBFGDkyBggAEEUYOdIBCDM0MjJqMGo3qAIAsAIA&FORM=ANNTA1&PC=U531

Event 5: Image Search for Volodymyr Zelenskyy
frame number: 149118
client mac: 08:00:27:d4:c0:18
client ip: 10.0.2.15
remote ip: 2.23.172.105
time: Sep 23, 2026 10:21:03.152962800 UTC (166.334240600 s)
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://www.bing.com/images/search?q=volodymyr+zelenskyy&FORM=HDRSC3

Event 6: Download of Source Image of Volodymyr Zelenskyy
frame number: 159516
client mac: 08:00:27:d4:c0:18
client ip: 10.0.2.15
remote ip: 67.205.4.140
time: Sep 23, 2026 10:21:20.810244300 UTC (183.991522100 s)
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://kourdi.com/wp-content/uploads/2022/11/Zelensky.png
bytes downloaded: 1669711
image path: cloud-llm-investigation-2/Zelensky.png


## Lessons learned from Gemini

  1. Missing System Utilities
  A few standard command-line tools were missing from the Debian/Ubuntu container image:

   - xxd / hexdump: 
     - Essential for converting hex dumps (http2.data.data or data-text-lines) into binary files when exporting raw data. Without xxd, we had to use Node.js buffers to write binary files to
       disk.
     - Adding xxd or bsdmainutils to the Dockerfile would make raw stream extraction a clean one-liner.
   - file:
     - file <path> was missing (command not found). Having file is handy for instantly verifying magic bytes, image dimensions, and formats of exported binary artifacts without needing an
       external viewer.
   - python3:
     - While prioritizing tshark is good practice, having a lightweight Python environment (or standard core utilities) provides a familiar Swiss Army knife for quick byte-level
       manipulation if needed.

  ---

  2. Output Volume & Token Consumption
  You rightly noticed that inspecting HTTP/HTTP2 packets consumed a significant amount of tokens early on. Here is why that happened and how it can be mitigated:

   - The -e http2.header.value Pitfall:
     - In tshark, HTTP/2 headers are stored as recurring fields. Passing -e http2.header.value dumps every single header in the frame (including enormous Cloudflare cookies, Sentry traces,
       authentication tokens, and CSP policies) as a comma-separated blob.
     - More efficient approach: Requesting specific pseudo-headers directly rather than dumping the whole header table:

   1     -e http2.headers.method -e http2.headers.authority -e http2.headers.path
   - Verbose (-V) Output:
     - Using -V dumps the entire protocol dissection tree, reassembled TCP/TLS segments, and encryption records, generating thousands of lines. Relying strictly on targeted -T fields with
       specific field filters keeps output minimal and context-efficient.

  ---

  3. HTTP/2 Object Exporting Limitation in tshark
   - tshark --export-objects natively supports http (HTTP/1.1), smb, tftp, and imf, but Wireshark 4.0.x does not support http2 in --export-objects.
   - This meant td82c1cc.jpg (served over HTTP/1.1) was cleanly exported via --export-objects http, but Zelensky.png (served over HTTP/2) had to be extracted by querying the final
     reassembled HTTP/2 DATA frame (frame.number == 161048 or 159040) and writing out its http2.data.data buffer.
   - Documenting or providing a helper script/recipe for HTTP/2 object carving is valuable for forensic tasks involving modern encrypted web traffic.

  ---

  4. Frame Number & Stream Demultiplexing Ambiguity
   - In modern protocols like HTTP/2 (and HTTP/1.1 with Keep-Alive), multiple distinct user actions (web search, image search, API telemetry) occur across a single persistent TCP
     connection.
   - In this capture, the Bing searches all took place over a single long-lived TCP stream (Stream 493). Specifying in the instructions whether "frame number" refers to the transport-layer
     connection establishment (the TCP SYN packet) or the application-layer request (the GET / HEADERS frame) removes ambiguity when students or analysts report multi-transaction sessions.

## Resources used

``` terminal
│  Model                         Reqs  Input Tokens   Cache Reads Output Tokens
│  ────────────────────────────────────────────────────────────────────────────
│  gemini-3.5-flash-lite              3         8,133             0     131   
│    ↳ utility_router                 3         8,133             0     131   
│  gemini-3.8-flash                  96    23,576,893    20,253,682     18,024
│    ↳ main                          96    23,576,893    20,253,682     18,024
│  gemini-3-flash-preview             5       338,746             0     703   
│    ↳ utility_loop_detector          5       338,746             0     703   
│  To resume this session: gemini --resume 35c18e09-15cb-4d14-b61b-c535b8c2cf3c  
```
