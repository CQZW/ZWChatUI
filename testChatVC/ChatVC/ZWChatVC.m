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

@interface ZWChatVC ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ZWChatVC
{
    
    //更多输入的状态,0 隐藏了,1 表情,2其他
    int     _morepanstatus;
    
    BOOL    _cgfok;
    
    CGFloat         _moreXpoint;
    CGFloat         _gitXpoint;
    
    CGFloat         _lastInputH;
    
    NIMInputAudioRecordIndicatorView*   _recshowing;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;


}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    
    self.mtableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerStartRefresh)];

    self.mtableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerStartRefresh)];
    
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
}

#pragma mark 消息数据获取主要修改这里开始
//获取消息,修改这里
-(void)headerStartRefresh
{
    
    [self getMsgBefor:self.mmsgdata.firstObject block:^(NSArray *all) {
        
        [self.mtableview.mj_header endRefreshing];
        if( all.count )
        {
            for ( NSInteger j = all.count-1 ; j >= 0; j-- ) {
                ZWMsgObj* one  = all[ j ];
                [self.mmsgdata insertObject:one atIndex:0];
                if( (self.mmsgdata.count % 8) ==  0)
                {//每5个就显示一个时间..
                    ZWMsgObj* timemsg  = [self makeTimeMsgObj:one];
                    [self.mmsgdata insertObject:timemsg atIndex:1];
                }
            }
        }
        
        [self.mtableview reloadData];
    
    }];
    
}

-(void)footerStartRefresh
{
    [self getMsgAfter:self.mmsgdata.lastObject block:^(NSArray *all) {
        
        [self.mtableview.mj_footer endRefreshing];
        if( all.count )
        {
            for ( NSInteger j = 0 ; j < all.count; j++ ) {
                ZWMsgObj* one  = all[ j ];
                [self.mmsgdata addObject:one];
                if( (self.mmsgdata.count % 8) ==  0)
                {//每5个就显示一个时间..
                    ZWMsgObj* timemsg  = [self makeTimeMsgObj:one];
                    [self.mmsgdata addObject:timemsg];
                }
            }
        }
        
        [self.mtableview reloadData];
 
    }];
    
   
}

//获取 msg 之前的消息,,,
-(void)getMsgBefor:(ZWMsgObj*)msg block:(void(^)(NSArray*all))block
{
    if( [self isKindOfClass:[ZWChatVC class]] )
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
    if( [self isKindOfClass:[ZWChatVC class]] )
    {
        
        [testMsg getMsgList:msg block:^(NSArray *all) {
            
            block( all );
            
        }];
    }
}


-(ZWMsgObj*)makeTimeMsgObj:(ZWMsgObj*)msg
{
    ZWMsgObjTime* tt = ZWMsgObjTime.new;
    tt.mMsgDate = msg.mMsgDate;
    return tt;
}


-(void)willSendThisText:(NSString*)txt
{
    self.minputtext.text = nil;
    
    if( [self isKindOfClass:[ZWChatVC class]] )
    {
        //for test
        [self sendOneMsg:[testMsg makeTestTextMsg:txt]];
    }
}

-(void)willSendThisImg:(UIImage*)img
{
    if( [self isKindOfClass:[ZWChatVC class]] )
    {
        //for test
        [self sendOneMsg:[testMsg makeTestPicMsg:img]];
    }
    
}

-(void)sendOneMsg:(ZWMsgObj*)sendMsg
{
    [self.mmsgdata addObject:sendMsg];
    [self.mtableview beginUpdates];
    
    [self.mtableview insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.mmsgdata.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.mtableview endUpdates];
    
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
    UITableViewCell* cell = nil;
    ZWMsgObj* msgobj = self.mmsgdata[ indexPath.row ];
    if( msgobj.mMsgType == 0 )
    {//时间
        ZWMsgObjTime* timeobj = (ZWMsgObjTime*)msgobj;
        ZWMsgTimeCell* timecell = [tableView dequeueReusableCellWithIdentifier:@"timecell"];
        
        timecell.mtimelabel.text = [timeobj getTimeStr];
        cell =  timecell;
    }
    else{
        ZWMsgCellRight* retcell = nil;
        if( msgobj.mMsgType == 1 )
        {//文字消息
            ZWMsgObjText * textobj = (ZWMsgObjText*)msgobj;
            if( textobj.mIsSendOut )
            {
                retcell = [tableView dequeueReusableCellWithIdentifier:@"rightcell"];
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
            ZWMsgObjPic* picobj = (ZWMsgObjPic*)msgobj;
            
            ZWMsgPicCellRight* piccell = nil;
            if( picobj.mIsSendOut )
            {
                piccell = [tableView dequeueReusableCellWithIdentifier:@"picrightcell"];
            }
            else{
                piccell = [tableView dequeueReusableCellWithIdentifier:@"picleftcell"];
            }
            
#pragma mark 图片最宽
            CGFloat picShowW = tableView.bounds.size.width - 150.0f;//这是最大的
            
            picShowW = picobj.mPicW > picShowW ? picShowW  :  picobj.mPicW;
            
            picobj.mPicW = picobj.mPicW == 0.0f ? (picobj.mPicH +1):picobj.mPicW;
            
            CGFloat picShowH = ( picobj.mPicH / picobj.mPicW ) * picShowW;
            
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
            ZWMsgObjVoice* voiceobj = (ZWMsgObjVoice*)msgobj;
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
            
            vcell.mlonglabel.text = [NSString stringWithFormat:@"%d''",voiceobj.mDurlong];
            CGFloat ff = (voiceobj.mDurlong / 60.0f ) * 150.0f;
#pragma mark 声音cell最宽,最窄
            ff = ff < 50?50.0f:ff;
            ff = ff > 150.0f?150.0f:ff;
            
            vcell.mlongrateconstW.constant = ff;
           
            
            retcell = vcell;
        }
        else if( msgobj.mMsgType == 4 )
        {
            ZWMsgObjGift* gifobj = (ZWMsgObjGift*)msgobj;
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
        
        [retcell.mheadimg sd_setImageWithURL:[NSURL URLWithString:msgobj.mHeadImgUrl] placeholderImage:[UIImage imageNamed:@"ic_default_head"]];
        cell = retcell;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZWMsgObj* msgobj = self.mmsgdata[ indexPath.row ];
    if( msgobj.mMsgType == 3 )
    {//播放语音消息
        
        [((ZWMsgObjVoice*)msgobj) startPlayVoice];
        
        [tableView reloadRowsAtIndexPaths:@[ indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
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
    _gitXpoint = contW;
    
    
    //然后是礼物的
    
    
    
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
    }
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
        
        [textView resignFirstResponder];
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

- (IBAction)onTouchRecordBtnDown:(id)sender {
    //self.recordPhase = AudioRecordPhaseStart;
    [self showRecSV:1];
}
- (IBAction)onTouchRecordBtnUpInside:(id)sender {
    // finish Recording
    //self.recordPhase = AudioRecordPhaseEnd;
    [self showRecSV:4];
}
- (IBAction)onTouchRecordBtnUpOutside:(id)sender {
    //TODO cancel Recording
    //self.recordPhase = AudioRecordPhaseEnd;
    [self showRecSV:4];
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
            
            self.mmorepanconsth.constant = 234;
            
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
