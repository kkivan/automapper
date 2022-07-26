import Foundation

public extension Decodable {
    static func from<T>(_ value: T) throws -> Self where T: Encodable {
        let json = try JSONEncoder().encode(value)
        return try JSONDecoder().decode(Self.self, from: json)
    }
}
