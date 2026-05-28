import ballerina/http;

// This service uses Swan Lake syntax but targets distribution 1.2.0 — will always fail to build
configurable string serviceName = ?;

service / on new http:Listener(8090) {
    resource function get health() returns json {
        return {"status": "ok", "service": serviceName};
    }
}
