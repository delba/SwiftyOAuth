//
// HTTP.swift
//
// Copyright (c) 2016 Damien (http://delba.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

typealias JSON = [String: Any]

struct HTTP {
    static func POST(_ URL: Foundation.URL, parameters: [String: String], completion: @escaping (Result<JSON>) -> Void) {
        var request = URLRequest(url: URL)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpMethod = "POST"
        
        request.httpBody = parameters.map { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error as NSError))
                return
            }
            
            guard let data = data else {
                // TODO better error than that...
                let error = NSError(domain: "No data received", code: 42, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let dictionary = object as? JSON {
                    completion(.success(dictionary))
                } else {
                    let error = NSError(domain: "Cannot initialize token", code: 42, userInfo: nil)
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error as NSError))
            }
        }
        
        task.resume()
    }
}
