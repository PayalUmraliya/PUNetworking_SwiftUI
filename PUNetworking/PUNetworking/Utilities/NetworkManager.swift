//
//  NetworkManager.swift
//  PUNetworking
import Foundation
import Combine

class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {
    }
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://picsum.photos"
    private let baseURLpost = "https://fakestoreapi.com"
    
    func makeURL(with path: String,reqType : String = "GET") -> String {
        return reqType == "GET" ? (String(self.baseURL) + path) : (String(self.baseURLpost) + path)
    }
    func getData<T: Decodable>(url: String, type: T.Type) -> Future<[T], Error> {
        return Future<[T], Error> { [weak self] promise in
            let prepareurl = self?.makeURL(with: url)
            guard let self = self, let url = URL(string: prepareurl ?? "") else {
                return promise(.failure(NetworkAPIError.invalidURL))
            }
            print("URL is \(url.absoluteString)")
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkAPIError.responseError
                    }
                    return data
                }
                .decode(type: [T].self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            promise(.failure(decodingError))
                        case let apiError as NetworkAPIError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(NetworkAPIError.unknown))
                        }
                    }
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.cancellables)
        }
    }
    
    func postData<T: Encodable, U: Decodable>(
            urlString: String,
            body: T,
            responseType: U.Type
        ) -> AnyPublisher<U, Error> {
            let prepareurl = self.makeURL(with: urlString,reqType: "POST")
            guard let url = URL(string: prepareurl) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: U.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
}
enum NetworkAPIError: Error {
    case invalidURL
    case responseError
    case unknown
}

extension NetworkAPIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}

enum AppViewState {
    case loading
    case error(message: String)
    case dataLoaded
}
