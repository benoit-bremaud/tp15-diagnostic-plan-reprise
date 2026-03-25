# TP15 — Diagnostic et Plan de Reprise — WallRide CMS
# Makefile for SonarQube analysis automation

SONAR_CONTAINER := vsea-sonarqube
SONAR_URL       := http://localhost:9000
SONAR_PROJECT   := tp15-wallride-audit
WALLRIDE_DIR    := wallride-fork

# ——————————————————————————————————————————————————————————————————————————
## @SonarQube Server
# ——————————————————————————————————————————————————————————————————————————

sonar-start: ## Start local SonarQube server (Docker, port 9000)
	@if docker ps -a --format '{{.Names}}' | grep -q '^$(SONAR_CONTAINER)$$'; then \
		echo "[sonar] Starting existing container..."; \
		docker start $(SONAR_CONTAINER); \
	else \
		echo "[sonar] Creating and starting SonarQube container..."; \
		docker run -d --name $(SONAR_CONTAINER) -p 9000:9000 \
			-v ci_sonarqube_data:/opt/sonarqube/data \
			-v ci_sonarqube_extensions:/opt/sonarqube/extensions \
			-v ci_sonarqube_logs:/opt/sonarqube/logs \
			sonarqube:community; \
	fi
	@echo "[sonar] Waiting for SonarQube to be ready at $(SONAR_URL) ..."
	@until curl -sf $(SONAR_URL)/api/system/status | grep -q '"status":"UP"'; do \
		printf '.'; sleep 3; \
	done
	@echo ""
	@echo "[sonar] SonarQube is UP → $(SONAR_URL)"

sonar-stop: ## Stop local SonarQube server
	docker stop $(SONAR_CONTAINER)
	@echo "[sonar] SonarQube stopped."

sonar-status: ## Show local SonarQube server status
	@if docker ps --format '{{.Names}}' | grep -q '^$(SONAR_CONTAINER)$$'; then \
		echo "[sonar] Container: running"; \
		curl -sf $(SONAR_URL)/api/system/status && echo || echo "[sonar] HTTP not yet ready"; \
	elif docker ps -a --format '{{.Names}}' | grep -q '^$(SONAR_CONTAINER)$$'; then \
		echo "[sonar] Container: stopped (run 'make sonar-start' to resume)"; \
	else \
		echo "[sonar] Container: not found (run 'make sonar-start' to create)"; \
	fi

# ——————————————————————————————————————————————————————————————————————————
## @WallRide Analysis
# ——————————————————————————————————————————————————————————————————————————

clone: ## Clone WallRide fork locally (if not already cloned)
	@if [ -d "$(WALLRIDE_DIR)" ]; then \
		echo "[wallride] Fork already cloned in $(WALLRIDE_DIR)/"; \
	else \
		echo "[wallride] Cloning fork..."; \
		git clone git@github.com:benoit-bremaud/wallride.git $(WALLRIDE_DIR); \
	fi

sonar-scan: clone ## Run SonarQube analysis via sonar-scanner (requires SONAR_TOKEN)
	@if [ -z "$(SONAR_TOKEN)" ]; then \
		echo "Error: SONAR_TOKEN is required."; \
		echo ""; \
		echo "  1. Open $(SONAR_URL) → My Account → Security → Generate Token"; \
		echo "  2. Run: make sonar-scan SONAR_TOKEN=sqp_xxxx"; \
		echo ""; \
		exit 1; \
	fi
	@echo "[sonar] Running SonarQube analysis on WallRide (source-only mode)..."
	cd $(WALLRIDE_DIR) && sonar-scanner \
		-Dsonar.projectKey=$(SONAR_PROJECT) \
		-Dsonar.projectName="WallRide CMS — Technical Audit" \
		-Dsonar.projectVersion=1.0.0-SNAPSHOT \
		-Dsonar.sources=wallride-core/src/main/java,wallride-bootstrap/src/main/java,wallride-tools/src/main/java \
		-Dsonar.tests=wallride-core/src/test/java,wallride-bootstrap/src/test/java \
		-Dsonar.java.source=1.8 \
		-Dsonar.sourceEncoding=UTF-8 \
		-Dsonar.exclusions="**/node_modules/**,**/target/**,wallride-ui-admin/**,wallride-ui-guest/**,wallride-dependencies/**,wallride-parent/**" \
		-Dsonar.host.url=$(SONAR_URL) \
		-Dsonar.token=$(SONAR_TOKEN)
	@echo ""
	@echo "[sonar] Analysis complete → $(SONAR_URL)/dashboard?id=$(SONAR_PROJECT)"

