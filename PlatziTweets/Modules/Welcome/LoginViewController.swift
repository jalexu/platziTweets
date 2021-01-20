//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 16/01/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD



// Extension para seleccionar color cuando sea modo oscuro

extension UIColor {
    static let custumGreen: UIColor = {
        if #available(iOS 13.0, *){
            return UIColor { (trait: UITraitCollection) -> UIColor in
                if trait.userInterfaceStyle == .dark{
                    return .white
                } else {
                    return .green
                }
            }
        } else {
            return .green
        }
        
    }()
}

class LoginViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    //MARK: - IBActions
    @IBAction func loginButtonAction() {
        view.endEditing(true)
        performLogin()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        septUpUI()
    }
    
    
    //MARK: - Private Methods
    private func septUpUI() {
        loginButton.layer.cornerRadius = 18
        loginButton.backgroundColor = UIColor.custumGreen
    }
    
    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Advertencia", subtitle: "Debes ingresar un correo válido!", style: .warning).show()
            return
        }
        
        guard let password = passwordTextfield.text, !password.isEmpty else {
            NotificationBanner(title: "Advertencia", subtitle: "Debes ingresar una contraseña!", style: .warning).show()
            return
        }
        
        //permite ir navegar entre segue
        //performSegue(withIdentifier: "showHome", sender: nil)
        
        //iniciar carga
        SVProgressHUD.show()
        
        //crear request
        let request = LoginRequest(email: email, password: password)
        
        //llamar a libreria de red
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            //finalizar carga
            SVProgressHUD.dismiss()
            switch response {
            case .success(let user):
            //sucede lo bueno
            //permite ir navegar entre segue
                self.performSegue(withIdentifier: "showHome", sender: nil)
                // se envia el token en el framawork para que quede almacenado
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
            
            
            case .error(let error):
                //pasa lo malo
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            
            case .errorResult(let entity):
                //cuando llegan del backedn
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
            }
        }
    }
    
    
}
