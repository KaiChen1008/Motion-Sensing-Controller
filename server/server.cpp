#include "WebsocketServer.h"
#include <iostream>
#include <thread>
#include <asio/io_service.hpp>
#include <string>
//The port number the WebSocket server listens on
#define PORT_NUMBER 8080

using namespace std;
// interface
// {"x": float, "y": float, "mode": int, "whiteSpace": bool}
double x, y, z;
int mode = 0; // 1: gyro, 0: btn
bool whiteSpace = false; // true : press, 

void websocketServerThread()
{
	//Create the event loop for the main thread, and the WebSocket server
	asio::io_service mainEventLoop;
	WebsocketServer server;
	
	//Register our network callbacks, ensuring the logic is run on the main thread's event loop
	server.connect([&mainEventLoop, &server](ClientConnection conn)
	{
		mainEventLoop.post([conn, &server]()
		{
			std::clog << "Connection opened." << std::endl;
			std::clog << "There are now " << server.numConnections() << " open connections." << std::endl;
			
			//Send a hello message to the client
			// server.sendMessage(conn, "hello", Json::Value());
		});
	});
	server.disconnect([&mainEventLoop, &server](ClientConnection conn)
	{
		mainEventLoop.post([conn, &server]()
		{
			std::clog << "Connection closed." << std::endl;
			// std::clog << "There are now " << server.numConnections() << " open connections." << std::endl;
		});
	});
	server.message("message", [&mainEventLoop, &server](ClientConnection conn, const Json::Value& args)
	{
		mainEventLoop.post([conn, args, &server]()
		{
			// std::clog << "message handler on the main thread" << std::endl;
			// std::clog << "Message payload:" << std::endl;
			for (auto key : args.getMemberNames()) {
				std::clog << key << ": " << args[key].asString() << std::endl;
				if      (strcmp(key.c_str(), "x") == 0) x = args[key].asDouble();
				else if (strcmp(key.c_str(), "y") == 0)	y = args[key].asDouble();
				else if (strcmp(key.c_str(), "z") == 0) z = args[key].asDouble();
				else if (strcmp(key.c_str(), "m") == 0) mode = args[key].asInt();
				else if (strcmp(key.c_str(), "w") == 0) whiteSpace = (args[key].asInt() == 1)  ? true : false;
			}
		});
	});
	
	//Start the networking thread
	std::thread serverThread([&server]() {
		server.run(PORT_NUMBER);
	});
	
	//Start the event loop for the main thread
	asio::io_service::work work(mainEventLoop);
	mainEventLoop.run();
}

int main() {
	std::thread serverThread(websocketServerThread); // 第一行


	serverThread.join(); // 放在最後面
}
