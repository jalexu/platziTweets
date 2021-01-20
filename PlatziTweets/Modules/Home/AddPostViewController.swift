//
//  AddPostViewController.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 17/01/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD
import FirebaseStorage
import CoreLocation

//para reproductor de videos
import AVFoundation
import AVKit
import MobileCoreServices

class AddPostViewController: UIViewController {
    
    //MARK: - IBOutles
    @IBOutlet weak  var postTextView: UITextView!
    @IBOutlet weak var previeImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    
    
    //MARK: -IBActions
    @IBAction func addPostAction() {
        if currentVideoURL != nil{
            uploadVideoToFirebase()
            return
        }
        
        if previeImageView.image != nil {
            uploadPhotoToFirebase()
        }
        
        savePost(imageUrl: nil, videoURL: nil)
        
    }
    
    
    @IBAction func dimissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openCamaraAction(_ sender: Any) {
        //Dialogo nativo
        
        let alert = UIAlertController(title: "Cámara", message: "Selecciona una opción",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
            self.openVideoCamera()
        }))
        
        //se debe agregar botón de cancelar
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
        //
    }
    
    @IBAction func openPreviewAction(_ sender: Any) {
        guard let currentVideoURL = currentVideoURL else {
            return
        }
        
        //reproducir video
        let avPlayer = AVPlayer(url: currentVideoURL)
        //levantar pantalla de reproductor
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            //reproducir automaticamente
            avPlayerController.player?.play()
        }
    }
    
    //MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    private var locationManager: CLLocationManager?
    private var userLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocation()
        self.videoButton.isHidden = true

    }
    
    private func requestLocation(){
        
        //validar que esté activa la validacion de geolocalizacion
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // precisar ubicación , pero esta es la que mas bateria gasta
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        //siempre los permisos
        locationManager?.requestAlwaysAuthorization()
        // Comienla la localizacion
        locationManager?.startUpdatingLocation()
        
    }
    
    private func openVideoCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)  //5 segundos
        //permite recortar la camara
        imagePicker?.allowsEditing = true
        
        //permite controllar cuando se toma la foto
        imagePicker?.delegate = self
        
        guard let newImagePicker = imagePicker else {
            return
        }
        
        //presentar otra modal o ventana para la camara se puede por código
        present(newImagePicker, animated: true, completion: nil)
    }
    
    private func openCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        //permite recortar la camara
        imagePicker?.allowsEditing = true
        
        //permite controllar cuando se toma la foto
        imagePicker?.delegate = self
        
        guard let newImagePicker = imagePicker else {
            return
        }
        
        //presentar otra modal o ventana para la camara se puede por código
        present(newImagePicker, animated: true, completion: nil)
    }
    
    
    private func uploadPhotoToFirebase(){
        // 1. Comprobar que la imagen exista
        // convertir la imagen a Data y comprimirla mientras mas baja mucho mas ligera
        guard let imageSaved = previeImageView.image,
              let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.2) else {
            return
        }
        
        
        SVProgressHUD.show()
        
        // 4. Configurar la cuenta para alamacenar en firebase  atraves del FirebasStorage
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        // 5. Referencia al storage de Firebase
        let storage = Storage.storage()
        
        // 6. Crear nombre imagen
        let imageName = Int.random(in: 100...1000)
        
        // 7. Referencia donde se va a guardar la foto
        let folderReference = storage.reference(withPath: "photos-platziTweet/\(imageName).jpg")
        
        // 8. Subir la foto al firabase, en un hilo secundario por lo pesado que es
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                // Regresar al hilo principal
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    if let errorResponse = error {
                        NotificationBanner(title: "Error", subtitle: errorResponse.localizedDescription, style: .warning).show()
                        return
                    }
                    
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        let downloadURL = url?.absoluteString ?? nil
                        self.savePost(imageUrl: downloadURL, videoURL: nil)
                    }
                }
            }
        }
    }
    
    
    private func uploadVideoToFirebase(){
        // 1. Comprobar que el video exista
        // convertir el video a Data
        guard let currentVideoSavedURL = currentVideoURL,
              let videoData: Data = try? Data(contentsOf: currentVideoSavedURL) else {
            return
        }
        
        
        SVProgressHUD.show()
        
        // 4. Configurar la cuenta para alamacenar en firebase  atraves del FirebasStorage
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/MP4"
        
        // 5. Referencia al storage de Firebase
        let storage = Storage.storage()
        
        // 6. Crear nombre imagen
        let videoName = Int.random(in: 100...1000)
        
        // 7. Referencia donde se va a guardar la foto
        let folderReference = storage.reference(withPath: "videos-platziTweet/\(videoName).mp4")
        
        // 8. Subir la foto al firabase, en un hilo secundario por lo pesado que es
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(videoData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                // Regresar al hilo principal
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    
                    if let errorResponse = error {
                        NotificationBanner(title: "Error", subtitle: errorResponse.localizedDescription, style: .warning).show()
                        return
                    }
                    
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        let downloadURL = url?.absoluteString ?? nil
                        self.savePost(imageUrl: nil, videoURL: downloadURL)
                    }
                }
            }
        }
    }
    
    
    private func savePost(imageUrl: String?, videoURL: String?) {
        
        //crear request de localizacion
        var postLocation: PostLocation?
        if let userLocation = userLocation {
            postLocation = PostLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        }
        
        SVProgressHUD.show()
        
        guard !postTextView.text.isEmpty else {
            NotificationBanner(title: "Advertencia", subtitle: "Debes ingresar un mensaje!", style: .warning).show()
            return
        }
        //1. Crear un solicitud
        
        let request = PostRequest(text: postTextView.text, imageUrl: imageUrl, videoUrl: videoURL, location: postLocation ?? nil)
        
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            SVProgressHUD.dismiss()
            
            switch response {
            case .success:
                self.dismiss(animated: true, completion: nil)
                
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
                
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
                
            }
        }
        
    }


}


extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //se dispara cuando el usuario finalice la accion de seleccionar o tomar la foto
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //cerrar la camara
        imagePicker?.dismiss(animated: true, completion: nil)
        
        //se valida que la llave venga con una image
        //Captura la imagen
        if info.keys.contains(.originalImage) {
            self.previeImageView.isHidden = false
            
            //obtenemos la imagen de la camara
            self.previeImageView.image = info[.originalImage] as? UIImage
            
        }
        
        //captura video
        if info.keys.contains(.mediaURL), let recordedVideoURL = (info[.mediaURL] as? URL)?.absoluteURL {
            
            self.videoButton.isHidden = false
            self.currentVideoURL = recordedVideoURL
            
        }
    }
    
}

extension AddPostViewController: CLLocationManagerDelegate{
    
    //vamos a obtener la mas aproximada debe ser la ultima del array
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let bestLocation = locations.last else {
            return
        }
        
        //Ya tenemos la ubicacion
        userLocation = bestLocation
    }
}
