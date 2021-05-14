//
//  APICaller.swift
//  Dogecoin
//
//  Created by Anthony Kim on 5/7/21.
//

import Foundation

final class APICaller {
    static let shared = APICaller() //singleton
    
    private init() {}
    
    struct Constants {
        static let apikey = "8bccdb3f-7970-4cd0-8896-96e7500a02cd"
        static let apikeyHeader = "X-CMC_PRO_API_KEY"
        static let baseUrl = "https://pro-api.coinmarketcap.com/v1/"
        static let doge = "dogecoin"
        static let endpoint = "cryptocurrency/quotes/latest"
    }
    
    enum APIError: Error {
        case invalidUrl
    }
    
    public func getDogeCoinData(completion: @escaping (Result<DogeCoinData, Error>) -> Void) {
        guard let url = URL(string: Constants.baseUrl + Constants.endpoint + "?slug=" + Constants.doge) else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        print("API URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.setValue(Constants.apikey, forHTTPHeaderField: Constants.apikeyHeader)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print("\n\n \(json)")
                
                let response = try JSONDecoder().decode(APIResponse.self, from: data)
//                print("\n\nAPI Result: \(response)\n\n")
                guard let dogeCoinData = response.data.values.first else {
                    return
                }
                
                completion(.success(dogeCoinData))
                
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
