Télé-information client for Alidron
===================================

[![build status](https://git.tinigrifi.org/ci/projects/7/status.png?ref=master)](https://git.tinigrifi.org/ci/projects/7?ref=master) [![Gitter](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/Alidron/talk)

This is a télé-information client (TIC) for Alidron. TIC is a system for reading energy data from main breakers in French households.

The Docker image is accessible on:
* ARM/Raspberry Pi: [alidron/rpi-alidron-tic](https://hub.docker.com/r/alidron/rpi-alidron-tic/)

The Dockerfile is accessible from the Github repository:
* ARM/Raspberry Pi: [Dockerfile](https://github.com/Alidron/alidron-tic/blob/master/Dockerfile-rpi)

Run
===

Only working on Raspberry Pi targets. Assuming your TIC reader is accessible on /dev/ttyUSB0:
```
$ docker run -d --device=/dev/ttyUSB0 alidron/rpi-alidron-tic python alidron-tic.py /dev/ttyUSB0
```

License and contribution policy
===============================

This project is licensed under LGPLv3.

To contribute, please, follow the [C4.1](http://rfc.zeromq.org/spec:22) contribution policy.
