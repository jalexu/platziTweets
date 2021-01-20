//
//  WelcomeViewController.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 16/01/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        septUpUI()
    }
    
    private func septUpUI() {
        loginButton.layer.cornerRadius = 18
    }

}
