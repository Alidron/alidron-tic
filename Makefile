# Copyright 2015-2016 - Alidron's authors
#
# This file is part of Alidron.
#
# Alidron is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Alidron is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Alidron.  If not, see <http://www.gnu.org/licenses/>.

image_name = alidron/alidron-tic
rpi_image_name = alidron/rpi-alidron-tic
private_rpi_registry = neuron.local:6667

container_name = alidron-tic

run_args = --device=/dev/ttyUSB0
exec_args = python alidron-tic.py /dev/ttyUSB0

network_name = alidron

.PHONY: clean clean-dangling build build-rpi push push-rpi push-rpi-priv pull pull-rpi pull-rpi-priv run-bash run-bash-rpi run run-rpi run-cmd run-cmd-rpi stop logs

clean:
	docker rmi $(image_name) || true

clean-dangling:
	docker rmi `docker images -q -f dangling=true` || true

build: clean-dangling
	docker build --force-rm=true -t $(image_name) .

build-rpi: clean-dangling
	docker build --force-rm=true -t $(rpi_image_name) -f Dockerfile-rpi .

push:
	docker push $(image_name)

push-rpi:
	docker push $(rpi_image_name)

push-rpi-priv:
	docker tag -f $(rpi_image_name) $(private_rpi_registry)/$(rpi_image_name)
	docker push $(private_rpi_registry)/$(rpi_image_name)

pull:
	docker pull $(image_name)

pull-rpi:
	docker pull $(rpi_image_name)

pull-rpi-priv:
	docker pull $(private_rpi_registry)/$(rpi_image_name)
	docker tag -f $(private_rpi_registry)/$(rpi_image_name) $(rpi_image_name)

run-bash:
	docker run -it --rm --net=$(network_name) --name=$(container_name) $(run_args) $(image_name) bash

run-bash-rpi:
	docker run -it --rm --net=$(network_name) --name=$(container_name) $(run_args) $(rpi_image_name) bash

run:
	docker run -d --net=$(network_name) --name=$(container_name) $(run_args) $(image_name) $(exec_args)

run-rpi:
	docker run -d --net=$(network_name) --name=$(container_name)-prod $(run_args) $(rpi_image_name) $(exec_args)

stop:
	docker stop $(container_name)-prod
	docker rm $(container_name)-prod

logs:
	docker logs -f $(container_name)-prod

