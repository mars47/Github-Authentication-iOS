//
//  AppDelegate.swift
//  GitHubLoginFromScratch
//
//  Created by Omar Amoako on 20/11/18.
//  Copyright © 2018 Omar Amoako. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        guard url.scheme == "githubloginfromscratch" else {return false} //Callback looks for this string
        
        url.absoluteString
        
        
        let clientId = "f357c0f9c46f687be6c0"
        let clientSecret = "724d611db9f892964b596ccf072f4c7b03c5e27d"
        let iosTeamID = "2330724"
        let bbcID = "828722"
        
        //, url.host == "example.com"
        if url != nil {
            
            //1. stores the access token from open URL 'code' parameter,
            //2. creates a new post request and uses the access token as one of the parameters
            //3. web request begins, the post request data that is returned is converted to a dictionary
            //4. the access token is extracted and ready to be used for API calls.
            //   - it must be put in the request header of any call
            
            
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
                        "code" : code,
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
        let urlString = "https://api.github.com/repos/bbc/mdt-ios-me/contents/Podfile.lock"
        
        if let url = NSURL(string: urlString) {
            
            let req = NSMutableURLRequest(url: url as URL)
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            req.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
//            req.addValue("user%20repo", forHTTPHeaderField: "Scopes")
                                   // "scope":
            
            let task = URLSession.shared.dataTask(with: req as URLRequest) { data, response, error in
                
                if let data = data {
                    if let content = String(data: data, encoding: String.Encoding.utf8) {
                        
                        DispatchQueue.main.async {
                            print(content)
                            //self.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    
    
}

