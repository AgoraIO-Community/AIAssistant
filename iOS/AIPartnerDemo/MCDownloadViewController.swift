//
//  MCDownloadViewController.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/9.
//

import UIKit

class MCDownloadViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var sizeLabel: UILabel!
    
    var totalSize: Float? // 需要定义一个变量来存储总大小
    var cancelAction: (() -> Void)? // 用于取消操作的函数
    var currentTitle: String?
    var hideCancelButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "download_vc_title".localized
        self.cancelButton.setTitle("download_vc_cancel".localized, for: .normal)
        if currentTitle != nil {
            self.sizeLabel.text = currentTitle
        }else{
            self.sizeLabel.text = String(format: "0.0MB / %.fMB", (totalSize ?? 0) / 1024 / 1024)
        }
        self.cancelButton.isHidden = hideCancelButton
    }
    
    func setProgress(_ progress: Float) {
        print(String(format: "%.2f", progress))
        self.progressView.progress = progress / 100.0
        if totalSize != nil {
            self.sizeLabel.text = String(format: "%.1fMB / %.fMB", totalSize! / 1024 / 1024 * progress / 100.0, totalSize! / 1024 / 1024)
        }else {
            self.sizeLabel.text = currentTitle
        }
    }
    
    @IBAction func didClickCancelButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        if let cancelAction = cancelAction {
            cancelAction()
        }
    }
}

