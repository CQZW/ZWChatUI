//
//  testMsg.h
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZWMsgObj;
@interface testMsg : NSObject


+(void)getMsgList:(ZWMsgObj*)lastMsg block:(void(^)(NSArray* all))block;


@end
