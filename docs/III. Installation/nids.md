# NIDS Installation

Before installing an NIDS, you need to prepare your dirtribution. In our case, we are going to use Debian.

## Debian Installation

For this installation, I choose the [debian-10.6.0-amd64-netinst.iso](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/).

During the installation, untick debian desktop environment.

## Suricata installation

### **Compilation chain installation** 

In order to compile Suricata and its dependencies, it is necessary to install on the system, a compilation chain

**Lexical and syntax analysers**

- `GNU Bison` : Compiler compiler in charge of semantic and syntactic analysis.
- `Flex` : Lexical pattern analyser.

```
$ sudo apt install flex bison
```

**Autotools**

- `GNU Make` : Provides help with compiling and linking by creating dependency installation description files called makefiles.
- `GNU AutoMake` : Allows the generation of a makefile from a higher level description.
- `GNU AutoConf` : Allows the generation of a shell script to configure the "co nfigure" development environment from programs based on the GNU M4 preprocessor.
- `GNU LibTool` :  Used with AutoConf and AutoMake to simplify the compilation process.
- `GNU AutoGen` : Provides a similar approach to Flex in makefile generation.

``` 
$ sudo apt install make automake autoconf libtool autogen m4
```

**Compiler**

- `GNU BinUtils` : Set of tools for the creation and management of binary programs and assembler sources.
- `GNU Debugger` : Provides a large set of tools for tracing or altering the execution of a program.
- `GNU C++` : Compiler for C++.

``` 
$ sudo apt install binutils gcc g++ gdb build-essential
```

**Installation of the dependencies**

To work, Suricata is mainly based on these libraries:

- `LibPCRE` : Provides functions for PCRE ("Perl Compatible Regular Expressions") based regular expression management.
- `LibPcap` : Provides functions for capturing network traffic.
- `LibNet` : Provides low-level network interaction functions.
- `LibYaml` : Provides data processing functions using the YAML form standard.
- `LibNetFilter` : Provides interaction functions with the kernel firewall.
- `Zlib` : Provides functions for compressing / decompressing data ;
- `LibJansson` : Provides functions for data processing using theJSON (JavaScript Object Notation) format.

``` 
apt install libpcre3 libpcre3-dbg libpcre3-dev libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev libnetfilter-queue-dev zlib1g zlib1g-dev libmagic-dev libcap-ng-dev libjansson-dev liblz4-dev libnss3-dev pkg-config magic coccinelle cbindgen rustc 
```

**Suricata download**

To download and build Suricata, enter the following:

```
$ wget http://www.openinfosecfoundation.org/download/suricata-6.0.0.tar.gz
$ tar -xvzf suricata-6.0.0.tar.gz
$ cd suricata-6.0.0
```

**Compilation of suricata**

To compile and install the program, you have to continue with the next commands:

```
$ ./configure
$ make
$ make install
```
To make sure the existing list with libraries will be updated with the new library, enter:
```
$ ldconfig
```

### Suricata configuration

**Creation of configuration files**

Creation of the event log storage directory :

```
$ mkdir /var/log/suricata
```

Creation of rules storage directory :

```
$ mkdir -p /etc/suricata/rules
```

Creating configuration files :

```
$ cp {suricata.yaml,etc/classification.config,etc/reference.config} /etc/suricata
$ touch /etc/suricata/threshold.config
```

Modification of the configuration file `suricata.yaml` :

```
$ vi /etc/suricata/suricata.yaml
```
Modification of local variables in Suricata :
```bash
    HOME_NET: "192.168.25.0/24"
```

Deactivation of rules allowing alerts to be sent to the SIEM :
```bash
# alert output to prelude (http://www.prelude-technologies.com/) only
# available if Suricata has been compiled with --enable-prelude
# - alert-prelude:
# enabled: no
# profile: suricata
# log-packet-content: no
# log-packet-header: yes
```
Configuration of logging flows :
```bash
# Define your logging outputs. If none are defined, or they are all  
# disabled you will get the default - console output.  
outputs:  
- console:      
    enabled: yes  
- file:      
    enabled: yes      
    filename: /var/log/suricata/suricata.log
```

#### **Suricata rules**

