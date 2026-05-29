import ballerina/os;
import ballerina/test;

// Build gate: fails when the SECRET build variable (or build secret) is set
// to any non-empty value. Add/remove in Choreo's "Build Variables and Secrets"
// panel to toggle success/failure for the same source commit.
@test:Config {}
function buildGateTest() {
    string envSecret = os:getEnv("SECRET");
    if envSecret != "" {
        test:assertFail(string `Build gate triggered: SECRET = "${envSecret}". Remove it to pass the build.`);
    }
}
