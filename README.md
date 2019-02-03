docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker container ls -a
docker run --name solr_xdaly -d -p 8983:8983 -t -v d:/solr:/opt/solr solr
docker exec -it --user=solr solr_xdaly bin/solr create_core -c core_xdaly