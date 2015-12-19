image_name = alidron/alidron-tic
rpi_image_name = alidron/rpi-alidron-tic
registry = registry.tinigrifi.org:5000
rpi_registry = neuron.local:6667

container_name = alidron-tic

run_args = --device=/dev/ttyUSB0
exec_args = python alidron-tic.py /dev/ttyUSB0

network_name = alidron

.PHONY: clean clean-dangling build build-rpi push push-rpi pull pull-rpi run-bash run-bash-rpi run run-rpi run-cmd run-cmd-rpi stop logs

clean:
	docker rmi $(image_name) || true

clean-dangling:
	docker rmi `docker images -q -f dangling=true` || true

build: clean-dangling
	docker build --force-rm=true -t $(image_name) .

build-rpi: clean-dangling
	docker build --force-rm=true -t $(rpi_image_name) -f Dockerfile-rpi .

push:
	docker tag -f $(image_name) $(registry)/$(image_name)
	docker push $(registry)/$(image_name)

push-rpi:
	docker tag -f $(rpi_image_name) $(rpi_registry)/$(rpi_image_name)
	docker push $(rpi_registry)/$(rpi_image_name)

pull:
	docker pull $(registry)/$(image_name)
	docker tag $(registry)/$(image_name) $(image_name)

pull-rpi:
	docker pull $(rpi_registry)/$(rpi_image_name)
	docker tag -f $(rpi_registry)/$(rpi_image_name) $(rpi_image_name)

run-bash:
	docker run -it --rm --net=$(network_name) --name=$(container_name) $(run_args) $(image_name) bash

run-bash-rpi:
	docker run -it --rm --net=$(network_name) --name=$(container_name) $(run_args) $(rpi_image_name) bash

run:
	docker run -d --net=$(network_name) --name=$(container_name) $(run_args) $(image_name) $(exec_args)

run-rpi:
	docker run -d --net=$(network_name) --name=$(container_name) $(run_args) $(rpi_image_name) $(exec_args)

stop:
	docker stop $(container_name)
	docker rm $(container_name)

logs:
	docker logs -f $(container_name)

