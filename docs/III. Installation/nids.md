# NIDS Installation

Before installing an NIDS, you need to prepare your dirtribution. In our case, we are going to use Debian.

## Debian Installation

### Workbench preparation

## Suricata installation

### **Installation of the compilation chain** 

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
- `Zlib` : 
- `LibJansson` :

``` 
apt install libpcre3 libpcre3-dbg libpcre3-dev libpcap-dev libnet1-dev libyaml-0-2 libyaml-dev libnetfilter-queue-dev zlib1g zlib1g-dev libmagic-dev libcap-ng-dev libjansson-dev liblz4-dev libnss3-dev pkg-config magic coccinelle cbindgen rustc 
```

### **Compilation of suricata**

```
$ sudo apt install suricata
$ ./configure
$ make
$ make install
```

## Suricata configuration

Creation of configuration files :

```
$ cd /etc/suricata
$ cp {/etc/suricata.yaml,/etc/classification.config,reference.config} /etc/suricata
$ touch /etc/suricata/threshold.config
```

Modification of the configuration file suricata.yaml :

##