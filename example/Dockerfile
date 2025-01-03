FROM denoland/deno:2.1.4

# The port that your application listens to.
EXPOSE 1993

WORKDIR /app

# Prefer not to run as root.
USER deno

# Cache the dependencies as a layer (the following two steps are re-run only when deno.json is modified).
# Ideally cache deno.json will download and compile _all_ external files used in main.ts.
COPY deno.json .
RUN deno install

# These steps will be re-run upon each file change in your working directory:
COPY . .
# Compile the main app so that it doesn't need to be compiled each startup/entry.
RUN deno cache main.ts

CMD ["serve", "--port", "1993", "main.ts"]
