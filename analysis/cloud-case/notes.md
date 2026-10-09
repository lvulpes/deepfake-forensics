
# 2026-10-02

# Chain of Custody
Created a chain of custody log called evidence-log.csv. This should be used to log each evidence item. Note that the evidence items are files, e.g the pcap, the disk image, etc. However, when files are carved out of those they also need to be added to the evidence log. So for example images carved out of the pcap get their own lines in the log, but single packets do not.

# PCAP investigation
The pcap contains a lot of traffic. It can be helpful to use the object exporter (File -> Export objects) to find uploads and downloads of images as anchors in the timeline.

## DNS traffic
Get all queried domains with:
``` terminal
tshark -r exp-grok-3.pcapng -Y "dns.flags.response == 0" -T fields -e frame.time -e dns.qry.name
```
## Bing conversation
Get all IPs returned for www.bing.com
``` terminal
tshark -r exp-grok-3.pcapng -Y 'dns.flags.response == 1 && (dns.qry.type == 1 || dns.qry.type == 28) && dns.qry.name == "www.bing.com"' -T fields -e dns.qry.name -e dns.a

tshark -r exp-grok-3.pcapng -Y 'dns.flags.response == 1 && (dns.qry.type == 1 || dns.qry.type == 28) && dns.qry.name == "www.bing.com"' -T fields -e dns.a | sed 's/,/\n/g' | sort -u
```

## All conversations with grok
Find the IP addresses returned as DNS responses for grok.com

``` terminal 
tshark -r exp-grok-3.pcapng -Y 'dns.flags.response == 1 && (dns.qry.type == 1 || dns.qry.type == 28) && dns.qry.name == "grok.com"' -T fields -e dns.a | sed 's/,/\n/g' | sort -u

ip.addr == 104.18.28.234 || ip.addr == 104.18.29.234 || ip.addr == 108.162.192.218 || ip.addr == 108.162.195.219 || ip.addr == 162.159.44.219 || ip.addr == 172.64.32.218 || ip.addr == 172.64.35.219 || ip.addr == 173.245.58.218
```

## Timeline of conversation with grok
- 2026-09-23T12:18:28.586273200+0200        first DNS query for grok.com
- 2026-09-23T12:18:28.901514700+0200        client sends SYN to grok.com
- 2026-09-23T12:18:28.907765500+0200        TLS client hello
- 2026-09-23T12:22:15.161413000+0200        165093: upload of picture_a to grok
- 2026-09-23T12:22:15.192981200+0200        166784: upload of picture_b to grok
- 2026-09-23T12:22:16.269521100+0200        tcp.stream eq 460 and http2.streamid eq 57 (download of picture_b from grok)
- 2026-09-23T12:22:27.328016400+0200        168805: prompt from human to grok (tcp stream eq 654)
- 2026-09-23T12:22:58.554686300+0200        Thumbnail (?) download of the deepfake image from assets.grok.com
- 2026-09-23T12:22:51.635449800+0200        Second thumbnail (?) of deepfake image

## Timeline of conversation with bing
- 2026-09-23T12:18:28.595064500+0200        first DNS query for www.bing.com
- 2026-09-23T12:20:21.646058500+0200        tcp.stream eq 510 and http2.streamid eq 1 (image search for Stefan Lofven)
- 2026-09-23T12:20:42.954379400+0200        tcp.stream eq 510 and http2.streamid eq 119 (download of image of Stefan Lofven)
- 2026-09-23T12:21:03.868588700+0200        tcp.stream eq 510 and http2.streamid eq 227 (image search for zelensky)
- 2026-09-23T12:21:21.010701000+0200        159544 download of Zelensky image from kourdi.com

## Timeline of conversation with x.com
- 2026-09-23T12:23:14.391379700+0200        First DNS query for x.com
- 2026-09-23T12:23:14.413904500+0200        TCP SYN
- 2026-09-23T12:23:14.420165000+0200        TLS client hello
- 2026-09-23T12:25:17.686267500+0200        219859 upload of deepfake image to x.com

## Open questions
- Many pictures were downloaded during the image search (just to be able to see them they need to be downloaded)
    How do we prove which image was used in the end? We need to follow the bytes...
- We need to find the download of the deepfake image from grok -> Carve the image and compare the hash
- The download from grok is likely inside a websocket connection, still have not found the image itself
- Even though the deepfake image download was found it is suspiciously small, it seems like a thumbnail, however it will have to do.

