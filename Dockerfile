FROM eclipse-temurin:11 as build

# copy source code
WORKDIR /app
COPY . /app

# gradle build
RUN if [ -f "./gradlew" ]; then chmod +x ./gradlew; fi
RUN --mount=type=cache,id=test-gradle,target=/root/.gradle ./gradlew clean bootjar -x test --build-cache -i -s --no-daemon

# runner
FROM eclipse-temurin:11-jre

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y install \
  libreoffice-common \ 
  unoconv \
  hyphen-af hyphen-en-us \
  fonts-dejavu fonts-dejavu-core fonts-dejavu-extra \
  fonts-droid-fallback fonts-dustin fonts-f500 fonts-fanwood fonts-freefont-ttf fonts-liberation \
  fonts-lmodern fonts-lyx fonts-sil-gentium fonts-texgyre fonts-tlwg-purisa fonts-opensymbol && \
  rm -rf /var/lib/apt/lists/*

RUN set -o errexit -o nounset \
  && groupadd --system --gid 1000 java \
  && useradd --system --gid java --uid 1000 --shell /bin/bash --create-home java

WORKDIR /app
COPY --from=build --chown=java:java /app/ .

USER java

CMD java -jar -Dspring.profiles.active=${PROFILE:=prod} build/libs/SpringbootApp-0.0.1-SNAPSHOT.jar
