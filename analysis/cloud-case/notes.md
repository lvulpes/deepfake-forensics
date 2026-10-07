
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
- 2026-09-23T12:22:27.328016400+0200        168805: prompt from human to grok (tcp stream eq 654)
- 2026-09-23T12:22:16.269521100+0200        tcp.stream eq 460 and http2.streamid eq 57 (download of picture_b from grok)

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

# Misc

Very strange instructions for grok in tcp stream eq 32
