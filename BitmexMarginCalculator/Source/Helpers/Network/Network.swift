//
//  Network.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 10/10/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

class NetworkRequestLimiter {
    static let shared = NetworkRequestLimiter()
    var counter = 0
    var maxRequests = 29
    
    func countRequest() -> Bool {
        if counter >= maxRequests {
            return false
        } else {
            counter += 1
            DispatchQueue.global().asyncAfter(deadline: .now() + 60) {
                self.counter -= 1
            }
            return true
        }
    }
}

enum Result<T> {
    case success(T)
    case failure(NSError)
}

class ServiceLayer {
    
    func request<T: Codable>(router: Router, completion: @escaping (Result<T>) -> Void) {
        
        if NetworkRequestLimiter.shared.countRequest() {
            var components = URLComponents()
            components.scheme = router.scheme
            components.host = router.host
            components.path = router.path
            components.queryItems = router.parameters
            
            guard let url = components.url else { return }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = router.method
            
            let session = URLSession(configuration: .default)
            let dataTask = session.dataTask(with: urlRequest) { data, response, error in
                
                guard error == nil else {
                    completion(.failure(error! as NSError))
                    return
                }
                guard response != nil else {
                    return
                }
                guard let data = data else {
                    return
                }
                
                do {
                    let responseObject = try JSONDecoder().decode(T.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(.success(responseObject))
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            dataTask.resume()
        } else {
            let error = NSError(domain: "Too many requests", code: -1000, userInfo: nil)
            completion(.failure(error))
        }
    }
}
