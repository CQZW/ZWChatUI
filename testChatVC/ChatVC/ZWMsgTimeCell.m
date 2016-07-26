//
//  ZWMsgTimeCell.m
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import "ZWMsgTimeCell.h"

@implementation ZWMsgTimeCell

- (void)awakeFromNib {
    // Initialization code
    
    self.mbgview.layer.cornerRadius = 3.0f;
    self.mbgview.layer.borderColor = [UIColor clearColor].CGColor;
    self.mbgview.layer.borderWidth = 1.0f;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
