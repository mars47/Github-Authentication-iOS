//
//  SignInViewController.swift
//  GitHubLoginFromScratch
//
//  Created by Omar Amoako on 20/11/18.
//  Copyright © 2018 Omar Amoako. All rights reserved.
// http://swift.tnantoka.com/2015/11/13/github-login-from-scratch.html

import UIKit
import SafariServices


class SignInViewController: UIViewController, UIWebViewDelegate {

    let clientId = "f357c0f9c46f687be6c0"
    let clientSecret = "724d611db9f892964b596ccf072f4c7b03c5e27d"

    override func viewDidLoad() {
        super.viewDidLoad()
        


        // Do any additional setup after loading the view.
//        if let webview = view as? UIWebView {
//            webview.delegate = self
//            let urlString = "https://github.com/login/oauth/authorize?client_id=\(clientId)"
//            if let url = NSURL(string: urlString) {
//                let req = NSURLRequest(url: url as URL)
//                webview.loadRequest(req as URLRequest)
//
//            }
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(clientId)&scope=user%20repo"
        let url = URL(string: urlString)!
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UIWebViewDelegate
    
   // func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {return false}
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        //, url.host == "example.com"
        if let url = request.url {
            if let code = url.query?.components(separatedBy: "code=").last {
                let urlString = "https://github.com/login/oauth/access_token"
                if let tokenUrl = NSURL(string: urlString) {
                    let req = NSMutableURLRequest(url: tokenUrl as URL)
                    req.httpMethod = "POST"
                    req.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.addValue("application/json", forHTTPHeaderField: "Accept")
                    let params = [
                        "client_id" : clientId,
                        "client_secret" : clientSecret,
                        "code" : code
                    ]
                    req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
                    let task = URLSession.shared.dataTask(with: req as URLRequest) { data, response, error in
                        
                        if let data = data {
                            do {
                                if let content = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    if let accessToken = content["access_token"] as? String {
                                        self.getUser(accessToken: accessToken)
                                    }
                                }
                            } catch {}
                        }
                    }
                    task.resume()
                }
            }
            return false
        }
        return true
    }
    
    func getUser(accessToken: String) {
        let urlString = "https://api.github.com/user"
        
        if let url = NSURL(string: urlString) {
           
            let req = NSMutableURLRequest(url: url as URL)
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            req.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
            
            
            let task = URLSession.shared.dataTask(with: req as URLRequest) { data, response, error in
                
                if let data = data {
                    if let content = String(data: data, encoding: String.Encoding.utf8) {
                        
                        DispatchQueue.main.async {
                            print(content)
                            self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}
