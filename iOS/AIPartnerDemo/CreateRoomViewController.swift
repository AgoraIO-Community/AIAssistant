//
//  ViewController.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/3.
//

import UIKit
//import DubbingRtvcSDK
import CommonCrypto
import SVProgressHUD

private let namesArray = ["James", "William", "Lucas", "Henry", "Jack", "Daniel", "Michael", "Logan", "Owen", "Ashley", "Aaron", "Cooper", "Alex", "Wesley", "Adam", "Bryson", "Jasper", "Jason", "Cole", "Ace", "Ivan", "Leon", "Brandon", "Joe", "Jenny", "Simon", "Kylie", "Kobe", "Jay", "Travis", "Jared", "Jefferey", "Hassan", "Dash", "Mia", "Isabella", "Emily", "Layla", "Nora", "Lily", "Zoe", "Stella", "Elena", "Claire", "Alice", "Bella", "Cora", "Eva", "Iris", "Maria", "Lucia", "Jasmine", "Olive", "Blake", "Aspen", "Myla", "Hanna", "Julie", "Eve"]

func hideUnityWindow(){
   DispatchQueue.main.async {
       let windows = UIApplication.shared.windows
       for window in windows {
           if window.rootViewController is UINavigationController {
               window.isHidden = false
           }else {
               window.isHidden = true
           }
           print("window = \(window)")
       }
   }
}

class CreateRoomViewController: UIViewController {

    // 昵称
    @IBOutlet weak var nameTF: UITextField!
    // 语言
    @IBOutlet weak var langButton: UIButton!
    // ai伴侣
    @IBOutlet weak var aiPartnerBtn: UIButton!
    
    @IBOutlet weak var sceneTitleLabel: UILabel!
    @IBOutlet weak var waitButton: UIButton!
    @IBOutlet weak var nickLabel: UILabel!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    private var downloadVC: MCDownloadViewController?
    
    private var rtvcDownloadVC: MCDownloadViewController?
    
    private var isRtvcLogined = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aiPartnerBtn.isSelected = true
        langButton.isSelected = LanguageManager.shared.current == .en
        refreshLocalizedUI()
        SVProgressHUD.setMaximumDismissTimeInterval(1.5)
        nameTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 30))
        nameTF.leftViewMode = .always
        
    }
    
    private func refreshLocalizedUI() {
        title = "create_room_title".localized
        sceneTitleLabel.text = "create_room_select_scene".localized
        aiPartnerBtn.setTitle("create_room_ai_companion".localized, for: .normal)
        waitButton.setTitle("create_room_wait_title".localized, for: .normal)
        nickLabel.text = "create_room_nickname_title".localized
        randomButton.setTitle("create_room_random_title".localized, for: .normal)
        joinButton.setTitle("create_room_join_button_title".localized, for: .normal)
        nameTF.placeholder = "create_room_name_tf_placeholder".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // 切换语言
    @IBAction func didClickLangButton(_ sender: UIButton) {
        langButton.isSelected = !langButton.isSelected
        LanguageManager.shared.current = LanguageManager.shared.current == .zh ? .en : .zh
        refreshLocalizedUI()
    }
    
    @IBAction func didClickRandomButton(_ sender: Any) {
        let index = Int(arc4random()) % namesArray.count
        self.nameTF.text = namesArray[index]
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let name = self.nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        let mateVC = segue.destination as! MateSceneViewController
        mateVC.name = name
    }
    
    @IBAction func didClickJoinRoomButton(_ sender: Any) {
        
        guard let name = self.nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), name.count > 0 else {
            print("没有输入昵称")
            SVProgressHUD.showInfo(withStatus: "create_room_empty_nickname_hud".localized)
            return
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let mateVC = sb.instantiateViewController(withIdentifier: "roomVC") as! MateSceneViewController
        mateVC.name = name
        self.navigationController?.pushViewController(mateVC, animated: true)
    }
}

