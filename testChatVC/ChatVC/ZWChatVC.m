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
#import "testMsg.h"
#import "ZWChatSomeDepend.h"
#import "UIImageView+WebCache.h"
#import "M80AttributedLabel.h"
@interface ZWChatVC ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation ZWChatVC
{
    
    //更多输入的状态,0 隐藏了,1 表情,2其他
    int     _morepanstatus;
    
    BOOL    _cgfok;
    
    CGFloat         _moreXpoint;
    CGFloat         _gitXpoint;
    
    CGFloat         _lastInputH;
    
    NSMutableArray* _msgdata;

    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
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
    
    
    _msgdata = NSMutableArray.new;
    
    self.mtableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerStartRefresh)];

    self.mtableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerStartRefresh)];
    
    UINib* nib = [UINib nibWithNibName:@"ZWMsgCellLeft" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"leftcell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgCellRight" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"rightcell"];
    
    nib = [UINib nibWithNibName:@"ZWMsgTimeCell" bundle:nil];
    [self.mtableview registerNib:nib forCellReuseIdentifier:@"timecell"];
    
    self.mtableview.delegate = self;
    self.mtableview.dataSource =  self;
    
    self.mtableview.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark 消息数据获取主要修改这里开始
//获取消息,修改这里
-(void)headerStartRefresh
{
    [testMsg getMsgList:_msgdata.firstObject block:^(NSArray *all) {
    
        [self.mtableview.mj_header endRefreshing];
        if( all.count )
        {
            for ( NSInteger j = all.count-1 ; j >=0; j-- ) {
                ZWMsgObj* one  = all[ j ];
                [_msgdata insertObject:one atIndex:0];
                if( _msgdata.count % 5 )
                {//每5个就显示一个时间..
                    ZWMsgObj* timemsg  = [self makeTimeMsgObj:one];
                    [_msgdata insertObject:timemsg atIndex:1];
                }
            }
        }
        
        [self.mtableview reloadData];

    }];
    
}

-(void)footerStartRefresh
{
    [testMsg getMsgList:_msgdata.lastObject block:^(NSArray *all) {
        
        [self.mtableview.mj_footer endRefreshing];
        if( all.count )
        {
            for ( NSInteger j = 0 ; j < all.count; j++ ) {
                ZWMsgObj* one  = all[ j ];
                [_msgdata addObject:one];
                if( (_msgdata.count % 5) ==  0)
                {//每5个就显示一个时间..
                    ZWMsgObj* timemsg  = [self makeTimeMsgObj:one];
                    [_msgdata addObject:timemsg];
                }
            }
        }
        
        [self.mtableview reloadData];
        
    }];
}

-(ZWMsgObj*)makeTimeMsgObj:(ZWMsgObj*)msg
{
    ZWMsgObjTime* tt = ZWMsgObjTime.new;
    tt.mMsgDate = msg.mMsgDate;
    return tt;
}

//获取消息,修改这里
#pragma mark 消息数据获取主要修改这里结束

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _msgdata.count;
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
    ZWMsgObj* msgobj = _msgdata[ indexPath.row ];
    if( msgobj.mMsgType == 0 )
    {//时间
        ZWMsgObjTime* timeobj = (ZWMsgObjTime*)msgobj;
        ZWMsgTimeCell* timecell = [tableView dequeueReusableCellWithIdentifier:@"timecell"];
        
        timecell.mtimelabel.text = [timeobj getTimeStr];
        cell =  timecell;
    }
    else if( msgobj.mMsgType == 1 )
    {//文字消息
        ZWMsgObjText * textobj = (ZWMsgObjText*)msgobj;
        if( textobj.mIsSendOut )
        {
            ZWMsgCellRight* cellsend = [tableView dequeueReusableCellWithIdentifier:@"rightcell"];
            [cellsend.mheadimg sd_setImageWithURL:[NSURL URLWithString:textobj.mHeadImgUrl] placeholderImage:[UIImage imageNamed:@"ic_default_head"]];
            cellsend.mmsglabel.text =  textobj.mTextMsg;
            [cellsend.mmsglabel appendImage:[UIImage imageNamed:@"face1.png"] maxSize:CGSizeMake(20, 20)];
            
            CGSize ss = [cellsend.mmsglabel sizeThatFits:CGSizeMake(tableView.bounds.size.width- 68 - 50, CGFLOAT_MAX)];
            cellsend.mlabelconstH.constant = ss.height;
            cellsend.mlabelconstW.constant = ss.width;
            cell = cellsend;
        }
        else{
            ZWMsgCellLeft* cellrecv = [tableView dequeueReusableCellWithIdentifier:@"leftcell"];
            [cellrecv.mheadimg sd_setImageWithURL:[NSURL URLWithString:textobj.mHeadImgUrl] placeholderImage:[UIImage imageNamed:@"ic_default_head"]];
            cellrecv.mmsglabel.text =  textobj.mTextMsg;
            [cellrecv.mmsglabel appendImage:[UIImage imageNamed:@"face1.png"] maxSize:CGSizeMake(20, 20)];
            
            CGSize ss = [cellrecv.mmsglabel sizeThatFits:CGSizeMake(tableView.bounds.size.width- 73 - 50, CGFLOAT_MAX)];
            cellrecv.mlabelconstH.constant = ss.height;
            cellrecv.mlabelconstW.constant = ss.width;
            cell = cellrecv;
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
        
    }
    else
    if( sender.tag < 1000 )
    {
        self.minputtext.text = [self.minputtext.text stringByAppendingString:[NSString stringWithFormat:@"[face%ld]",sender.tag]];
        [self textViewDidChange:self.minputtext];
    }
    else
    {//相册,照片,礼物什么的
        
    }
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

- (IBAction)onTouchRecordBtnDown:(id)sender {
    //self.recordPhase = AudioRecordPhaseStart;
}
- (IBAction)onTouchRecordBtnUpInside:(id)sender {
    // finish Recording
    //self.recordPhase = AudioRecordPhaseEnd;
}
- (IBAction)onTouchRecordBtnUpOutside:(id)sender {
    //TODO cancel Recording
    //self.recordPhase = AudioRecordPhaseEnd;
}

- (IBAction)onTouchRecordBtnDragInside:(id)sender {
    //TODO @"手指上滑，取消发送"
    //self.recordPhase = AudioRecordPhaseRecording;
}
- (IBAction)onTouchRecordBtnDragOutside:(id)sender {
    //TODO @"松开手指，取消发送"
    //self.recordPhase = AudioRecordPhaseCancelling;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self hidenMorePan];
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
