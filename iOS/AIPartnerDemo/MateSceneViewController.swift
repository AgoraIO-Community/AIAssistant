//
//  MateSceneViewController.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/6.
//

import UIKit
import AgoraAIGCService
import AgoraRtcKit
//import DubbingRtvcSDK
import SVProgressHUD

private let CELL_ID = "ChatCell"

class MateSceneViewController: UIViewController {

    var name: String!
    
    private var aiManager = AIGCManager()
    private var chatArray = [ChatInfo]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var myNameBtn: UIButton!
    // ai形象
    @IBOutlet weak var avatarView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    // 聊天列表
    @IBOutlet weak var chatTableView: UITableView!
    // 话题
    @IBOutlet weak var topicBtn: CustomButton!
    // 评分
    @IBOutlet weak var evaluateBtn: CustomButton!
    // 切换声音
    @IBOutlet weak var changeVoiceBtn: CustomButton!
    // 选择角色
    @IBOutlet weak var selectRoleBtn: CustomButton!
    // 呼叫
    @IBOutlet weak var callButton: UIButton!
    // 挂断
    @IBOutlet weak var hangUpButton: UIButton!
    // 静音
    @IBOutlet weak var muteButton: UIButton!
    
    private var selectedRole: AIRoleInfo?
    
    private let rtcManager = RtcManager()
    
    private var isConnecting = false {
        didSet {
            if waitToBeClose && !isConnecting {
                SVProgressHUD.dismiss()
                self.turnOff()
            }
        }
    }
    
    private var waitToBeClose = false
    
    // 记录开始的时间戳
    private var startDateMap = [String: Date]()
    private var recordDelayMap = [String: Bool]()
    private var aiChatInfoMap = [String: ChatInfo]()
    
    deinit {
        print(" === MateScenViewController is dealloc ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLocalizedUI()
        callButton.isEnabled = false
        selectRoleBtn.isEnabled = false
        
        let language: AgoraAIGCLanguage = LanguageManager.shared.current == .en ? .EN_US : .ZH_CN
        aiManager.initAIGC(language, name: name)
        aiManager.delegate = self
//        MetaManager.shared.enterScene(renderView: self.avatarView)
        
        initRTC()
//        initRtvcAISpeaker()
    }
    
    func initRtvcAISpeaker() {
        /*
        guard let array = DBRtvcManager.shared.getSpeakerList() else { return }
        for speakerId in array {
            if speakerId == 192 {
                DBRtvcManager.shared.setSpeaker(speakerId: speakerId)
            }
        }
         */
    }
    
    // 点击关闭
    @IBAction func didClickCloseButton(_ sender: Any) {
        if isConnecting {
            SVProgressHUD.show(withStatus: "shutting_down".localized)
            waitToBeClose = true
            return
        }
        turnOff()
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        rtcManager.muteMic(sender.isSelected)
    }
    
    // 点击呼叫
    @IBAction func didClickCallButton(_ sender: Any) {
        startConnect()
    }
    
    // 挂断
    @IBAction func didClickHangUp(_ sender: Any) {
        startDisconnect()
    }
    
    // 话题
    @IBAction func didClickTopicButton(_ sender: Any) {
        if callButton.isHidden == false {
            print(" 开始后才可以添加话题 ")
            if !waitToBeClose {
                SVProgressHUD.showInfo(withStatus: "mate_scene_topic_before_call_hud".localized)
            }
            return
        }
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let topicVC = sb.instantiateViewController(withIdentifier: "topicVC") as! EditTopicViewController
        topicVC.endEditTopicAction { topic in
            if topic == "/start" {
                self.aiManager.pushText(.start)
            }else{
                self.aiManager.pushText(.topic, text: topic)
            }
//            self.aiManager.pushText(.topic, text: topic)
        }
        self.present(topicVC, animated: true)
    }
    
    private func turnOff() {
        self.navigationController?.popViewController(animated: true)
        aiManager.stopService()
        aiManager.delegate = nil
        AgoraAIGCService.destory()
//        MetaManager.shared.leaveScene()
        rtcManager.leaveChanel()
        rtcManager.delegate = nil
    }
    
    // 评价
    @IBAction func didClickEvaluateButton(_ sender: Any) {
        self.aiManager.pushText(.evaluate)
    }
    
    // 切换声音
    @IBAction func didClickChangeVoiceButton(_ sender: CustomButton) {
        changeVoiceBtn.isSelected = !changeVoiceBtn.isSelected
    }
    
    // 选择角色
    @IBAction func didClickSelectRoleButton(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let selectRoleVC = sb.instantiateViewController(withIdentifier: "selectRoleVC") as! SelectRoleViewController
        selectRoleVC.aiManager = aiManager
        selectRoleVC.onSelectedIndex {[weak self] selectedIndex in
            self?.aiManager.resetRole(index: selectedIndex)
        }
        navigationController?.pushViewController(selectRoleVC, animated: true)
    }
    
    func refreshLocalizedUI(){
        myNameBtn.setTitle(name, for: .normal)
        if let selectedRole = selectedRole {
            let isEnglishTeacher = selectedRole.roleId == .wendy_en || selectedRole.roleId == .cindy_en
            topicBtn.isHidden = !isEnglishTeacher
            evaluateBtn.isHidden = !isEnglishTeacher
            callButton.setTitle("\("mate_scene_call_sb".localized)\(selectedRole.nickname)", for: .normal)
        }else{
            topicBtn.isHidden = true
            evaluateBtn.isHidden = true
            callButton.setTitle("mate_scene_call_sb".localized, for: .normal)
        }
        topicBtn.setTitle("Topic", imageName: "scene_topic")
        evaluateBtn.setTitle("Evaluate", imageName: "scene_evaluate")
//        changeVoiceBtn.setTitle("mate_scene_change_voice_btn_nor_title".localized, imageName: "scene_voice_default", state: .normal)
//        changeVoiceBtn.setTitle("mate_scene_change_voice_btn_sel_title".localized, imageName: "scene_voice_ai", state: .selected)
        selectRoleBtn.setTitle("mate_scene_change_role_btn_title".localized, imageName: "scene_role")
        avatarImageView.image = UIImage(named: selectedRole?.avatarIcon ?? "avatar_static_1")
    }
    
    private func initRTC(){
        rtcManager.delegate = self
        rtcManager.joinChannel()
    }
    
    private func resetData(){
        chatArray.removeAll()
        startDateMap.removeAll()
        recordDelayMap.removeAll()
        aiChatInfoMap.removeAll()
        tableView.reloadData()
    }
}

extension MateSceneViewController {
    
