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

typealias JSON = [String: AnyObject]

struct HTTP {
    static func POST(URL: NSURL, parameters: [String: String], completion: Result<JSON, NSError> -> Void) {
        let request = NSMutableURLRequest(URL: URL)
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        request.HTTPMethod = "POST"
        
        request.HTTPBody = parameters.map { "\($0)=\($1)" }
            .joinWithSeparator("&")
            .dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completion(.Failure(error))
                return
            }
            
            guard let data = data else {
                // TODO better error than that...
                let error = NSError(domain: "No data received", code: 42, userInfo: nil)
                completion(.Failure(error))
                return
            }
            
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                if let dictionary = object as? JSON {
                    completion(.Success(dictionary))
                } else {
                    let error = NSError(domain: "Cannot initialize token", code: 42, userInfo: nil)
                    completion(.Failure(error))
                }
            } catch {
                completion(.Failure(error as NSError))
            }
        }
        
        task.resume()
    }
}