sonar-scan-mvn: clone ## Run SonarQube analysis via Maven (needs compiled classes)
	@if [ -z "$(SONAR_TOKEN)" ]; then \
		echo "Error: SONAR_TOKEN is required."; \
		echo "  Run: make sonar-scan-mvn SONAR_TOKEN=sqp_xxxx"; \
		exit 1; \
	fi
	@echo "[sonar] Compiling WallRide with JAXB workaround..."
	cd $(WALLRIDE_DIR) && mvn compile -DskipTests -Pjar \
		-Dorg.glassfish.jaxb:jaxb-runtime:2.3.2 || true
	@echo "[sonar] Running Maven SonarQube analysis..."
	cd $(WALLRIDE_DIR) && mvn sonar:sonar \
		-Dsonar.projectKey=$(SONAR_PROJECT) \
		-Dsonar.projectName="WallRide CMS — Technical Audit" \
		-Dsonar.host.url=$(SONAR_URL) \
		-Dsonar.token=$(SONAR_TOKEN) \
		-Dsonar.java.source=1.8 \
		-Dsonar.exclusions="**/node_modules/**,wallride-ui-admin/**,wallride-ui-guest/**"
	@echo ""
	@echo "[sonar] Analysis complete → $(SONAR_URL)/dashboard?id=$(SONAR_PROJECT)"

# ——————————————————————————————————————————————————————————————————————————
## @Helpers
# ——————————————————————————————————————————————————————————————————————————

sonar-open: ## Open SonarQube dashboard in browser
	xdg-open "$(SONAR_URL)/dashboard?id=$(SONAR_PROJECT)" 2>/dev/null || \
	open "$(SONAR_URL)/dashboard?id=$(SONAR_PROJECT)" 2>/dev/null || \
	echo "Open $(SONAR_URL)/dashboard?id=$(SONAR_PROJECT) in your browser"

sonar-metrics: ## Fetch key metrics from SonarQube API (requires analysis to be done)
	@echo "[sonar] Fetching metrics for $(SONAR_PROJECT)..."
	@echo ""
	@echo "=== Bugs ==="
	@curl -sf "$(SONAR_URL)/api/measures/component?component=$(SONAR_PROJECT)&metricKeys=bugs,reliability_rating" \
		-u "$(SONAR_TOKEN):" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "  (not available)"
	@echo ""
	@echo "=== Vulnerabilities ==="
	@curl -sf "$(SONAR_URL)/api/measures/component?component=$(SONAR_PROJECT)&metricKeys=vulnerabilities,security_rating,security_hotspots" \
		-u "$(SONAR_TOKEN):" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "  (not available)"
	@echo ""
	@echo "=== Code Smells & Technical Debt ==="
	@curl -sf "$(SONAR_URL)/api/measures/component?component=$(SONAR_PROJECT)&metricKeys=code_smells,sqale_index,sqale_debt_ratio,sqale_rating" \
		-u "$(SONAR_TOKEN):" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "  (not available)"
	@echo ""
	@echo "=== Duplication ==="
	@curl -sf "$(SONAR_URL)/api/measures/component?component=$(SONAR_PROJECT)&metricKeys=duplicated_lines_density,duplicated_blocks" \
		-u "$(SONAR_TOKEN):" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "  (not available)"
	@echo ""
	@echo "=== Coverage ==="
	@curl -sf "$(SONAR_URL)/api/measures/component?component=$(SONAR_PROJECT)&metricKeys=coverage,lines_to_cover,uncovered_lines" \
		-u "$(SONAR_TOKEN):" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "  (not available)"

clean: ## Remove compiled artifacts from WallRide fork
	@if [ -d "$(WALLRIDE_DIR)" ]; then \
		cd $(WALLRIDE_DIR) && mvn clean -q 2>/dev/null; \
		echo "[wallride] Cleaned."; \
	fi

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: sonar-start sonar-stop sonar-status clone sonar-scan sonar-scan-mvn sonar-open sonar-metrics clean help
.DEFAULT_GOAL := help
