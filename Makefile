#ToolDAQFrameworkPath=/home/annie/ANNIEDAQ/ToolDAQ/ToolDAQFramework
ToolDAQFrameworkPath=ToolDAQ/ToolDAQFramework

ZMQLib= -L $(ToolDAQFrameworkPath)/../zeromq-4.0.7/lib -lzmq 
ZMQInclude= -I $(ToolDAQFrameworkPath)/../zeromq-4.0.7/include/ 

BoostLib= -L $(ToolDAQFrameworkPath)/../boost_1_60_0/install/lib -lboost_date_time -lboost_serialization
BoostInclude= -I $(ToolDAQFrameworkPath)/../boost_1_60_0/install/include

RootInclude=  -I $(ToolDAQFrameworkPath)/../root/include
RootLib=   -L $(ToolDAQFrameworkPath)/../root/lib  -lCore -lCint -lRIO -lNet -lHist -lGraf -lGraf3d -lGpad -lTree -lRint -lPostscript -lMatrix -lMathCore -lThread -pthread -lm -ldl -rdynamic -pthread -m64

DataModelInclude = $(RootInclude)
DataModelLib = $(RootLib)

MyToolsInclude = $(RootInclude) -I $(ToolDAQFrameworkPath)/../libpqxx-4.0.1/install/include
MyToolsLib = $(RootLib)  -L $(ToolDAQFrameworkPath)/../libpqxx-4.0.1/install/lib/ -lpqxx  -L /usr/lib64/


all: lib/libMyTools.so lib/libToolChain.so lib/libStore.so include/Tool.h  lib/libServiceDiscovery.so lib/libDataModel.so lib/libLogging.so RemoteControl  NodeDaemon

	g++ -g src/main.cpp -o main -I include -L lib -lStore -lMyTools -lToolChain -lDataModel -lLogging -lServiceDiscovery -lpthread $(DataModelInclude) $(MyToolsInclude)  $(MyToolsLib) $(ZMQLib) $(ZMQInclude)  $(BoostLib) $(BoostInclude)


lib/libStore.so:

	cp $(ToolDAQFrameworkPath)/src/Store/Store.h include/
	g++ -g -fPIC -shared  -I inlcude $(ToolDAQFrameworkPath)/src/Store/Store.cpp -o lib/libStore.so


include/Tool.h:

	cp $(ToolDAQFrameworkPath)/src/Tool/Tool.h include/


lib/libToolChain.so: lib/libStore.so include/Tool.h lib/libDataModel.so lib/libMyTools.so lib/libServiceDiscovery.so lib/libLogging.so

	cp $(ToolDAQFrameworkPath)/src/ToolChain/*.h include/
	g++ -g -fPIC -shared $(ToolDAQFrameworkPath)/src/ToolChain/ToolChain.cpp -I include -lpthread -L lib -lStore -lDataModel -lMyTools -lServiceDiscovery -lLogging -o lib/libToolChain.so $(DataModelInclude) $(ZMQLib) $(ZMQInclude) $(MyToolsInclude)  $(BoostLib) $(BoostInclude)


clean: 
	rm -f include/*.h
	rm -f lib/*.so
	rm -f main
	rm -f RemoteControl
	rm -f NodeDaemon

lib/libDataModel.so: lib/libStore.so lib/libLogging.so

	cp DataModel/DataModel.h include/
	cp DataModel/PMTData.h include/
	cp DataModel/RunInformation.h include/
	cp DataModel/MRDTree.h include/
	cp DataModel/SplitTree.h include/
	cp DataModel/PulseTree.h include/
	cp DataModel/TrigData.h include/
	g++ -g -fPIC -shared DataModel/DataModel.cpp DataModel/PMTData.C DataModel/RunInformation.C DataModel/MRDTree.C DataModel/SplitTree.C DataModel/PulseTree.C DataModel/TrigData.C -I include -L lib -lStore  -lLogging  -o lib/libDataModel.so $(DataModelInclude) $(DataModelLib) $(ZMQLib) $(ZMQInclude)  $(BoostLib) $(BoostInclude)

lib/libMyTools.so: lib/libStore.so include/Tool.h lib/libDataModel.so lib/libLogging.so

	cp UserTools/*.h include/
	cp UserTools/Factory/*.h include/
	g++ -g -fPIC -shared  UserTools/Factory/Factory.cpp -I include -L lib -lStore -lDataModel -lLogging -o lib/libMyTools.so $(MyToolsInclude) $(MyToolsLib) $(DataModelInclude) $(ZMQLib) $(ZMQInclude) $(BoostLib) $(BoostInclude)

RemoteControl:
	cp $(ToolDAQFrameworkPath)/RemoteControl ./

NodeDaemon:
	cp $(ToolDAQFrameworkPath)/NodeDaemon ./

lib/libServiceDiscovery.so: lib/libStore.so
	cp $(ToolDAQFrameworkPath)/src/ServiceDiscovery/ServiceDiscovery.h include/
	g++ -shared -fPIC -I include $(ToolDAQFrameworkPath)/src/ServiceDiscovery/ServiceDiscovery.cpp -o lib/libServiceDiscovery.so -L lib/ -lStore  $(ZMQInclude) $(ZMQLib) $(BoostLib) $(BoostInclude)

lib/libLogging.so: lib/libStore.so
	cp $(ToolDAQFrameworkPath)/src/Logging/Logging.h include/
	g++ -shared -fPIC -I include $(ToolDAQFrameworkPath)/src/Logging/Logging.cpp -o lib/libLogging.so -L lib/ -lStore $(ZMQInclude) $(ZMQLib) $(BoostLib) $(BoostInclude)

update:
	cd $(ToolDAQFrameworkPath)
	git pull
	cd ../..
	git pull
