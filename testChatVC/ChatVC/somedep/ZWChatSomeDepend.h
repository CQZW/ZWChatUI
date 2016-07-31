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

@property (nonatomic,strong)    NSString*   mMsgID;
@property (nonatomic,assign)    int         mMsgStatus;//0 正常,1发送中,2发送失败,

@property (nonatomic,strong)    NSString*   mHeadImgUrl;
@property (nonatomic,assign)    BOOL        mIsSendOut;//是否是发出去的
@property (nonatomic,assign)    int         mMsgType;//0 时间消息, 1 文字消息, 2,图片消息,3 语音消息,4 礼物
@property (nonatomic,strong)    NSDate*     mMsgDate;//消息时间

-(NSString*)getTimeStr;

//文字消息的数据
@property (nonatomic,strong)    NSString*   mTextMsg;//文字消息内容

//图片消息的数据
@property (nonatomic,assign)    CGFloat     mPicW;
@property (nonatomic,assign)    CGFloat     mPicH;
@property (nonatomic,strong)    NSString*   mPicURL;//图片URL
@property (nonatomic,strong)    UIImage*    mImgObj;//如果有这个就优先显示这个

//语音消息的数据
@property (nonatomic,assign)    NSTimeInterval             mDurlong;//单位,秒..有小数点.
@property (nonatomic,strong)    NSData*         mVoiceData;//如果有这个,优先用这个,
@property (nonatomic,strong)    NSURL*          mVoiceURL;//声音文件的URL,
@property (nonatomic,assign)    BOOL            mIsPlaying;


//礼物消息的数据
@property (nonatomic,strong)    NSString*       mGiftId;
@property (nonatomic,strong)    NSString*       mGiftIconURL;//礼物小图标URL
@property (nonatomic,strong)    NSString*       mGiftDesc;
@property (nonatomic,strong)    NSString*       mDetailURL;//详情URL
@property (nonatomic,strong)    NSString*       mJyStr;

//需要填充数据,,比如,语音要下载什么的,
-(void)fetchMsgData:(void(^)(NSString* errmsg))block;


@end














