import Foundation

struct NotImplemented<T>: Error {
    let location: String
    init(file: StaticString = #file, line: Int = #line) {
        self.location = "\(file):\(line)"
    }
}

struct MirrorDecoder<Value>: Decoder {
    var userInfo: [CodingUserInfoKey : Any] = [:]
    var codingPath: [CodingKey] = []
    var value: Value

    init(value: Value, codingPath: [CodingKey] = []) {
        self.value = value
        self.codingPath = codingPath
    }

    // container with keys, eg struct or dictionary
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {

        if let dict = value as? [String: Any] {
            return KeyedDecodingContainer(DictionaryDecodingContrainer(dict: dict))
        }
        return KeyedDecodingContainer(MirrorKeyedDecodingContainer(value: value))
    }

    // container without keys, eg array [1,2,3]
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {

        let m = Mirror(reflecting: value)
        let children = m.children.map(\.value)

        return MirrorUnkeyedDecodingContainer(values: children)
    }
    // single value, eg 1 or "str"
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        MirrorSingleValue(codingPath: codingPath, value: value)
    }
}

struct DictionaryDecodingContrainer<Key, Value>: KeyedDecodingContainerProtocol where Key: CodingKey  {

    func decodeNil(forKey key: Key) throws -> Bool {
        fatalError()
    }

    var codingPath: [CodingKey] = []

    var allKeys: [Key] { dict.keys.compactMap { Key(stringValue: $0) } }

    let dict: [String: Value]

    func contains(_ key: Key) -> Bool {
        fatalError()
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        try T.init(from: MirrorDecoder(value: dict[key.stringValue]!))
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError()
    }
}

struct MirrorUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    var values: [Any]

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try T.init(from: MirrorDecoder(value: values.removeFirst()))
    }

    var codingPath: [CodingKey] = []

    var count: Int? { values.count }

    var isAtEnd: Bool { currentIndex >= count ?? 0 }

    var currentIndex: Int = 0

    mutating func decodeNil() throws -> Bool {
        fatalError()
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    mutating func superDecoder() throws -> Decoder {
        fatalError()
    }
}

struct MirrorSingleValue<Value>: SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []
    let value: Value

    func decodeNil() -> Bool {
        true
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return value as! T
    }
}

struct MirrorKeyedDecodingContainer<Key, Value>: KeyedDecodingContainerProtocol where Key: CodingKey {
    var codingPath: [CodingKey] = []

    var allKeys: [Key] = []

    let value: Value

    init(value: Value) {
        self.value = value
    }

    func childFor(_ key: Key) -> Any? {
        let m = Mirror(reflecting: value)
        let child = m.children.first(where: { child in
            child.label == key.stringValue
        })
        return child?.value
    }

    func contains(_ key: Key) -> Bool {
        childFor(key) != nil 
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        childFor(key) == nil
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let child = childFor(key)

        return try T.init(from: MirrorDecoder(value: child!))
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable, Key: Hashable {
        fatalError()
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError()
    }
}
