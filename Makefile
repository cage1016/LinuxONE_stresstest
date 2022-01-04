.PHONY: run-ap
run-ap: ## run run-ap
	@echo "Running run-ap"
	./jmeter.sh -i ghcr.io/cage1016/jmeter-s390x:5.4.1 \
		-d podman \
		-f ap.jmx \
		-t ap \
		-l OUTPUT_FOLDER=$(PWD),TARGET_HOST=192.168.1.201,TARGET_PORT=8080,THREADS=10,RAMD_UP=10,DURATION=20

.PHONY: help
help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help