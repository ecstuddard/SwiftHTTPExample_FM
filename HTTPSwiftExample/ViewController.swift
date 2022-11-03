//
//  ViewController.swift
//  HTTPSwiftExample
//
//  Created by Eric Larson on 3/30/15.
//  Copyright (c) 2015 Eric Larson. All rights reserved.
//

// This exampe is meant to be run with the python example:
//              tornado_example.py 
//              from the course GitHub repository: tornado_bare, branch sklearn_example


// if you do not know your local sharing server name try:
//    ifconfig |grep inet   
// to see what your public facing IP address is, the ip address can be used here
//let SERVER_URL = "http://erics-macbook-pro.local:8000" // change this for your server name!!!


let SERVER_URL = "http://10.8.116.92:8000" // change this for your server name!!!

import UIKit

class ViewController: UIViewController, URLSessionDelegate {
    
    var session = URLSession()
    var floatValue = 5.5
    let operationQueue = OperationQueue()
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var ipTextField: UITextField!
    
    let animation = CATransition()
    
    //MARK: Setup Session and Animation 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // setup URL Session
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
        
        // create reusable animation
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionReveal
        animation.duration = 0.5
        
        
    }

    //MARK: Get Request
    @IBAction func sendGetRequest(_ sender: AnyObject) {
        // create a GET request and get the reponse back as NSData
        guard let serverURL = getServerURL(endpoint: "/GetExample", query: "?arg=\(self.floatValue)") else { return }
                var request = URLRequest(url: serverURL)
                sendRequest(request: request)
        
    }
    
    //MARK: Post Request, args in url
    @IBAction func sendPostRequest(_ sender: AnyObject) {
        guard let serverURL = getServerURL(endpoint: "/DoPost") else { return }
                var request = URLRequest(url: serverURL)
                
                let requestBody: Data? = "arg1=\(self.floatValue)".data(using: .utf8)
                request.httpMethod = "POST"
                request.httpBody = requestBody
                sendRequest(request: request)
        
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                // TODO: handle error!
                print("Response:\n%@",response!)
                let strData = String(data:data!, encoding:String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                // show to screen
                DispatchQueue.main.async{
                    self.mainTextView.layer.add(self.animation, forKey: nil)
                    self.mainTextView.text = "\(response!) \n==================\n\(strData!)"
                }
        })
        
        dataTask.resume() // start the task
    
    }
    
    //MARK: Post Request, args in request body (preferred)
    @IBAction func sendPostWithJsonInBody(_ sender: AnyObject) {
        guard let serverURL = getServerURL(endpoint: "/PostWithJson") else { return }
               var request = URLRequest(url: serverURL)
               
               let jsonUpload: NSDictionary = ["arg": [3.2, self.floatValue * 2, self.floatValue]]
               request.httpMethod = "POST"
               request.httpBody = convertDictionaryToData(with: jsonUpload)
               sendRequest(request: request)

        
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
                        completionHandler:{(data, response, error) in
                            print("Response:\n%@",response!)
                            let jsonDictionary = self.convertDataToDictionary(with: data)
                            
                            DispatchQueue.main.async{
                                self.mainTextView.layer.add(self.animation, forKey: nil)
                                self.mainTextView.text = "\(response!) \n==================\n\(jsonDictionary)"
                            }
        })
        
        postTask.resume() // start the task
        
    }
    //MARK: Helper to get URL from Text Field
    private func getServerURL(endpoint: String, query: String = "") -> URL? {
        guard let ipAddress = ipTextField.text, !ipAddress.isEmpty else { return nil }
        return URL(string: "http://\(ipAddress):8000\(endpoint)\(query)")
        }
    
    //MARK: JSON Conversion Functions
    func convertDictionaryToData(with jsonUpload:NSDictionary) -> Data?{
        do { // try to make JSON and deal with errors using do/catch block
            let requestBody = try JSONSerialization.data(withJSONObject: jsonUpload, options:JSONSerialization.WritingOptions.prettyPrinted)
            return requestBody
        } catch {
            print("json error: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: Send Request
    private func sendRequest(request: URLRequest) {
        let dataTask = self.session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Response:\n\(response!)")
                
                // Convert to string for display
            let strData = String(data: data, encoding: .utf8) ?? "No data"
            DispatchQueue.main.async {
                self.mainTextView.layer.add(self.animation, forKey: nil)
                self.mainTextView.text = "\(response!) \n==================\n\(strData)"
            }
        }
        dataTask.resume()
    }
    
    func convertDataToDictionary(with data:Data?)->NSDictionary{
        do { // try to parse JSON and deal with errors using do/catch block
            let jsonDictionary: NSDictionary =
                try JSONSerialization.jsonObject(with: data!,
                                              options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            return jsonDictionary
            
        } catch {
            print("json error: \(error.localizedDescription)")
            return NSDictionary() // just return empty
        }
    }
    

}





