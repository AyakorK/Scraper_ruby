run:
	docker build . -t scrap_ruby --compress
	docker run -v $$(pwd)/output:/app/output scrap_ruby

pwd:
	echo $$(pwd)