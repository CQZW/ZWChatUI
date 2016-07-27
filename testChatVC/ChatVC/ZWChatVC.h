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
@property (nonatomic,strong)    NSMutableArray*     mmsgdata;

//顶部的显示
@property (weak, nonatomic) IBOutlet UILabel *mtoptitle;



//加载之前的消息
-(void)headerStartRefresh;

//加载之后的消息
-(void)footerStartRefresh;


//获取 msg 之前的消息,,,子类实现
-(void)getMsgBefor:(ZWMsgObj*)msg block:(void(^)(NSArray*all))block;

//获取 msg 之后的消息,,子类实现
-(void)getMsgAfter:(ZWMsgObj*)msg block:(void(^)(NSArray*all))block;

//这几个 will 函数,自己实现了,然后调用 sendOneMsg 就好了

//将要发送一个文字了,,,,..子类实现了
-(void)willSendThisText:(NSString*)txt;

//将要发送图片 ,,,,..子类实现了
-(void)willSendThisImg:(UIImage*)img;




-(void)sendOneMsg:(ZWMsgObj*)sendMsg;


@end
