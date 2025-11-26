import Foundation

/// Response model for the Coffee API's random coffee endpoint.
///
/// This model represents the JSON response from the `/random.json` endpoint,
/// which returns a URL to a random coffee image.
///
/// Example JSON:
/// ```json
/// {
///     "file": "https://coffee.alexflipnote.dev/random_image.jpg"
/// }
/// ```
public struct CoffeeResponse: Codable, Sendable {
    /// The URL string of the random coffee image.
    public let file: String

    /// Creates a new coffee response.
    ///
    /// - Parameter file: The URL string of the coffee image.
    public init(file: String) {
        self.file = file
    }

    /// Converts the file string to a URL, if valid.
    public var imageURL: URL? {
        URL(string: file)
    }
}
