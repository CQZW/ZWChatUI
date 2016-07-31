//
//  ZWChatVC.m
//  testChatVC
//
//  Created by zzl on 16/7/25.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import "ZWChatVC.h"
#import "IQKeyboardManager.h"
#import "MJRefresh.h"

#import "ZWMsgCellLeft.h"
#import "ZWMsgCellRight.h"
#import "ZWMsgTimeCell.h"
#import "ZWMsgVoiceCellLeft.h"
#import "ZWMsgVoiceCellRight.h"
#import "ZWMsgPicCellLeft.h"
#import "ZWMsgPicCellRight.h"
#import "ZWMsgGiftCellLeft.h"
#import "ZWMsgGiftCellRight.h"

#import "testMsg.h"
#import "ZWChatSomeDepend.h"
#import "UIImageView+WebCache.h"
#import "M80AttributedLabel.h"
#import "SVProgressHUD.h"
#import "NIMInputAudioRecordIndicatorView.h"
#import <AVFoundation/AVFoundation.h>
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"




@interface ZWChatVC ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,UIGestureRecognizerDelegate>

@end

@implementation ZWChatVC
{
    
    //更多输入的状态,0 隐藏了,1 表情,2其他
    int     _morepanstatus;
    
    BOOL    _cgfok;
    
    BOOL    _doing;
    
    CGFloat         _moreXpoint;
    CGFloat         _giftXpoint;
    
    CGFloat         _lastInputH;
    
    NIMInputAudioRecordIndicatorView*   _recshowing;
    
    AVAudioRecorder*            _recorder;
    BOOL                        _brecwillsend;
    NSTimer*                    _timer;
    NSTimeInterval              _recduration;
    
    
    AVAudioPlayer*              _player;
    ZWMsgObj*              _nowplayingmsg;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 5.0f;
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;


}

- (IBAction)backclicked:(id)sender {
    
    
    if( [self.navigationController topViewController] == self )
    {//如果有导航控制器,,并且顶部就是自己,,那么应该 返回
        if( self.navigationController.viewControllers.count == 1 )
        {//如果只有一个,,,那么
            if( self.presentingViewController )
            {//如果有,,那么就dismiss
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    
                    
                }];
                return;
            }
            else
            {
                NSLog(@"how to back11");
            }
            
        }else
            [self.navigationController popViewControllerAnimated:YES];
        
    }
    else//其他情况,就再判断是否有 presentingViewController
    if( self.presentingViewController )
    {//如果有,,那么就dismiss
        [self dismissViewControllerAnimated:YES completion:^{
           
            
            
        }];
        return;
    }
    else
    {
        NSLog(@"how to back");
    }
    
}

- (IBAction)clickedtophead:(id)sender {
    
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    
    CGPoint pp  = [touch locationInView:self.view];
    if( pp.y > self.minputview.frame.origin.y )
    {//只要点击了在输入框的下面...这种就放过...
        return NO;
    }
    
    //下面的点击 都是在 输入框的上面,,,就是点击了tablewview的范围
    if( self.minputtext.isFirstResponder )
    {//键盘开启的,就关闭键盘,,,
        [self.minputtext resignFirstResponder];
        return YES;
    }
    
    //键盘没有开启,但是,输入其他的,表情,,礼物的什么显示起的,,,
    if( self.mmorepanconsth.constant > 0 )
    {
        [self hidenMorePan];
        return YES;
    }
    
    //下面是判断 CELL的点击位置..
    pp = [touch locationInView:self.mtableview];
    
    NSIndexPath * indexpath = [self.mtableview indexPathForRowAtPoint:pp];
    UITableViewCell* cell =  [self.mtableview cellForRowAtIndexPath:indexpath];
    
    UIView* msgbodyrect = [cell viewWithTag:99];
    pp  = [touch locationInView:cell];
    
    if( CGRectContainsPoint(msgbodyrect.frame,pp) )
    {//在消息体的范围,就允许响应tableview的 didselectrow...
        return NO;
    }
    
    UIView* failedicon = [cell viewWithTag:98];
    
    if( CGRectContainsPoint(failedicon.frame,pp) )
    {
        [self failedIconTouched:indexpath iconhiden:failedicon.hidden];
    }
    
    return YES;
    
}