    // 开始连接
    private func startConnect() {
        aiManager.startService()
        rtcManager.startRecord()
        callButton.isEnabled = false
        selectRoleBtn.isEnabled = false
//        SVProgressHUD.show()
        isConnecting = true
    }
    
    private func startDisconnect(){
        rtcManager.stopRecord()
        aiManager.stopService()
//        SVProgressHUD.show()
    }
    
    // ai接听成功
    private func connected(){
        self.muteButton.isHidden = false
        self.hangUpButton.isHidden = false
        self.callButton.isHidden = true
        self.callButton.isEnabled = true
        self.selectRoleBtn.isEnabled = true
//        SVProgressHUD.dismiss()
        isConnecting = false
    }
    
    // 与ai断开链接
    private func disConnected(){
        self.muteButton.isHidden = true
        self.hangUpButton.isHidden = true
        self.callButton.isHidden = false
        self.callButton.isEnabled = true
        self.selectRoleBtn.isEnabled = true
        isConnecting = false
//        SVProgressHUD.dismiss()
    }
}

extension MateSceneViewController: RtcManagerDelegate {

    func rtcManagerOnCaptureAudioFrame(frame: AgoraAudioFrame) {
        aiManager.pushSpeechDialogue(frame: frame)
    }

    func rtcManagerOnCreatedRenderView(view: UIView) {
        
    }
    
    func rtcManagerOnVadUpdate(isSpeaking: Bool) {
        
    }

