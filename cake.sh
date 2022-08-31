#!/bin/sh
############################################################


### Interfaces ###

## Go to: "Network -> Interfaces" and write the name of those interfaces here.

## Change this to the name of your "LAN interface", if you have altered it from the OpenWrt default.
LAN="br-lan"


## Change this to the name of your "WAN interface".
WAN="wan"


############################################################


### Download methods ###

DOWN_METHOD="veth"  # Write: "veth" | "normal"
                    # "veth"   The 'DSCP marks' work on download and upload in "Cake".
                    # "normal" The 'DSCP marks' only work on upload in "Cake".


######################################################################################################################


### CAKE settings ###

DOWNRATE="42000"  # Change this to about 80-95% of your download speed (in kbit).
UPRATE="16000"     # Change this to about 80-95% of your upload speed (in kbit).
                   # Do a Speed Test: https://www.speedtest.net/
                   # Not recommendable: Don't write anything in "DOWNRATE" or "UPRATE" to use 'qdisc shaper' with no limit on the bandwidth ('unlimited' parameter).
                   # Not recommendable: Write "0" in "DOWNRATE" or "UPRATE" to disable 'qdisc shaper' on download or upload.

AUTORATE_INGRESS="no"  # Write: "yes" | "no"
                       # Enable CAKE automatic rate estimation for ingress.
                       # For it to work you need to write your bandwidth in "DOWNRATE" to specify an initial estimate.
                       # This is most likely to be useful with cellular links, which tend to change quality randomly.

## Make sure you set these parameters correctly for your connection type or don't write any value and use a presets or keywords below.
OVERHEAD="22"  # Write values between "-64" and "256"
MPU=""       # Write values between "0" and "256"
FRAMING="ptm"   # Write: "ptm" | "atm" | "noatm"
             # These values overwrite the presets or keyboards below.
             # Read: https://openwrt.org/docs/guide-user/network/traffic-shaping/sqm#configuring_the_sqm_bufferbloat_packages
             # Read: https://openwrt.org/docs/guide-user/network/traffic-shaping/sqm-details#sqmlink_layer_adaptation_tab

## Only use these presets or keywords if you don't write a value above in OVERHEAD, MPU and FRAMING.
COMMON_LINK_PRESETS="conservative"  # Write the keyword below:
                                    # "conservative"     Failsafe     (overhead 48 - atm)
                                    # "ethernet"         Ethernet     (overhead 38 - mpu 84 - noatm)
                                    # "docsis"           Cable Modem  (overhead 18 - mpu 64 - noatm)
                                    # "pppoe-ptm"        VDSL2        (overhead 30 - ptm)
                                    # "bridged-ptm"      VDSL2        (overhead 22 - ptm)
                                    # "pppoa-vcmux"      ADSL         (overhead 10 - atm)
                                    # "pppoa-llc"        ADSL         (overhead 14 - atm)
                                    # "pppoe-vcmux"      ADSL         (overhead 32 - atm)
                                    # "pppoe-llcsnap"    ADSL         (overhead 40 - atm)
                                    # "bridged-vcmux"    ADSL         (overhead 24 - atm)
                                    # "bridged-llcsnap"  ADSL         (overhead 32 - atm)
                                    # "ipoa-vcmux"       ADSL         (overhead 8  - atm)
                                    # "ipoa-llcsnap"     ADSL         (overhead 16 - atm)
                                    # If you are unsure, then write "conservative" as a general safe value.
                                    # These keywords have been provided to represent a number of common link technologies.
                                    ######################################################################################
                                    # For true ATM links (ADSL), one often can measure the real per-packet overhead empirically,
                                    # see: https://github.com/moeller0/ATM_overhead_detector for further information how to do that.

## This keyword is not for standalone use, but act as a modifier to some previous presets or keywords.
ETHER_VLAN_KEYWORD=""  # Write values between "1" and "3" or don't write any value.
                       # In addition to those previous presets or keywords it is common to have VLAN tags (4 extra bytes) or PPPoE encapsulation (8 extra bytes).
                       # "1" Adds '4 bytes' to the overhead  (ether-vlan)
                       # "2" Adds '8 bytes' to the overhead  (ether-vlan ether-vlan)
                       # "3" Adds '12 bytes' to the overhead (ether-vlan ether-vlan ether-vlan)
                       # This keyword "ether-vlan" may be repeated as necessary in 'EXTRA PARAMETERS'.
                       # Read: https://man7.org/linux/man-pages/man8/tc-cake.8.html#OVERHEAD_COMPENSATION_PARAMETERS

