include .env

DOCKER_COMPOSE = $(shell if docker compose version > /dev/null 2>&1; then echo "docker compose"; else echo "docker-compose"; fi)

setup:
	make build && make migrate

run:
	$(DOCKER_COMPOSE) up -d

test:
	docker exec -it docker_api_core go test ./... -v

build:
	$(DOCKER_COMPOSE) up --build -d

down:
	$(DOCKER_COMPOSE) down -v

logs:
	docker logs --follow docker_api_core

kill-all:
	docker kill $$(docker ps -aq)

rm-all:
	docker rm $$(docker ps -aq)

clean-all:
	docker system prune -a --volumes

migration:
	docker exec -it docker_api_core migrate create -ext sql -dir internal/database/migrations -seq $(name)

migrate:
	docker exec -it docker_api_core migrate -path internal/database/migrations -database "postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -verbose up

migrate-version:
	docker exec -it docker_api_core migrate -database "postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -path internal/database/migrations version

clean-dirty-migrate:
	docker exec -it docker_api_core migrate -database "postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -path internal/database/migrations force $(VERSION)

migrate-undo:
	docker exec -it docker_api_core migrate -path internal/database/migrations -database "postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -verbose down -all

seed:
	docker exec -it docker_api_core migrate -path internal/database/seeders -database "postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable" -verbose up