-(void)taprootview:(UITapGestureRecognizer*)sender
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer* tapgusest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(taprootview:)];
    tapgusest.delegate = self;
    
    [self.view addGestureRecognizer:tapgusest];
    
    
    self.minputtext.layer.borderColor = [UIColor colorWithRed:0.788 green:0.792 blue:0.804 alpha:1.000].CGColor;
    self.minputtext.layer.borderWidth = 1.0f;
    self.minputtext.layer.cornerRadius = 3.0f;
    
    self.minputtext.delegate = self;
    
    _lastInputH = 31.0f;
    
    self.mvoicebtpress.layer.borderColor = [UIColor colorWithRed:0.788 green:0.792 blue:0.804 alpha:1.000].CGColor;
    self.mvoicebtpress.layer.borderWidth = 1.0f;
    self.mvoicebtpress.layer.cornerRadius = 3.0f;
    
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnDown:) forControlEvents:UIControlEventTouchDown];
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnDragInside:) forControlEvents:UIControlEventTouchDragInside];
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    self.mmsgdata = NSMutableArray.new;
    if( !self.mCannotLoadHistoryMsg )
        self.mtableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerStartRefresh)];
    
    if( !self.mCannotLoadNewestMsg )
        self.mtableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerStartRefresh)];
    
    
    UINib* nib = [UINib nibWithNibName:@"ZWMsgCellLeft" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"leftcell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgCellRight" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"rightcell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgTimeCell" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"timecell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgVoiceCellRight" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"voicerightcell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgVoiceCellLeft" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"voiceleftcell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgPicCellLeft" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"picleftcell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgPicCellRight" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"picrightcell"];
    
    
    
    nib = [UINib nibWithNibName:@"ZWMsgGiftCellRight" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"gifrightcell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgGiftCellLeft" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"gifleftcell"];
    
    self.mtableview.delegate = self;
    self.mtableview.dataSource =  self;
    
    self.mtableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if( !self.mDontAutoLoadFrist )
    {
        if( !self.mCannotLoadHistoryMsg )
            [self.mtableview.mj_header beginRefreshing];
        else if( !self.mCannotLoadNewestMsg )
            [self.mtableview.mj_footer beginRefreshing];
    }
    
}

