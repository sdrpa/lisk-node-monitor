// Created by Sinisa Drpa on 2/7/18.

import Foundation

final class Server {
   let address: String

   var error: Error?
   var syncing: Bool?
   var height: Int?
   var broadhash: String?
   var consensus: Int?

   private var basePath: String {
      let port = String(7000)
      let path = "http://" + address + ":" + port + "/api"
      return path
   }

   init(address: String) {
      self.address = address
   }
}

extension Server: CustomStringConvertible {
   var description: String {
      return "\(address)"
      //return "\(address), height: \(height), consensus: \(consensus)"
   }
}

extension Server {
   func getStatus(completion: @escaping () -> Void) {
      struct Result: Decodable {
         let success: Bool
         let syncing: Bool
         let height: Int
         let broadhash: String
         let consensus: Int
      }

      func decode(result data: Data) throws -> Result? {
         let decoder = JSONDecoder()
         do {
            let result = try decoder.decode(Result.self, from: data)
            return result
         } catch let e {
            throw e
         }
      }

      let path = basePath + "/loader/status/sync"
      guard let url = URL(string: path) else {
         fatalError()
      }
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.timeoutInterval = 5

      let session = URLSession(configuration: .default)
      let dataTask = session.dataTask(with: request) { [weak self] data, response, error in
         defer {
            completion()
         }
         if let e = error {
            self?.error = e
         } else if let data = data,
            let response = response as? HTTPURLResponse,
            response.statusCode == 200 {
            do {
               let result = try decode(result: data)
               self?.error = nil
               self?.syncing = result?.syncing
               self?.height = result?.height
               self?.broadhash = result?.broadhash
               self?.consensus = result?.consensus
            } catch let e {
               self?.error = e
            }
         }
      }
      dataTask.resume()
   }
}
