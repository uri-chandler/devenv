# Easily manage docker containers
#
alias dockers='docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.RunningFor}}\t{{.Status}}"'

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
