//
//  EditTopicViewController.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/6.
//

import UIKit
//import IQKeyboardManager

class EditTopicViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    private var endTopicAction:((_ topic: String)->Void)?
    
    @IBOutlet weak var blankViewHeightCon: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func didClickOKButton(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true)
        self.endTopicAction?(textView.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func endEditTopicAction(_ completion: ((_ topic: String)->Void)?) {
        self.endTopicAction = completion
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        dismiss(animated: true)
    }

}

extension EditTopicViewController {
    func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        // 获取键盘高度
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrame.height
        
        let window = UIApplication.shared.windows.first
        let safeBottomInset = window?.safeAreaInsets.bottom ?? 0.0
        print(" keyboradHeight = \(keyboardHeight), safeBottomInset = \(safeBottomInset)")
        // 处理键盘高度变化
        blankViewHeightCon.constant = keyboardHeight + 100
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        dismiss(animated: true)
    }
}
