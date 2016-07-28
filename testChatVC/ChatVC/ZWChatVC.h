//
//  ZWChatVC.h
//  testChatVC
//
//  Created by zzl on 16/7/25.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWChatSomeDepend.h"
@interface ZWChatVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *mtopview;


@property (weak, nonatomic) IBOutlet UITableView *mtableview;

@property (weak, nonatomic) IBOutlet UIView *minputview;
@property (weak, nonatomic) IBOutlet UIButton *mleftvoicebt;
@property (weak, nonatomic) IBOutlet UIButton *mfacebt;
@property (weak, nonatomic) IBOutlet UIButton *mmorebt;

@property (weak, nonatomic) IBOutlet UITextView *minputtext;
@property (weak, nonatomic) IBOutlet UIButton *mvoicebtpress;

@property (weak, nonatomic) IBOutlet UIView *mmoreinputpan;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mmorepanconsth;


@property (weak, nonatomic) IBOutlet UIScrollView *mmoremoreview;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minputbarconsth;



//下面的东西用于继承者用...

//消息数据
#pragma mark 注意消息顺序
//整个代码 所有消息顺序都是 按照时间排序 0---> 9

@property (nonatomic,strong)    NSMutableArray*     mmsgdata;

//顶部的显示
@property (weak, nonatomic) IBOutlet UILabel *mtoptitle;

//不要一进入界面就自动加载
@property (nonatomic,assign)    BOOL    mDontAutoLoadFrist;//默认 NO ,就是要加载的意思

//加载之前的消息
-(void)headerStartRefresh;

//加载之后的消息
-(void)footerStartRefresh;

#pragma mark 继承主要看这里开始

@property (nonatomic,assign)    BOOL        mCannotLoadHistoryMsg;//不能加载历史消息,就没有顶部的刷新,
@property (nonatomic,assign)    BOOL        mCannotLoadNewestMsg;//不能加载最新消息,就是没有底部的刷新,

//获取 msg 之前的消息,,,子类实现
-(void)getMsgBefor:(ZWMsgObj*)msg block:(void(^)(NSArray*all))block;

//获取 msg 之后的消息,,子类实现
-(void)getMsgAfter:(ZWMsgObj*)msg block:(void(^)(NSArray*all))block;

//这几个 will 函数,自己实现了,然后调用 addOneMsg 就好了

//将要发送一个文字了,,,,..子类实现了
-(void)willSendThisText:(NSString*)txt;

//将要发送图片 ,,,,..子类实现了
-(void)willSendThisImg:(UIImage*)img;

//将要发送一个语音...,,这个函数一返回
-(void)willSendThisVoice:(NSURL*)voicepath duration:(NSTimeInterval)duration;

//添加条消息到后面
-(void)addOneMsg:(ZWMsgObj*)sendMsg;

//删除一条消息
-(void)delOneMsg:(ZWMsgObj*)delMsg;

//更新一条消息
-(void)updateOneMsg:(ZWMsgObj*)updMsg;


#pragma mark 继承主要看这里结束


@end
