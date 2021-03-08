//
//  SinglePictureCell.swift
//  PlaceOnTheWall
//
//  Created by Olena Stepaniuk on 07.03.2021.
//

import UIKit

class SinglePictureCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
