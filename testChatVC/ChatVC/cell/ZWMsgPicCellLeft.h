//
//  ZWMsgPicCellLeft.h
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWMsgPicCellLeft : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mheadimg;
@property (weak, nonatomic) IBOutlet UIImageView *mtagimg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mimgconstW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mimgconstH;

@end
