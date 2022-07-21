import Foundation

struct MirrorDecoder<Value>: Decoder {
    var userInfo: [CodingUserInfoKey : Any] = [:]
    var codingPath: [CodingKey] = []
    var value: Value

    init(value: Value, codingPath: [CodingKey] = []) {
        self.value = value
        self.codingPath = codingPath
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
//        print(value)
        return KeyedDecodingContainer(MirrorKeyedDecodingContainer(value: value))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        MirrorSingleValue(codingPath: codingPath, value: value)
    }
}

struct MirrorSingleValue<Value>: SingleValueDecodingContainer {
    var codingPath: [CodingKey] = []
    let value: Value

    func decodeNil() -> Bool {
        true
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
//        print(type, value, codingPath)
        return value as! T
    }
}

struct MirrorKeyedDecodingContainer<Key, Value>: KeyedDecodingContainerProtocol where Key: CodingKey {
    var codingPath: [CodingKey] = []

    var allKeys: [Key] = []

    let value: Value

    func contains(_ key: Key) -> Bool {
        let m = Mirror(reflecting: value)
        let child = m.children.first(where: { child in
            child.label == key.stringValue
        })
        return child != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        let m = Mirror(reflecting: value)
        let child = m.children.first(where: { child in
            child.label == key.stringValue
        })
        return child != nil
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let m = Mirror(reflecting: value)
        let child = m.children.first(where: { child in
            child.label == key.stringValue
        })

        return try T.init(from: MirrorDecoder(value: child!.value))
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
