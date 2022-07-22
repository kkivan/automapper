import XCTest
@testable import automapper

final class AutomapperTests: XCTestCase {

    func testStruct() throws {
        let from = From(id: 1, str: "str")
        let to = try To.from(from)
        assert(from, to)
    }

    func testNestedStruct() throws {
        let from = NestedFrom(from: From(id: 1, str: "str"))
        let to = try NestedTo.from(from)
        assert(from.from, to.from)
    }

    func testStructWithOptionalToOptional() throws {
        let from = FromWithOpt(str: "str")
        let to = try ToWithOpt.from(from)
        XCTAssertEqual(from.str, to.str)
    }

    func testArray() throws {
        let from = ToArray(arr: [1, 2, 3])
        let to = try FromArray.from(from)
        XCTAssertEqual(from.arr, to.arr)
    }

    func testDictionaryInStruct() throws {
        let from = ToDict(dict: ["KEY": "VALUE",
                                 "KEY2": "VALUE2"])
        let to = try FromDict.from(from)
        XCTAssertEqual(from.dict, to.dict)
    }

    func testInt() throws {
        let from = 1
        let to = try Int.from(from)
        XCTAssertEqual(from, to)
    }

    func testDictionary() throws {
        let from =  ["KEY": "VALUE",
                     "KEY2": "VALUE2"]
        let to = try [String: String].from(from)
        XCTAssertEqual(from, to)
    }

    func testDictionaryWithStructs() throws {
        let from =  ["KEY": From(id: 1, str: "str1"),
                     "KEY2": From(id: 2, str: "str2")]
        let to = try [String: To].from(from)
        XCTAssertFalse(to.isEmpty)
        from.forEach { key, value in
            assert(value, to[key])
        }
    }

    func testArrayOfStructs() throws {
        let from =  [From(id: 1, str: "str1"),
                     From(id: 2, str: "str2")]
        let to = try [To].from(from)
        XCTAssertFalse(to.isEmpty)
        zip(from, to).forEach(assert)
    }

    func testThatNoFieldMapsToNil() throws {
        struct From {
            let id: Int
        }

        struct To: Decodable {
            let id: Int
            let str: String?
        }

        let from = From(id: 1)
        let to = try To.from(from)
        XCTAssertEqual(from.id, to.id)
        XCTAssertNil(to.str)
    }
}

func assert(_ from: From, _ to: To?) {
    XCTAssertEqual(from.id, to?.id)
    XCTAssertEqual(from.str, to?.str)
}

struct ToDict {
    let dict: [String: String]
}

struct FromDict: Decodable {
    let dict: [String: String]
}

struct ToArray {
    let arr: [Int]
}

struct FromArray: Decodable {
    let arr: [Int]
}

struct FromWithOpt {
    let str: String?
}
struct ToWithOpt: Decodable {
    let str: String?
}

struct NestedFrom {
    let from: From
}

struct NestedTo: Decodable {
    let from: To
}

struct From {
    let id: Int
    let str: String
}

struct To: Decodable {
    let id: Int
    let str: String
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
    let user: UserDomain?
}
