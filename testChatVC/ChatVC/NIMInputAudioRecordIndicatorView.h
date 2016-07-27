//
//  NIMInputAudioRecordIndicatorView.h
//  NIMKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NIMInputAudioRecordIndicatorView : UIView

@property (nonatomic,assign)    int             mstatus;//1 开始了,,2 显示上滑什么,,,3 显示取消

@property (nonatomic, assign) NSTimeInterval recordTime;

@end
