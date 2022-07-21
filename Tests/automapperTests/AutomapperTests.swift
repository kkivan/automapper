import XCTest
@testable import automapper

final class AutomapperTests: XCTestCase {
    func testExample() throws {
        let network = Network(int: 99, str: nil, user: .init(id: 11))
        let domain = try Domain.init(from: MirrorDecoder(value: network))
        XCTAssertEqual(network.int, domain.int)
        XCTAssertEqual(network.str, domain.str)
        XCTAssertEqual(network.user.id, domain.user.id)
    }
}

struct UserNetwork: Decodable {
    let id: Int
}

struct UserDomain: Decodable {
    let id: Int
}

struct Network: Decodable {
    let int: Int?
    let str: String?
    let user: UserNetwork
}


struct Domain: Decodable {
    let int: Int
    let str: String?
    let user: UserDomain
}

// Nested?
// optional wrapping when A is nonoptional but B is optional
// Array?
// Dictionary?
// Generic?
