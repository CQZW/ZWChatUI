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
       
        NSArray* ss = @[@"http://p3.gexing.com/touxiang/20120727/1444/501238c78343b_200x200_3.jpg",@"http://v1.qzone.cc/avatar/201404/03/12/51/533ce8ccb2555295.jpg%21200x200.jpg"];
        
        NSArray* aa = @[@"asdfad[face1]",@"[face1]阿萨德[face1]发的事",@"[face1]啊撒旦发射点法啊上的浪费那啊 [face1]",@"啧啧啧啧[face1]去啊额烦",@"啊的身份垃圾;啦卷帘大将fl;a家拉屎的风景垃圾谁了解对方拉屎都放假啊是大幅拉升多方了解啊塑料袋积分[face1]拉丝机练腹肌阿隆索多久发啦[face1]姐啊斯蒂芬阿斯蒂芬啊是"];
        NSMutableArray* tt =NSMutableArray.new;
        int msgid = 1;
        for ( int j = 0; j<5; j++) {
            
            ZWMsgObjText* mmm = ZWMsgObjText.new;
            
            mmm.mMsgID = [NSString stringWithFormat:@"%d",msgid];
            msgid++;
            
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
            
            mmm.mMsgID = [NSString stringWithFormat:@"%d",msgid];
            msgid++;
            
            
            mmm.mIsSendOut = arc4random() % 2;
            mmm.mHeadImgUrl = ss[ mmm.mIsSendOut ];
            mmm.mMsgType = 3;
            mmm.mMsgDate = [NSDate date];
            
            mmm.mDurlong = arc4random()% 60;
            
            [NSThread sleepForTimeInterval:0.1];
            [tt addObject:mmm];
        }
        
        NSArray* pppp = @[
                          @[
                          @"http://b.hiphotos.baidu.com/image/pic/item/d058ccbf6c81800a30063c13b33533fa838b47cf.jpg",
                          @(500),@(700)],
                          @[
                              @"http://e.hiphotos.baidu.com/image/pic/item/64380cd7912397dd25024f305c82b2b7d0a2878f.jpg",
                              @(594),@(891)
                              ],
                          @[
                              @"http://c.hiphotos.baidu.com/image/pic/item/6a600c338744ebf8a05ade3bdbf9d72a6059a78f.jpg",
                              @(463),@(690)
                              ],
                          @[
                              @"http://c.hiphotos.baidu.com/image/pic/item/f31fbe096b63f62431b8e7078544ebf81b4ca3c9.jpg",
                              @(456),
                              @(646)
                              ],
                          @[
                              @"http://d.hiphotos.baidu.com/image/pic/item/caef76094b36acaf9da262e37ed98d1001e99c6b.jpg",
                              @(620),@(891)
                              ],
                          @[
                              @"http://www.pp3.cn/uploads/201509/2015091008.jpg",
                              @(1440),@(900)
                              ]
                          ];
        
        for ( int j = 0; j<5; j++) {
            
            ZWMsgObjPic* mmm = ZWMsgObjPic.new;
            
            mmm.mMsgID = [NSString stringWithFormat:@"%d",msgid];
            msgid++;
            
            mmm.mIsSendOut = arc4random() % 2;
            mmm.mHeadImgUrl = ss[ mmm.mIsSendOut ];
            mmm.mMsgType = 2;
            mmm.mMsgDate = [NSDate date];
            
            NSArray*bbbb= pppp[ arc4random() % pppp.count ];
            mmm.mPicURL = bbbb[0];
            mmm.mPicW = [bbbb[1] intValue];
            mmm.mPicH = [bbbb[2] intValue];
            
            [NSThread sleepForTimeInterval:0.1];
            [tt addObject:mmm];
        }
        
        ZWMsgObjGift*mmm = ZWMsgObjGift.new;
        mmm.mMsgID = [NSString stringWithFormat:@"%d",msgid];
        msgid++;
        
        mmm.mIsSendOut = YES;
        mmm.mHeadImgUrl = ss[ 1 ];
        mmm.mMsgType = 4;
        mmm.mMsgDate = [NSDate date];
        
        mmm.mGiftDesc = @"我送你一个礼物我送你一个礼物我送你一个礼物我送你一个礼物我送你一个礼物我送你一个礼物我送你一个礼物我送你一个礼物";
        mmm.mGiftIconURL = @"http://gb.cri.cn/mmsource/images/2007/08/21/ee070821009.jpg";
        mmm.mJyStr = @"你的经验值+1";
        
        [tt addObject:mmm];
        
        mmm = ZWMsgObjGift.new;
        mmm.mMsgID = [NSString stringWithFormat:@"%d",msgid];
        msgid++;
        
        mmm.mIsSendOut = NO;
        mmm.mHeadImgUrl = ss[ 0 ];
        mmm.mMsgType = 4;
        mmm.mMsgDate = [NSDate date];
    
        mmm.mGiftDesc = @"收到一个什么礼物,好多钱,去查看详情吧";
        mmm.mGiftIconURL = @"http://gb.cri.cn/mmsource/images/2007/08/21/ee070821009.jpg";
        
        [tt addObject:mmm];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            block( tt );
            
        });
        
    });
    

}

