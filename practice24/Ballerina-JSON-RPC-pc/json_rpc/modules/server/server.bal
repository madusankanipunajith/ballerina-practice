import json_rpc.caller;
import json_rpc.'types;
import json_rpc.util;
//import ballerina/tcp;
// import ballerina/io;
// import ballerina/log;

type SingleJRPCOutput 'types:Response|'types:Error;
type BatchJRPCOutput 'types:Response|'types:Error[];

type BatchResponse 'types:JsonRPCTypes?[]; 

# User Input parameters  
public type Input 'types:InputFunc|anydata[];

public type JRPCSA JRPCService[];

public class JRPCService {

    public 'types:JRPCMethods methods;

    public isolated function init() {
        self.methods = new();
    }

    // return an error by default....
    public isolated function name() returns string|error{
        return "";
    }

}


public class Server {

    private JRPCSA jrpcsa = [];

    public isolated function init(JRPCSA services){
        self.jrpcsa = services;
    }

    private isolated function methodFilter('types:Request result) returns 'types:Method|error{

            string method = result.method;
            'types:Methods allMethods = {}; 
            string serviceName = "";
            string methodName = "";

            if self.jrpcsa.length() == 1 {

                allMethods = self.jrpcsa[0].methods.getMethods();
                methodName = method;

            }else if self.jrpcsa.length() > 1 {

                int? index = method.indexOf("/");

                if index is int{

                    serviceName = string:substring(method, 0, index);
                    methodName = string:substring(method, index+1, method.length());
                
                }else{

                    return error("can't find the method");
                }


                foreach var item in self.jrpcsa {
                    if item.name() == serviceName {
                        allMethods = item.methods.getMethods(); continue;
                    }
                }
               
            }else{

                return error("service is not initialized");
            }          

            //'types:Methods allMethodss = self.jservice.methods.getMethods();

            'types:Method|error selectedMethod = trap allMethods.get(methodName);

            if selectedMethod is error {

                return error("method is not found...");

            }else{

                return selectedMethod;
            }
        
    }

    private isolated function executeSingleJson('types:Request message) returns 'types:Error|'types:Response{

            'types:Method|error mf = self.methodFilter(message);

            if mf is error{
                return util:methodNotFoundError(message.id);
            }

            return checkpanic caller:executor(message, mf);

    }

    private isolated function executeBatchJson(json[] message) returns BatchResponse{
        BatchResponse batch_res_array = [];

            foreach var item in message {
                
                if caller:checker(item) is 'types:Request{
                    batch_res_array.push(self.executeSingleJson(<'types:Request> caller:checker(item)));
                }

                if caller:checker(item) is 'types:Error{
                    batch_res_array.push(caller:checker(item));
                }
                              
            }

            return batch_res_array;
        

    }

    public isolated function runner(string message) returns 'types:JsonRPCTypes|BatchResponse{
       
        'types:Identy identity = caller:requestIdentifier(message);

        if identity is 'types:Error{
            return identity;
        }

        if identity is map<json>{
           
            if caller:checker(identity) is 'types:Request {
                return self.executeSingleJson(<'types:Request> caller:checker(identity));     
            }

            if caller:checker(identity) is 'types:Error{
                return <'types:Error> caller:checker(identity);
            }
           
        }   

        if identity is json[]{
            return self.executeBatchJson(identity);
        }

        return util:serverError();
    }


    public isolated function sendReply(){

    }

}
