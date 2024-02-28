//
//  SelectRoleCell.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/7.
//

import UIKit

class SelectRoleCell: UICollectionViewCell {
    
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var genderView: UIImageView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    var role: AIRoleInfo! {
        didSet{
            indicatorView.isHidden = !role.isSelected
            genderView.image = UIImage(named: role.gender == .female ? "role_gender_female" : "")
            iconImageView.image = UIImage(named: role.avatarIcon)
            iconImageView.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3).cgColor
            iconImageView.layer.borderWidth = 2
        }
    }
    
}
