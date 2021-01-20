//
//  MapaViewController.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 18/01/21.
//

import UIKit
import MapKit

class MapaViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var mapCointeiner: UIView!
    
    
    //MARK: - Properties
    var posts =  [Post]()
    private var map: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMap()
        setupMarkets()
    }
    
    
    private func setupMap() {
        //frame es el tamaño que va a tener en pantalla en este caso el mismo del mapConteiner
        map = MKMapView(frame: mapCointeiner.bounds)
        
        mapCointeiner.addSubview(map ?? UIView())
        
    }
    
    private func setupMarkets (){
        posts.forEach { item in
            //envia la paleta de marcado al mapa
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
            marker.title = item.text
            marker.title = item.author.names
            
            map?.addAnnotation(marker)
        }
        
        
        guard let firstPost = posts.last else {
            return
        }
        
        let firstPostLocation = CLLocationCoordinate2D(latitude: firstPost.location.latitude, longitude: firstPost.location.longitude)
        
        guard let heading = CLLocationDirection(exactly: 12) else{
            return
        }
        
        map?.camera = MKMapCamera(lookingAtCenter: firstPostLocation, fromDistance: 80, pitch: .zero, heading: heading)
        
    }

}
