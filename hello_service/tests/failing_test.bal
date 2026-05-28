import ballerina/test;

// Set enable: true to intentionally fail the build
@test:Config {enable: false}
function intentionalFailTest() {
    test:assertFail("Intentional test failure — set enable: false to pass the build");
}
