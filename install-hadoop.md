
étapes :

1. Install OS
2. Config OS
3. Install Hadoop
4. Install TEZ
5. Install HIVE
6. Install PrestoDB



# 1 Install OS

Depuis un live CD, préférer SANS interface graphique.

----------

# 2 Config OS

## Config root

* login root
* pass 'motdepasseduroot'

## Création de l'utilisateur "hduser"
* useradd  hduser
* passwd hduser
	* 'motdepasseduuser'
	* 'motdepasseduuser'


## Fichier '/etc/hosts'
	
	192.168.60.3 nc-h01 nc-h01
	192.168.60.4 nc-h02 nc-h02
	192.168.60.5 nc-h03 nc-h03
	192.168.60.6 nc-h04 nc-h04
	192.168.60.7 nc-h05 nc-h05
	192.168.60.8 nc-h06 nc-h06
	192.168.60.9 nc-h07 nc-h07

## Autologin SSH

Paquets à installer

	yum install nano openssh wget



#### Etape 1: Créer la clé publique du serveur 

Se loger sur le nouveau serveur avec l'utilisateur 'hduser' et générer sa pair de clés :

	su - hduser
	ssh-keygen -t rsa

Question posée :

	Enter passphrase (empty for no passphrase): [Press enter key]
=> Ne rien entrer et presser entrer

	Enter same passphrase again: [Press enter key]
=> Ne rien entrer et presser entrer
	
#### Etape 2: Mise à jour du fichier  '/home/hduser/.ssh/authorized_keys' pour autoriser le master

Ajouter la clé publique du master sur le nouveau noeud :

	ssh hduser@NC-H04 
	ssh-copy-id NOUVEAUNOEUD

#### Etape 3 : Ajustement des permissions sur le fichier '/home/hduser/.ssh/authorized_keys'

Tapper les commandes suivantes :

	chmod 700 .ssh
	chmod 640 .ssh/authorized_keys

#### Etape 4 : Vérification de l'autologin
Se loger avec l'utilisateur 'hduser' sur le master (il demandera le mdp) puis faire 1 rebond inverse (il ne doit pas vous demander le mdp)

	ssh hduser@NC-H04 
	ssh hduser@NC-H02 

------------------------------------------

### Installation du service de synchronisation du temps `ntp`

Le service `ntp` sert à synchroniser les horloges systèmes des différents 
serveurs du cluster. Ce service est critique car si les nœuds ne sont pas 
synchronisé au niveau du temps, aucun logiciel ne peux fonctionner en mode 
distribué sur le cluster.

Installez le deamon ntp

    yum install ntp ntpdate

Tester une synchronisation avec le serveur de PROD `192.168.60.126`

    ntpdate 192.168.60.126

Cette commande donne si ok :

    14 May 17:59:45 ntpdate[3390]: step time server 192.168.60.126 offset -7204.755878 sec

Le chiffre -7204.755878 sec donne l'offset. (> 1 c'est pas bon, relancer plusieurs fois)

Si tout est bon (offset << 1), activer le deamon `ntp` sur le serveur

    service ntpd start

Donne (OK en vert):

    Starting ntpd:                                    [  OK  ]

Activer au démarrage

    chkconfig ntpd on

Contrôler que la conf est ok avec la commande suivante :

    ntptime | grep OK

Doit retourner 

    ntp_gettime() returns code 0 (OK)
    ntp_adjtime() returns code 0 (OK)

Configurer le serveur NTP de prod 192.168.60.126

    nano /etc/ntp.conf

Ajouter la ligne :

    server 192.168.60.126 

-----------------------------------------

### Installation du service de Monitoring du cluster `ganglia`

Ce service sert à avoir des informations sur les différents nœuds du cluster 
(charge CPU, débits réseaux, accès disques, etc...).

Install repo EPEL

    rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

install ganglia esclave

    yum install ganglia-gmond

Activation

    service gmond start

Donne (OK en vert):

    Starting GANGLIA gmond:                                    [  OK  ]

Activer au demarrage

    chkconfig gmond on

---------------------------------------
### Installation du programme `Java`

Copie du package Java. Le plus simple est de copier depuis un serveur existant

(as root)

    scp jdk-7u45-linux-x64.rpm SERVEUR_CIBLE:~/

