//
//  SelectRoleViewController.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/7.
//

import UIKit
import AgoraAIGCService

private let CELLID = "SelectRole"

class SelectRoleViewController: UIViewController {
    
    typealias SelectedAction = (_ selectedIndex: Int)->Void
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var comfirmButton: UIButton!
    
    private var selectedAction: SelectedAction?
    
    var aiManager: AIGCManager!
    
    private var roleArray = [AIRoleInfo]()
    
    private var selectedIndex = 0 {
        didSet{
            for (i, role) in roleArray.enumerated() {
                role.isSelected = i == selectedIndex
                if role.isSelected {
                    avatarImageView?.image = UIImage(named: role.avatarIcon)
                    nicknameLabel?.text = role.nickname
                    descLabel?.text = role.desc
                }
                collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        roleArray = aiManager.roleArray
        selectedIndex = aiManager.selectedIndex
        refreshLocalizedUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func refreshLocalizedUI(){
        titleLabel.text = "select_role_title".localized
        comfirmButton.setTitle("select_role_confirm_btn_title".localized, for: .normal)
    }

    @IBAction func didClickOffButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didClickConfirmButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
//        aiManager.selectedIndex = selectedIndex
        self.selectedAction?(selectedIndex)
    }
    
    func onSelectedIndex(_ action: SelectedAction?) {
        self.selectedAction = action
    }
    
}

extension SelectRoleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SelectRoleCell = collectionView.dequeueReusableCell(withReuseIdentifier: CELLID, for: indexPath) as! SelectRoleCell
        let role = roleArray[indexPath.item]
        cell.role = role
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
    }
    
}
