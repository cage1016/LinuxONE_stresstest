.PHONY: run-ap
run-ap: ## run run-ap
	@echo "Running run-ap"
	./jmeter.sh -i ghcr.io/cage1016/jmeter-s390x:5.4.1 \
		-d podman \
		-f ap.jmx \
		-t ap \
		-z true \
		-l OUTPUT_FOLDER=$(PWD)/ap,TARGET_HOST=192.168.1.201,TARGET_PORT=8080,THREADS=1000,RAMD_UP=120,DURATION=600,jmeter.save.saveservice.timestamp_format='"yyyy/MM/dd HH:mm:ss"' \
		-g jmeter.jtl=ResponseTimesOverTime,perfMon.jtl=PerfMon 2>&1 | tee run-ap.log

.PHONY: run-oracle
run-oracle: ## run-oracle
	@echo "Running run-oracle"
	./jmeter.sh -i ghcr.io/cage1016/jmeter-s390x:5.4.1 \
		-d podman \
		-f oracle.jmx \
		-t oracle \
		-z true \
		-l OUTPUT_FOLDER=$(PWD)/oracle,THREADS=1000,RAMD_UP=120,DURATION=600,jmeter.save.saveservice.timestamp_format='"yyyy/MM/dd HH:mm:ss"' \
		-g jmeter.jtl=ResponseTimesOverTime,perfMon.jtl=PerfMon 2>&1 | tee run-ap.log


.PHONY: help
help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help