Install repo Java (reprendre dans dossier racine /root d'1 serveur existant)

	rpm -Uvh jdk-7u45-linux-x64.rpm

Vérifier que java est bien OK avec la commande :

	java -version 

Doit afficher un message de ce style :

    java version "1.7.0_45"
    Java(TM) SE Runtime Environment (build 1.7.0_45-b18)
    Java HotSpot(TM) 64-Bit Server VM (build 24.45-b08, mixed mode)

--------------------------------------------------------------------

#### Optimisation de CENTOS

On centos, desactivate secure policy (SELINUX)

    setenforce 0

Modify key SELINUX   

	nano  /etc/sysconfig/selinux

Dans le fichier changer la clef `SELINUX`

    SELINUX=disabled

Contrôler avec la commande :

    sestatus

La commande doit retourner :

    SELinux status:                 disabled

Sinon redémarrage!

La machine doit être reboot

##### Disable iptables

    service iptables stop
    service ip6tables stop

    chkconfig iptables off
    chkconfig ip6tables off

##### Disable swappiness

Control si c'est présnet :

    cat /proc/sys/vm/swappiness

Resutat
* 60 => présent
* 0 => désactivé

Desactiver avec dans _/etc/sysctl.conf_

    nano /etc/sysctl.conf

Changer la variable _vm.swappiness_ à la valeur _0_ dans le fichier _/etc/sysctl.conf_

Contrôler avec la commande

    sysctl vm.swappiness

Changer avec la commande

    sysctl vm.swappiness=0

## Désactivation IPV6 ##

Fichier /etc/sysctl.conf

    net.ipv6.conf.all.disable_ipv6 = 1
    net.ipv6.conf.default.disable_ipv6 = 1
    
## Bonding carte réseau ##

Source :

https://www.centos.org/docs/5/html/5.2/Deployment_Guide/s2-modules-bonding.html
https://www.centos.org/docs/5/html/5.2/Deployment_Guide/s3-modules-bonding-directives.html
https://www.centos.org/docs/5/html/5.2/Deployment_Guide/s2-networkscripts-interfaces-chan.html

Création de l'alias bonding : vi /etc/modprobe.conf

    alias bond0 bonding


Création d'une carte réseau : vi /etc/sysconfig/network-scripts/ifcfg-bond0

    DEVICE=bond0 
    BONDING_OPTS="mode=6 miimon=500" 
    BOOTPROTO=none 
    ONBOOT=yes 
    NETWORK=192.168.60.0
    NETMASK=255.255.255.128
	GATEWAY=192.168.60.126
    IPADDR=192.168.60.7
    USERCTL=no

Sur chaque carte réseau : /etc/sysconfig/network-scripts/ifcfg-em<N>

    DEVICE=em1 
    BOOTPROTO=none 
    ONBOOT=yes 
    MASTER=bond0 
    SLAVE=yes 
    USERCTL=no



-----------------------------------------------------------------

## iSCSI (UNIQUEMENT SUR LES NOEUDS QUI N'ONT PAS DE DISQUE)


    iscsiadm -m node -T iqn.2000-01.com.synology:nc-nas.nc-h04 -p 192.168.10.6 -l


    192.168.10.6:3260,0 iqn.2000-01.com.synology:nc-nas.nc-h04
    169.254.240.168:3260,0 iqn.2000-01.com.synology:nc-nas.nc-h04


First install the Open-iSCSI initiator utils:

    yum -y install iscsi-initiator-utils

Edit /etc/iscsi/iscsid.conf and set your username and password, only if you use CHAP authentication to your iSCSI service.

Most likely, you will have to allow access to the iSCSI volume on the array, so log into your NAS admin interface and authorize your Linux host either by username, IP, or initiator name. You can find your Linux host's initiator name in: 

    /etc/iscsi/initiatorname.iscsi

Set iscsi to start on boot, and start it now:

    chkconfig iscsid on ; service iscsid start
    chkconfig iscsi on ; service iscsi start

Use iscsiadm to discover your iSCSI targets, replacing the IP with your own portal IP:

    iscsiadm -m discovery -t st -p 192.168.1.123

Once discovery tells you the target names, log into the one you want to work with:

    iscsiadm -m node -T iqn.2123-01.com:blah:blah:blah -p 192.168.1.123 -l

If you want to automatically login at boot:

    iscsiadm -m node -T iqn.2123-01.com:blah:blah:blah -p 192.168.1.123 -o update -n node.startup -v automatic

Now the iSCSI volume should be detected by your system as a block device. You can check what device it was detected as by tailing your log.

    tail -n 50 /var/log/messages

For a simple Linux partition, instead of LVM, we will create a new partition on the block device and then format it as ext3:

    parted -s -- /dev/sdd mklabel gpt
    parted -s -- /dev/sdd mkpart primary ext3 1 -1
    mkfs -t ext3 -m 1 -L mysan1 -O  dir_index,filetype,has_journal,sparse_super /dev/sdd1
    mount /dev/sdd1 /mnt/san01

iSCSI fstab entries require the "_netdev" option, so there is not an attempt to mount until networking is enabled. Mounting by label is also a good option, as devices may be detected at boot in different orders.

Mount new partition:
    mkdir /mnt/iscsi
    mount /dev/sdd1 /mnt/iscsi

----------------------------------------------------------------------------

### Snappy

Install from epel (as root)

    yum install snappy

Add symlink generic (as root)

    cd /usr/lib64/
    ln -sf libsnappy.so.1.1.4 ./libsnappy.so

Contrôler avec la commande :

     ls /usr/lib64/libsnappy.so* -all

Le résultat doit être similaire à 

    lrwxrwxrwx  1 root root    18 May 15 12:27 /usr/lib64/libsnappy.so -> libsnappy.so.1.1.4
    lrwxrwxrwx. 1 root root    18 May 14 15:43 /usr/lib64/libsnappy.so.1 -> libsnappy.so.1.1.4
    -rwxr-xr-x. 1 root root 19848 Nov 23 01:17 /usr/lib64/libsnappy.so.1.1.4

--------------------------------------------------------------------------------

### Find Out Which Process Is Listening Upon a Port

    netstat -tulpn | grep :$PORT

---

# Configuration d'Hadoop 2

## Installation de Hadoop 2 (avec l'utilisateur hduser - ne pas utiliser root !)

1. Téléchargement de l'archive `hadoop-2.x.x.bin.tar.gz`(actuellement version 2.5.0)
	
	yum install wget

	wget http://mir2.ovh.net/ftp.apache.org/dist/hadoop/common/hadoop-x.x.x/hadoop-x.x.x-bin.tar.gz /home/hduser/

2. Désarchivage dans le répertoire de l'utilisateur `/home/hduser/`

	tar -xvf hadoop-2.4.1-bin.tar.gz	

3. Modifications des fichiers de configuration dans `/home/hduser/hadoop-2.5.0/etc/hadoop`

###Fichier  core-site.xml (general)
Lignes à ajouter à l'intérieur de la balise "configuration"

Configuration du master:

    <property>
    <name>fs.default.name</name
    <value>hdfs://nc-h04</value>
    </property>

Tmp sur le disque local	ou sur le NAS (iSCSI)

    <property>
    <name>hadoop.tmp.dir</name>
    <!--<value>/home/hduser/tmp</value>-->
    <value>/mnt/iscsi/tmp-hadoop-1</value>
    <description>A base for other temporary directories.</description>
    </property>	



Il faut créer le dossier manuellement

Partie compression
> 	<property>
> 	<name>io.compression.codecs</name>
> 	<value>org.apache.hadoop.io.compress.GzipCodec,org.apache.hadoop.io.compress.DefaultCodec,org.apache.hadoop.io.compress.BZip2Codec,com.hadoop.compression.lzo.LzoCodec,com.hadoop.compression.lzo.LzopCodec,org.apache.hadoop.io.compress.SnappyCodec</value>
> 	</property>
> 	<property>
> 	<name>io.compression.codec.lzo.class</name>
> 	<value>com.hadoop.compression.lzo.LzoCodec</value>
> 	</property>


###Fichier hdfs-site.xml (partie fichier)
	<?xml version="1.0"?>
	<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
	<configuration>
	
	<property>
	<name>dfs.replication</name>
	<value>3</value>
	</property>
	
	<property>
	<name>dfs.block.size</name>
	<value>134217728</value>
	</property>
	
	<property>
	<name>dfs.webhdfs.enabled</name>
	<value>true</value>
	</property>
	
	  <property>
	    <name>dfs.permissions</name>
	    <value>false</value>
	  </property>
	
	  <property>
	    <name>dfs.client.read.shortcircuit</name>
	    <value>true</value>
	</property>
	<property>
	    <name>dfs.block.local-path-access.user</name>
	    <value>hduser</value>
	  </property>
	
	<property>
	    <name>dfs.domain.socket.path</name>
	    <value>/var/run/hadoop-hdfs/dn._PORT</value>
	</property>
	
	<property>
	    <name>dfs.client.file-block-storage-locations.timeout</name>
	    <value>3000</value>
	</property>
	</configuration>


###Fichier mapred-site.xml (partie execution)
	<?xml version="1.0"?>
	<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
	<configuration>
	<property>
	<name>mapred.job.tracker</name>
	<value>nc-h04:8021</value> 
	</property>
	
	<property>
	<name>mapred.child.java.opts</name>
	<value>-Xmx200m</value>
	</property>
	
	<property>
	<name>mapred.tasktracker.map.tasks.maximum</name>
	<value>3</value>
	</property>
	
	<property>
	<name>mapred.tasktracker.reduce.tasks.maximum</name>
	<value>3</value>
	</property>
	
	<property>
	  <name>mapred.jobtracker.taskScheduler</name>
	  <value>org.apache.hadoop.mapred.FairScheduler</value>
	</property>
	
	</configuration>

###Fichier hadoop-env.sh  (conf variables d'environnement)
	# The java implementation to use.  Required.
	export JAVA_HOME="/usr/java/jdk1.7.0_45"
	
	# Extra Java CLASSPATH elements.  Optional.
	# export HADOOP_CLASSPATH=
	
	# The maximum amount of heap to use, in MB. Default is 1000.
	 export HADOOP_HEAPSIZE=2000
	
	# Extra Java runtime options.  Empty by default.
	 export HADOOP_OPTS=-server
	
	# Command specific options appended to HADOOP_OPTS when specified
	export HADOOP_NAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS"
	export HADOOP_SECONDARYNAMENODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS"
	export HADOOP_DATANODE_OPTS="-Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS"
	export HADOOP_BALANCER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS"
	export HADOOP_JOBTRACKER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS"
	
	
	# The scheduling priority for daemon processes.  See 'man nice'.
	 export HADOOP_NICENESS=10


##Sur le MASTER (nc-h04) fichier de configuration 'slaves'

Mettre à jour le fichier '/home/hduser/hadoop-2.5.0/etc/hadoop/slaves' avec la liste des serveurs du cluster (master 
+ esclaves). 1 par ligne

Ex: 

	nc-h01
	nc-h02
	nc-h03
	nc-h04
	nc-h05
	nc-h06
	nc-h07


#Lancement à partir du master en SSH

Il faut donc que la clé publique du master soit sur chaque 'home/hduser/.ssh/authorized_keys' des nodes et sur lui même

	Namenode = Master fichier
	Datanode = Slave fichier

### Lancement du script `/home/hduser/hadoop-1.2.1/bin/start-dfs.sh`

	# Run this on master node.
	 ./hadoop-2.5.0/sbin/start-dfs.sh

	
	
### Vérifier que tous les noeuds sont présents dans l'interface de gestion matériel

	http://nc-h04:50070/dfshealth.jsp
	
### Lancement du script `/home/hduser/hadoop-1.2.1/bin/start-mapred.sh`
	
	bin=`dirname "$0"`
	bin=`cd "$bin"; pwd`
	
	if [ -e "$bin/../libexec/hadoop-config.sh" ]; then
	  . "$bin"/../libexec/hadoop-config.sh
	else
	  . "$bin/hadoop-config.sh"
	fi
	
	# start mapred daemons
	# start jobtracker first to minimize connection errors at startup
	"$bin"/hadoop-daemon.sh --config $HADOOP_CONF_DIR start jobtracker
	"$bin"/hadoop-daemons.sh --config $HADOOP_CONF_DIR start tasktracker



Add symlink (as hduser) (sur chaque nœuds)

    ln -sf /usr/lib64/libsnappy.so /home/hduser/hadoop-1.2.1/lib/native/Linux-amd64-64/.


## Installation de Hive (uniquement sur le serveur MASTER)

L'installation se fait 

	Dezipper /home/hduser/hive.0.12.bin.tar.gz dans /home/hduser/hive-0.12.0/conf

Fichier ./conf/hive-site.xml
	
	<?xml version="1.0"?>
	<configuration>
	<!-- Partie base de donnée d'administration -->
	<property>
	  <name>javax.jdo.option.ConnectionURL</name>
	  <value>jdbc:postgresql://nc-h04:5432/metastore</value>
	</property>
	
	<property>
	  <name>javax.jdo.option.ConnectionDriverName</name>
	  <value>org.postgresql.Driver</value>
	</property>
	
	<property>
	  <name>javax.jdo.option.ConnectionUserName</name>
	  <value>hiveuser</value>
	</property>
	
	<property>
	  <name>javax.jdo.option.ConnectionPassword</name>
	  <value>mvsmt4521</value>
	</property>
	
	<property>
	    <name>datanucleus.autoStartMechanism</name>
	    <value>SchemaTable</value>
	  </property>
	

	<property>
	    <name>hive.metastore.warehouse.dir</name>
	    <value>hdfs://nc-h04/user/hive/warehouse</value>
	  </property>
	
	<!-- Partie metastore -->
	<property>
	  <name>hive.metastore.uris</name>
	  <value>thrift://nc-h04:9083</value>
	  <description>IP address (or fully-qualified domain name) and port of the metastore host</description>
	</property>
	
	<property>
	  <name>hive.server2.authentication</name>
	  <value>NONE</value>
	  <description>
	    Client authentication types.
	       NONE: no authentication check
	       LDAP: LDAP/AD based authentication
	       KERBEROS: Kerberos/GSSAPI authentication
	       CUSTOM: Custom authentication provider
	               (Use with property hive.server2.custom.authentication.class)
	  </description>
	</property>
	
	<property>
	  <name>hive.server2.enable.impersonation</name>
	  <description>Enable user impersonation for HiveServer2</description>
	  <value>true</value>
	</property>
	
	<!-- ENABLE STATS ON POSTGRES -->
	<property>
	  <name>hive.stats.dbclass</name>
	  <value>jdbc:postgresql</value>
	  <description>The default database that stores temporary hive statistics.</description>
	</property>
	
	<property>
	  <name>hive.stats.jdbcdriver</name>
	  <value>org.postgresql.Driver</value>
	  <description>The JDBC driver for the database that stores temporary hive statistics.</description>
	</property>
	
	<property>
	  <name>hive.stats.dbconnectionstring</name>
	  <value>jdbc:postgresql://nc-h04:5432/metastore?user=hiveuser&amp;password=mvsmt4521</value>
	  <description>The default connection string for the database that stores temporary hive statistics.</description>
	</property>
	
	<property>
	  <name>hive.stats.collect.tablekeys</name>
	  <value>true</value>
	  <description>Whether join and group by keys on tables are derived and maintained in the QueryPlan.
	    This is useful to identify how tables are accessed and to determine if they should be bucketed.
	  </description>
	</property>
	
	<property>
	  <name>hive.stats.collect.scancols</name>
	  <value>true</value>
	  <description>Whether column accesses are tracked in the QueryPlan.
	    This is useful to identify how tables are accessed and to determine if there are wasted columns that can be trimmed.
	  </description>
	</property>
	
	</configuration>

#Lancement de Hive

--launch_metastore.sh

	export HIVE_HOME=/home/hduser/hive-0.12.0
	$HIVE_HOME/bin/hive --service metastore

--launch_hiveserver2.sh

	export HADOOP_HOME=/home/hduser/hadoop-1.2.1
	export HIVE_HOME=/home/hduser/hive-0.12.0
	export HIVE_AUX_JARS_PATH=/home/hduser/presto_scripts/json-serde-1.1.9.2-SNAPSHOT-jar-with-dependencies.jar
	
	HIVE_SERVER2_THRIFT_PORT=10000
	
	$HIVE_HOME/bin/hiveserver2


### On se connecte avec utilitaire SQL

	http://nc-h04:10000/NOMDELABASE
	connecteur de type jdbc 
 

## Installation de PrestoDB

Installation sur l'ensemble des noeuds master et esclaves

1. Téléchargement de l'archive `PrestoDB`(dernière version)
2. Désarchivage dans le répertoire de l'utilisateur _/home/hduser/_

    tar -xvf presto-server-0.69-SNAPSHOT.tar.gz

3. Récupérer le répertoire _./etc_ sur un des noeuds

	 scp -r /home/hduser/presto-server-0.69-SNAPSHOT/etc/ nc-h06:~/presto-server-0.69-SNAPSHOT 

4. Créer les répertoires de travail suivants :

	mkdir /home/hduser/tmp-presto
	mkdir /home/hduser/tmp-presto/data

5. Configuration dans le dossier _./etc_

/home/hduser/presto-server-0.69-SNAPSHOT/etc/jvm.config 

	=> conf JAVA, changement de la mémoire en fonction du serveur


/home/hduser/presto-server-0.69-SNAPSHOT/etc/config.properties 

	coordinator=true
	datasources=jmx,hive,tpch
	http-server.http.port=8080
	presto-metastore.db.type=h2
	presto-metastore.db.filename=var/db/MetaStore
	task.max-memory=1GB
	discovery-server.enabled=false
	discovery.uri=http://nc-h04:8411
	experimental-syntax-enabled=true

/home/hduser/presto-server-0.69-SNAPSHOT/etc/node.properties 

	node.environment=blitzprod => doit être le même partout
	node.id="go internet generate guid"
	node.data-dir=/home/hduser/tmp-presto/data => verifier que le dossier existe
 
3. Configuration dans le dossier /home/hduser/presto-server-0.69-SNAPSHOT/etc/catalog/hive.properties
 (lien vers les données)

	connector.name=hive-hadoop1
	hive.metastore.uri=thrift://nc-h04:9083

4. Créer un fichier avec la version de Presto

	vi ~/.presto_version
	
5. Mettre dans le fichier la ligne suivante :

	0.69-SNAPSHOT
	
6. Scripts dans `/home/hduser/presto_scripts`	(Fichier 'presto-nodes' à configurer avec l'ensemble des nodes)
	scp -r /home/hduser/presto_scripts/ nc-h06:/home/hduser/

_Start/Stop_
	Sur l'ensemble des noeud

_Upgrade_
	Permet de mettre à jour la liste des noeuds sur l'ensemble des noeuds 





-------------------------------------

#PARTIE R&D

### Compiler les libs natives

BUILD HADOOP NATIVE LIBRARIES
JANUARY 15, 2014 WEI	 3 COMMENTS
How to build Hadoop Native Libraries for Hadoop 2.2.0
Because the distributed Hadoop 2.2.0 provides a 32bit libhadoop by default, user has to build the native libraries to avoid those warning messages such as, disabled stack guard of libhadoop.so.

Java HotSpot(TM) 64-Bit Server VM warning: You have loaded library /opt/hadoop-2.2.0/lib/native/libhadoop.so.1.0.0 which might have disabled stack guard. The VM will try to fix the stack guard now.
It's highly recommended that you fix the library with 'execstack -c <libfile>', or link it with '-z noexecstack'.
13/11/01 10:58:59 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
The official Hadoop websitehttp://hadoop.apache.org/docs/r2.2.0/hadoop-project-dist/hadoop-common/NativeLibraries.html gives completely unclear instructions on how to build Hadoop native libraries.

So here are what you should do:

You need all the build tools:

$ sudo apt-get install build-essential
$ sudo apt-get install g++ autoconf automake libtool cmake zlib1g-dev pkg-config libssl-dev
$ sudo apt-get install maven
Another prerequisite, protoco buffer: protobuf version 2.5, which can be downloaded from https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz. Download it to the /tmp directory; then,

$ tar xzvf protobuf-2.5.0.tar.gz
$ cd protobuf-2.5.0
$ ./configure --prefix=/usr
$ make
$ make check
$ sudo make install
Having all the tools, we can now build Hadoop native libraries. Assuming you have downloaded the Hadoop 2.2.0 source code, do:

$ tar xzvf hadoop-2.2.0-src.tar.gz
$ cd hadoop-2.2.0-src
$ mvn package -Pdist,native -DskipTests -Dtar
Note: there is a missing dependency in the maven project module that results in a build failure at the hadoop-auth stage. Here is  the official bug report  and fix is

Index: hadoop-common-project/hadoop-auth/pom.xml
===================================================================
--- hadoop-common-project/hadoop-auth/pom.xml	(revision 1543124)
+++ hadoop-common-project/hadoop-auth/pom.xml	(working copy)
@@ -54,6 +54,11 @@
     </dependency>
     <dependency>
       <groupId>org.mortbay.jetty</groupId>
+      <artifactId>jetty-util</artifactId>
+      <scope>test</scope>
+    </dependency>
+    <dependency>
+      <groupId>org.mortbay.jetty</groupId>
       <artifactId>jetty</artifactId>
       <scope>test</scope>
     </dependency>
 

Maven will do all the heavy work for you, and you should get this after build is completed

[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------
[INFO] Total time: 15:39.705s
[INFO] Finished at: Fri Nov 01 14:36:17 CST 2013
[INFO] Final Memory: 135M/422M
The built native libraries should be at

hadoop-2.2.0-src/hadoop-dist/target/hadoop-2.2.0/lib

## Installation de TEZ 0.4 (UNIQUEMENT LE MASTER)

### Installation de Protobuf 2.5.0

Install google protocol buffers (protoc, protobuf) on CentOS 6 (linux)
BY FRANK · MAY 21, 2013


Step 0. Install GCC :

	yum install gcc-c++

Step 1. Download source code :

  	https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.bz2

Step 2. Extract :

    tar -xvf protobuf-2.5.0.tar.bz2

Step 3. Build and install:

    cd protobuf-2.5.0
    ./configure
    make
    sudo make install

### Changer le pom.xml

Changer pour avoir la bonne version de Hadoop 

=> ??????
=> Je m'arrète la
Ensuite

    mvn clean install -DskipTests=true -Dmaven.javadoc.skip=true

## Installation de HIVE 0.13 (UNIQUEMENT LE MASTER)

Penser à ajouter le connecteur JDBC pour le metastore

Notes: 

- I start hive with "hive -hiveconf hive.execution.engine=tez", not exactly necessary, but it will start the AM/containers right away instead of on first query. 
- hive-exec jar should be copied to hdfs:///user/hive/ (location can be changed with: hive.jar.directory). This avoids re-localization of the hive jar. 

Hive settings: 

	// needed because SMB isn't supported on tez yet 
	set hive.optimize.bucketmapjoin=false; 
	set hive.optimize.bucketmapjoin.sortedmerge=false; 
	set hive.auto.convert.sortmerge.join=false; 
	set hive.auto.convert.sortmerge.join.noconditionaltask=false; 
	set hive.auto.convert.join.noconditionaltask=true; 

	// depends on your available mem/cluster, but map/reduce mb should be set to the same for container reuse 
	set hive.auto.convert.join.noconditionaltask.size=64000000; 
	set mapred.map.child.java.opts=-server -Xmx3584m -Djava.net.preferIPv4Stack=true; 
	set mapred.reduce.child.java.opts=-server -Xmx3584m -Djava.net.preferIPv4Stack=true; 
	set mapreduce.map.memory.mb=4096; 
	set mapreduce.reduce.memory.mb=4096; 

	// generic opts 
	set hive.optimize.reducededuplication.min.reducer=1; 
	set hive.optimize.mapjoin.mapreduce=true; 
	
	// autogather might require you to up the max number of counters, if you run into issues 
	set hive.stats.autogather=true; 
	set hive.stats.dbclass=counter; 
	
	// tea settings can also go into fez-site if desired 
	set mapreduce.map.output.compress=true; 
	set mapreduce.map.output.compress.codec=org.apache.hadoop.io.compress.DefaultCodec; 
	set tez.runtime.intermediate-output.should-compress=true; 
	set tez.runtime.intermediate-output.compress.codec=org.apache.hadoop.io.compress.DefaultCodec; 
	set tez.runtime.intermdiate-input.is-compressed=true; 
	set tez.runtime.intermediate-input.compress.codec=org.apache.hadoop.io.compress.DefaultCodec; 

	// tez groups in the AM 
	set hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat; 
	
	set hive.orc.splits.include.file.footer=true; 
	
	set hive.root.logger=ERROR,console; 
	set hive.execution.engine=tez; 
	set hive.vectorized.execution.enabled=true; 
	set hive.exec.local.cache=true; 
	set hive.compute.query.using.stats=true; 

for tez: 

	  <property> 
	    <name>tez.am.resource.memory.mb</name> 
	    <value>8192</value> 
	  </property> 
	  <property> 
	    <name>tez.am.java.opts</name> 
	    <value>-server -Xmx7168m -Djava.net.preferIPv4Stack=true</value> 
	  </property> 
	  <property> 
	    <name>tez.am.grouping.min-size</name> 
	    <value>16777216</value> 
	  </property> 
	  <!-- Client Submission timeout value when submitting DAGs to a session --> 
	  <property> 
	    <name>tez.session.client.timeout.secs</name> 
	    <value>-1</value> 
	  </property> 
	  <!-- prewarm stuff --> 
	  <property> 
	    <name>tez.session.pre-warm.enabled</name> 
	    <value>true</value> 
	  </property> 
	
	  <property> 
	    <name>tez.session.pre-warm.num.containers</name> 
	    <value>10</value> 
	  </property> 
	  <property> 
	    <name>tez.am.grouping.split-waves</name> 
	    <value>0.9</value> 
	  </property> 
	
	  <property> 
	    <name>tez.am.container.reuse.enabled</name> 
	    <value>true</value> 
	  </property> 
	  <property> 
	    <name>tez.am.container.reuse.rack-fallback.enabled</name> 
	    <value>true</value> 
	  </property> 
	  <property> 
	    <name>tez.am.container.reuse.non-local-fallback.enabled</name> 
	    <value>true</value> 
	  </property> 
	  <property> 
	    <name>tez.am.container.session.delay-allocation-millis</name> 
	    <value>-1</value> 
	  </property> 
	  <property> 
	    <name>tez.am.container.reuse.locality.delay-allocation-millis</name> 
	    <value>250</value> 
	  </property> 


# Aide / NB

### ulimit and nproc

    ulimit -s 4096

Modify nproc (as root)

    echo "hduser     soft    nproc     32000" >> /etc/security/limits.d/90-nproc.conf


# Check TEZ

1. Check with MR

    ./hadoop-2.4.0/bin/hadoop jar ~/tez-0.4.0-incubating/tez-dist/target/tez-0.4.0-incubating/tez-0.4.0-incubating/tez-mapreduce-examples-*.jar orderedwordcount /tmp/test.txt /tmp/out

# Activer le short circuit

Depuis le master, on copie les libs natives

    scp -r hadoop-2.4.0/lib/native nc-h01:~/hadoop-2.4.0/lib/

Modif le hadoop-env.sh pour enlever les conf inutiles

    nano hadoop-2.4.0/etc/hadoop/hadoop-env.sh

En root (/var/lib/hadoop-hdfs/)<rep dans le fichier hdfs-site.xml>:

    mkdir /var/lib/hadoop-hdfs
    chown hduser:hduser /var/lib/hadoop-hdfs/

Ensuite :

    hadoop-2.4.0/sbin/hadoop-daemon.sh start datanode
    tail /home/hduser/hadoop-2.4.0/logs/hadoop-hduser-datanode-nc-h01.log -n 30



# Commandes utiles

Savoir le nombres de cœurs CPU physique

    lscpu | grep -m 1 "CPU(s):" 

Connaître la RAM (en MB):

    free -m

Donne : 

                 total       used       free     shared    buffers     cached
    Mem:         15917      15000        916          0         84       8532
    -/+ buffers/cache:       6382       9534
    Swap:         8023         32       7991

Ce qui veux dire =>  16Go (15917Mb)


Connaître le poids d'un dossier 

    du --max-depth=1 -h

#### Changer la config des limites

Edition du fichier _/etc/security/limits.conf_ :

    nano /etc/security/limits.conf

Changement des limites pour le user _hduser_ :

    hduser - memlock unlimited
    hduser - nofile 16384
    hduser - nproc 32768
    hduser - as unlimited

Rappel

    item can be one of the following:
        - core - limits the core file size (KB)
        - data - max data size (KB)
        - fsize - maximum filesize (KB)
        - memlock - max locked-in-memory address space (KB)
        - nofile - max number of open files
        - rss - max resident set size (KB)
        - stack - max stack size (KB)
        - cpu - max CPU time (MIN)
        - nproc - max number of processes
        - as - address space limit (KB)
        - maxlogins - max number of logins for this user
        - maxsyslogins - max number of logins on the system
        - priority - the priority to run user process with
        - locks - max number of file locks the user can hold
        - sigpending - max number of pending signals
        - msgqueue - max memory used by POSIX message queues (bytes)
        - nice - max nice priority allowed to raise to values: [-20, 19]
        - rtprio - max realtime priority

Contrôle avec la commande :

    ulimit -l

Donne :

    unlimited


# Test I/O

dd if=/mnt/iscsi/Encaissement_2B.txt iflag=direct of=/dev/null bs=1M count=1M

dd if=/mnt/iscsi/Encaissement_2B.txt iflag=direct of=/dev/null bs=1M count=1M

# TAR

How to create a compressed tar.gz file from multiple files and folders in Linux?
In order to create a compressed tar.gz file from multiple files or/and folders we need to run the same tar command we used when we archived a single file/folder and to append the rest of the files/folders' names to it.

    tar -czf new-tar-file-name.tar.gz file1 file2 folder1 folder2

How to extract a compressed tar.gz file in Linux?

    tar -xzf tar-file-name.tar.gz

----

# Monter un nouveau disque Hadoop

La partition système est généralement sda avec sda1 et sda2.
Lors d'un rajout de disque, il faut donc chercher sd**b**, sd**c**,sd**d**...

1. vérifier la présence

Avec la commande

    ls /dev/sd*

2. Creer une nouvelle partition

    fdisk /dev/sdX

Dans le menu de fdisk (pour mettre aligner sur les blocs)

    u 

Créer un partition étendu avec les commandes

    n -> e -> 1 
    	First sector (63-1952497663, default 63):
    Using default value 63
    Last sector, +sectors or +size{K,M,G} (63-1952497663, default 1952497663):
    Using default value 1952497663
    
    	-> w

3. Formatter la nouvelle partition

    mkfs -t ext4 /dev/sdaX

4. Ajouter au montage automatique

    blkid /dev/sdX

Pour savoir quel disque est quel UUID :

    ls -l /dev/disk/by-uuid

Notez le UUID, et ajouter au fichier _/etc/fstab_ une ligne

Y est le numéro de disque 
    nano /etc/fstab

    UUID=<UUID> /mnt/diskY ext4 noatime,data=writeback,barrier=0,nobh,errors=remount-ro 0 1

5. Creer le point de montage

    mkdir /mnt/diskY

6. Monter la partition

    mount /mnt/diskY

7. Corriger les droits

    chown hduser:hduser -R /mnt/diskY

5. Tester le débit

Créer un gros fichier (1GB) avec la commande

    dd if=/dev/zero of=/home/hduser/bloc2.raw bs=100M count=10

Mesurer le débit

    time dd if=/home/hduser/bloc.raw iflag=direct of=/dev/null bs=1024k count=1024