DOWN_PRIORITY_QUEUE="diffserv4"  # Write: "besteffort" | "diffserv3" | "diffserv4" | "diffserv8"
UP_PRIORITY_QUEUE="diffserv4"    # Write: "besteffort" | "diffserv3" | "diffserv4" | "diffserv8"
                                 # CAKE can divide traffic into tins based on the Diffserv field.
                                 # "besteffort" only has 'one tin' or priority tier.
                                 # "diffserv3" has '3 tins' or different priority tiers.
                                 # "diffserv4" has '4 tins' or different priority tiers.
                                 # "diffserv8" has '8 tins' or different priority tiers. <- Broken

PER_HOST_ISOLATION="yes"  # Write: "yes" | "no"
                          # Per-Host Isolation or 'dual-dsthost' (download) and 'dual-srchost' (upload), prevents a single host/client
                          # that has multiple connections (like when torrenting) from hogging all the bandwidth
                          # and provides better traffic management when multiple hosts/clients are using the internet at the same time.

DOWN_NAT="no"  # Write: "yes" | "no"
UP_NAT="yes"   # Write: "yes" | "no"
               # Perform a NAT lookup before applying flow-isolation rules to improve fairness between hosts "inside" the NAT.
               # Don't use "nat" parameter in download when use 'Veth method' or flow-isolation stops working.
               # Only use "nat" parameter in download when use 'Normal method'.
               ## Recommendation: Don't use "nat" in download on the "Veth interfaces" and only use "nat" in download and upload on the "WAN interface".

DOWN_WASH="no"  # Write: "yes" | "no"
UP_WASH="yes"   # Write: "yes" | "no"
                # "wash" only clears all DSCP marks after the traffic has been tinned.
                # Don't wash incoming (download) DSCP marks, because also wash the custom DSCP marking from this script and the script already washes the marks below.
                # Wash outgoing (upload) DSCP marks to ISP, because may be mis-marked from ISP perspective.
                ## Recommendation: Don't use "wash" on ingress (download) so that "WMM" can make use of the custom DSCP marking and just use "wash" on egress (upload).

INGRESS_MODE="yes"  # Write: "yes" | "no"
                    # Enabling "ingress mode" ('ingress' parameter) will tune the AQM to always keep at least two packets queued *for each flow*.
                    # Basically will drop and/or delay packets in a way that the rate of packets leaving the shaper is smaller or equal to the configured shaper-rate.
                    # This leads to slightly more aggressive dropping, but this also ameliorates one issue we have with post-bottleneck shaping,
                    # namely the inherent dependency of the required bandwidth "sacrifice" with the expected number of concurrent bulk flows.
                    # Thus, being more lenient and keeping a minimum number of packets queued will improve throughput in cases
                    # where the number of active flows are so large that they saturate the bottleneck even at their minimum window size.

UP_ACK_FILTER="auto"  # Write: "yes" | "no" | "auto"
                      # Write "auto" or don't write anything, so that the script decide to use this parameter, depending on the bandwidth you wrote in "DOWNRATE" and "UPRATE".
                      # If your up/down bandwidth is at least 1x15 asymmetric, you can try the 'ack-filter' option.
                      # It doesn't help on your downlink, nor on symmetric links.
                      # 'ack-filter' only makes sense for egress (upload), so don't add 'ack-filter' keyword for the ingress side (download).
                      # Don't recommend turning it on more symmetrical link bandwidths the effect is negligible at best.

