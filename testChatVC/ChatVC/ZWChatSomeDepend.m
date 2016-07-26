//
//  ZWChatSomeDepend.m
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import "ZWChatSomeDepend.h"
#import "ZWChatVC.h"
@implementation ZWChatSomeDepend



+(NSString *) FormartTime:(NSDate*) compareDate
{
    
    if( compareDate == nil ) return @"";
    
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = timeInterval;
    NSString *result;
    
    if (timeInterval < 60) {
        if( temp == 0 )
            result = @"刚刚";
        else
            result = [NSString stringWithFormat:@"%d秒前",(int)temp];
    }
    else if(( timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%d分钟前",(int)temp/60];
    }
    
    else if(( temp/86400) <30){
        
        NSDateFormatter *date = [[NSDateFormatter alloc] init];
        [date setDateFormat:@"dd"];
        NSString *str = [date stringFromDate:[NSDate date]];
        int nowday = [str intValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd"];
        NSString *strDate = [dateFormatter stringFromDate:compareDate];
        int day = [strDate intValue];
        if (nowday-day==0) {
            [dateFormatter setDateFormat:@"今天 HH:mm"];
            result =    [dateFormatter stringFromDate:compareDate];
        }
        else if(nowday-day==1)
        {
            
            [dateFormatter setDateFormat:@"昨天 HH:mm"];
            result =  [dateFormatter stringFromDate:compareDate];
            
            
        }
        
        
        else if( temp < 8 )
        {
            if (temp==1) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"昨天HH:mm"];
                NSString *strDate = [dateFormatter stringFromDate:compareDate];
                result = strDate;
            }
            else if(temp == 2)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"前天HH:mm"];
                NSString *strDate = [dateFormatter stringFromDate:compareDate];
                result = strDate;
            }
            
        }
        else
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            NSString *strDate = [dateFormatter stringFromDate:compareDate];
            result = strDate;
            
        }
    }
    else
    {//超过一个月的就直接显示时间了
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *strDate = [dateFormatter stringFromDate:compareDate];
        result = strDate;
    }
    
    /*
     else if((temp = (temp/(3600*24))/30) <12){
     result = [NSString stringWithFormat:@"%d个月前",(int)temp];
     }
     else{
     temp = temp/12;
     result = [NSString stringWithFormat:@"%d年前",(int)temp];
     }
     */
    
    return  result;
}
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

@implementation ZWMsgObj


@end


@implementation ZWMsgObjTime

-(NSString*)getTimeStr
{
    return [ZWChatSomeDepend FormartTime:self.mMsgDate];
}

@end


@implementation ZWMsgObjText


@end