+(ZWMsgObjText*)makeTestTextMsg:(NSString*)text
{
    NSArray* ss = @[@"http://p3.gexing.com/touxiang/20120727/1444/501238c78343b_200x200_3.jpg",@"http://v1.qzone.cc/avatar/201404/03/12/51/533ce8ccb2555295.jpg%21200x200.jpg"];
    
    NSArray* aa = @[@"asdfad[face1]",@"[face1]阿萨德[face1]发的事",@"[face1]啊撒旦发射点法啊上的浪费那啊 [face1]",@"啧啧啧啧[face1]去啊额烦",@"啊的身份垃圾;啦卷帘大将fl;a家拉屎的风景垃圾谁了解对方拉屎都放假啊是大幅拉升多方了解啊塑料袋积分[face1]拉丝机练腹肌阿隆索多久发啦[face1]姐啊斯蒂芬阿斯蒂芬啊是"];
    
    ZWMsgObjText* mmm = ZWMsgObjText.new;
    
    mmm.mMsgID = [NSString stringWithFormat:@"%ld",(NSInteger)[NSDate timeIntervalSinceReferenceDate]*1000];
    
    mmm.mIsSendOut = YES;
    mmm.mHeadImgUrl = ss[ mmm.mIsSendOut ];
    mmm.mMsgType = 1;
    mmm.mMsgDate = [NSDate date];
    mmm.mTextMsg = text;
    if( text == nil )
        mmm.mTextMsg = aa[ arc4random()% aa.count  ];
    return mmm;
}

+(ZWMsgObjPic*)makeTestPicMsg:(UIImage*)img
{
    NSArray* ss = @[@"http://p3.gexing.com/touxiang/20120727/1444/501238c78343b_200x200_3.jpg",@"http://v1.qzone.cc/avatar/201404/03/12/51/533ce8ccb2555295.jpg%21200x200.jpg"];

    NSArray* pppp = @[
                      @[
                          @"http://b.hiphotos.baidu.com/image/pic/item/d058ccbf6c81800a30063c13b33533fa838b47cf.jpg",
                          @(500),@(700)],
                      @[
                          @"http://e.hiphotos.baidu.com/image/pic/item/64380cd7912397dd25024f305c82b2b7d0a2878f.jpg",
                          @(594),@(891)
                          ],
                      @[
                          @"http://c.hiphotos.baidu.com/image/pic/item/6a600c338744ebf8a05ade3bdbf9d72a6059a78f.jpg",
                          @(463),@(690)
                          ],
                      @[
                          @"http://c.hiphotos.baidu.com/image/pic/item/f31fbe096b63f62431b8e7078544ebf81b4ca3c9.jpg",
                          @(456),
                          @(646)
                          ],
                      @[
                          @"http://d.hiphotos.baidu.com/image/pic/item/caef76094b36acaf9da262e37ed98d1001e99c6b.jpg",
                          @(620),@(891)
                          ],
                      @[
                          @"http://www.pp3.cn/uploads/201509/2015091008.jpg",
                          @(1440),@(900)
                          ]
                      ];
    
    
    ZWMsgObjPic* mmm = ZWMsgObjPic.new;
    
    mmm.mMsgID = [NSString stringWithFormat:@"%ld",(NSInteger)[NSDate timeIntervalSinceReferenceDate]*1000];
    
    mmm.mIsSendOut = YES;
    mmm.mHeadImgUrl = ss[ mmm.mIsSendOut ];
    mmm.mMsgType = 2;
    mmm.mMsgDate = [NSDate date];
    if( img == nil)
    {
        NSArray*bbbb= pppp[ arc4random() % pppp.count ];
        mmm.mPicURL = bbbb[0];
        mmm.mPicW = [bbbb[1] intValue];
        mmm.mPicH = [bbbb[2] intValue];
    }
    else{
        mmm.mImgObj = img;
    }
    
    
    
    [NSThread sleepForTimeInterval:0.1];
    return mmm;
}

+(ZWMsgObjVoice*)makeTestVoiceMsg:(NSURL*)voicepath duration:(NSTimeInterval)duration
{
    NSArray* ss = @[@"http://p3.gexing.com/touxiang/20120727/1444/501238c78343b_200x200_3.jpg",@"http://v1.qzone.cc/avatar/201404/03/12/51/533ce8ccb2555295.jpg%21200x200.jpg"];
    
    
    ZWMsgObjVoice* mmm = ZWMsgObjVoice.new;
    
    mmm.mMsgID = [NSString stringWithFormat:@"%ld",(NSInteger)[NSDate timeIntervalSinceReferenceDate]*1000];
    
    mmm.mIsSendOut = YES;
    mmm.mHeadImgUrl = ss[ mmm.mIsSendOut ];
    mmm.mMsgType = 3;
    mmm.mMsgDate = [NSDate date];
    
    
    mmm.mDurlong = ceil(duration);
    mmm.mVoiceData = [NSData dataWithContentsOfURL:voicepath];
    
    
    
    return mmm;
    
}


@end
