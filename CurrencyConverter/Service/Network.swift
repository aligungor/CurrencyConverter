import Foundation

protocol Network {
    func performRequest<T: Decodable>(
        endpoint: Endpoint,
        decodingType: T.Type
    ) async throws -> T
}

final class DefaultNetwork: Network {
    func performRequest<T: Decodable>(
        endpoint: Endpoint,
        decodingType: T.Type
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        // All requests are GET. An enum could be implemented when there are more method types
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)

        // Ensure the response is valid HTTP response with status code 200-299
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        // Decode the response into the given type
        return try JSONDecoder().decode(T.self, from: data)
    }
}
