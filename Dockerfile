# syntax=docker/dockerfile:1

###############
# Build Stage #
###############
FROM swift:6.0 AS builder
WORKDIR /app

# resolve dependencies
COPY Package.* ./
RUN swift package resolve

# copy and build binaries
COPY . .
RUN swift build -c release --product ProjectRulesIO

#################
# Runtime Stage #
#################
FROM swift:6.0-slim
WORKDIR /app

# copy bineries and assets from build stage
COPY --from=builder /app/.build/release/ProjectRulesIO .
COPY --from=builder /app/Public ./Public

# default settings for vapor
ENV PORT=8080

EXPOSE 8080

# exec server app
CMD ["./ProjectRulesIO"]
