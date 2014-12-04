import sys
from ws4py.client.threadedclient import WebSocketClient

class DummyClient(WebSocketClient):
    def __init__(self, *args, **kwargs):
        self.quiet = kwargs.pop('quiet', False)
        super(self.__class__, self).__init__(*args, **kwargs)

    def opened(self):
        if self.quiet:
            return

        def data_provider():
            for i in range(1, 200, 25):
                yield "#" * i
                yield ' '

        self.send(data_provider())

        for i in range(0, 200, 25):
            print i
            self.send("*" * i)

    def closed(self, code, reason=None):
        print "Closed down", code, reason

    def received_message(self, m):
        print 'Got:', m
        if len(m) == 175:
            self.close(reason='Bye bye')

if __name__ == '__main__':
    try:
        quiet = '-q' in sys.argv
        ws = DummyClient('ws://127.0.0.1:9000/ws', protocols=['http-only', 'chat'], quiet=quiet)
        ws.connect()
        ws.run_forever()
    except KeyboardInterrupt:
        ws.close()
