//
//  WebService.swift
//  Homework24
//
//  Created by Nini Bardavelidze on 11.05.24.
//

import Foundation
public enum NetworkError: Error {
    case decodeError
    case wrongResponse
    case wrongStatusCode(code: Int)
}
public class NetworkService {
    public static let shared = NetworkService()
    public init() {}
    public func getData<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.wrongResponse))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                completion(.failure(NetworkError.wrongStatusCode(code: (response as? HTTPURLResponse)?.statusCode ?? -1)))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.decodeError))
                return
            }
            do {
                let decoder = JSONDecoder()
                let object = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(object))
                }
            } catch {
                completion(.failure(NetworkError.decodeError))
            }
        }.resume()
    }
}
