.PHONY: fetch-mdc generate-html local-run deploy

# .envファイルが存在する場合は読み込む
ifneq (,$(wildcard .env))
    include .env
    export
endif

fetch-mdc:
	@echo "Fetching MDC files..."
	@sh -c '. .env 2>/dev/null || true; scripts/fetch_mdc_files.sh' > scripts/generate_html/mdc.json
	@echo "Sources/ProjectRulesIO/mdc.json updated."

generate-html: fetch-mdc
	@echo "Generating html..."
	@sh -c '. .env 2>/dev/null || true; swift scripts/generate_html/generate_html.swift Public/index.html'
	@echo "Public/index.html updated."

docker-build:
	@echo "Building Docker image and running container..."
	@sh -c '. .env 2>/dev/null || true; docker buildx build --platform linux/amd64 --tag projectrules-io . --load'

docker-run:
	@echo "Running Docker container..."
	@sh -c '. .env 2>/dev/null || true; docker run -p 8080:8080 projectrules-io'

local-run: generate-html docker-build docker-run
	@echo "Local development build and run complete."

deploy: generate-html docker-build
	@sh -c '. .env 2>/dev/null || true; scripts/deploy.sh'