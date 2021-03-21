export JAVA_HOME=/usr/lib/jvm/jdk-14.0.2
sudo update-alternatives --config java
alias java="/.$JAVA_HOME/bin/java"
alias javac="/.$JAVA_HOME/bin/javac"
shopt -s expand_aliases
source ~/.bashrc
java -version
javac -version
~/./servers/tomcat9/bin/shutdown.sh
rm ~/servers/tomcat9/webapps/webrtc.war
rm -rf ~/servers/tomcat9/webapps/webrtc
mvn clean install
cp ~/git/webrtc/target/webrtc.war ~/servers/tomcat9/webapps/
~/./servers/tomcat9/bin/startup.sh
tail -f ~/servers/tomcat9/logs/catalina.out