First you have to install suricata-update :
```
sudo apt install suricata-update
```

If upgrading from an older version of Suricata, or running a development version that may not be bundled with Suricata-Update, you will have to check that your `suricata.yaml` is configured for Suricata-Update. The main difference is the `default-rule-path` which is `/var/lib/suricata/rules` when using Suricata-Update.

You will want to update your suricata.yaml to have the following 
:
```bash
default-rule-path: /var/lib/suricata/rules

rule-files:
    - suricata.rules
```
**Discover Other Available Rule Sources**

First update the rule source index with the update-sources command, for example:

```
$ suricata-update update-sources
```
Then list the sources from the index. Example :
```
$ suricata-update list-sources
```
Now enable the ptresearch/attackdetection ruleset :
```
$ suricata-update enable-source ptresearch/attackdetection
```
And update your rules again:
```
$ suricata-update
```

#### **Run suricata**

```
$ suricata -c /etc/suricata/suricata.yaml -i ens33
```

## Tcpdump installation

Tcpdump is a data-network packet analyzer computer program that runs under a command line interface. It allows the user to display TCP/IP and other packets being transmitted or received over a network to which the computer is attached.

We are going to use it in order to capture the traffic between the malware and internet or fake internet.

First, we must install the packet tcpdump :
```
$ apt install tcp-dump
```

If your $PATH is empty, You may set the PATH variable with this command :
```bash
$ export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
```

```
-w capture_file -> pcap
-i [network interface]
```

```
$ tcpdump -i [networkinterface] -w capture_file
```

## Installing a Fake Internet with INetSim and PolarProxy

**Inetsim** is a software that simulates common internet services like HTTP, SMTP, DNS, FTP, IRC. This software is useful when analysing the network behavior of malware without connecting them to Internet. **PolarProxy** is a transparent SSL/TLS proxy. He is primarily designed to intercept and decrypt TLS encrypted traffic from malware. PolarProxy decrypts and re-encrypts TLS traffic, while also saving the decrypted traffic in a PCAP file that can be loaded into Wireshark or an intrusion detection system (IDS).  

### INetSim Installation

To install INetSim using apt, add the INetSim Debian Archive repository to your apt sources: 

```bash
$ echo "deb http://www.inetsim.org/debian/ binary/" > /etc/apt/sources.list.d/inetsim.list 
```
To access the Debian package sources, also add: 
 ```bash
$ echo "deb-src http://www.inetsim.org/debian/ source/" >> /etc/apt/sources.list.d/inetsim.list
 ```
To allow apt to verify the digital signature on the INetSim Debian Archive's Release file, add the INetSim Archive Signing Key to the apt trusted keys: 
 ```
$ wget -O - https://www.inetsim.org/inetsim-archive-signing-key.asc | apt-key add - 
 ```
After installing the key, update the cache of available packages: 
```
$ apt update 
```
Finally, install INetSim: 
```
$ apt install inetsim
```

### Configuration

By default INetSim listens on 127.0.0.1, for change this you need to un-commenting and editing the service_bind-address variable in /etc/inetsim/inetsim.conf.
```
service_bind_address    192.168.53.19 
```
Also configure INetSim's fake DNS server to resolve all domain names to the IP of INetSim with the dns_default_ip setting: 
```
dns_default_ip    192.168.53.19 
```
Finally, disable the ```start_service https``` and ```start_service smtps``` lines, because these services will be replaced with PolarProxy: 
```
start_service dns
start_service http
#start_service https
start_service smtp
#start_service smtps
```
Restart the INetSim service after changing the config. 
```
sudo systemctl restart inetsim.service 
```
Verify that you can access INetSim's HTTP server with curl: 
```
curl http://192.168.53.19
```

### PolarProxy installation

```
sudo mkdir /var/log/PolarProxy
mkdir ~/PolarProxy
cd ~/PolarProxy/
curl https://www.netresec.com/?download=PolarProxy | tar -xzvf -
exit
sudo cp /home/proxyuser/PolarProxy/PolarProxy.service /etc/systemd/system/PolarProxy.service
```

