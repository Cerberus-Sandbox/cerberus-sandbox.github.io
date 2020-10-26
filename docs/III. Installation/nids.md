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