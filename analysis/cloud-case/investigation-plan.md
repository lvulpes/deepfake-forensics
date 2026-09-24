# Digital Forensics Project Analysis Plan

Mount the virtual hard drives as read-only and generate initial SHA-256 hashes of all evidence files (VHDs, PCAPs, RAM dumps) to establish the chain of custody.

## Phase 1: Network Traffic Analysis (PCAPs)
Process the network captures first to establish a timeline of external interactions and local service API calls.
* **Cloud Generation (Grok VM):** Filter for DNS queries and TLS SNI (Server Name Indication) handshakes for `grok.com` or associated API endpoints. Isolate the TCP streams to identify payload size spikes correlating with the generation and downloading of the deepfake.
* **Local Generation (FaceFusion VM):** Analyze the loopback interface capture. Filter for HTTP/Websocket traffic (typically port 7860 for Gradio interfaces used by FaceFusion). Reassemble HTTP POST requests to extract base64-encoded source images sent to the local inference server and the returning generated media.
* **Source Material & Dissemination (Both VMs):** Filter for SNI and DNS related to the source material domains and `twitter.com`/`x.com`. Isolate the exact timestamp of the HTTP POST/TLS streams representing the deepfake upload to Twitter.

## Phase 2: Windows Hard Drive Artifacts
Parse the virtual hard drives using FTK Imager or Autopsy to extract specific Windows OS and application artifacts proving execution and file manipulation.
* **Browser Forensics (Grok & Source Downloads):** Extract SQLite databases from `AppData\Local\Google\Chrome\User Data\Default\` (or equivalent for Edge/Firefox). Query the `History` and `Downloads` tables to map the exact URLs, search terms, and download timestamps for the source images and the Grok web interface sessions.
* **Execution Evidence (FaceFusion):** Parse `C:\Windows\Prefetch` for `PYTHON.EXE` and `C:\Windows\AppCompat\Programs\Amcache.hve`. This will prove when the FaceFusion environment was executed, how many times it was run, and from what specific directory path.
* **File System Timestamps (MFT & USN Journal):** Parse the Master File Table (`$MFT`) and the Update Sequence Number Journal (`$Extend\$UsnJrnl:$J`). Track the creation, modification, and potential deletion events for the downloaded source images and the generated deepfake outputs. The USN Journal will show the exact sequence of file writes by the browser (Grok) vs. the Python process (FaceFusion).
* **User Interaction (LNK & Jump Lists):** Analyze `C:\Users\<User>\AppData\Roaming\Microsoft\Windows\Recent` (LNK files) and `AutomaticDestinations` (Jump Lists). These artifacts will prove the user actively opened, viewed, or moved the deepfake images in Windows Explorer before uploading them to Twitter.

## Phase 3: Additional Evidence Sources
Gather these secondary sources to corroborate the network and disk findings.
* **Final Output Images:** Download the live, public tweets and images directly from Twitter. Compare the hash and Exif metadata of the Twitter-hosted images against the artifacts recovered from the VHDs to document exactly what metadata Twitter scrubs or alters upon upload.
* **Hypervisor Logs:** Pull the hypervisor logs (VMware, VirtualBox, or Hyper-V) from the host machine. Correlate the physical VM start, suspend, and stop times with the internal Windows Event logs (e.g., Event ID 6005/6006 in `System.evtx`) to validate the timeline's integrity.
* **Open Source Intelligence (OSINT):** Capture a forensic archive of the Twitter accounts (using a tool like `yt-dlp` or web archiving) to freeze the dissemination state, view counts, and timestamps as seen by the public.

## Phase 4: RAM Analysis
Use Volatility 3 on the memory dumps to recover ephemeral data that never hit the VHD.
* Run `windows.netstat.NetStat` to map open network sockets at the time of the dump, corroborating the PCAP IP endpoints.
* Run `windows.cmdline.CmdLine` to recover the exact arguments passed to the FaceFusion Python script (e.g., execution flags, target paths).
* Run `windows.memmap.Memmap` against the browser processes (e.g., `chrome.exe`) and carve the memory space with `strings` or `grep` to recover cleartext Grok prompts, API keys, or raw image data that was encrypted in the network capture.
