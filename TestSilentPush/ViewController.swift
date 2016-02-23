//
//  ViewController.swift
//  TestSilentPush
//
//  Created by Guillaume Bonnin on 18/02/2016.
//  Copyright © 2016 Smart&Soft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var ibLabelCountSilentPush: UILabel!
    @IBOutlet weak var ibLabelWeather: UILabel!
    @IBOutlet weak var ibLabelUser: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateView()
        //self.updateUser()
    }

    @IBAction func didTouchButtonRefresh(sender: AnyObject) {
        self.updateView()
    }
    
    func updateView() {
        ibLabelCountSilentPush.text = String(NSUserDefaults.standardUserDefaults().integerForKey(Constants.CountSilentPushSettings))
        
        let userName = NSUserDefaults.standardUserDefaults().objectForKey(Constants.CurrentUserName)
        ibLabelUser.text = userName as? String ?? "User not defined"
        
        let weather = NSUserDefaults.standardUserDefaults().objectForKey(Constants.CurrentWeather)
        ibLabelWeather.text = weather as? String ?? "Undefined"
    }
    
    func fetchWeather(completion: () -> Void) {
        RemoteServices.fetchWeather { (result) -> Void in
            if let weather = result as? String where weather.characters.count > 0 {
                NSUserDefaults.standardUserDefaults().setObject(result, forKey: Constants.CurrentWeather)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            self.updateView()
            completion()
        }
    }
    
    func fetchUser(completion: () -> Void) {
        RemoteServices.fetchRandomUser { (result) -> Void in
            if let userName = result as? String where userName.characters.count > 0 {
                NSUserDefaults.standardUserDefaults().setObject(result, forKey: Constants.CurrentUserName)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            self.updateView()
            completion()
        }
    }
}

