//
//  testMsg.m
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import "testMsg.h"
#import "ZWChatSomeDepend.h"
@implementation testMsg





+(void)getMsgList:(ZWMsgObj*)lastMsg block:(void(^)(NSArray* all))block
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        NSArray* ss = @[@"http://img0.imgtn.bdimg.com/it/u=1850159850,51447102&fm=21&gp=0.jpg",@"http://img0.imgtn.bdimg.com/it/u=2509068887,1759572463&fm=21&gp=0.jpg"];
        
        NSArray* aa = @[@"asdfad[face1]",@"[face1]阿萨德[face1]发的事",@"[face1]啊撒旦发射点法啊上的浪费那啊 [face1]",@"啧啧啧啧[face1]去啊额烦",@"啊的身份垃圾;啦卷帘大将fl;a家拉屎的风景垃圾谁了解对方拉屎都放假啊是大幅拉升多方了解啊塑料袋积分[face1]拉丝机练腹肌阿隆索多久发啦[face1]姐啊斯蒂芬阿斯蒂芬啊是"];
        NSMutableArray* tt =NSMutableArray.new;
        for ( int j = 0; j<5; j++) {
            
            ZWMsgObjText* mmm = ZWMsgObjText.new;
            mmm.mIsSendOut = arc4random() % 2;
            mmm.mHeadImgUrl = ss[ mmm.mIsSendOut ];
            mmm.mMsgType = 1;
            mmm.mMsgDate = [NSDate date];
            mmm.mTextMsg = aa[ arc4random()% aa.count  ];
            
            [NSThread sleepForTimeInterval:0.1];
            [tt addObject:mmm];
        }
        
        for ( int j = 0; j<5; j++) {
            
            ZWMsgObjVoice* mmm = ZWMsgObjVoice.new;
            mmm.mIsSendOut = arc4random() % 2;
            mmm.mHeadImgUrl = ss[ mmm.mIsSendOut ];
            mmm.mMsgType = 3;
            mmm.mMsgDate = [NSDate date];
            
            mmm.mDurlong = arc4random()% 60;
            
            [NSThread sleepForTimeInterval:0.1];
            [tt addObject:mmm];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            block( tt );
            
        });
        
    });
    
}
@end
