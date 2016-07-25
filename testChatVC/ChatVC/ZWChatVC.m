//
//  ZWChatVC.m
//  testChatVC
//
//  Created by zzl on 16/7/25.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import "ZWChatVC.h"
#import "IQKeyboardManager.h"

@interface ZWFaceBT : UIView

@property (nonatomic,weak) ZWChatVC* mtagvc;

@property (nonatomic,assign)    NSInteger   mIndex;


@end

@interface ZWMoreBT : ZWFaceBT


@end

@implementation ZWMoreBT
{
    UILabel*    _bottomlabel;
    UIImageView*    _itimg;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    _bottomlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-25, frame.size.width, 20.0f)];
    _bottomlabel.font = [UIFont systemFontOfSize:14];
    _bottomlabel.textAlignment = NSTextAlignmentCenter;
    _bottomlabel.textColor = [UIColor colorWithWhite:0.518 alpha:1.000];
    [self addSubview:_bottomlabel];
    
    return self;
}

-(void)setTxt:(NSString*)text
{
    _bottomlabel.text = text;
}
-(void)setImg:(UIImage*)img
{
    _itimg = [[UIImageView alloc]initWithImage:img];
    [self addSubview:_itimg];

    CGRect ff = _itimg.frame;
    ff.size.width = img.size.width*0.6f;
    ff.size.height = img.size.height*0.6f;
    _itimg.frame = ff;
    
    _itimg.center = CGPointMake( self.bounds.size.width/2.0f , self.bounds.size.height/2.0f );

    _bottomlabel.center = CGPointMake( _itimg.center.x ,  ff.origin.y + ff.size.height + 25.0f );
    
    
}

@end

@implementation ZWFaceBT
{
    UIImageView*    _imgv;
    UIButton*       _bt;
    

    
}


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    _bt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self addSubview:_bt];
    [_bt addTarget:self action:@selector(ZWFaceBTclicked:) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

-(void)ZWFaceBTclicked:(UIButton*)sender
{
    if( self.mtagvc )
    {
        sender.tag = _mIndex;
        [self.mtagvc performSelector:@selector(moreItemClicked:) withObject:sender];
    }
}
-(void)setImg:(UIImage*)img
{
    [self setImg:img sss:0.6f];
    
}

-(void)setImg:(UIImage*)img sss:(CGFloat)sss
{
    _imgv = [[UIImageView alloc]initWithImage:img];
    [self addSubview:_imgv];
    
    CGRect ff = _imgv.frame;
    ff.size.width = img.size.width*sss;
    ff.size.height = img.size.height*sss;
    _imgv.frame = ff;
    
    _imgv.center = CGPointMake( self.bounds.size.width/2.0f , self.bounds.size.height/2.0f );

}

@end

@interface ZWChatVC ()<UITextViewDelegate>

@end

@implementation ZWChatVC
{
    
    //更多输入的状态,0 隐藏了,1 表情,2其他
    int     _morepanstatus;
    
    BOOL    _cgfok;
    
    CGFloat         _moreXpoint;
    CGFloat         _gitXpoint;
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

    
    self.mvoicebtpress.layer.borderColor = [UIColor colorWithRed:0.788 green:0.792 blue:0.804 alpha:1.000].CGColor;
    self.mvoicebtpress.layer.borderWidth = 1.0f;
    self.mvoicebtpress.layer.cornerRadius = 3.0f;
    
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnDown:) forControlEvents:UIControlEventTouchDown];
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnDragInside:) forControlEvents:UIControlEventTouchDragInside];
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.mvoicebtpress addTarget:self action:@selector(onTouchRecordBtnUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
}

-(void)cfgmoremoreview
{
    if( _cgfok ) return;
    _cgfok = YES;
    
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
    NSLog(@"xx:%d",sender.tag);
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
