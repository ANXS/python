.PHONY: clean dist_clean molecule testenv

BUILD_IMAGE="anxsscaffolding/build"

molecule:
	docker run \
		-v $(shell pwd):/mnt \
		-v /var/run/docker.sock:/var/run/docker.sock \
		$(BUILD_IMAGE)