We will need to modify the PolarProxy service config file a bit before we start it. Edit the ExecStart setting in /etc/systemd/system/PolarProxy.service to configure PolarProxy to terminate the TLS encryption for HTTPS and SMTPS (implicitly encrypted email submission). The HTTPS traffic should be redirected to INetSim's web server on tcp/80 and the SMTPS to tcp/25. 

```
ExecStart=/home/proxyuser/PolarProxy/PolarProxy -v -p 10443,80,80 -p 10465,25,25 -x /var/log/PolarProxy/polarproxy.cer -f /var/log/PolarProxy/proxyflows.log -o /var/log/PolarProxy/ --certhttp 10080 --terminate --connect 192.168.53.19 --nosni nosni.inetsim.org
```

 Here's a break-down of the arguments sent to PolarProxy through the ExecStart setting above:

**-v** : verbose output in syslog (not required)

**-p 10443,80,80** : listen for TLS connections on tcp/10443, save decrypted traffic in PCAP as tcp/80, forward traffic to tcp/80

**-p 10465,25,25** : listen for TLS connections on tcp/10465, save decrypted traffic in PCAP as tcp/25, forward traffic to tcp/25

**-x /var/log/PolarProxy/polarproxy.cer** : Save certificate to be imported to clients in /var/log/PolarProxy/polarproxy.cer (not required)

**-f /var/log/PolarProxy/proxyflows.log** : Log flow meta data in /var/log/PolarProxy/proxyflows.log (not required)

**-o /var/log/PolarProxy/** : Save PCAP files with decrypted traffic in /var/log/PolarProxy/

**--certhttp 10080** : Make the X.509 certificate available to clients over http on tcp/10080

**--terminate** : Run PolarProxy as a TLS termination proxy, i.e. data forwarded from the proxy is decrypted

**--connect 192.168.53.19** : forward all connections to the IP of INetSim
--nosni nosni.inetsim.org : Accept incoming TLS connections without SNI, behave as if server name was "nosni.inetsim.org".

Finally, start the PolarProxy systemd service: 
```
$ sudo systemctl enable PolarProxy.service
$ sudo systemctl start PolarProxy.service 
```

Verify that you can reach INetSim through PolarProxy's TLS termination proxy using curl: 
```
$ curl --insecure --connect-to example.com:443:192.168.53.19:10443 https://example.com
```

Do the same thing again, but also verify the certificate against PolarProxy's root CA this time. The root certificate is downloaded from PolarProxy via the HTTP service running on tcp/10080 and then converted from DER to PEM format using openssl, so that it can be used with curl's "--cacert" option. 

```
$ curl http://192.168.53.19:10080/polarproxy.cer > polarproxy.cer

$ openssl x509 -inform DER -in polarproxy.cer -out polarproxy-pem.crt

$ curl --cacert polarproxy-pem.crt --connect-to example.com:443:192.168.53.19:10443 https://example.com
```

Now let's set up routing to forward all HTTPS traffic to PolarProxy's service on tcp/10443 and SMTPS traffic to tcp/10465. I'm also adding a firewall rule to redirect ALL other incoming traffic to INetSim, regardless of which IP it is destined to, with the final REDIRECT rule. Make sure to replace "enp0s8" with the name of your interface. 

```
$ sudo iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 443 -j REDIRECT --to 10443

$ sudo iptables -t nat -A PREROUTING -i enp0s8 -p tcp --dport 465 -j REDIRECT --to 10465

$ sudo iptables -t nat -A PREROUTING -i enp0s8 -j REDIRECT
```
To check the iptables rules :
```
$ sudo iptables -t nat -L 
```

Verify that the iptables port redirection rule is working from another machine connected to the offline 192.168.53.0/24 network: 
```
$ curl --insecure --resolve example.com:443:192.168.53.19 https://example.com

$ curl --insecure --resolve example.com:465:192.168.53.19 smtps://example.com
```

It is now time to save the firewall rules, so that they will survive reboots.
```
$ sudo apt-get install iptables-persistent 
```

## Sources
https://www.netresec.com/?page=Blog&month=2019-12&post=Installing-a-Fake-Internet-with-INetSim-and-PolarProxy

https://github.com/catmin/inetsim/tree/master/data/http/fakefiles