#pragma mark 消息数据获取主要修改这里开始
//获取消息,修改这里
-(void)headerStartRefresh
{
    ZWMsgObj* fmsg = nil;
    for ( ZWMsgObj* one in self.mmsgdata ) {
        if( one.mMsgType != 0 )
        {
            fmsg = one;
            break;
        }
    }
    
    [self getMsgBefor:fmsg block:^(NSArray *all) {
        
        [self.mtableview.mj_header endRefreshing];
        if( all.count )
        {
            int timecellcount =0;
            int ss = self.mmsgdata.count;
            for ( NSInteger j = all.count-1 ; j >= 0; j-- ) {
                ZWMsgObj* one  = all[ j ];
                [self.mmsgdata insertObject:one atIndex:0];
                if( (self.mmsgdata.count % 8) ==  0)
                {//每5个就显示一个时间..
                    ZWMsgObj* timemsg  = [self makeTimeMsgObj:one];
                    [self.mmsgdata insertObject:timemsg atIndex:1];
                    timecellcount++;
                }
            }
       
            [self.mtableview reloadData];
            if( ss == 0 )
            {
                [self.mtableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:all.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            else{
                NSInteger aaa = all.count + timecellcount + 1;
                aaa = aaa >= self.mmsgdata.count ? (self.mmsgdata.count - 1) :aaa;
                
                [self.mtableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:aaa inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
        
    }];
    
}


-(void)footerStartRefresh
{
    ZWMsgObj* findlast = nil;
    
    for ( NSInteger j = self.mmsgdata.count-1; j>=0; j--) {
        ZWMsgObj*one = self.mmsgdata[ j ];
        if( one.mMsgType != 0 )
        {
            findlast = one;
            break;
        }
    }
    
    [self getMsgAfter:findlast block:^(NSArray *all) {
        
        [self.mtableview.mj_footer endRefreshing];
        if( all.count )
        {
            int timecellcount =0;
            int ss = self.mmsgdata.count;
            for ( NSInteger j = 0 ; j < all.count; j++ ) {
                ZWMsgObj* one  = all[ j ];
                [self.mmsgdata addObject:one];
                if( (self.mmsgdata.count % 8) ==  0)
                {//每5个就显示一个时间..
                    ZWMsgObj* timemsg  = [self makeTimeMsgObj:one];
                    [self.mmsgdata addObject:timemsg];
                    timecellcount++;
                }
            }
            
            [self.mtableview reloadData];
            
            if( ss == 0  )
            {
                [self.mtableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mmsgdata.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }
    }];
}

//获取 msg 之前的消息,,,
-(void)getMsgBefor:(ZWMsgObj*)msg block:(void(^)(NSArray*all))block
{
    if( [NSStringFromClass([self class]) isEqualToString:NSStringFromClass([ZWChatVC class])] )
    {
    //for test code ,,,子类继承实现这个函数,
        [testMsg getMsgList:msg block:^(NSArray *all) {
            
            block( all );
            
        }];
    }
}

//获取 msg 之后的消息
-(void)getMsgAfter:(ZWMsgObj*)msg block:(void(^)(NSArray*all))block
{
    //for test code ,,,子类继承实现这个函数,
    if( [NSStringFromClass([self class]) isEqualToString:NSStringFromClass([ZWChatVC class])] )
    {
        
        [testMsg getMsgList:msg block:^(NSArray *all) {
            
            block( all );
            
        }];
    }
}


-(ZWMsgObj*)makeTimeMsgObj:(ZWMsgObj*)msg
{
    ZWMsgObj* tt = ZWMsgObj.new;
    tt.mMsgDate = msg.mMsgDate;
    return tt;
}


-(void)willSendThisText:(NSString*)txt
{
    self.minputtext.text = @"";
    self.minputbarconsth.constant = 48;
    
    if( [NSStringFromClass([self class]) isEqualToString:NSStringFromClass([ZWChatVC class])] )
    {
        //for test
        __block ZWMsgObj* msgobj =  [testMsg makeTestTextMsg:txt];
        msgobj.mMsgStatus = 1;
        [self addOneMsg:msgobj];
        
        //模拟异步发送动作,,2秒完成之后,
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
           
            msgobj.mMsgStatus = 2;
            [self didSendThisMsg:msgobj];
            
        });
    }
}

-(void)willSendThisImg:(UIImage*)img
{
    if( [NSStringFromClass([self class]) isEqualToString:NSStringFromClass([ZWChatVC class])] )
    {
        //for test
        [self addOneMsg:[testMsg makeTestPicMsg:img]];
    }
    
}

-(void)willSendThisVoice:(NSURL*)voicepath duration:(NSTimeInterval)duration
{
    if( [NSStringFromClass([self class]) isEqualToString:NSStringFromClass([ZWChatVC class])] )
    {
        //for test
        [self addOneMsg:[testMsg makeTestVoiceMsg:voicepath duration:duration]];
        
    }
}

//发送完成,,当异步发送完成之后,调用该函数
-(void)didSendThisMsg:(ZWMsgObj*)msg
{
    if( msg == nil ) return;
    
    if( ![self.mmsgdata containsObject:msg] )
    {//如果还没有,就添加...
        [self addOneMsg:msg];
        return;
    }
    //就是更新下状态
    [self updateOneMsg:msg];
    
    
}

//需要重新发送
-(void)willReSendThisMsg:(ZWMsgObj*)msg
{
    //开始发送
    msg.mMsgStatus = 1;
    [self updateOneMsg:msg];
    
    //for testcode
    if( [NSStringFromClass([self class]) isEqualToString:NSStringFromClass([ZWChatVC class])] )
    {
        __block ZWMsgObj* msgobj =  msg;
        
        //模拟异步重新发送,,,
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            
            //发送成功
            msgobj.mMsgStatus = 0;
            [self didSendThisMsg:msgobj];
            
            
        });
    }
    
    
}

-(void)wantFetchMsg:(ZWMsgObj*)msg block:(void(^)(NSString* errmsg,ZWMsgObj*msg))block
{
    [msg fetchMsgData:^(NSString *errmsg) {
       
        block( errmsg , msg);
        
    }];
}


-(void)addOneMsg:(ZWMsgObj*)sendMsg
{
    if( [self.mmsgdata containsObject:sendMsg] ) return;
    
    [self.mmsgdata addObject:sendMsg];
    [self.mtableview beginUpdates];
    
    [self.mtableview insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.mmsgdata.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.mtableview endUpdates];
    
    [self.mtableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.mmsgdata.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}
//删除一条消息
-(void)delOneMsg:(ZWMsgObj*)delMsg
{
    NSUInteger xx = [self.mmsgdata indexOfObject:delMsg];
    if( xx == NSNotFound ) return;
    
    [self.mmsgdata removeObjectAtIndex:xx];
    [self.mtableview beginUpdates];
    
    [self.mtableview deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:xx inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.mtableview endUpdates];
}

//更新一条消息
-(void)updateOneMsg:(ZWMsgObj*)updMsg
{
    NSUInteger xx = [self.mmsgdata indexOfObject:updMsg];
    if( xx == NSNotFound ) return;
    
    [self.mtableview reloadData];
    return;
    
    [self.mmsgdata replaceObjectAtIndex:xx withObject:updMsg];
    
    CGPoint sss = self.mtableview.contentOffset;
    
    [self.mtableview beginUpdates];
    [self.mtableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:xx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.mtableview endUpdates];
    
    [self.mtableview setContentOffset:sss];
    
}
//获取消息,修改这里
#pragma mark 消息数据获取主要修改这里结束


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mmsgdata.count;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWMsgObj* msgobj = self.mmsgdata[ indexPath.row ];
    
    ZWMsgCellRight* retcell = nil;
    if( msgobj.mMsgType == 1 )
    {//文字消息
        ZWMsgObj * textobj = msgobj;
        if( textobj.mIsSendOut )
        {
            retcell = [tableView dequeueReusableCellWithIdentifier:@"rightcell"];
            if( msgobj.mMsgStatus == 1 )
            {
                [retcell.msv startAnimating];
            }
            else
            {
                [retcell.msv stopAnimating];
            }
            retcell.mfailedicon.hidden = !(msgobj.mMsgStatus == 2);
            
        }
        else{
            retcell = [tableView dequeueReusableCellWithIdentifier:@"leftcell"];
        }
        
        [self dealFace:retcell.mmsglabel str:textobj.mTextMsg];
        
        CGSize ss = [retcell.mmsglabel sizeThatFits:CGSizeMake(tableView.bounds.size.width- 73 - 50, CGFLOAT_MAX)];
        retcell.mlabelconstH.constant = ss.height;
        retcell.mlabelconstW.constant = ss.width;
        
    }
    else if(  msgobj.mMsgType == 2 )
    {//图片
        ZWMsgObj* picobj = msgobj;
        
        ZWMsgPicCellRight* piccell = nil;
        if( picobj.mIsSendOut )
        {
            piccell = [tableView dequeueReusableCellWithIdentifier:@"picrightcell"];
            
            if( msgobj.mMsgStatus == 1 )
            {
                [piccell.msv startAnimating];
            }
            else
            {
                [piccell.msv stopAnimating];
            }
            piccell.mfailedicon.hidden = !(msgobj.mMsgStatus == 2);

        }
        else{
            piccell = [tableView dequeueReusableCellWithIdentifier:@"picleftcell"];
        }
        
#pragma mark 图片最宽
        CGFloat picShowW = tableView.bounds.size.width - 150.0f;//这是最大的
        CGFloat screenW = picobj.mPicW/[UIScreen mainScreen].scale;//真正屏幕宽度
        picShowW = screenW > picShowW ? picShowW  : screenW;
        picShowW = picShowW == 0.0f ? (100.0f):picShowW;
        
        CGFloat picShowH = ( picobj.mPicH / picobj.mPicW ) * picShowW;

        picShowH = picShowH == 0.0f ? (100.0f):picShowH;

        if( picobj.mImgObj )
        {
            piccell.mtagimg.image = picobj.mImgObj;
        }
        else
        {
            [piccell.mtagimg sd_setImageWithURL:[NSURL URLWithString:picobj.mPicURL] placeholderImage:[UIImage imageNamed:@"DefaultImg"]];
        }
        
        piccell.mimgconstH.constant = picShowH;
        piccell.mimgconstW.constant = picShowW;
        
        retcell = piccell;
    }
    else if ( msgobj.mMsgType == 3 )
    {//语音
        ZWMsgObj* voiceobj = msgobj;
        ZWMsgVoiceCellRight* vcell = nil;
        if( voiceobj.mIsSendOut )
        {
            vcell = [tableView dequeueReusableCellWithIdentifier:@"voicerightcell"];
            if( voiceobj.mIsPlaying )
            {
                vcell.mvoiceicon.image = nil;
                vcell.mvoiceicon.image =
                [UIImage animatedImageWithImages:@[
                                                   [UIImage imageNamed:@"ic_play_voice_right0"],
                                                   [UIImage imageNamed:@"ic_play_voice_right1"],
                                                   [UIImage imageNamed:@"ic_play_voice_right2"],
                                                   [UIImage imageNamed:@"ic_play_voice_right3"],
                                                   [UIImage imageNamed:@"ic_play_voice_right4"],
                                                   [UIImage imageNamed:@"ic_play_voice_right5"],
                                                   ] duration:1.8f];
            }
            else{
                vcell.mvoiceicon.image = [UIImage imageNamed:@"ic_play_voice_right0"];
            }
        }
        else
        {
            vcell = [tableView dequeueReusableCellWithIdentifier:@"voiceleftcell"];
            if( voiceobj.mIsPlaying )
            {
                vcell.mvoiceicon.image = nil;
                vcell.mvoiceicon.image =
                [UIImage animatedImageWithImages:@[
                                                   [UIImage imageNamed:@"ic_play_voice_left0"],
                                                   [UIImage imageNamed:@"ic_play_voice_left1"],
                                                   [UIImage imageNamed:@"ic_play_voice_left2"],
                                                   [UIImage imageNamed:@"ic_play_voice_left3"],
                                                   [UIImage imageNamed:@"ic_play_voice_left4"],
                                                   [UIImage imageNamed:@"ic_play_voice_left5"],
                                                   ] duration:1.8f];
            }
            else{
                vcell.mvoiceicon.image = [UIImage imageNamed:@"ic_play_voice_left0"];
            }
        }
        
        vcell.mlonglabel.text = [NSString stringWithFormat:@"%.1f''",voiceobj.mDurlong];
        CGFloat ff = (voiceobj.mDurlong / 60.0f ) * 150.0f;
#pragma mark 声音cell最宽,最窄
        ff = ff < 50?50.0f:ff;
        ff = ff > 150.0f?150.0f:ff;
        
        vcell.mlongrateconstW.constant = ff;
        
        
        retcell = vcell;
    }
    else if( msgobj.mMsgType == 4 )
    {
        ZWMsgObj*  gifobj =  msgobj;
        ZWMsgGiftCellRight* giftcell = nil;
        if( gifobj.mIsSendOut )
        {
            giftcell = [tableView dequeueReusableCellWithIdentifier:@"gifrightcell"];
            giftcell.mjy.text = gifobj.mJyStr;
        }
        else{
            giftcell = [tableView dequeueReusableCellWithIdentifier:@"gifleftcell"];
        }
        
        [giftcell.mgificon sd_setImageWithURL:[NSURL URLWithString:gifobj.mGiftIconURL] placeholderImage:nil];
        giftcell.mgifdesc.text = gifobj.mGiftDesc;
        
        retcell = giftcell;
    }
    else
    {//其他什么鬼...其他所有消息都当真时间消息处理了....
        
        ZWMsgObj* timeobj =  msgobj;
        ZWMsgTimeCell* timecell = [tableView dequeueReusableCellWithIdentifier:@"timecell"];
        
        timecell.mtimelabel.text = [timeobj getTimeStr];
        timecell.selectionStyle = UITableViewCellSelectionStyleNone;
        return timecell;
    }
    
    
    [retcell.mheadimg sd_setImageWithURL:[NSURL URLWithString:msgobj.mHeadImgUrl] placeholderImage:[UIImage imageNamed:@"ic_default_head"]];
    retcell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    return retcell;
}


- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWMsgObj* msgobj = self.mmsgdata[ indexPath.row ];

    if( msgobj.mMsgType == 1 )
    {
        return YES;
    }
    
    return NO;
}

//每个cell都会点击出现Menu菜单
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if ( action == @selector(copy:) ) {
        ZWMsgObj* msgobj = self.mmsgdata[ indexPath.row ];
        [UIPasteboard generalPasteboard].string = msgobj.mTextMsg;
    }
}


-(void)failedIconTouched:(NSIndexPath*)indexPath iconhiden:(BOOL)iconhiden
{
    if( iconhiden ) return;
    
    ZWMsgObj* msgobj = self.mmsgdata[ indexPath.row ];
    if( msgobj.mMsgStatus == 2 )
    {
        [self willReSendThisMsg:msgobj];
        return;
    }
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZWMsgObj* msgobj = self.mmsgdata[ indexPath.row ];
    
    [self msgClicked:msgobj];
    
}
-(void)msgClicked:(ZWMsgObj*)msgobj
{
    if( msgobj.mMsgType == 3 )
    {//播放语音消息
        
        [self playVoiceMsg:(ZWMsgObj*)msgobj block:^(BOOL playing) {
            
            if( playing )
                [self.mtableview reloadData];
        }];
        
    }
    else if( msgobj.mMsgType == 2 )
    {//查看大图
        
        MJPhoto* pp =  MJPhoto.new;
        pp.url = [NSURL URLWithString:   msgobj.mPicURL  ];
        pp.srcImageView = nil;
        
        MJPhotoBrowser* browser = [[MJPhotoBrowser alloc]init];
        browser.currentPhotoIndex = 0;
        browser.photos  = @[pp];
        [browser show];
        
    }
}

-(void)playVoiceMsg:(ZWMsgObj*)msg block:(void(^)( BOOL playing ))block
{
    [_player stop];
    _player = nil;
    if( msg == _nowplayingmsg )
    {
        [self stopPlayVoice:msg];
        _nowplayingmsg = nil;
        return;//这种就是停止的意思
    }
    
    if ( msg.mVoiceData == nil ) {
        //数据没有就填充下,,,具体是用URL下载,还是怎么的,自己处理
        [self wantFetchMsg:msg block:^(NSString *errmsg, ZWMsgObj *msg) {
            
            if( errmsg )
            {
                [SVProgressHUD showErrorWithStatus:errmsg];
            }
            else
            {
                block ([self realPlayVoice:msg] );
            }
            
        }];
        return;
    }
    
    block( [self realPlayVoice:msg] );
    
}
-(BOOL)realPlayVoice:(ZWMsgObj*)msg
{
    _player = [[AVAudioPlayer alloc]initWithData:msg.mVoiceData error:nil];
    
    _player.delegate = self;
    _nowplayingmsg = msg;
    _nowplayingmsg.mIsPlaying = YES;
    
    if( _player == nil || ![_player prepareToPlay] || ![_player play] )
    {
        [SVProgressHUD showErrorWithStatus:@"播放该消息失败"];
        [self stopPlayVoice:msg];
        _nowplayingmsg = nil;
        return NO;
    }
    return YES;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlayVoice:_nowplayingmsg];
    _nowplayingmsg = nil;
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    [self stopPlayVoice:_nowplayingmsg];
    _nowplayingmsg = nil;
}

