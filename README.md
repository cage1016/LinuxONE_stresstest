# LinuxONE stress test

### Scenario 1

> Performance Stress (JMeter) - Web AP

prerequisites:
1. static nginx server (support `x86` and `s390x`)
  - ghcr.io/cage1016/nginx-website:0.1.0
  - ghcr.io/cage1016/nginx-website-gz:0.1.0

1. start Nginx server `DB10` & `DB20`
    ```bash
    $ podman run -d -v 8080:80 ghcr.io/cage1016/nginx-website-gz:0.1.0
    $ podman run -d -v 8081:80 ghcr.io/cage1016/nginx-website:0.1.0
    ```

1. Run Jmeter docker with thread group parameters
    ```bash
    # Jmeter Default ThreadGroup strategy
    # OUTPUT_FOLDER=$(PWD)/ap;TARGET_HOST=192.168.1.201;TARGET_PORT=8080;ENV_THREADS=1;ENV_RAMD_UP=1;ENV_DURATION=1
    make run-ap

    # jp@gc - Ultimate Thread Group
    # OUTPUT_FOLDER=$(PWD)/ap2;TARGET_HOST=192.168.1.201;TARGET_PORT=8080;threads_schedule="spawn(200,10s,10s,50s,10s) spawn(300,10s,10s,100s,30s) spawn(400,10s,10s,150s,30s)"
    make run-ap2
    ```

### Scenario 2

> Performance Stress (JMeter) - Oracle DB

prerequisites
1. oracle RAC
1. Run Jmeter docker with thread group parameters
    ```bash
    # Jmeter Default ThreadGroup strategy
    # OUTPUT_FOLDER=$(PWD)/oracle;THREADS=1000;RAMD_UP=120;DURATION=600
    make run-oracle

    # jp@gc - Ultimate Thread Group
    # OUTPUT_FOLDER=$(PWD)/oracle2;threads_schedule="spawn(200,10s,10s,50s,10s) spawn(300,10s,10s,100s,30s) spawn(400,10s,10s,150s,30s)"
    make run-oracle2
    ```