## Don't write 'ms', just write the number.
RTT="40"  # Write values between "1" and "1000" or don't write any value to use the default value (100).
        # This parameter defines the time window that your shaper will give the endpoints to react to shaping signals (drops or ECN).
        # The default "100ms" is pretty decent that works for many people, assuming their packets don't always need to cross long distances.
        # If you are based in Europe and access data in California I would assume 200-300ms to be a better value.
        # The general trade off is higher RTTs cause higher bandwidth utilization at the cost of increased latency under load (or rather longer settling times).
        # If your game servers are "40ms" RTT away, you should configure cake accordingly (this will lead to some bandwidth sacrifices for flows with a longer RTT).
        # Again setting RTT too high will increase the latency under load (aka the Bufferbloat) while increasing bandwidth utilization.
        # You should measure the RTT for cake while your network is not loaded.
        # Use ping to measure the Round Trip Time (RTT) on servers you normally connect.
        # Example: ping -c 20 openwrt.org (Linux)
        # Example: ping -n 20 openwrt.org (Windows)

DOWN_EXTRA_PARAMETERS=""  # Add any custom parameters separated by spaces.
UP_EXTRA_PARAMETERS=""    # Add any custom parameters separated by spaces.
                          # These will be appended to the end of the CAKE options and take priority over the options above.
                          # There is no validation done on these options. Use carefully!
                          # Look: https://man7.org/linux/man-pages/man8/tc-cake.8.html


######################################################################################################################


### DSCP marks ###

## Before changing the DSCP marks, first look at the images of the post and read this:
## Information: https://datatracker.ietf.org/doc/html/rfc8325


## Default Chain for iptables
CHAIN="FORWARD"  # Write: "FORWARD" | "POSTROUTING"


## Wash all DSCP marks and now this is the default DSCP for all unmarked traffic.
STANDARD_DEFAULT="CS0"


## Network services
SSH="CS2"
NTP="CS2"
DNS="CS2"
ICMP="CS0"
DOT="AF41"  # DNS over TLS (DoT)


## Prioritize traffic
TELEPHONY="EF"                  # VoIP and VoWiFi (WiFi Calling).
MULTIMEDIA_CONFERENCING="AF41"  # Zoom, Microsoft Teams, Skype, GoToMeeting, Webex Meeting, Jitsi Meet, Google Meet, FaceTime and TeamViewer.
REAL_TIME_GAMING="CS4"          # PC Game Ports and Game Consoles (Need to be added below).
MULTIMEDIA_STREAMING="AF31"     # Browsing and Multimedia Streaming to Watch YouTube, Netflix, Twitch and QUIC Protocol (TCP/UDP ports 80, 443 and 8080).
BROADCAST_VIDEO="CS3"           # Live Streaming to YouTube Live, Twitch, Vimeo and LinkedIn Live.
HIGH_THROUGHPUT_DATA="AF11"     # Web Traffic (TCP ports 80, 443 and 8080).
LOW_PRIORITY_DATA="CS1"         # Bulk traffic such as BitTorrent, Usenet or TCP downloads that have transferred more than 10 seconds worth of packets.

                                ## The DSCP marks "LE" and "VA" (aka. "VOICE-ADMIT") don't work.
                                ## You can test changing the DSCP mark "CS4" to "EF" in the game category.


############################################################


### DSCP ports settings ###

## You can delete the ports below, they are just an example.


## PC Game Ports (List 1)
TCP_GAME_PORTS_LIST_1="25565"
UDP_GAME_PORTS_LIST_1="19132:19133,25565"
                       # Define a list of TCP and UDP ports used by PC Games.
                       # Use a comma to separate the values or ranges A:B as shown.
                       # Up to 15 ports can be specified. A port range (port:port) counts as two ports.


## PC Game Ports (List 2)
TCP_GAME_PORTS_LIST_2="3074"
UDP_GAME_PORTS_LIST_2="3074,3659,30000:45000"
                       # Define a second list of TCP and UDP ports used by PC Games.
                       # Use a comma to separate the values or ranges A:B as shown.
                       # Up to 15 ports can be specified. A port range (port:port) counts as two ports.


## BitTorrent Ports
TCP_BULK_PORTS="6881:6889,6969,51413"
UDP_BULK_PORTS="6881:6889,6969,51413"
                # Define a list of TCP and UDP ports used for 'bulk traffic' such as BitTorrent.
                # Set your BitTorrent client to use a known port and include it here.
                # Use a comma to separate the values or ranges A:B as shown.
                # Recommendation: On your BitTorrent client (qBittorrent) only use the "uTP" protocol.


