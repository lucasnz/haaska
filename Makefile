.PHONY: clean deploy discover sample_config modernize_config

BUILD_DIR=build
ZIP_FILE=haaska.zip

haaska.zip: haaska.py config/* requirements.txt
	mkdir -p $(BUILD_DIR)
	cp $^ $(BUILD_DIR)
	pip install -r requirements.txt -t $(BUILD_DIR)
	chmod 755 $(BUILD_DIR)/haaska.py
	cd $(BUILD_DIR); zip ../$(ZIP_FILE) -r *

clean:
	rm -rf $(BUILD_DIR) $(ZIP_FILE)

deploy: haaska.zip
	aws lambda update-function-code \
		--function-name haaska \
		--zip-file fileb://$(ZIP_FILE)

discover:
	aws lambda invoke \
		--function-name haaska \
		--cli-binary-format raw-in-base64-out \
		--payload '{...}' \
		/dev/fd/3 3>&1 >/dev/null | jq '.'

sample_config:
	python -c 'from haaska import Configuration; print(Configuration().dump())' > config/config.json.sample

modernize_config: config/config.json
	python -c 'from haaska import Configuration; print(Configuration("config/config.json").dump())' > config/config.json.modernized
