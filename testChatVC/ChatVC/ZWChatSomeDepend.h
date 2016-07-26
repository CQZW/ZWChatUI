//
//  ZWChatSomeDepend.h
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZWChatVC;

@interface ZWChatSomeDepend : NSObject

+(NSString *) FormartTime:(NSDate*) compareDate;

@end


@interface ZWFaceBT : UIView

@property (nonatomic,weak) ZWChatVC* mtagvc;

@property (nonatomic,assign)    NSInteger   mIndex;

-(void)setImg:(UIImage*)img;
-(void)setImg:(UIImage*)img sss:(CGFloat)sss;

@end

@interface ZWMoreBT : ZWFaceBT

-(void)setTxt:(NSString*)text;

@end


@interface ZWMsgObj : NSObject

@property (nonatomic,strong)    NSString*   mHeadImgUrl;
@property (nonatomic,assign)    BOOL        mIsSendOut;//是否是发出去的
@property (nonatomic,assign)    int         mMsgType;//0 时间消息, 1 文字消息, 2,图片消息,3 语音消息,4 礼物
@property (nonatomic,strong)    NSDate*     mMsgDate;//消息时间

@end


@interface ZWMsgObjTime : ZWMsgObj


-(NSString*)getTimeStr;


@end


@interface ZWMsgObjText : ZWMsgObj

@property (nonatomic,strong)    NSString*   mTextMsg;//文字消息内容

@end

@interface ZWMsgObjPic : ZWMsgObj

@property (nonatomic,assign)    CGFloat     mPicW;
@property (nonatomic,assign)    CGFloat     mPicH;
@property (nonatomic,strong)    NSString*   mPicURL;//图片URL

@end

@interface ZWMsgObjVoice : ZWMsgObj

@property (nonatomic,assign)    int             mDurlong;//11秒
@property (nonatomic,strong)    NSData*         mVoiceData;


@end














