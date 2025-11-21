import Foundation

public actor CoffeeAPIService: CoffeeAPIServiceProtocol {
    private let urlSession: URLSession
    private let baseURL = "https://coffee.alexflipnote.dev"

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func fetchRandomCoffee() async throws -> CoffeeAPIResponse {
        guard let url = URL(string: "\(baseURL)/random.json") else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            do {
                return try decoder.decode(CoffeeAPIResponse.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }

    public func downloadImage(from url: URL) async throws -> Data {
        do {
            let (data, response) = try await urlSession.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            guard !data.isEmpty else {
                throw NetworkError.noData
            }

            return data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
