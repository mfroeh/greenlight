.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo 'Are you sure you want to run this command [y/N]?' && read ans && [ $${ans:-N} = y ]

.PHONY: run/api
run/api:
	@go run ./cmd/api --db-dsn=${GREENLIGHT_DB_DSN}

.PHONY: build/api
build/api:
	@go build -ldflags="-s" -o ./bin/api ./cmd/api
	GODS=linux GOARCH=amd64 go build -ldflags="-s" -o ./bin/linux_amd64/api ./cmd/api

.PHONY: db/psql
db/psql:
	psql ${GREENLIGHT_DB_DSN}up:

.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -ext sql -dir ./migrations ${name}

.PHONY: db/migrations/up
db/migrations/up: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} up

.PHONY: audit
audit: vendor
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor