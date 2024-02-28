//
//  DataHandler.swift
//  AIPartnerDemo
//
//  Created by FanPengpeng on 2023/11/8.
//

import UIKit
import AgoraAIGCService
import AgoraRtcKit

private let zh_STT = "xunfei"
private let zh_llm = "minimax-abab5.5-chat"
private let en_STT = "microsoft"
private let en_llm = "azureOpenai-gpt-4"

protocol AIGCManagerDelegate: NSObjectProtocol{
    func onSelectedRoleChanged(_ newRole: AIRoleInfo, oldRole: AIRoleInfo?)
    
    func onEventResult(with event: AgoraAIGCServiceEvent, code: AgoraAIGCServiceCode, message: String?)
    
    func onSpeech2Text(withRoundId roundId: String, result: String, recognizedSpeech: Bool) -> AgoraAIGCHandleResult
    
    func onLLMResult(withRoundId roundId: String, answer: String, isRoundEnd: Bool)  -> AgoraAIGCHandleResult
    
    func onText2SpeechResult(withRoundId roundId: String, voice: Data, sampleRates: Int, channels: Int, bits: Int) -> AgoraAIGCHandleResult
}

class AIGCManager: NSObject {
    
    weak var delegate: AIGCManagerDelegate?
    
    private var service: AgoraAIGCService?
    
    private var lang: AgoraAIGCLanguage!
    
    private var userName: String!
    
    private var isStarted = false
    private var isStaring = false
    
    lazy var roleArray: [AIRoleInfo] = {
        var arr = [AIRoleInfo]()
        let roleIds: [AIRoleInfo.RoleId] = lang == .ZH_CN ? [.yunibobo_zh, .jingxiang_zh] : [.foodie_en, .wendy_en, .cindy_en]
        let airoles = service?.getRoles()
        for roleId in roleIds {
            if let aiRole = airoles?.first(where: {$0.roleId == roleId.rawValue}) {
                let role = AIRoleInfo(nickname: aiRole.roleName, desc: aiRole.desc, roleId: aiRole.roleId, isSelected: false)
                arr.append(role)
            }
        }
        return arr
    }()
    
    private var willSelectedIndex = 0
    
    private (set) var selectedIndex = 0 {
        didSet {
            for (i, role) in roleArray.enumerated() {
                role.isSelected = i == selectedIndex
                if role.isSelected {
                    currentRole = role
                }
            }
        }
    }
    
    private (set) var currentRole: AIRoleInfo? {
        didSet{
            if oldValue != currentRole {
                if let currentRole = currentRole {
                    service?.setRoleWithId(currentRole.roleId.rawValue)
                    setupVendor(for: currentRole.roleId)
                    delegate?.onSelectedRoleChanged(currentRole, oldRole: oldValue)
                }
            }
        }
    }
    
    func resetRole(index: Int) {
        if selectedIndex == index {
            return
        }
        willSelectedIndex = index
        service?.stop()
        AgoraAIGCService.destory()
        createAIGCServer()
    }
    
    
    func initAIGC(_ language: AgoraAIGCLanguage, name: String) {
        lang = language
        userName = name
        if service != nil {
            startService()
            return
        }
        createAIGCServer()
    }
    
    private func createAIGCServer() {
        isStarted = false
        isStaring = false
        service = AgoraAIGCService.create()
        let uid = GenTools.RTC_UID
        let appId = KeyCenter.APP_ID
        let token = GenTools.RTM_TOKEN
        
        let input = AgoraAIGCSceneMode(language: lang,
                                       speechFrameBits: 16,
                                       speechFrameSampleRates: 16000,
                                       speechFrameChannels: 1)
        let output = AgoraAIGCSceneMode(language: lang,
                                        speechFrameBits: 16,
                                        speechFrameSampleRates: 16000,
                                        speechFrameChannels: 1)
        
        let config = AgoraAIGCConfigure(appId: appId,
                                        rtmToken: token,
                                        userId: "\(uid)",
                                        enableMultiTurnShortTermMemory: true,
                                        speechRecognitionFiltersLength: 3,
                                        input: input,
                                        output: output,
                                        userName: userName,
                                        logFilePath: nil,
                                        noiseEnvironment: .noise,
                                        speechRecognitionCompletenessLevel: .high)
        
        service?.delegate = self
        service?.initialize(config)
    }
    
    func setupVendor(for roleId: AIRoleInfo.RoleId){
        let serviceVendor = findSpecificVendorGroup(for: roleId)
        service?.setServiceVendor(serviceVendor)
    }
    
