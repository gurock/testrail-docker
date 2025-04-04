FROM cassandra:3.11

RUN cd $CASSANDRA_HOME/lib && \
    curl https://repo1.maven.org/maven2/com/stratio/cassandra/cassandra-lucene-index-plugin/3.11.3.0/cassandra-lucene-index-plugin-3.11.3.0.jar -O
    
COPY custom-entrypoint.sh /custom-entrypoint.sh
ENTRYPOINT ["/custom-entrypoint.sh"]
CMD ["cassandra", "-f"]