-(void)stopPlayVoice:(ZWMsgObj*)msg
{
    msg.mIsPlaying = NO;
    NSUInteger ii = [self.mmsgdata indexOfObject: msg ];
    if( ii == NSNotFound )
    {
        
    }
    else
    {
        [self.mtableview reloadData];
        return;
        
        NSIndexPath* iiii = [NSIndexPath indexPathForRow:ii inSection:0];
        [self.mtableview reloadRowsAtIndexPaths:@[ iiii ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

-(void)dealFace:(M80AttributedLabel*)mal str:(NSString*)str
{
    NSRange searchFrom;
    searchFrom.length = str.length;
    searchFrom.location = 0;
    
    mal.text = nil;
    
    do
    {
        NSRange find = [str rangeOfString:@"\\[[a-z]+[0-9]+\\]" options:NSRegularExpressionSearch range:searchFrom];
        if( find.location == NSNotFound )
        {//最好一次么有找到..
            [mal appendText:[str substringWithRange:NSMakeRange(searchFrom.location, str.length - searchFrom.location)]];
            break;
        }
        
        NSString* facename = [str substringWithRange:find];
        facename = [facename substringWithRange:NSMakeRange(1, facename.length-2)];
        
        [mal appendText:[str substringWithRange:NSMakeRange(searchFrom.location, find.location - searchFrom.location)]];
        [mal appendImage:[UIImage imageNamed:facename] maxSize:CGSizeMake(18, 18)];

        searchFrom.location =   find.location + find.length;
        searchFrom.length   =   str.length - searchFrom.location;
        
    }while( searchFrom.location < str.length );
    
}

-(void)cfgmoremoreview
{
    if( _cgfok ) return;
    _cgfok = YES;
    
    
    //这里逻辑很简单,就是一行一行的摆放控件.....
    
    
    //face 目录下面有105个PNG图片
    int maxface = 105;
    
    CGFloat perPageW = self.mmoremoreview.bounds.size.width;
    CGFloat perW = perPageW/ 6.0f;
    CGFloat perH = 200.0f / 4.0f;
    
    int page = 0;

    CGFloat xPoint = 0.0f;
    CGFloat yPoint = 20;
    
    xPoint = page * perPageW;
    
    int nextrow = 0;
    int nowrows = 0;
    for( int index = 1; index <= maxface;index++)
    {
        ZWFaceBT*bt = [[ZWFaceBT alloc]initWithFrame:CGRectMake(xPoint, yPoint, perW, perH)];
        [bt setImg:[UIImage imageNamed:[NSString stringWithFormat:@"face%d.png",index]]];
        bt.mtagvc = self;
        bt.mIndex = index;
        
        [self.mmoremoreview addSubview:bt];
        nextrow +=1;
        xPoint += perW;
        if( nextrow == 6 )
        {//6个就换一行
            nowrows++;
            nextrow = 0;
            xPoint = page * perPageW;
            yPoint += perH;
        }
        if( (index % 22) ==  0 || index == maxface)//或者已经是最后一个了
        {
            ZWFaceBT*btdel = [[ZWFaceBT alloc]initWithFrame:CGRectMake(xPoint, yPoint, perW, perH)];
            [btdel setImg:[UIImage imageNamed:@"2.0_sixin_lt_shanchu_n"] sss:1.0f];
            btdel.mtagvc = self;
            btdel.mIndex = -1;
            
            [self.mmoremoreview addSubview:btdel];
            xPoint += perW;
            
            if( index == maxface && nextrow == 5 )
            {//这需要换行..
                if( nowrows == 4 )
                {//需要换页,
                    page++;
                    yPoint = 20.0f;
                    xPoint = page * perPageW;
                }
                else{//只需要换行..
                    
                    xPoint = page * perPageW;
                    yPoint += perH;
                }
            }
            
            ZWFaceBT*btsend = [[ZWFaceBT alloc]initWithFrame:CGRectMake(xPoint, yPoint, perW, perH)];
            [btsend setImg:[UIImage imageNamed:@"2.0_sixin_lt_fasong_h"] sss:1.0f];
            btsend.mtagvc = self;
            btsend.mIndex = -2;
            
            [self.mmoremoreview addSubview:btsend];
            
            if( index == maxface && nextrow == 5 && nowrows == 4 )
            {
                
            }
            else{
                page++;
                nextrow = 0;
                yPoint = 20.0f;
                xPoint = page * perPageW;
                nowrows = 0;
            }
        }
    }
    
    
    CGFloat contW = ceil((maxface / 22.0f )) * perPageW;
    
    _moreXpoint = contW;
    
    //这是表情..
    //self.mmoremoreview.contentSize = CGSizeMake( ceil((maxface / 22.0f )) * perPageW, self.mmoremoreview.bounds.size.height);
    
    //然后是输入更多的,,这个就只考虑一页的情况
    NSArray* allmore = @[ @[ @"照片",@"ic_private_chat_more_photo" ], @[ @"拍摄",@"ic_private_chat_more_camera" ], @[ @"礼物",@"ic_private_chat_more_gift" ] ];
    xPoint = contW;
    yPoint = 10;
    
    perW = perPageW / 4.0f;
    perH = 80.0f;
    
    nextrow = 0;
    for( int index = 0 ; index < allmore.count ; index++  )
    {
        NSArray* aa = allmore[ index ];
        
        ZWMoreBT * bt = [[ZWMoreBT alloc]initWithFrame:CGRectMake(xPoint,yPoint, perW, perH)];
        [bt setTxt:aa[0]];
        [bt setImg:[UIImage imageNamed:aa[1]]];
        bt.mtagvc = self;
        bt.mIndex = 1000 + index;
        
        
        [self.mmoremoreview addSubview: bt];
        nextrow++;
        
        xPoint += perW;
        
    }
    
    contW += perPageW;
    
    
    self.mmoremoreview.contentSize = CGSizeMake( contW, self.mmoremoreview.bounds.size.height);
    _giftXpoint = contW;
  
    
    //for test
    if( self.mGiftView == nil )
    {
        self.mGiftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.mmoremoreview.bounds.size.width, MorePanH)];
        self.mGiftView.backgroundColor = [UIColor redColor];
        self.mGiftView.hidden = YES;
    }
    
}



-(void)moreItemClicked:(UIButton*)sender
{
    if( sender.tag == -1 )
    {
        if( self.minputtext.text.length > 0 )
        {
            self.minputtext.text = [self.minputtext.text substringToIndex: self.minputtext.text.length - 2 ];
            [self textViewDidChange:self.minputtext];
        }
    }
    else if( sender.tag == -2 )
    {
        if( self.minputtext.text.length == 0 )
        {
            [SVProgressHUD showErrorWithStatus:@"请先输入发送内容"];
            return;
        }
        
        [self willSendThisText:self.minputtext.text];
        
    }
    else
    if( sender.tag < 1000 )
    {
        self.minputtext.text = [self.minputtext.text stringByAppendingString:[NSString stringWithFormat:@"[face%ld]",sender.tag]];
        [self textViewDidChange:self.minputtext];
    }
    else
    {//相册,照片,礼物什么的
        if ( sender.tag == 1000 )
        {
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.delegate = self;
                picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            
            [self presentViewController:picker animated:YES completion:nil];
            
            
        }else if ( sender.tag == 1001 ){
            
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                picker.sourceType=UIImagePickerControllerSourceTypeCamera;
                picker.delegate = self;
                picker.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
            }
            
            [self presentViewController:picker animated:YES completion:nil];
            
        }
        else if( sender.tag == 1002 )
        {
            [self showGiftView];
        }
    }
}

-(void)showGiftView
{
    if( self.mGiftView == nil ) return;
    if( !self.mGiftView.hidden ) return;
    if( _doing ) return;
    _doing = YES;
    
    CGRect ff = self.mGiftView.frame;
    ff.origin.y = ff.size.height * 1;
    self.mGiftView.frame = ff;
    
    if( self.mGiftView.superview == nil )
        [self.mmoreinputpan addSubview:self.mGiftView];
    
    self.mGiftView.hidden = NO;
    
    [UIView animateWithDuration:0.1f animations:^{
        
        CGRect fff = self.mGiftView.frame;
        fff.origin.y = 0.0f;
        self.mGiftView.frame = fff;
        
    } completion:^(BOOL finished) {
        
        _doing = NO;
        
    }];
    
}
-(void)hidenGiftView
{
    if( self.mGiftView == nil ) return;
    if( self.mGiftView.hidden ) return;
    if( _doing ) return;
    _doing = YES;
    
    [UIView animateWithDuration:0.1f animations:^{
        
        CGRect fff = self.mGiftView.frame;
        fff.origin.y = fff.size.height * 1;
        self.mGiftView.frame = fff;
        
    } completion:^(BOOL finished) {
        
        self.mGiftView.hidden = YES;
        _doing = NO;
        
    }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* tagimg = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if( tagimg == nil )
    {
        [SVProgressHUD showErrorWithStatus:@"图片无效!请重新选择"];
        return;
    }
    [self willSendThisImg:tagimg];
    [self hidenMorePan];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}





- (void)textViewDidChange:(UITextView *)textView
{
    if( textView.contentSize.height > _lastInputH )
    {
        _lastInputH = textView.contentSize.height;
        self.minputbarconsth.constant = _lastInputH + self.minputtext.textContainerInset.top + self.minputtext.textContainerInset.bottom ;
        [self.view layoutIfNeeded];
    }
    else if( textView.contentSize.height < _lastInputH )
    {
        _lastInputH = textView.contentSize.height;
        self.minputbarconsth.constant = _lastInputH + self.minputtext.textContainerInset.top + self.minputtext.textContainerInset.bottom;
        [self.view layoutIfNeeded];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        if( textView.text.length == 0 )
        {
            [SVProgressHUD showErrorWithStatus:@"请先输入发送内容"];
            return NO;
        }
        
        [self willSendThisText:textView.text];
        return NO;
    }
    return YES;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hidenMorePan];
}

#pragma mark 录音操作开始

- (IBAction)onTouchRecordBtnDown:(id)sender {
    [self showRecSV:1];
    [self startRecordeAudio];
}
- (IBAction)onTouchRecordBtnUpInside:(id)sender {
    // finish Recording
    //self.recordPhase = AudioRecordPhaseEnd;
    [self showRecSV:4];
    _brecwillsend = YES;
    [self stopRecordeAudio];
}
- (IBAction)onTouchRecordBtnUpOutside:(id)sender {
    //TODO cancel Recording
    //self.recordPhase = AudioRecordPhaseEnd;
    [self showRecSV:4];
    _brecwillsend = NO;
    [self stopRecordeAudio];
}

- (IBAction)onTouchRecordBtnDragInside:(id)sender {
    //TODO @"手指上滑，取消发送"
    //self.recordPhase = AudioRecordPhaseRecording;
    [self showRecSV:3];
    
}
- (IBAction)onTouchRecordBtnDragOutside:(id)sender {
    //TODO @"松开手指，取消发送"
    //self.recordPhase = AudioRecordPhaseCancelling;
    [self showRecSV:2];
}

//status  1 开始了,,2 显示上滑什么,,,3 显示取消 4 移除..
-(void)showRecSV:(int)status
{
    if( status == 4 )
    {
        [_recshowing removeFromSuperview];
        _recshowing = nil;
        return;
    }
    
    if( _recshowing == nil )
    {
        _recshowing = [[NIMInputAudioRecordIndicatorView alloc]init];
        [self.view addSubview:_recshowing];
        _recshowing.center = self.view.center;
    }
    _recshowing.mstatus = status;
    
}

#pragma mark 录音API操作这里可能会影响APP
-(void)startRecordeAudio
{
    if( _recorder.recording ) return;
    
    
    if( ![self canRecord] )
    {
        [SVProgressHUD showErrorWithStatus:@"获取麦克风权限失败"];
        return;
    }
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    if( ![session.category isEqualToString:AVAudioSessionCategoryPlayAndRecord] ||
        ![session.category isEqualToString:AVAudioSessionCategoryRecord]
       )
    {
        if( ![session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil] )
        {
            [SVProgressHUD showErrorWithStatus:@"录音失败"];
            return;
        }
        if( ![session setActive:YES error:nil] )
        {
            [SVProgressHUD showErrorWithStatus:@"录音失败"];
            return;
        }
    }
    
    NSMutableDictionary *recordSetting = NSMutableDictionary.new;
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSError* error = nil;
    _recorder = [[AVAudioRecorder alloc]initWithURL:[self makerecfilepath] settings:recordSetting error:&error];
    _recorder.delegate  = self;
    if( _recorder == nil || ![_recorder prepareToRecord] )
    {
        [SVProgressHUD showErrorWithStatus:@"录音失败"];
        return;
    }
    
    if( ![_recorder recordForDuration:60.0f] )
    {
        [SVProgressHUD showErrorWithStatus:@"录音失败"];
        return;
    }
    
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timersel) userInfo:nil repeats:YES];
    _recduration = 0.0f;
}

