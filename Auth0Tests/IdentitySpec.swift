import Foundation
import Quick
import Nimble

@testable import Auth0

let required: [String: Any] = [
    "user_id": UserId,
    "connection": "MyConnection",
    "provider": "auth0"
]

class UserIdentitySharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("invalid identity") { (context: SharedExampleContext) in
            let key = context()["key"] as! String
            it("should return nil when missing \(key)") {
                var dict = required
                dict[key] = nil
                let identity = Identity(json: dict)
                expect(identity).to(beNil())
            }
        }
    }
}
class UserIdentitySpec: QuickSpec {

    override func spec() {

        describe("init from json") {

            let token = UUID().uuidString
            let secret = UUID().uuidString

            it("should build with required values") {
                let identity = Identity(json: required)
                expect(identity?.identifier) == UserId
                expect(identity?.connection) == "MyConnection"
                expect(identity?.provider) == "auth0"
                expect(identity?.social) == false
                expect(identity?.profileData).to(beEmpty())
            }

            it("should have social flag") {
                var json = required
                json["isSocial"] = true
                let identity = Identity(json: json)
                expect(identity?.social) == true
            }

            it("should have profile data") {
                var json = required
                json["profileData"] = ["key": "value"]
                let identity = Identity(json: json)
                expect(identity?.profileData["key"] as? String) == "value"
            }

            it("should have access token & secret") {
                var json = required
                json["access_token"] = token
                json["access_token_secret"] = secret
                let identity = Identity(json: json)
                expect(identity?.accessToken) == token
                expect(identity?.accessTokenSecret) == secret
            }

            it("shoud have expire information") {
                let date = Date()
                let interval = date.timeIntervalSince1970
                var json = required
                json["expires_in"] = interval
                let identity = Identity(json: json)
                expect(identity?.expiresIn?.timeIntervalSince1970) == interval
            }

            it("should return nil with empty json") {
                let identity = Identity(json: [:])
                expect(identity).to(beNil())
            }

            ["user_id", "connection", "provider"].forEach { key in itBehavesLike("invalid identity") { return ["key": key] } }
        }
    }

}

