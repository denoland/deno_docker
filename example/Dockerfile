FROM denoland/deno:2.7.6

# The port that your application listens to.
EXPOSE 1993

WORKDIR /app

# Cache dependencies as a layer (re-run only when package.json changes).
COPY package.json .
RUN deno install

# These steps will be re-run upon each file change in your working directory:
COPY . .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

# Prefer not to run as root.
USER deno

CMD ["run", "--allow-net", "--allow-read", "--allow-env", "main.ts"]
