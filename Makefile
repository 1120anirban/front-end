.PHONY: test coverage

dev: clean image container networks logs

compose:
	@docker-compose -f test/docker-compose.yml up -d

deps:
	@npm install

image:
	@docker build -t dev/frontend .

container:
	@docker run -it -d --name devfrontend -P -e NODE_ENV=development -e PORT=8080 -p 8080:8080 dev/frontend

networks:
	@docker network connect test_default devfrontend

clean:
	@if [ $$(docker ps -a -q -f name=devfrontend | wc -l) -ge 1 ]; then docker rm -f devfrontend; fi
	@if [ $$(docker images -q dev/frontend | wc -l) -ge 1 ]; then docker rmi dev/frontend; fi

test:
	@$$(npm bin)/istanbul cover $$(npm bin)/_mocha -- test/*_test.js test/api/*_test.js

test-w:
	@$$(npm bin)/mocha -w --recursive test/{api,*_test.js}

coverage:
	@open coverage/lcov-report/index.html

browser:
	@open http://$$(docker-machine ip):8080

logs:
	@docker logs -f devfrontend

e2e:
	@./test/e2e/runner.sh
