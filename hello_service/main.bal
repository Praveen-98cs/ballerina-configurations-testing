import ballerina/http;
import ballerina/io;
import ballerina/os;
import ballerina/test;

// ============================================
// MINIMAL TEST - Level 1, 2, 3 Configurations
// ============================================

// Level 1: Simple object
type SimpleConfig record {
    string name;
    int count;
    boolean enabled;
};

// Level 2: One level of nesting
type DatabaseConfig record {
    string host;
    int port;
    boolean sslEnabled;
};

type Level2Config record {
    string appName;
    DatabaseConfig database;
};

// Level 3: Two levels of nesting (3 levels total)
type AuthConfig record {
    string provider;
    string clientId;
    boolean enabled;
};

type SecurityConfig record {
    AuthConfig auth;
    boolean requireHttps;
};

type Level3Config record {
    string serviceName;
    SecurityConfig security;
};

// ============================================
// CONFIGURABLE VARIABLES
// ============================================

// LEVEL 1 CONFIGS
configurable SimpleConfig simpleRequired = ?;  // REQUIRED - no default

configurable SimpleConfig simpleOptional = {   // OPTIONAL - has default
    name: "default_name",
    count: 10,
    enabled: true
};

// LEVEL 2 CONFIGS
configurable Level2Config level2Required = ?;  // REQUIRED - no default

configurable Level2Config level2Optional = {   // OPTIONAL - has default
    appName: "DefaultApp",
    database: {
        host: "localhost",
        port: 5432,
        sslEnabled: false
    }
};

// LEVEL 3 CONFIGS
configurable Level3Config level3Required = ?;  // REQUIRED - no default

configurable Level3Config level3Optional = {   // OPTIONAL - has default
    serviceName: "DefaultService",
    security: {
        auth: {
            provider: "oauth",
            clientId: "default-client",
            enabled: false
        },
        requireHttps: true
    }
};

// Simple primitives
configurable string primitiveRequired = ?;     // REQUIRED
configurable string primitiveOptional = "default_value";  // OPTIONAL
configurable int numberOptional = 42;          // OPTIONAL

// Environment variable
configurable string name = os:getEnv("NAME");

// Build gate: setting any non-empty value via Choreo's Configurations panel
// makes the unit test stage fail, which fails the build. Useful for
// reproducing same-commit success/failure scenarios. Leave empty to pass.
configurable string secret = "";

// ============================================
// SERVICE
// ============================================
service / on new http:Listener(8090) {
    
    resource function get test() returns json {
        io:println("\n========================================");
        io:println("MINIMAL CONFIGURATION TEST");
        io:println("========================================\n");
        
        io:println("--- LEVEL 1 CONFIGS ---");
        io:println("simpleRequired: ", simpleRequired);
        io:println("simpleOptional: ", simpleOptional);
        io:println("");
        
        io:println("--- LEVEL 2 CONFIGS ---");
        io:println("level2Required: ", level2Required);
        io:println("level2Optional: ", level2Optional);
        io:println("");
        
        io:println("--- LEVEL 3 CONFIGS ---");
        io:println("level3Required: ", level3Required);
        io:println("level3Optional: ", level3Optional);
        io:println("");
        
        io:println("--- PRIMITIVES ---");
        io:println("primitiveRequired: ", primitiveRequired);
        io:println("primitiveOptional: ", primitiveOptional);
        io:println("numberOptional: ", numberOptional);
        io:println("");
        
        io:println("========================================\n");
        
        string message = "Hello, " + name + "! Minimal test completed.";
        
        json response = {
            "greeting": message,
            "test": "minimal",
            "configurations": {
                "level1": {
                    "simpleRequired": simpleRequired.toJson(),
                    "simpleOptional": simpleOptional.toJson()
                },
                "level2": {
                    "level2Required": level2Required.toJson(),
                    "level2Optional": level2Optional.toJson()
                },
                "level3": {
                    "level3Required": level3Required.toJson(),
                    "level3Optional": level3Optional.toJson()
                },
                "primitives": {
                    "primitiveRequired": primitiveRequired,
                    "primitiveOptional": primitiveOptional,
                    "numberOptional": numberOptional
                }
            },
            "summary": {
                "totalConfigs": 9,
                "requiredConfigs": 4,
                "optionalConfigs": 5,
                "note": "Optional configs have hardcoded defaults in code"
            }
        };
        
        return response;
    }
}

// Set enable: true to intentionally fail the Choreo unit test stage
@test:Config {enable: false}
function intentionalFailTest() {
    test:assertFail("Intentional test failure — set enable: false to pass the build");
}

// Build gate: fails when the 'secret' configurable is set to any non-empty value.
@test:Config {}
function buildGateTest() {
    if secret != "" {
        test:assertFail(string `Build gate triggered: 'secret' was set to "${secret}". Clear it to pass the build.`);
    }
}