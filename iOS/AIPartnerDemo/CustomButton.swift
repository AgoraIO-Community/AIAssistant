//
//  CustomButton.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/6.
//

import UIKit

class CustomButton: UIControl {
    
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    
    private var titlesMap = [UInt : String]()
    private var imagesMap = [UInt : UIImage]()
    
    override var isSelected: Bool {
        didSet{
            updateState()
        }
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXibView()
    }
    
    private func loadXibView(){
        imageView = UIImageView()
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .black
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        self.layer.cornerRadius = 13
        self.layer.masksToBounds = true
//        addSubview(contentView)
    }
    
    func setTitle(_ title: String, imageName: String?, state: UIControl.State = .normal) {
        titlesMap[state.rawValue] = title
        imagesMap[state.rawValue] = UIImage(named: imageName ?? "")
        updateState()
    }
    
    func setTitle(_ title: String, for state: UIControl.State) {
        titlesMap[state.rawValue] = title
        updateState()
    }
    
    func setmyImage(_ image: UIImage?, for state: UIControl.State) {
        imagesMap[state.rawValue] = image
        updateState()
    }
    
    private func updateState(){
        if isSelected == true {
            imageView.image = imagesMap[UIControl.State.selected.rawValue] ?? imagesMap[UIControl.State.normal.rawValue]
            titleLabel.text = titlesMap[UIControl.State.selected.rawValue] ?? titlesMap[UIControl.State.normal.rawValue]
        }else{
            imageView.image = imagesMap[UIControl.State.normal.rawValue]
            titleLabel.text = titlesMap[UIControl.State.normal.rawValue]
        }
    }
   
}
