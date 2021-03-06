.PHONY: run-ap
run-ap: ## run run-ap
	@echo "Running run-ap"
	./jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 \
		-d podman \
		-f ap.jmx \
		-t ap \
		-z true \
		-l 'jmeter.save.saveservice.timestamp_format="yyyy/MM/dd HH:mm:ss";OUTPUT_FOLDER=$(PWD)/ap;TARGET_HOST=192.168.1.201;TARGET_PORT=8080;ENV_THREADS=1000;ENV_RAMD_UP=120;ENV_DURATION=300' \
		-g 'jmeter.jtl=ResponseTimesOverTime;perfMon.jtl=PerfMon;jmeter.jtl=ThreadsStateOverTime' 2>&1 | tee run.log

.PHONY: run-ap2
run-ap2: ## run run-ap2
	@echo "Running run-ap2"
	./jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 \
		-d podman \
		-f ap2.jmx \
		-t ap2 \
		-z true \
		-l 'jmeter.save.saveservice.timestamp_format="yyyy/MM/dd HH:mm:ss";OUTPUT_FOLDER=$(PWD)/ap2;TARGET_HOST=192.168.1.201;TARGET_PORT=8080;threads_schedule="spawn(200,10s,10s,50s,10s) spawn(300,10s,10s,100s,30s) spawn(400,10s,10s,150s,30s)"' \
		-g 'jmeter.jtl=ResponseTimesOverTime;perfMon.jtl=PerfMon;jmeter.jtl=ThreadsStateOverTime' 2>&1 | tee run.log

.PHONY: run-oracle
run-oracle: ## run-oracle
	@echo "Running run-oracle"
	./jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 \
		-d podman \
		-f oracle.jmx \
		-t oracle \
		-z true \
		-l 'jmeter.save.saveservice.timestamp_format="yyyy/MM/dd HH:mm:ss";OUTPUT_FOLDER=$(PWD)/oracle;THREADS=1000;RAMD_UP=120;DURATION=600' \
		-g 'jmeter.jtl=ResponseTimesOverTime;perfMon.jtl=PerfMon;jmeter.jtl=ThreadsStateOverTime' 2>&1 | tee run.log

.PHONY: run-oracle2
run-oracle2: ## run run-oracle2
	@echo "Running run-oracle2"
	./jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 \
		-d podman \
		-f oracle2.jmx \
		-t oracle2 \
		-z true \
		-l 'jmeter.save.saveservice.timestamp_format="yyyy/MM/dd HH:mm:ss";OUTPUT_FOLDER=$(PWD)/oracle2;threads_schedule="spawn(200,10s,10s,50s,10s) spawn(300,10s,10s,100s,30s) spawn(400,10s,10s,150s,30s)"' \
		-g 'jmeter.jtl=ResponseTimesOverTime;perfMon.jtl=PerfMon;jmeter.jtl=ThreadsStateOverTime' 2>&1 | tee run.log

.PHONY: download
download: ## download
	@echo "Downloading files"
	scp ibmu01@sysage.tech:/home/kaichu/LinuxONE_stresstest/$(f) ./tmp

.PHONY: help
help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help