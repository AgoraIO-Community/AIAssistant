//
//  AIGCService.h
//  GPT
//
//  Created by ZYP on 2023/10/7.
//

#import <Foundation/Foundation.h>
#import "AgoraAIGCObjects.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraAIGCServiceDelegate <NSObject>
/// result of sdk event
/// - Parameters:
///   - event: event type
///   - code: error code or success(AIGCServiceCodeSuccess)
///   - message: error message, `nil` if code == AIGCServiceCodeSuccess
- (void)onEventResultWithEvent:(AgoraAIGCServiceEvent)event
                          code:(AgoraAIGCServiceCode)code
                       message:(NSString * _Nullable)message;

/// result event of sound to text
/// - Parameters:
///   - roundId: Generate a roundId through rules such as sentence segmentation and muting. Each roundId represents the same content.
///   - recognizedSpeech: indicates whether it is a complete sentence
- (AgoraAIGCHandleResult)onSpeech2TextWithRoundId:(NSString *)roundId
                                           result:(NSMutableString *)result
                                 recognizedSpeech:(BOOL)recognizedSpeech;

/// result event of llm
/// - Parameters:
///   - answer: resutl of llm
///   - isRoundEnd: indicates whether it is at the end of the round
- (AgoraAIGCHandleResult)onLLMResultWithRoundId:(NSString *)roundId
                                         answer:(NSMutableString *)answer
                                     isRoundEnd:(BOOL)isRoundEnd;

/// result event of text to sound (The calling frequency is 40ms)
/// - Parameters:
///   - roundId: same as it in `onSpeech2TextWithRoundId`
///   - voice: audio from text to sound
///   - sampleRates: 16000
///   - channels: 1
///   - bits: 16
- (AgoraAIGCHandleResult)onText2SpeechResultWithRoundId:(NSString *)roundId
                                                  voice:(NSData *)voice
                                            sampleRates:(NSInteger)sampleRates
                                               channels:(NSInteger)channels
                                                   bits:(NSInteger)bits;
@end

@interface AgoraAIGCService : NSObject

@property(nonatomic, weak)id<AgoraAIGCServiceDelegate> delegate;
/// create an instance, it will be a single instance
+ (instancetype)create;
/// destory the single instance
+ (void)destory;
/// get sdk version
+ (NSString *)getSdkVersion;
/// initialize logic
- (void)initialize:(AgoraAIGCConfigure *)config;
/**
 * get a role list
 *
 * @return
 * - nil: no role
 * - not nil: list of role
 */
- (NSArray <AgoraAIGCAIRole *>* _Nullable)getRoles;
- (void)setRoleWithId:(NSString *)roleId;
/**
 * get a current role
 * @Note: use it after `setRoleWithId`
 */
- (AgoraAIGCAIRole * _Nullable)getCurrentRole;
/**
 * get all given support vendors (stt/llm/tts)
 * @return
 * - a group obj
 */
- (AgoraAIGCServiceVendorGroup * _Nullable)getServiceVendors;
/**
 * set a Vendor
 *
 * @param vendor vendor.
 * @return code
 */
- (AgoraAIGCServiceCode)setServiceVendor:(AgoraAIGCServiceVendor *)vendor;
/**
 * set a custom prompt
 *
 * @param prompt your custom prompt.
 * @return code
 */
- (AgoraAIGCServiceCode)setPrompt:(NSString *)prompt;
- (void)start;
- (void)stop;
/// push audio data
- (AgoraAIGCServiceCode)pushSpeechDialogueWithData:(NSData *)data
                                               vad:(AgoraAIGCVad)vad;
/// push text
- (AgoraAIGCServiceCode)pushTxtDialogue:(NSString *)text;

/// push text to tts, generate audio data
/// - Parameters:
///   - isAppend: wheather is interupte current audio data
- (AgoraAIGCServiceCode)pushTxtToTTS:(NSString *)text isAppend:(BOOL)isAppend;
/// unavailable
- (instancetype)init __attribute__((unavailable("Use create instead")));
@end

NS_ASSUME_NONNULL_END