    func findSpecificVendorGroup(for roleId: AIRoleInfo.RoleId) -> AgoraAIGCServiceVendor {
        guard let vendors = service?.getVendors() else {
            fatalError("getVendors ret nil")
        }
        
        var stt: AgoraAIGCSTTVendor?
        var llm: AgoraAIGCLLMVendor?
        var tts: AgoraAIGCTTSVendor?
        
        let sttVenderId = lang == .ZH_CN ? zh_STT : en_STT
        let llmVenderId = lang == .ZH_CN ? zh_llm : en_llm
        
        for vendor in vendors.stt {
            if vendor.id == sttVenderId {
                stt = vendor
                break
            }
        }
        
        for vendor in vendors.llm {
            if vendor.id == llmVenderId {
                llm = vendor
                break
            }
        }
        
        for vendor in vendors.tts {
            if vendor.id == roleId.ttsVenderId {
                tts = vendor
                break
            }
        }
        
        return AgoraAIGCServiceVendor(stt: stt!, llm: llm!, tts: tts!)
    }
    
    func stopService(completion:(()->Void)? = nil){
        if isStarted {
            service?.stop()
            print("==== service === stop")
        }
    }
    
    func startService(){
        if isStarted == false && isStaring == false{
            service?.start()
            isStaring = true
            print("==== service === start")
        }
    }
    
    func pushSpeechDialogue(frame: AgoraAudioFrame) {
        if isStarted {
            let count = frame.samplesPerChannel * frame.channels * frame.bytesPerSample
            let data = Data(bytes: frame.buffer!, count: count)
            DispatchQueue.main.async {
                self.service?.pushSpeechDialogue(with: data, vad: .mute)
            }
        }
    }
    
    func pushSpeechDialogue(data: Data) {
        service?.pushSpeechDialogue(with: data, vad: .mute)
    }
    
    func pushText(_ command: Command, text: String? = nil) {
        var content = ""
        switch command {
        case .topic:
            content = "/\(command) \(text ?? "")"
        case .evaluate:
            content = "/\(command)"
        case .chatMessge:
            content = "/\(command)"
        case .start:
            content = "/\(command)"
        }
        if !content.isEmpty {
            print("==== service === pushText: \(content)")
            service?.pushTxtDialogue(content)
        }
    }
}

extension AIGCManager: AgoraAIGCServiceDelegate {
    
    func onEventResult(with event: AgoraAIGCServiceEvent, code: AgoraAIGCServiceCode, message: String?) {
        if event == .initialize, code == .success {
            DispatchQueue.main.async {[weak self] in
                if let self = self {
                    self.selectedIndex = self.willSelectedIndex
                }
            }
        }
        
        if event == .initialize, code == .initializeFail {
            service = nil
            initAIGC(lang, name: userName)
        }
        
        print("==== service === event = \(event.rawValue) code = \(code.rawValue)")
        if event == .stop, code == .success {
            self.isStaring = false
            self.isStarted = false
            print("==== service === stop === \(code == .success ? "success" : "failed")")
        }
        if event == .start {
            self.isStaring = false
            self.isStarted = code == .success
            print("==== service === start === \(code == .success ? "success" : "failed")")
        }
     
        delegate?.onEventResult(with: event, code: code, message: message)
    }
    
    func onSpeech2Text(withRoundId roundId: String, result: NSMutableString, recognizedSpeech: Bool) -> AgoraAIGCHandleResult {
        guard let delegate = delegate else{
            return .continue
        }
        return delegate.onSpeech2Text(withRoundId: roundId, result: result as String, recognizedSpeech: recognizedSpeech)
    }
    
    func onLLMResult(withRoundId roundId: String, answer: NSMutableString, isRoundEnd: Bool) -> AgoraAIGCHandleResult {
        guard let delegate = delegate else{
            return .continue
        }
        return delegate.onLLMResult(withRoundId: roundId, answer: answer as String, isRoundEnd: isRoundEnd)
    }
    
    func onText2SpeechResult(withRoundId roundId: String, voice: Data, sampleRates: Int, channels: Int, bits: Int) -> AgoraAIGCHandleResult {
        guard let delegate = delegate else{
            return .continue
        }
        return delegate.onText2SpeechResult(withRoundId: roundId, voice: voice, sampleRates: sampleRates, channels: channels, bits: bits)
    }
}

extension AIGCManager {
    enum Command: String {
        case topic
        case evaluate
        case chatMessge
        case start
    }
}
