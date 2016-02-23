//
//  RemoteServices.swift
//  TestSilentPush
//
//  Created by Guillaume Bonnin on 19/02/2016.
//  Copyright © 2016 Smart&Soft. All rights reserved.
//

import Foundation
import Alamofire

struct RemoteServices {
    
    private static let weatherServiceURL = "http://www.smartnsoft.com/shared/weather/index.php?city=paris&forecasts=7"
    
    private static let randomUserURL = "http://randomuser.me/api/"
    
    static func fetchWeather(completion: (AnyObject?) -> Void) {
        Alamofire.request(.GET, weatherServiceURL)
            .validate()
            .responseJSON { response in
                if let JSON = response.result.value as? [String: AnyObject],
                    forecasts = JSON["forecasts"] as? [[String: AnyObject]] where forecasts.count >= 1 {
                        let currentForecast = forecasts[NSUserDefaults.standardUserDefaults().integerForKey(Constants.CountSilentPushSettings) % forecasts.count]
                        completion(currentForecast["type"])
                        return
                }
                completion(nil)
        }
    }
    
    static func fetchRandomUser(completion: (AnyObject?) -> Void) {
        Alamofire.request(.GET, randomUserURL)
            .validate()
            .responseJSON { response in
                if let JSON = response.result.value as? [String: AnyObject],
                    results = JSON["results"] as? [[String: AnyObject]],
                    currentUser = results[0]["user"] as? [String: AnyObject],
                    name = currentUser["name"] as? [String: AnyObject],
                    firstName = name["first"] as? String,
                    lastName = name["last"] as? String {
                        completion(firstName + " " + lastName)
                        return
                }
                completion(nil)
        }
    }
    
}