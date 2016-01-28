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

import logging
import serial
import signal
import sys
from functools import partial

from isac import IsacNode, IsacValue
from isac.tools import green

logger = logging.getLogger(__name__)

logging.basicConfig(level=logging.INFO)

class BadChecksum(Exception):
    pass

def _read_trame(trame):
    trame = trame.strip('\r\n')

    if not _checksum(trame):
        raise BadChecksum(trame)

    # Separator can either be a space or a tab
    sep = trame[-2]
    first_sep_i = trame.index(sep)

    tag = trame[:first_sep_i]
    data = trame[first_sep_i+1:-2]

    return tag, data

def _checksum(trame):
    c = ord(trame[-1])

    sum_ = sum(map(ord, trame[:-2]))
    if ((sum_ & 0x3F) + 0x20) == c:
        return True

    # Try with the last separator (new norm)
    sum_ += ord(trame[-2])
    if ((sum_ & 0x3F) + 0x20) == c:
        return True

    return False

class AlidronTIC(object):

    ALLOWED_TAGS = ['ADCO', 'BASE', 'IINST', 'IMAX', 'ISOUSC', 'OPTARIF', 'PAPP', 'PTEC']

    def __init__(self, port):
        self.isac_node = IsacNode('alidron-tic')
        green.signal(signal.SIGTERM, partial(self._sigterm_handler))
        green.signal(signal.SIGINT, partial(self._sigterm_handler))

        self.ser = serial.Serial(
            port=port,
            baudrate=1200,
            bytesize=serial.SEVENBITS,
            parity=serial.PARITY_EVEN,
            stopbits=serial.STOPBITS_ONE,
            timeout=1
        )

        self.signals = {}

    def start(self):
        green.spawn(self.run)

    def serve_forever(self):
        self.start()
        try:
            while True:
                green.sleep(1)
        except (KeyboardInterrupt, SystemExit):
            logger.info('Stopping')
            self.stop()

    def stop(self):
        self.running = False
        self.isac_node.shutdown()
        green.sleep(2)

    def _sigterm_handler(self):
        logger.info('Received SIGTERM signal, exiting')
        self.stop()
        logger.info('Exiting')
        sys.exit(0)

    def run(self):
        self.running = True
        while self.running:
            try:
                try:
                    tag, data = _read_trame(self.ser.readline())
                except BadChecksum:
                    continue

                logger.debug('Read %s: %s', tag, data)
                
                if tag not in self.ALLOWED_TAGS:
                    logger.warning('Discarding %s: %s', tag, data)
                    continue
                
                try:
                    signal = self.signals[tag]
                except KeyError:
                    logger.info('Creating ISAC value for %s', tag)
                    metadata = {
                        'ts_precision': 's',
                        'smoothing': True
                    }
                    signal = IsacValue(
                        self.isac_node,
                        'tic://alidron-tic/%s' % tag,
                        static_tags={'location': 'entrance.switchboard'},
                        metadata=metadata,
                        survey_last_value=False,
                        survey_static_tags=False
                    )
                    self.signals[tag] = signal

                try:
                    signal.value = int(data)
                except ValueError:
                    signal.value = data

            except Exception as ex:
                logger.error('Hum, something weird: %s', ex)

def main(port):
    tic = AlidronTIC(port)
    tic.serve_forever()

if __name__ == '__main__':
    main(sys.argv[1])