    func rtcManagerOnDebug(text: String) {
        
    }
}


extension MateSceneViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatCell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! ChatCell
        cell.chatInfo = chatArray[indexPath.row]
        return cell
    }
    
    func addOrUpdateInfo(info: ChatInfo) {
        if chatArray.isEmpty {
            chatArray.append(info)
            tableView.reloadData()
            return
        }
        
        for (index, obj) in chatArray.enumerated().reversed() {
            if obj.chatId == info.chatId {
                if obj.isAI {
                    chatArray[index].content.append(info.content)
                }else{
                    chatArray[index].content = info.content
                }
                let indexPath = IndexPath(row: index, section: 0)
                tableView.reloadData()
                tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
                return
            }
        }
        
        chatArray.append(info)
        tableView.reloadData()
        let indexPath = IndexPath(row: chatArray.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
    
    func updateInfoDelay(info: ChatInfo) {
        for (index, obj) in chatArray.enumerated().reversed() {
            if obj.chatId == info.chatId {
                if obj.isAI {
                    chatArray[index].delay = info.delay
                    let indexPath = IndexPath(row: index, section: 0)
                    tableView.reloadData()
                    tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
                }
            }
        }
    }
}

extension MateSceneViewController: AIGCManagerDelegate {
    func onSelectedRoleChanged(_ newRole: AIRoleInfo, oldRole: AIRoleInfo?) {
        print(" ==== onSelectedRoleChanged ==== ")
        resetData()
        disConnected()
        selectedRole = newRole
        refreshLocalizedUI()
//        MetaManager.shared.updateAvatar(newRole.avatarName.rawValue)
    }
    
    
    func onEventResult(with event: AgoraAIGCServiceEvent, code: AgoraAIGCServiceCode, message: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            
            if event == .initialize, code == .initializeFail {
                print("====initializeFail")
                return
            }
            
            if event == .initialize, code == .success {
                print("====initialize success")
//                aiManager.selectedIndex = 0
                callButton.isEnabled = true
                selectRoleBtn.isEnabled = true
            }
            
            if event == .start {
                if code == .success {
                    connected()
                }else {
                    disConnected()
                    SVProgressHUD.showError(withStatus: "call_failed".localized)
                }
            }
            if event == .stop, code == .success {
                disConnected()
            }
            
        }
    }
    
    func onSpeech2Text(withRoundId roundId: String,
                       result: String,
                       recognizedSpeech: Bool) -> AgoraAIGCHandleResult {
        let info = ChatInfo(chatId: roundId + "me", isAI: false, content: result, name: name)
        DispatchQueue.main.async { [weak self] in
            if recognizedSpeech {
                self?.startDateMap[roundId] = Date()
            }
            print("aigc [stt]: \(roundId), result: \(result), recognizedSpeech:\(recognizedSpeech)")
            self?.addOrUpdateInfo(info: info)
        }
        
        return .continue
    }
    
    func onLLMResult(withRoundId roundId: String, answer: String, isRoundEnd: Bool) -> AgoraAIGCHandleResult {
        print("aigc [llm]: roundid = \(roundId)")
        let isSpecial = roundId.hasPrefix("00000000000000000000000000000000")
        let aiNickname = aiManager.currentRole?.nickname ?? ""
        let roleId = aiManager.currentRole?.roleId
        if isSpecial && roleId == .foodie_en {
            return .discard
        }
        let info = ChatInfo(chatId: roundId + "ai" , isAI: true, content: answer, name: aiNickname)
        DispatchQueue.main.async { [weak self] in
            if self?.startDateMap[roundId] == nil {
                self?.startDateMap[roundId] = Date()
            }
            if self?.aiChatInfoMap[roundId] == nil {
                self?.aiChatInfoMap[roundId] = info
            }
            print("aigc [llm]: \(roundId), answer: \(answer)")
            self?.addOrUpdateInfo(info: info)
        }
        if isSpecial {
            return .discard
        }
        return .continue
    }
    
    func onText2SpeechResult(withRoundId roundId: String, voice: Data, sampleRates: Int, channels: Int, bits: Int) -> AgoraAIGCHandleResult {
        DispatchQueue.main.async { [weak self] in
            
//            MetaManager.shared.pushAudio(toLipSync: voice,sampleRate: sampleRates, channels: channels)
            if let info = self?.aiChatInfoMap[roundId], info.delay == 0, let startDate = self?.startDateMap[roundId] {
                let endDate = Date()
                info.delay = Int(endDate.timeIntervalSince(startDate) * 1000)
                self?.updateInfoDelay(info: info)
            }
            self?.rtcManager.setPlayData(data: voice)
            /*
            if let isAI = self?.changeVoiceBtn.isSelected, isAI == true {
                DBRtvcManager.shared.realTimeTranscribeData(data: voice) {[weak self] resultData in
                    if let data = resultData {
                        self?.rtcManager.setPlayData(data: data)
                    }
                }
            }else{
                self?.rtcManager.setPlayData(data: voice)
            }
             */
        }
        return .continue
    }
    
}
