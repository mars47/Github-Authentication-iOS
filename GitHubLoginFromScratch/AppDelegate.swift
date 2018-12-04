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
    
    var request: URLRequest! = nil
    
    
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
    
    //How this works
    
    //In the last stage of authentication, Github will append a code to your authization callback url which is set in github app settings
    //it will look something like ---> "githubloginfromscratch://callback?code=bea40cde68b19670ca3a"
    //when the callback url is invoked inside the browser it will open the app, and the appdelegate method bellow is called
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        guard url.scheme == "githubloginfromscratch" else {return false} //Checkes url scheme of the callback
        
        
        let clientId = "f357c0f9c46f687be6c0"
        let clientSecret = "724d611db9f892964b596ccf072f4c7b03c5e27d"
        let iosTeamID = "2330724"
        let bbcID = "828722"
        
        //, url.host == "example.com"
        if url != nil {
            
            //1. 'code' is extracted from URL query string and is stored inside code variable
            //2. a post request is then created and the 'code' is sent back to github as one of the parameters
            //3. once the post request finishes, the request repsonse is serialised as a JSON object and converted to a dictionary ('content')
            //4. 'content' has a key that contains the access token needed for API calls. This is stored inside a variable ready for use.
            //   - 'accessToken' variable must be put inside the request header of any API call
            
            
            if let code = url.query?.components(separatedBy: "code=").last { //1.
                let urlString = "https://github.com/login/oauth/access_token"
                if let tokenUrl = NSURL(string: urlString) {
                    let req = NSMutableURLRequest(url: tokenUrl as URL) //2.
                    req.httpMethod = "POST"
                    req.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.addValue("application/json", forHTTPHeaderField: "Accept")
                    let params = [
                        "client_id" : clientId,
                        "client_secret" : clientSecret,
                        "code" : code, //2.
                    ]
                    req.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
                    
                    let task = URLSession.shared.dataTask(with: req as URLRequest) { data, response, error in //3.
                        
                        if let data = data {
                            do {
                                if let content = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] { //3.
                                    if let accessToken = content["access_token"] as? String { //4.
                                        self.getPodlockMeta(accessToken: accessToken)
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
    
    
    func getPodlockMeta(accessToken: String) {
        let urlString = "https://api.github.com/repos/bbc/mdt-ios-me/contents/Podfile.lock"
        
        if let url = NSURL(string: urlString) {
            
            let req = NSMutableURLRequest(url: url as URL)
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            req.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: req as URLRequest) { data, response, error in
                
                if let data = data {
                    do {
                        if let content = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                            let downloadUrl = content["download_url"] as! String;
                            var request = URLRequest(url: URL(string: downloadUrl)!)
                            request.addValue("application/json", forHTTPHeaderField: "Accept")
                            request.addValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
                            self.downloadPodlockFileContents(downloadUrl: request)
                            
                            //print(content)
                            //                        DispatchQueue.main.async {
                            //                            //self.presentingViewController?.dismiss(animated: true, completion: nil)
                            //                        }
                        }
                    } catch { }
                }
            }
            task.resume()
        }
    }
    
    
    func downloadPodlockFileContents(downloadUrl: URLRequest) {
        
        let task = URLSession.shared.dataTask(with: downloadUrl) { data, response, error in
            
            if let data = data {
                
                if var content = String(data: data, encoding: String.Encoding.utf8) {
                
                    //content = content.replacingOccurrences(of: "\n", with: "[]")
                    print(content)

                }
                
            }
        }
        task.resume()
        
        
        
    }
    
    
}

