//
//  HomeViewController.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 17/01/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD
import AVKit

class HomeViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createPostButton: UIButton!
    
    //MARK: - Properties
    private let cellId = "TweetableViewCell"
    private var dataSource = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
    }
    
    private func setupUI(){
        //1. Asignar celda
        //2. Registar celdas
        tableView.delegate = self
        tableView.dataSource = self
        createPostButton.layer.cornerRadius = 4
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
        
    }
    
    private func getPosts() {
        SVProgressHUD.show()
        
        // Consumir servicio
        SN.get(endpoint: Endpoints.getPosts) { (response: SNResultWithEntity<[Post], ErrorResponse>) in
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let post):
                self.dataSource = post
                self.tableView.reloadData()
                
            case .error(let error):
                //pasa lo malo
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            
            case .errorResult(let entity):
                //cuando llegan del backedn
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
            }
        }
    }
    
    
    private func deletePostAt(indexPath: IndexPath) {
        SVProgressHUD.show()
        
        //obtener el id del post
        let postId = dataSource[indexPath.row].id
        
        
        //crear el enpodint para borrar tweet
        let enpoint = Endpoints.delete + postId
        
        SN.delete(endpoint: enpoint) { (response: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            SVProgressHUD.dismiss()
            
            switch response {
            case .success:
                //1.Borrarel post del dataSource
                self.dataSource.remove(at: indexPath.row)
            // 2. Borrar el post de la celda
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
                
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
                
            }
        }
        
    }
    

}

//MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Borrar") { (_, _) in
            //aquí borramos el tweet
            self.deletePostAt(indexPath: indexPath)
            
        }
        
        return [deleteAction]
    }
}


//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        if let createCell = cell as? TweetableViewCell {
            //se confirufra la celda
            createCell.septupCellWiht(post: dataSource[indexPath.row])
            createCell.needToShowVideo = { url in
                //aqui se abre un viewController
                
                //reproducir video
                let avPlayer = AVPlayer(url: url)
                //levantar pantalla de reproductor
                let avPlayerController = AVPlayerViewController()
                avPlayerController.player = avPlayer
                
                self.present(avPlayerController, animated: true) {
                    //reproducir automaticamente
                    avPlayerController.player?.play()
                }
            }
        }
        
        return cell
    }
    
    
}


//MARK: - Navigation
extension HomeViewController {
    
    //transicion entre pantallas (solo stroryboads)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //1. validar que si sea el segue deseado
        
        if segue.identifier == "showHome", let mapViewController = segue.destination as? MapaViewController {
            // ya se sabe a que pantalla vamos
            mapViewController.posts = dataSource.filter{$0.hasLocation}
            
        }
    }
}
