.PHONY: help
help:
	@echo "debug-test"
	@echo "	just echo if we in compose or not"
	@echo "debug-build"
	@echo "	build the docker image"
	@echo "debug-run"
	@echo "	run a container from the image in the foreground"
	@echo "debug-headless"
	@echo "	run detached (in the background)"
	@echo "debug-logs"
	@echo "	connect to detached container and get the logs"
	@echo "debug-stop-remove"
	@echo "	stop the detched container and remove it"
	@echo "debug-clean"
	@echo "	remove the container and the image"
	@echo ""
	@echo "NOTE: use COMPOSE=1 in the shell env to make use of docker compose"
	@echo ""

debug-build: debug-nowait-build

debug-test: _debug-test
ifeq ($(COMPOSE), 1)
_debug-test:
	@echo compose is set
else
_debug-test:
	@echo without compose
endif

debug-run: _debug-run
ifeq ($(COMPOSE), 1)
_debug-run: debug-nowait-compose
else
_debug-run: debug-no-compose-run
endif

debug-headless: _debug-headless
ifeq ($(COMPOSE), 1)
_debug-headless: debug-nowait-compose-headless
else
_debug-headless: debug-no-compose-run-headless
endif

debug-logs: _debug_logs
ifeq ($(COMPOSE), 1)
_debug-logs: debug-nowait-compose-headless-logs
else
_debug-logs: debug-no-compose-run-headless-logs
endif

debug-stop-remove: _debug-stop-remove
ifeq ($(COMPOSE), 1)
_debug-stop-remove: debug-nowait-compose-headless-stop debug-nowait-compose-headless-remove 
else
_debug-stop-remove: debug-no-compose-run-headless-stop debug-no-compose-run-remove
endif

debug-clean: debug-nowait-image-remove clean-force

# build

debug-nowait-build:
	docker build --file Dockerfile.debug --tag go-debugger-image .

# clean realted

debug-nowait-image-remove:
	docker image rm go-debugger-image -f

clean-force:
	# compose create another image  - need to remove this as well
	#  ⠿ Container go-docker-debug-app-1  Started 
	docker container rm go-docker-debug-app-1  -f
	docker image rm go-docker-debug-app  -f
	docker image rm go-debugger-image  -f

# check whats going on 

check:
	@ echo === docker ps ===
	docker ps -a
	@ echo === docker container ===
	docker container ls -a
	@ echo === docker images ===
	docker image ls -a


# using docker compose 

debug-nowait-compose:
	tag=go-debugger-image docker compose -f docker-compose.yml up

debug-nowait-compose-headless:
	tag=go-debugger-image docker compose -f docker-compose.yml up -d

debug-nowait-compose-headless-logs:
	tag=go-debugger-image docker compose -f docker-compose.yml logs --follow

debug-nowait-compose-headless-stop:
	tag=go-debugger-image docker compose -f docker-compose.yml down

debug-nowait-compose-headless-remove:
	tag=go-debugger-image docker compose -f docker-compose.yml rm -f

# using docker without compose

debug-no-compose-run:
	docker run  -p 3000:3000 -p 4000:4000 --name  go-debugger-container go-debugger-image

debug-no-compose-run-headless:
	docker run  -p 3000:3000 -p 4000:4000 --name  go-debugger-container --detach go-debugger-image 

debug-no-compose-run-headless-logs:
	docker logs --follow go-debugger-container

debug-no-compose-run-headless-stop:
	docker stop go-debugger-container 

debug-no-compose-run-remove:
	docker container rm -f go-debugger-container 