## Custom Ports [OPTIONAL]
DSCP_OTHER_PORTS="CS0"  # Change this DSCP mark wherever you want.

TCP_OTHER_PORTS=""
UDP_OTHER_PORTS=""
                 # Define a list of TCP and UDP ports and mark wherever you want.
                 # Use a comma to separate the values or ranges A:B as shown.
                 # Up to 15 ports can be specified. A port range (port:port) counts as two ports.


############################################################


### DSCP IP address settings ###

## To add static IP addresses in OpenWrt go to: "Network -> DHCP and DNS -> Static Leases -> Click 'Add'"
## You can delete the IP addresses below, they are just an example.


## Game Consoles (Static IP)
IPV4_GAME_CONSOLES_STATIC_IP="192.168.2.160"
                              # Define a list of IP addresses that will cover all ports (except 80,443,8080 and BitTorrent ports).
                              # Write a single IP or a CIDR block for a range of IP addresses A/B and use a comma to separate them as shown.
                              # CIDR Address Range "192.168.1.20/30" = '192.168.1.20' to '192.168.1.23'
                              # IPv4 CIDR: https://www.subnet-calculator.com/cidr.php

IPV6_GAME_CONSOLES_STATIC_IP="fd30:9abe:f0ab::15,fd30:9abe:f0ab::20/126"
                              # Go to: "Network -> Interfaces -> Global network options (tab) -> IPv6 ULA-Prefix"
                              # and replace that IP with this "fd30:9abe:f0ab::" or replace the IP of the script with that IP, but don't change the CIDR notation "/48" in the router or add it in the script.

                              # In the IPv6 address simply change the number after the double colon "::" for the last number of your static IP (IPv4).
                              # The last number "::15" or CIDR "::20/126" is the static IP of '192.168.1.15' and CIDR '192.168.1.20/30' (IPv4).
                              # CIDR Address Range "::20/126" = '::20' to '::23'
                              # IPv6 CIDR: https://www.vultr.com/resources/subnet-calculator-ipv6/ (Display: short)


## TorrentBox (Static IP)
IPV4_TORRENTBOX_STATIC_IP="192.168.1.10"
                           # Define a list of IP addresses and mark 'all traffic' as bulk.
                           # Write a single IP or a CIDR block for a range of IP addresses A/B and use a comma to separate them as shown.

IPV6_TORRENTBOX_STATIC_IP="fd30:9abe:f0ab::10"
                           # Go to: "Network -> Interfaces -> Global network options (tab) -> IPv6 ULA-Prefix"
                           # and replace that IP with this "fd30:9abe:f0ab::" or replace the IP of the script with that IP, but don't change the CIDR notation "/48" in the router or add it in the script.

                           # In the IPv6 address simply change the number after the double colon "::" for the last number of your static IP (IPv4).
                           # The last number "::10" is the static IP of '192.168.1.10' (IPv4).


## Custom IP address [OPTIONAL]
DSCP_OTHER_STATIC_IP="CS0"  # Change this DSCP mark wherever you want.

IPV4_OTHER_STATIC_IP=""
IPV6_OTHER_STATIC_IP=""
                      # Define a list of IP addresses and mark 'all traffic' wherever you want.
                      # Write a single IP or a CIDR block for a range of IP addresses A/B and use a comma to separate them as shown.



## Custom IP address + Ports (List 1) [OPTIONAL]
DSCP_OTHER_STATIC_IP_PORTS_LIST_1="CS0"  # Change this DSCP mark wherever you want.

IPV4_OTHER_STATIC_IP_PORTS_LIST_1=""
IPV6_OTHER_STATIC_IP_PORTS_LIST_1=""
                                   # Define a list of IP addresses to 'only' use the ports from this rule.
                                   # Write a single IP or a CIDR block for a range of IP addresses A/B and use a comma to separate them as shown.

TCP_OTHER_STATIC_IP_PORTS_LIST_1=""
UDP_OTHER_STATIC_IP_PORTS_LIST_1=""
                                  # Define a list of TCP and UDP ports.
                                  # Use a comma to separate the values or ranges A:B as shown.
                                  # Up to 15 ports can be specified. A port range (port:port) counts as two ports.


