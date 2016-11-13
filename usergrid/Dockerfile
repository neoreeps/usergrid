FROM neoreeps/ug-java

WORKDIR /root
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# build usergrid
# this is done in one run step so less files are included in the layers of the
# docker image, making it smaller.
RUN echo "--> install tomcat and packages required for compilation" \
    && apt-get update \
    && apt-get install -y maven curl tomcat7 git-core \
    && echo "--> fix tomcat7 init script: add missing java8 location" \
    && sed -i "s#/usr/lib/jvm/java-7-oracle#/usr/lib/jvm/java-7-oracle /usr/lib/jvm/java-8-oracle#g" /etc/init.d/tomcat7 \
    && echo "--> build usergrid-java" \
    && git clone --single-branch --branch master --depth 1 \
        https://github.com/apache/usergrid-java /root/usergrid-java \
    && cd /root/usergrid-java \
    && mvn clean install -DskipTests=true \
    && echo "--> build usergrid" \
    && git clone --single-branch --branch 2.1.0 --depth 1 \
        https://github.com/apache/usergrid.git /root/usergrid \
    && cd /root/usergrid \
    && echo "--> set logging level" \
    && grep -rl log4j.rootLogger=INFO stack | xargs sed -i 's#log4j.rootLogger=INFO#log4j.rootLogger=WARN#g' \
    && cd /root/usergrid/stack \
    && echo "--> fixup REST SDK version" \
    && sed -i 's/0.0.10-SNAPSHOT/2.2.0-SNAPSHOT/g' pom.xml \
    && mvn clean package -DskipTests=true \
    && echo "--> cleanup" \
    && rm -rf /var/lib/tomcat7/webapps/ROOT \
    && mv /root/usergrid/stack/rest/target/ROOT.war /var/lib/tomcat7/webapps \
    && mv /root/usergrid/stack/config/src/main/resources/usergrid-default.properties /usr/share/tomcat7/lib/usergrid-deployment.properties \
    && apt-get purge --auto-remove -y maven git-core ant \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /root/usergrid

# exposed ports:
#  8080 usergrid http interface
#  8443 usergrid https interface
EXPOSE 8080 8443

# runtime configuration script: since this is updated frequently during development, add it last
COPY start.sh /start.sh

# default command when starting container with "docker run"
CMD /start.sh
