import cherrypy
from ws4py.server.cherrypyserver import WebSocketPlugin, WebSocketTool
from ws4py.websocket import WebSocket

cherrypy.config.update({'server.socket_port': 9000})
WebSocketPlugin(cherrypy.engine).subscribe()
cherrypy.tools.websocket = WebSocketTool()


clients = set()


class EchoWebSocket(WebSocket):
    def opened(self):
        clients.add(self)

    def closed(self, code, reason=None):
        clients.remove(self)

    def received_message(self, message):
        """
        Broadcast any received message.
        """
        for c in clients:
            c.send(message.data, message.is_binary)


class Root(object):
    @cherrypy.expose
    def index(self):
        return 'some HTML with a websocket javascript connection'

    @cherrypy.expose
    def ws(self):
        # you can access the class instance through
        handler = cherrypy.request.ws_handler

cherrypy.quickstart(Root(), '/', config={'/ws': {'tools.websocket.on': True,
                                                 'tools.websocket.handler_cls': EchoWebSocket}})
