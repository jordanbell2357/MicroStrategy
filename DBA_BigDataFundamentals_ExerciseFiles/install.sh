echo DBA exercise files, last updated 1/17/2023
cd ~
clear
echo Downloading exercise files...
wget https://share.microstrategy.com/messages/TgGr399xJOmPVp5aP2Oa9o/attachments/YDHphEddC4nuoMMiou9BFU/download/DBA.zip
echo Unzipping exercise files to mstr home directory
unzip -o DBA.zip
echo Performing remaining setup
sudo yum install java-1.8.0-openjdk-devel
FILE=/home/mstr/hadoop.zip
mkdir Install
unzip -qqo ~/hadoop.zip -d /home/mstr/Install
mv ~/Install/hadoop/* ~/Install							   
chmod 777 /home/mstr/Install -R
echo Type your password from the Welcome to MicroStrategy on Cloud email, then press Enter.
read pass											   
PGPASSWORD=$pass /opt/mstr/MicroStrategy/install/Repository/bin/mstr_psql -h 127.0.0.1 postgres -f /home/mstr/Install/Install_metastore.sql
if [ $? -ne 0 ]; then { echo "On your keyboard, press the up arrow, hit enter and to try again." ; rm -rdf Install&&exit 1; } fi
echo Configuring hive file system
FILE=/home/mstr/Install/hive-site.xml
echo '      <value>'$pass'</value>' >> $FILE
echo '	</property>' >> $FILE
echo '	<property>' >> $FILE
echo '		<name>hive.server2.enable.doAs</name>' >> $FILE
echo '		<value>false</value>' >> $FILE
echo '	</property>' >> $FILE
echo '</configuration>' >> $FILE
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
echo Installing Hadoop...
cp ~/hadoop-3.2.1.tar.gz /tmp
tar xzf /tmp/hadoop-3.2.1.tar.gz -C /opt/mstr
rm -rdf /tmp/hadoop-3.2.1.tar.gz
mv /opt/mstr/hadoop-3.2.1 /opt/mstr/hadoop
echo Installing Hive...
cp ~/apache-hive-3.1.2-bin.tar.gz /tmp
tar xzf /tmp/apache-hive-3.1.2-bin.tar.gz -C /opt/mstr
rm -rdf /tmp/apache-hive-3.1.2-bin.tar.gz
mv /opt/mstr/apache-hive-3.1.2-bin  /opt/mstr/hive
echo Installing Spark...
cp ~/spark-3.0.0-preview2-bin-hadoop3.2.tgz /tmp
tar xzf /tmp/spark-3.0.0-preview2-bin-hadoop3.2.tgz -C /opt/mstr
rm -rdf /tmp/spark-3.0.0-preview2-bin-hadoop3.2.tgz
mv /opt/mstr/spark-3.0.0-preview2-bin-hadoop3.2  /opt/mstr/spark
echo Creating hadoop file system in MicroStrategy
mkdir -p /opt/mstr/data/nn
mkdir -p /opt/mstr/data/snn
mkdir -p /opt/mstr/data/dn
mkdir -p /opt/mstr/hadoop/logs
chmod g+w /opt/mstr/hadoop/logs
echo Adding system variables to bashrc file
cp ~/.bashrc .bashbk
echo 'export HADOOP_HOME=/opt/mstr/hadoop' >> ~/.bashrc
echo 'export HADOOP_CONF_DIR=/opt/mstr/hadoop/etc/hadoop' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME=/opt/mstr/hadoop' >> ~/.bashrc
echo 'export HADOOP_COMMON_HOME=/opt/mstr/hadoop' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME=/opt/mstr/hadoop' >> ~/.bashrc
echo 'export YARN_HOME=/opt/mstr/hadoop' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0' >> ~/.bashrc
echo 'export HIVE_HOME=/opt/mstr/hive' >> ~/.bashrc
echo 'export SPARK_HOME=/opt/mstr/spark' >> ~/.bashrc
echo 'export PYSPARK_DRIVER_PYTHON=jupyter' >> ~/.bashrc
echo "export PYSPARK_DRIVER_PYTHON_OPTS='notebook'" >> ~/.bashrc
echo 'export PYSPARK_PYTHON=python3' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/opt/mstr/hadoop/lib/native:$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'PATH=$PATH:/opt/mstr/hadoop/bin:/opt/mstr/hive/bin:/opt/mstr/spark/bin:/opt/mstr/anaconda/bin:/opt/mstr/anaconda/condabin' >> ~/.bashrc
echo Copying Jupyter notebooks and other necessary exercise files
mkdir /home/mstr/notebooks
mv /home/mstr/Install/Data_Transformation_DF.ipynb /home/mstr/notebooks
mv /home/mstr/Install/Data_Transformation_SQL.ipynb /home/mstr/notebooks
mv /home/mstr/Install/Structured_Streaming.ipynb /home/mstr/notebooks
mv /home/mstr/Install/zips.json /home/mstr
mv /home/mstr/Install/mongodb-org-4.2.repo /home/mstr
mv /home/mstr/Install/hadoop-env.sh /opt/mstr/hadoop/etc/hadoop
mv /home/mstr/Install/core-site.xml /opt/mstr/hadoop/etc/hadoop 
mv /home/mstr/Install/hdfs-site.xml /opt/mstr/hadoop/etc/hadoop
mv /home/mstr/Install/mapred-site.xml /opt/mstr/hadoop/etc/hadoop
mv /home/mstr/Install/yarn-site.xml /opt/mstr/hadoop/etc/hadoop
mv /home/mstr/Install/hive-site.xml /opt/mstr/hive/conf
mv /opt/mstr/hive/lib/log4j-slf4j-impl-2.10.0.jar /opt/mstr/hive/lib/log4j-slf4j-impl-2.10.0.jar.extra
/opt/mstr/hadoop/bin/hdfs namenode -format -force
/opt/mstr/hadoop/sbin/start-dfs.sh
/opt/mstr/hadoop/sbin/start-yarn.sh
/opt/mstr/hadoop/bin/hdfs dfs -mkdir -p /user/hive/warehouse
/opt/mstr/hadoop/bin/hdfs dfs -mkdir /spark-logs
/opt/mstr/hadoop/bin/hdfs dfs -mkdir /student
/opt/mstr/hadoop/bin/hdfs dfs -put /home/mstr/zips.json /student/zips.json
/opt/mstr/hadoop/bin/hdfs dfs -put /opt/mstr/hive/examples/files/parquet_vector_map_type.txt /student/vector.txts
cp /opt/mstr/hive/lib/postgresql* /opt/mstr/spark/jars
cp /opt/mstr/hive/conf/hive-site.xml /opt/mstr/spark/conf
cp /opt/mstr/spark/conf/spark-defaults.conf.template /opt/mstr/spark/conf/spark-defaults.conf
/opt/mstr/hadoop/bin/hdfs dfs -put /home/mstr/Install/product.csv /student/product.csv
/opt/mstr/hadoop/bin/hdfs dfs -put /home/mstr/Install/customer.csv /student/customer.csv
/opt/mstr/hadoop/bin/hdfs dfs -put /home/mstr/Install/order.csv /student/order.csv
echo 'spark.sql.warehouse.dir=/user/hive/warehouse' >> /opt/mstr/spark/conf/spark-defaults.conf
echo Copying last files necessary to Install folder
cp /home/mstr/Install/airport.sql .
cp /home/mstr/Install/update.sql .
cp /home/mstr/Install/log_table.sql .
cp /home/mstr/Install/emp_sls.txt .
cp /home/mstr/Install/region.txt .
rm /opt/mstr/hive/lib/guava-19.0.jar
cp /opt/mstr/hadoop/share/hadoop/hdfs/lib/guava-27.0-jre.jar /opt/mstr/hive/lib/
/opt/mstr/hadoop/bin/hdfs dfs -mkdir -p /user/stream
echo Unzipping sales logs
cp ~/slog.tar /home/mstr
cp ~/slog.tar /home/mstr/slog.zip
chmod 777 /home/mstr/slog.zip
unzip -qqo ~/slog.zip -d /home/mstr/slog
/opt/mstr/hadoop/bin/hdfs dfs -put /home/mstr/slog/*.csv /user/stream
rm -rdf ~/slog
rm -rdf ~/slog.zip
echo Installing anaconda
cp ~/anaconda3.sh /home/mstr
bash ~/anaconda3.sh -b -p /opt/mstr/anaconda
/opt/mstr/anaconda/bin/pip install mstrio-py
/opt/mstr/anaconda/bin/pip install --upgrade urllib3
/opt/mstr/anaconda/bin/jupyter-nbextension install connector-jupyter --py --sys-prefix
/opt/mstr/anaconda/bin/jupyter-nbextension enable connector-jupyter --py --sys-prefix
echo Installing pyspark
/opt/mstr/anaconda/bin/pip install pyspark
echo Installing pandas
/opt/mstr/anaconda/bin/pip install pandas