-(void)timersel
{
    _recshowing.recordTime = _recorder.currentTime;
    _recduration += _timer.timeInterval;
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            } else {
                bCanRecord = NO;
            }
        }];
    }
    
    return bCanRecord;
}

-(void)stopRecordeAudio
{
    [_recorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if( _brecwillsend )
    {
        [self willSendThisVoice:recorder.url  duration:_recduration];
    }
    
    [_timer invalidate];
    _timer = nil;
    
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error
{
    [SVProgressHUD showErrorWithStatus:@"录音失败"];
    
    [_timer invalidate];
    _timer = nil;
    
}


-(NSURL*)makerecfilepath
{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"recfile_%ld.acc",(NSInteger)[[NSDate date] timeIntervalSince1970]]];
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
#pragma mark 录音操作结束


- (IBAction)voiceclicked:(UIButton*)sender {
    
    self.minputtext.hidden = !self.minputtext.hidden;
    if( self.minputtext.isFirstResponder )
    {
        [self.minputtext resignFirstResponder];
    }
    if( self.mmorepanconsth.constant > 0 )
    {
        [self hidenMorePan];
    }
    
    [sender setBackgroundImage:[UIImage imageNamed:self.minputtext.hidden ?  @"2.0_sixin_jp_":@"icon_duijiang"] forState:UIControlStateNormal];
    
}

- (IBAction)faceclicked:(id)sender {
    [self clickedfacemore:YES];
}

- (IBAction)moreclicked:(id)sender {
    [self clickedfacemore:NO];
}

-(void)hidenMorePan
{
    [UIView animateWithDuration:0.3f animations:^{
        
        self.mmorepanconsth.constant = 0;
        [self.view layoutIfNeeded];
        
        _morepanstatus = 0;
        
    }];
}

-(void)clickedfacemore:(BOOL)bface
{
    if( !bface && _morepanstatus == 2 ) return;//已经是显示的输入更多,就不管了,
    
       
    if( self.mmorepanconsth.constant == 0 )
    {//那么就需要 显示下面的
        
        if( self.minputtext.isFirstResponder )
        {
            [self.minputtext resignFirstResponder];
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            
            self.mmorepanconsth.constant = MorePanH;
            
            [self.view layoutIfNeeded];
        }];
        
        _morepanstatus = bface ? 1 : 2;

        
        if( _morepanstatus == 1 )
            [self showFacePan];
        else if( _morepanstatus == 2 )
            [self showMorePan];
    }
    else{
        
        if( bface && _morepanstatus == 2 )
        {//只是要切换到 表情,不用隐藏
            _morepanstatus = 1;
            [self showFacePan];
        }
        else if( !bface && _morepanstatus == 1 )
        {//只是要切换到其他,不需 隐藏
            _morepanstatus = 2;
            [self showMorePan];
        }
        else        //隐藏下面的
            [self hidenMorePan];
    }
}

-(void)showFacePan
{
    [self cfgmoremoreview];
    [self.mmoremoreview setContentOffset:CGPointMake(0, 0)];
    [self hidenGiftView];
    
}

-(void)showMorePan
{
    [self cfgmoremoreview];
    
    [self.mmoremoreview setContentOffset:CGPointMake(_moreXpoint, 0)];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
