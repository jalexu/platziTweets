//
//  TweetableViewCell.swift
//  PlatziTweets
//
//  Created by Jaime Uribe on 17/01/21.
//

import UIKit
import Kingfisher
//
class TweetableViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    /*
     Las celdas NUNCA PUEDEN INVOCAR VIEWCONTROLLERS
     */
    
    //MARK: -IBAction
    @IBAction func openVideoAction(_ sender: Any) {
        
        guard let validateUrl = videoUrl else {
            return
        }
        needToShowVideo?(validateUrl)
    }
    
    
    //MARK: - Properties
    private var videoUrl: URL?
    
    // ESTE METODO PEMITIRA SER EJECUTADO EN EL VIEWCONTROLLER,
    var needToShowVideo: ((_ url: URL) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func septupCellWiht(post: Post) {
        videoButton.isHidden = !post.hasVideo
        nameLabel.text = post.author.names
        nicknameLabel.text = post.author.nickname
        messageLabel.text = post.text
        
        if post.hasImage {
            tweetImageView.isHidden = false
            //si la imagen está convertir la url con la libreria Kingfisher
            tweetImageView.kf.setImage(with: URL(string: post.imageUrl))
        } else {
            tweetImageView.isHidden = true
        }
        
        videoUrl = URL(string: post.videoUrl)
    }
}
