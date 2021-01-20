//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 16/01/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: - IBActions
    @IBAction func registrerButtonAction() {
        //permite cerrar el teclado
        view.endEditing(true)
        performRegistrer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        septUpUI()
    }
    
    
    //MARK: - Private Methods
    private func septUpUI() {
        registerButton.layer.cornerRadius = 18
    }
    
    private func performRegistrer() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Advertencia", subtitle: "Debes ingresar un correo válido!", style: .warning).show()
            return
        }
        
        guard let password = passwordTextfield.text, !password.isEmpty else {
            NotificationBanner(title: "Advertencia", subtitle: "Debes ingresar una contraseña!", style: .warning).show()
            return
        }
        
        guard let name = passwordTextfield.text, !name.isEmpty else {
            NotificationBanner(title: "Advertencia", subtitle: "Debes ingresar un nombre!", style: .warning).show()
            return
        }
        
        //permite ir navegar entre segue
//        performSegue(withIdentifier: "showHome", sender: nil)
        
        //show progress
        SVProgressHUD.show()
        
        //request
        let request = ResgisterRequest(email: email, password: password, names: name)
        
        SN.post(endpoint: Endpoints.register, model: request) { (response: SNResultWithEntity<RegisterResponse, ErrorResponse>) in
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let user):
                self.performSegue(withIdentifier: "showHome", sender: nil)
                // se envia el token en el framawork para que quede almacenado
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
                
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
                
            }
        }
    }
}
