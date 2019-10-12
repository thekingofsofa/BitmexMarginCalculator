//
//  Network.swift
//  BitmexMarginCalculator
//
//  Created by Иван Барабанщиков on 10/10/19.
//  Copyright © 2019 Ivan Barabanshchykov. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}

class ServiceLayer {
    
    func request<T: Codable>(router: Router, completion: @escaping (Result<T>) -> Void) {
        
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
            // 5.
            
            guard error == nil else {
                completion(.failure(error!))
                print(error?.localizedDescription)
                return
            }
            guard response != nil else {
                return
            }
            guard let data = data else {
                return
            }
            
            let responseObject = try! JSONDecoder().decode(T.self, from: data)
            
            DispatchQueue.main.async {
                completion(.success(responseObject))
            }
        }
        dataTask.resume()
    }
}
