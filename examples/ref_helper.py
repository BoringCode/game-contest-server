#! /usr/bin/env python3

from optparse import OptionParser
import socket

#Create and listen to a socket
class SocketServer():
    def __init__(self):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.bind(('', 0))
        self.port = self.socket.getsockname()[1]
        self.socket.listen(10)

    def __del__(self):
        self.socket.shutdown(socket.SHUT_RDWR)
        self.socket.close()

#Handle individual connections to the socket server
class Connection():
    def __init__(self, server):
        self.connection, self.address = server.socket.accept()

    def listen(self, buffersize):
        var = ""
        while var == "":
            var = self.connection.recv(buffersize)
        return var

    def send(self, data):
        self.connection.send(data)

    def __del__(self):
        self.connection.shutdown(socket.SHUT_RDWR)
        self.connection.close()

class Manager():
    #Create connection with manager
    def __init__(self, hostname, port):
        self.connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.connection.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.ip = socket.gethostbyname(hostname)
        self.connection.connect((self.ip, port))

    #Send command to manager
    def send(self, command, value):
        #Convert array to value that server can understand
        if isinstance(value, list):
            value = map(str, value)
            value = "|".join(value)
        message = command + ":" + str(value) + "\n"
        try:
            result = self.connection.send(message.encode())
        except:
            result = False
        return result

    def __del__(self):
        self.connection.shutdown(socket.SHUT_RDWR)
        self.connection.close()

#Parse options from manager
parser = OptionParser()
parser.add_option("-p","--port",action="store",type="int",dest="port")
parser.add_option("-n","--num",action="store",type="int",dest="num") #number of players, not used with checkers
parser.add_option("-r", "--rounds", action="store", type="int", dest="rounds") #Number of rounds, not used
(options, args) = parser.parse_args()

#connect to match wrapper
manager = Manager('localhost', options.port)

#create and bind socket to listen for connecting players
playerServer = SocketServer()

#Tell the manager what port players should connect on
manager.send("port", playerServer.port)

