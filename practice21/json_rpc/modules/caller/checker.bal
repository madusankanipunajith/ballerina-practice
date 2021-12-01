import json_rpc.validator;
import json_rpc.store;

# Description
#
# + message - Parameter Description
# + return - Return Value Description  
public isolated function checker(json message) returns validator:Error|validator:Request|null{
    validator:JsonRPCTypes result = validator:messageValidator(message);

    if result is validator:Error{
        return result;
    }

    if result is validator:Request{
        anydata reqestParams = result.params;

        if( !(reqestParams is anydata[]) && !(reqestParams is map<anydata>) && !(reqestParams === ())){
                    
            return store:invalidMethodParams(result.id);       
        }

        return result;
    }

    // if it is a response or something else
    return null;
}