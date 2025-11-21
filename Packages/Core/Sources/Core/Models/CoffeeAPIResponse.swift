import Foundation

public struct CoffeeAPIResponse: Codable, Sendable {
    public let file: String

    public init(file: String) {
        self.file = file
    }
}
