.PHONY: db-up db-down api-up api-test ios-project

db-up:
	docker compose up -d db

db-down:
	docker compose down

api-up:
	cd backend && ./gradlew bootRun

api-test:
	cd backend && ./gradlew test

ios-project:
	cd ios && xcodegen generate