## Reconstructed timeline

### Bing search for Stefan:
packet: 125961
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 2.23.172.105
time: 2026-09-23T12:20:21.646058500+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://www.bing.com/search?q=stefan+l%C3%B6fven&cvid=ffc581f5d00e41149665997955e1b051&gs_lcrp=EgRlZGdlKgYIABBFGDkyBggAEEUYOdIBCDM1ODNqMGo3qAIAsAIA&FORM=ANNTA1&PC=U531


### Download of Stefan image 1:
packet: 144986
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 2.23.88.229
time: 2026-09-23 12:20:43.460336800+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://i0.web.de/image/684/35972684,pd=2/stefan-loefven.jpg
bytes downloaded: 240791
filename: picture_a.i0.web.de.jpg
note: This one is actually used in the deepfake generation

### Download of Stefan image 2:
packet: 146115
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 104.17.28.235
time: 2026-09-23T12:20:43.717132800+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://cdn.ebs.newsner.com/wp-content/uploads/sites/13/2021/07/stefan-lofven-statsminister-s.jpg
Bytes downloaded: 618672
filename: picture_a.cdn.ebs.newsner.com.jpg
note: This image is not used in the deepfake generation

### Bing search for Zelensky:
packet: 148377
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 2.23.172.105
time: 2026-09-23T12:21:00.396037800+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://www.bing.com/search?q=volodymyr+zelenskyy&cvid=8bfab82eaa234590b917ae387d9c8989&gs_lcrp=EgRlZGdlKgYIABBFGDkyBggAEEUYOdIBCDM0MjJqMGo3qAIAsAIA&FORM=ANNTA1&PC=U531

### Download of Zelensky image:
packet: 159544
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 67.205.4.140
time: 2026-09-23T12:21:21.010701000+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://kourdi.com/wp-content/uploads/2022/11/Zelensky.png
bytes downloaded: 1669711
filename: picture_b.kourdi.com.png
note: This image is used in the deepfake generation

### Upload of Zelensky to grok:
packet: 164981
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 104.18.28.234
time: 2026-09-23T12:22:15.153241400+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://grok.com/http/upload-file-v2/direct
bytes uploaded: 1669897
filename: picture_b.grok.com.png
note: This is a PNG upload of picture_b to grok, IT STILL NEEDS CARVING

### Upload of Stefan to grok:
packet: 165089
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 104.18.28.234
time: 2026-09-23T12:22:15.161244900+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://grok.com/http/upload-file-v2/direct
bytes uploaded: 228425
filename: picture_a.grok.com.jpg
note: Lofven JPG upload to grok

### Prompt to grok:
packet: 168805
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 104.18.28.234
time: 2026-09-23T12:22:27.328016400+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0 (Before switch to websocket)
URL: https://grok.com/ws/mgw/?uid=bd99dc24-a9c9-4222-abe0-f5b4cd8ebe1d (Before switch to websocket)
note: The prompt is through websocket connection, HTTP2 parameters from before switch

### Download deepfake from grok:
packet: 170581
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 104.18.28.234
time: 2026-09-23T12:22:58.403963200+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://assets.grok.com/users/bd99dc24-a9c9-4222-abe0-f5b4cd8ebe1d/generated/c588c87d-cc66-4da9-bd4c-0abd1e407503/image.jpg
bytes downloaded: 241537
filename: deepfake.grok.com.jpg
note: This is the deepfake image before it was screenshotted. It includes 2 signatures before the binary image data (watermarks?)

### Upload deepfake to X:
packet: 218435
source mac: 08:00:27:d4:c0:18
source ip: 10.0.2.15
destination ip: 172.66.0.227
time: 2026-09-23T12:25:17.631113300+0200
user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0
URL: https://upload.x.com/i/media/upload.json?command=APPEND&media_id=2102705838913667072&segment_index=0
bytes uploaded: 1729507
filename: deepfake.upload.x.com.png
note: This deepfake image is larger because it was produced with snipping tool to avoid watermarking.

# Misc

Very strange instructions for grok in tcp stream eq 32

# TO DO
- Enrich above evidence with source, destination IPs, source MAC address -> DONE
- Save all relevant carved images -> DONE
- Delete irrelevant carved images -> DONE
- Add saved files to evidence-log -> TO DO AFTER COFFEE
