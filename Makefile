# Makefile for Displace Technologies Container Library
# Provides local building capabilities with same logic as GitHub Actions

# Configuration
REGISTRY ?= ghcr.io
REGISTRY_NAMESPACE ?= displacetech
PLATFORM ?= linux/amd64
BUILD_ARGS ?=

# Version definitions (update these when versions change)
ALPINE_VERSION ?= 3.22
APACHE_VERSION ?= 2.4.65
APACHE_RELEASE ?= r0
PHP83_FULL_VERSION ?= 8.3.26
PHP84_FULL_VERSION ?= 8.4.13
PHP_RELEASE ?= r0
MARIADB_VERSION ?= 11.5
WORDPRESS_VERSION ?= 6.8.3
WPCLI_VERSION ?= 2.12.0

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
NC := \033[0m # No Color

# Helper function to print colored output
define print_header
	@echo "$(CYAN)================================$(NC)"
	@echo "$(CYAN)$(1)$(NC)"
	@echo "$(CYAN)================================$(NC)"
endef

define print_success
	@echo "$(GREEN)✅ $(1)$(NC)"
endef

define print_info
	@echo "$(BLUE)ℹ️  $(1)$(NC)"
endef

define print_warning
	@echo "$(YELLOW)⚠️  $(1)$(NC)"
endef

define print_error
	@echo "$(RED)❌ $(1)$(NC)"
endef

# Default target
.PHONY: help
help: ## Show this help message
	@echo "$(CYAN)Displace Technologies Container Library - Build System$(NC)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(CYAN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(PURPLE)%s$(NC)\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Building Images

.PHONY: build-all
build-all: build-apache build-php-fpm build-mariadb build-wordpress ## Build all container images
	$(call print_success,"All containers built successfully!")

.PHONY: build-apache
build-apache: ## Build Apache container
	$(call print_header,"Building Apache $(APACHE_VERSION)")
	docker build \
		--platform $(PLATFORM) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg APACHE_VERSION=$(APACHE_VERSION) \
		--build-arg APACHE_RELEASE=$(APACHE_RELEASE) \
		$(BUILD_ARGS) \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:latest \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:2.4 \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:$(APACHE_VERSION) \
		containers/apache/2.4/
	$(call print_success,"Apache container built")

.PHONY: build-php-fpm
build-php-fpm: build-php-fpm-83 build-php-fpm-84 ## Build all PHP-FPM containers

.PHONY: build-php-fpm-83
build-php-fpm-83: ## Build PHP-FPM 8.3 container
	$(call print_header,"Building PHP-FPM 8.3 $(PHP83_FULL_VERSION)")
	docker build \
		--platform $(PLATFORM) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg PHP_VERSION=8.3 \
		--build-arg PHP_FULL_VERSION=$(PHP83_FULL_VERSION) \
		--build-arg PHP_RELEASE=$(PHP_RELEASE) \
		$(BUILD_ARGS) \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:8.3 \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:$(PHP83_FULL_VERSION) \
		containers/php-fpm/8.3/
	$(call print_success,"PHP-FPM 8.3 container built")

.PHONY: build-php-fpm-84
build-php-fpm-84: ## Build PHP-FPM 8.4 container (latest)
	$(call print_header,"Building PHP-FPM 8.4 $(PHP84_FULL_VERSION)")
	docker build \
		--platform $(PLATFORM) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg PHP_VERSION=8.4 \
		--build-arg PHP_FULL_VERSION=$(PHP84_FULL_VERSION) \
		--build-arg PHP_RELEASE=$(PHP_RELEASE) \
		$(BUILD_ARGS) \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:latest \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:8.4 \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:$(PHP84_FULL_VERSION) \
		containers/php-fpm/8.4/
	$(call print_success,"PHP-FPM 8.4 container built")

.PHONY: build-mariadb
build-mariadb: ## Build MariaDB container
	$(call print_header,"Building MariaDB $(MARIADB_VERSION)")
	docker build \
		--platform $(PLATFORM) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		$(BUILD_ARGS) \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:latest \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:11 \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:$(MARIADB_VERSION) \
		containers/mariadb/11.5/
	$(call print_success,"MariaDB container built")

.PHONY: build-wordpress
build-wordpress: build-wordpress-php83 build-wordpress-php84 ## Build all WordPress containers

.PHONY: build-wordpress-php83
build-wordpress-php83: ## Build WordPress with PHP 8.3
	$(call print_header,"Building WordPress $(WORDPRESS_VERSION) with PHP 8.3")
	docker build \
		--platform $(PLATFORM) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg PHP_VERSION=8.3 \
		--build-arg PHP_FULL_VERSION=$(PHP83_FULL_VERSION) \
		--build-arg PHP_RELEASE=$(PHP_RELEASE) \
		--build-arg WORDPRESS_VERSION=$(WORDPRESS_VERSION) \
		--build-arg WPCLI_VERSION=$(WPCLI_VERSION) \
		$(BUILD_ARGS) \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/wordpress:$(WORDPRESS_VERSION)-php8.3 \
		containers/wordpress/6.8.3-php8.3/
	$(call print_success,"WordPress PHP 8.3 container built")

.PHONY: build-wordpress-php84
build-wordpress-php84: ## Build WordPress with PHP 8.4
	$(call print_header,"Building WordPress $(WORDPRESS_VERSION) with PHP 8.4")
	docker build \
		--platform $(PLATFORM) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg PHP_VERSION=8.4 \
		--build-arg PHP_FULL_VERSION=$(PHP84_FULL_VERSION) \
		--build-arg PHP_RELEASE=$(PHP_RELEASE) \
		--build-arg WORDPRESS_VERSION=$(WORDPRESS_VERSION) \
		--build-arg WPCLI_VERSION=$(WPCLI_VERSION) \
		$(BUILD_ARGS) \
		-t $(REGISTRY)/$(REGISTRY_NAMESPACE)/wordpress:$(WORDPRESS_VERSION)-php8.4 \
		containers/wordpress/6.8.3-php8.4/
	$(call print_success,"WordPress PHP 8.4 container built")

##@ Testing

.PHONY: test
test: test-stack ## Run all tests

.PHONY: test-stack
test-stack: ## Test the complete WordPress stack
	$(call print_header,"Testing WordPress Complete Stack")
	@if command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1; then \
		cd examples && \
		(docker-compose --version >/dev/null 2>&1 && docker-compose -f wordpress-complete.yml up -d) || \
		(docker compose --version >/dev/null 2>&1 && docker compose -f wordpress-complete.yml up -d); \
		echo "Waiting for services to be ready..."; \
		sleep 30; \
		if curl -f http://localhost:8080 >/dev/null 2>&1; then \
			$(call print_success,"WordPress stack test passed"); \
		else \
			$(call print_error,"WordPress stack test failed"); \
			exit 1; \
		fi; \
		(docker-compose --version >/dev/null 2>&1 && docker-compose -f wordpress-complete.yml down -v) || \
		(docker compose --version >/dev/null 2>&1 && docker compose -f wordpress-complete.yml down -v); \
	else \
		$(call print_error,"Docker Compose not found. Please install docker-compose or use 'docker compose'."); \
		exit 1; \
	fi

.PHONY: test-individual
test-individual: ## Test individual containers
	$(call print_header,"Testing Individual Containers")
	@echo "Testing Apache..."
	@docker run --rm --name test-apache -d -p 8081:80 $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:latest
	@sleep 5
	@if curl -f http://localhost:8081 >/dev/null 2>&1; then \
		$(call print_success,"Apache test passed"); \
	else \
		$(call print_error,"Apache test failed"); \
	fi
	@docker stop test-apache >/dev/null 2>&1 || true
	
	@echo "Testing PHP-FPM..."
	@docker run --rm --name test-php -d $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:latest php-fpm -t
	@if docker wait test-php >/dev/null 2>&1; then \
		$(call print_success,"PHP-FPM test passed"); \
	else \
		$(call print_error,"PHP-FPM test failed"); \
	fi
	
	@echo "Testing MariaDB..."
	@docker run --rm --name test-mariadb -d -e MYSQL_ROOT_PASSWORD=testpass $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:latest
	@sleep 15
	@if docker exec test-mariadb mariadb-admin ping -h localhost >/dev/null 2>&1; then \
		$(call print_success,"MariaDB test passed"); \
	else \
		$(call print_error,"MariaDB test failed"); \
	fi
	@docker stop test-mariadb >/dev/null 2>&1 || true

##@ Registry Operations

.PHONY: push-all
push-all: ## Push all container images to registry
	$(call print_header,"Pushing all images to $(REGISTRY)/$(REGISTRY_NAMESPACE)")
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:latest
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:2.4
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:$(APACHE_VERSION)
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:latest
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:8.3
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:8.4
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:$(PHP83_FULL_VERSION)
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:$(PHP84_FULL_VERSION)
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:latest
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:11
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:$(MARIADB_VERSION)
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/wordpress:$(WORDPRESS_VERSION)-php8.3
	docker push $(REGISTRY)/$(REGISTRY_NAMESPACE)/wordpress:$(WORDPRESS_VERSION)-php8.4
	$(call print_success,"All images pushed to registry")

.PHONY: login
login: ## Login to container registry
	@echo "Logging in to $(REGISTRY)..."
	@docker login $(REGISTRY)

##@ Development

.PHONY: clean
clean: ## Remove all built container images
	$(call print_header,"Cleaning up local images")
	@echo "Removing Apache images..."
	@docker rmi $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:latest $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:2.4 $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache:$(APACHE_VERSION) 2>/dev/null || true
	@echo "Removing PHP-FPM images..."
	@docker rmi $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:latest $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:8.3 $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:8.4 $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:$(PHP83_FULL_VERSION) $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm:$(PHP84_FULL_VERSION) 2>/dev/null || true
	@echo "Removing MariaDB images..."
	@docker rmi $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:latest $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:11 $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb:$(MARIADB_VERSION) 2>/dev/null || true
	@echo "Removing WordPress images..."
	@docker rmi $(REGISTRY)/$(REGISTRY_NAMESPACE)/wordpress:$(WORDPRESS_VERSION)-php8.3 $(REGISTRY)/$(REGISTRY_NAMESPACE)/wordpress:$(WORDPRESS_VERSION)-php8.4 2>/dev/null || true
	$(call print_success,"Cleanup completed")

.PHONY: list-images
list-images: ## List all built container images
	$(call print_header,"Built Container Images")
	@echo "$(YELLOW)Apache:$(NC)"
	@docker images $(REGISTRY)/$(REGISTRY_NAMESPACE)/apache --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "  No Apache images found"
	@echo ""
	@echo "$(YELLOW)PHP-FPM:$(NC)"
	@docker images $(REGISTRY)/$(REGISTRY_NAMESPACE)/php-fpm --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "  No PHP-FPM images found"
	@echo ""
	@echo "$(YELLOW)MariaDB:$(NC)"
	@docker images $(REGISTRY)/$(REGISTRY_NAMESPACE)/mariadb --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "  No MariaDB images found"
	@echo ""
	@echo "$(YELLOW)WordPress:$(NC)"
	@docker images $(REGISTRY)/$(REGISTRY_NAMESPACE)/wordpress --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null || echo "  No WordPress images found"

.PHONY: info
info: ## Show build configuration
	$(call print_header,"Build Configuration")
	@echo "$(YELLOW)Registry:$(NC)             $(REGISTRY)/$(REGISTRY_NAMESPACE)"
	@echo "$(YELLOW)Platform:$(NC)             $(PLATFORM)"
	@echo "$(YELLOW)Alpine Version:$(NC)       $(ALPINE_VERSION)"
	@echo "$(YELLOW)Apache Version:$(NC)       $(APACHE_VERSION)"
	@echo "$(YELLOW)PHP 8.3 Version:$(NC)      $(PHP83_FULL_VERSION)"
	@echo "$(YELLOW)PHP 8.4 Version:$(NC)      $(PHP84_FULL_VERSION)"
	@echo "$(YELLOW)MariaDB Version:$(NC)      $(MARIADB_VERSION)"
	@echo "$(YELLOW)WordPress Version:$(NC)    $(WORDPRESS_VERSION)"
	@echo "$(YELLOW)WP-CLI Version:$(NC)       $(WPCLI_VERSION)"
	@echo ""
	@echo "$(CYAN)To override versions:$(NC)"
	@echo "  make build-all ALPINE_VERSION=3.23 PHP84_FULL_VERSION=8.4.14"

##@ Quick Commands

.PHONY: dev-stack
dev-stack: ## Start development WordPress stack
	$(call print_header,"Starting Development Stack")
	cd examples && \
	(docker-compose --version >/dev/null 2>&1 && docker-compose -f wordpress-development.yml up -d) || \
	(docker compose --version >/dev/null 2>&1 && docker compose -f wordpress-development.yml up -d)
	$(call print_success,"Development stack started")
	$(call print_info,"WordPress: http://localhost:8080")
	$(call print_info,"PHPMyAdmin: http://localhost:8081")
	$(call print_info,"Database: localhost:3306 (user: developer, pass: devpass123)")

.PHONY: dev-stack-down
dev-stack-down: ## Stop development WordPress stack
	$(call print_header,"Stopping Development Stack")
	cd examples && \
	(docker-compose --version >/dev/null 2>&1 && docker-compose -f wordpress-development.yml down -v) || \
	(docker compose --version >/dev/null 2>&1 && docker compose -f wordpress-development.yml down -v)
	$(call print_success,"Development stack stopped")

.PHONY: prod-stack
prod-stack: ## Start production WordPress stack
	$(call print_header,"Starting Production Stack")
	cd examples && \
	(docker-compose --version >/dev/null 2>&1 && docker-compose -f wordpress-complete.yml up -d) || \
	(docker compose --version >/dev/null 2>&1 && docker compose -f wordpress-complete.yml up -d)
	$(call print_success,"Production stack started")
	$(call print_info,"WordPress: http://localhost:8080")
	$(call print_warning,"Remember to change default passwords in production!")

.PHONY: prod-stack-down
prod-stack-down: ## Stop production WordPress stack
	$(call print_header,"Stopping Production Stack")
	cd examples && \
	(docker-compose --version >/dev/null 2>&1 && docker-compose -f wordpress-complete.yml down -v) || \
	(docker compose --version >/dev/null 2>&1 && docker compose -f wordpress-complete.yml down -v)
	$(call print_success,"Production stack stopped")

# Default target when no target is specified
.DEFAULT_GOAL := help