restart: down up

build:
	docker compose build

up:
ifdef PROFILE
	docker compose -f docker-compose.$(PROFILE).yaml up -d $(SERVICES)
else
	docker compose up -d $(SERVICES)
endif

up/local/nginx:
	docker compose -f docker-compose.local.yaml up -d nginx

up/local/app:
	cd app && npm start

down:
	docker rm -f poc-embed-app
	docker stop poc-embed-n8n poc-embed-nginx
