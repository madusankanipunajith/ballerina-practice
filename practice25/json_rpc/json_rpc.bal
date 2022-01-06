// import json_rpc.server;
// import json_rpc.'types;
// import ballerina/io;

// string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
// string str1 = "{\"jsonrpc\":\"2.0\",\"method\":\"notific\",\"params\":{\"x\":89, \"y\":100}}";
// string str2 = "{\"foo\": \"boo\"}";
// string str3 = "[{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}, {\"jsonrpc\":\"2.0\",\"method\":\"sub\",\"params\":{\"x\":89, \"y\":100},\"id\":10}]";
// string str4 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":[10,20,30],\"id\":10}";
// string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"print\",\"id\":10}";
// string str60 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":100,\"id\":10}";
// string str6 = "[]";
// string str7 = "{\"jsonrpc\":\"2.0\",\"method\":\"thermometer/convirt\",\"params\":{\"z\":100},\"id\":10}";
// string str8 = "{\"jsonrpc\":\"2.0\",\"method\":\"thermometer/print\",\"params\":{\"z\":100},\"id\":10}";

// type Nip record {|
//     int x;
//     int y;
// |};

// type Temp record {
//   float z;
// };


// public function main() {
   
//     Calculator calc = new();
//     //Thermometer termo = new();
//     server:Server s1 = new([calc]);
//     io:println(s1.runner(str6));

// }

// class Calculator{
//   *server:JRPCService;

//     function init() {
//       CalcMethods cmethods = new();
//       self.methods = cmethods;
//     }

//     public isolated function name() returns string|error {
//         return "calculator";
//     }

// }

// class Thermometer {
//   *server:JRPCService;

//     function init() {
//       TherMethods tmethods = new();
//       self.methods = tmethods;
//     }

//     public isolated function name() returns string|error {
//         return "thermometer";
//     }
// }


// isolated class CalcMethods {
//   *'types:JRPCMethods;

//     isolated function addFunction(server:Input ifs) returns int|error{
//       Nip nip = check ifs.cloneWithType();
//       return nip.x + nip.y;
//     }

//     isolated function subFunction(server:Input ifs) returns int|error{
//       Nip nip = check ifs.cloneWithType();
//       return nip.x - nip.y;
//     }

//     isolated function notificFunction(server:Input ifs) {
//       io:println(ifs);
//     }
    
//     public isolated function getMethods() returns 'types:Methods{

//         'types:Methods meth={
//           "add": self.addFunction,
//           "sub": self.subFunction,
//           "notific": self.notificFunction
//         };

//         return meth;
//     }    

// }

// isolated class TherMethods {
//   *'types:JRPCMethods;

//     isolated function convirtFunction(server:Input ifs) returns error|float{
//       Temp temp = check ifs.cloneWithType();
//       float ans = (temp.z*9/5) + 32;
//       return ans;
//     }

//     isolated function printFunction(server:Input ifs) {
//       Temp temp = checkpanic ifs.cloneWithType();
//       io:println("Hello madusanka : ", temp.z);
//     }

//     public isolated function getMethods() returns types:Methods {
//         return {"convirt":self.convirtFunction, "print":self.printFunction};
//     }
// }





import json_rpc.'types;
import json_rpc.'client;
import ballerina/io;
public function main() returns error? {

    'client:Client cl = new();
    'client:ClientServices tcpService = check cl.setConfig("localhost", 9000, 'client:TCP);

    ClientMethods clm = new(tcpService);

    clm.addFunction(125, {"x":10, "y":20}, function (types:JRPCResponse t) returns () {
     io:println(t);   
    });

    // 'types:Request r ={
    //   method: "add",
    //   params: {"x":10, "y":20},
    //   id: 156
    // };

    // 'types:Request s ={
    //   method: "add",
    //   params: 1000,
    //   id: 157
    // };

    // 'types:Notification n ={
    //   method: "mult",
    //   params: [10,20]
    // };

    

    // io:println(tcpService.sendMessage(r));

    // tcpService.sendNotification(n);

    // io:println(tcpService.sendMessage(s)); 

    tcpService.closeClient();

}


class ClientMethods {
  *'client:JRPCClientMethods;

  function init('client:ClientServices cls) {
    self.clientServices = cls;
  }

  public function addFunction(int id,json params, function ('types:JRPCResponse response) callback) {
    'types:Request r ={
      id:id,
      params: params,
      method:"add"
    };

    types:JRPCResponse sendMessage = self.clientServices.sendMessage(r);
    callback(sendMessage);
  }

  public function subFunction(int id,json params, function ('types:JRPCResponse response) callback) {
    'types:Request r ={
      id:id,
      params: params,
      method:"sub"
    };

    types:JRPCResponse sendMessage = self.clientServices.sendMessage(r);
    callback(sendMessage);
  }

  public function notFunction(json params) {
    'types:Notification n ={
      params: params,
      method: "mult"
    };

    self.clientServices.sendNotification(n);
  }
}

