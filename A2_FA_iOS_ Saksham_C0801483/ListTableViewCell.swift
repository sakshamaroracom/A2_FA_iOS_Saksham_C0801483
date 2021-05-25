//
//  ListTableViewCell.swift
//  CoreDataSample
//
//  Created by Saksham Arora on 23/05/21.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var deleteIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
