//
//  ChatCell.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/8.
//

import UIKit
//import YYText

private let buttonWidth: CGFloat = 70
private let buttonHeight: CGFloat = 18

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var chatLabel: UILabel!
    
    lazy var button: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 9
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.clipsToBounds = true
        button.isHidden = true
        button.setImage(UIImage(named: "flash"), for: .normal)
        button.backgroundColor = UIColor(red: 0.44, green: 0.52, blue: 0.80, alpha: 0.8)
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            button.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            button.widthAnchor.constraint(equalToConstant: buttonWidth),
            button.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        return button
    }()
    
    var chatInfo: ChatInfo? {
        didSet{
            if let info = chatInfo {
                set(content: info.content, name: info.name, delay: info.delay, isAI: info.isAI)
            }
        }
    }
    
    func set(content: String, name: String, delay: Int = 0, isAI: Bool) {
        let attributedString = NSMutableAttributedString()
        let nameColor = UIColor(red: 0.65, green: 0.76, blue: 1, alpha: 1)
        let attriName = NSAttributedString(string: "\(name): ",attributes: [NSAttributedString.Key.foregroundColor : nameColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)])
        let attriContent = NSAttributedString(string: content)
        button.isHidden = true
        if isAI {
//            if delay > 0 {
//                button.setTitle("\(delay)ms", for: .normal)
//                button.isHidden = false
//                let attriDelay = NSAttributedString.yy_attachmentString(withContent: "", contentMode: UIView.ContentMode.center, attachmentSize: CGSize(width: buttonWidth + 2, height: buttonHeight), alignTo: button.titleLabel?.font ?? UIFont.systemFont(ofSize: 13), alignment: .center)
//                attributedString.append(attriDelay)
//            }
            attributedString.append(attriName)
            attributedString.append(attriContent)
          
            if delay > 0 {
                button.setTitle("\(delay)ms", for: .normal)
                button.isHidden = false
                // 设置首行缩进距离
                let paragraphStyle = NSMutableParagraphStyle()
                let firstLineIndent: CGFloat = buttonWidth + 2
                paragraphStyle.firstLineHeadIndent = firstLineIndent
                paragraphStyle.headIndent = 0
                attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
            }
            
        }else{
            attributedString.append(attriName)
            attributedString.append(attriContent)
        }
        chatLabel.attributedText = attributedString
    }
}