## Custom IP address + Ports (List 2) [OPTIONAL]
DSCP_OTHER_STATIC_IP_PORTS_LIST_2="CS0"  # Change this DSCP mark wherever you want.

IPV4_OTHER_STATIC_IP_PORTS_LIST_2=""
IPV6_OTHER_STATIC_IP_PORTS_LIST_2=""
                                   # Define a list of IP addresses to 'only' use the ports from this rule.
                                   # Write a single IP or a CIDR block for a range of IP addresses A/B and use a comma to separate them as shown.

TCP_OTHER_STATIC_IP_PORTS_LIST_2=""
UDP_OTHER_STATIC_IP_PORTS_LIST_2=""
                                  # Define a list of TCP and UDP ports.
                                  # Use a comma to separate the values or ranges A:B as shown.
                                  # Up to 15 ports can be specified. A port range (port:port) counts as two ports.


######################################################################################################################


### Firewall ###

FIREWALL_RESTART="no"  # Write: "yes" | "no"
                       # "yes" Restart the firewall to flush the iptables.
                       # "no"  Delete the rules from the chain without restarting the firewall.
                       # This option is for when you change DSCP flags and add ports or IP addresses.
                       # Restarting the firewall will cause you to lose all current connections, but is more reliable to clear the iptables and DSCP flags.
                       ## Recommendation: "no", and just use "yes" when the iptables don't clear properly.


############################################################


### Change the 'Default settings' in OpenWrt ###

DEFAULT_QDISC="cake"  # Write: "fq" | "fq_codel" | "cake"
                      # "fq"       Great qdisc for end hosts, preferably endhost without virtual machines running.
                      # "fq_codel" Great all around qdisc. (Default in OpenWrt)
                      # "cake"     Great for WAN links, but computationally expensive with little advantages over 'fq_codel' for LAN links.


TCP_CONGESTION_CONTROL="bbr"  # Write: "cubic" | "bbr"
                              # "cubic" (Default in OpenWrt)
                              # "bbr"   New congestion control by Google, maybe this can improve network response.


ECN="2"  # Write values between "0" and "2"
         # "0" Disable ECN. Neither initiate nor accept ECN. (Default in OpenWrt)
         # "1" Enable ECN. When requested by incoming connections and also request ECN on outgoing connection attempts.
         # "2" Enable ECN. When requested by incoming connections, but do not request ECN on outgoing connections.
         # Read: https://www.bufferbloat.net/projects/cerowrt/wiki/Enable_ECN/


############################################################


### irqbalance and Packet Steering ###

IRQBALANCE="yes"  # Write: "yes" | "no"
                  ## If you disable it with "no", you must also "reboot" the router for it to take effect.
                  # Help balance the cpu load generated by interrupts across all of a systems cpus and probably increase performance.
                  # The purpose of irqbalance is to distribute hardware interrupts across processors/cores on a multiprocessor/multicore system in order to increase performance.


PACKET_STEERING="yes"  # Write: "yes" | "no"
                       ## If you disable it with "no", you must also "reboot" the router for it to take effect.
                       # Enable packet steering across all CPUs. May help or hinder network speed.
                       # It's another (further) approach of trying to equally distribute the load of (network-) packet processing over all available cores.
                       # In theory this should also 'always' help, in practice it can be worse on some devices.
                       # It enables some kind of steering that seems different than what irqbalance does. I'm guessing it sets some of the manual IRQ or TX/RX IRQ assignments.

                       ## Enabling packet-steering can go either way, it may improve your throughput or it can worsen your results.
                       ## This is hardware (and to come extent protocol-, as in PPPoE vs DHCP vs whatever) dependent, so you need to
                       ## test both and compare your speedtests (and CPU load, keep "htop" open over SSH) for both configuration settings.


############################################################


### Hotplug ###

HOTPLUG="yes"  # Write: "yes" | "no"
               # Hotplug to automatically reloads the script.


######################################################################################################################

#########################     #########################     #########################
### DO NOT EDIT BELOW ###     ### DO NOT EDIT BELOW ###     ### DO NOT EDIT BELOW ###
### DO NOT EDIT BELOW ###     ### DO NOT EDIT BELOW ###     ### DO NOT EDIT BELOW ###
#########################     #########################     #########################

### CAKE settings ###