//
//  testMsg.h
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZWChatSomeDepend.h"
@interface testMsg : NSObject


+(void)getMsgList:(ZWMsgObj*)lastMsg block:(void(^)(NSArray* all))block;


+(ZWMsgObj*)makeTestPicMsg:(UIImage*)img;


+(ZWMsgObj*)makeTestTextMsg:(NSString*)text;


+(ZWMsgObj*)makeTestVoiceMsg:(NSURL*)voicepath duration:(NSTimeInterval)duration;


@end
