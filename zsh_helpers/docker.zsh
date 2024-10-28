# Easily manage docker containers
#
alias dockers='docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.RunningFor}}\t{{.Status}}"'
alias mongosh='docker run -it --rm mongosh mongosh'


# PlantUML
#
plantush() {
  docker pull plantuml/plantuml-server:jetty >/dev/null 2>&1
  docker stop plantush >/dev/null 2>&1 || true
  docker rm plantush >/dev/null 2>&1 || true
  if docker run --name plantush -d -p 9876:8080 -v $HOME/devenv/plantuml:/include plantuml/plantuml-server:jetty >/dev/null 2>&1; then
    echo "Ok, plantush is now running"

    # Wait for the container to be fully up and running
    echo "Waiting for plantush to start..."
    until docker exec plantush curl -s http://localhost:8080 > /dev/null; do
      sleep 1
    done

    echo "Modifying jetty.start file..."
    # Modify the jetty.start file
    docker exec plantush sed -i 's|exec /opt/java/openjdk/bin/java |&-Dplantuml.include.path=/include |' /var/lib/jetty/jetty.start

    echo "Restarting plantush container..."
    docker restart plantush >/dev/null 2>&1

    echo "Configuration complete and plantush restarted"
  else
    echo "Failed to run plantush"
  fi
}


# MongoDB with replica set of a single node
#
mongodb() {
  docker pull mongo:latest || echo "Failed to pull latest MongoDB image, using local image."

  docker rm -f mongodb >/dev/null 2>&1 || echo "Failed to remove existing mongodb container, or none existed."

  if ! docker run -d \
    --name mongodb \
    -p 27017:27017 \
    mongo:latest \
    --noauth \
    --replSet rs0; then
    echo "Failed to run MongoDB container."
    return 1
  fi

  sleep 5  # Wait for MongoDB to start

  if ! docker exec mongodb mongosh --quiet --eval 'rs.initiate({_id : "rs0", members: [{ _id: 0, host: "localhost:27017" }]})'; then
    echo "Failed to initiate replica set."
    return 1
  fi

  echo "All done!"
  echo "MongoDB is now available at: mongodb://localhost:27017/?replicaSet=rs0"
}


# Redis
#
redis() {
  docker pull redis:latest || echo "Failed to pull latest Redis image, using local image."

  docker rm -f redis >/dev/null 2>&1 || echo "Failed to remove existing redis container, or none existed."

  if ! docker run -d \
    --name redis \
    -p 6379:6379 \
    redis:latest; then
    echo "Failed to run Redis container."
    return 1
  fi

  echo "All done!"
  echo "Redis is now available at: redis://localhost:6379"
}