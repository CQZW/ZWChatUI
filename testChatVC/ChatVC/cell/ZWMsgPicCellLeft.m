//
//  ZWMsgPicCellLeft.m
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import "ZWMsgPicCellLeft.h"

@implementation ZWMsgPicCellLeft

- (void)awakeFromNib {
    // Initialization code
    
    self.mheadimg.layer.borderColor = [UIColor clearColor].CGColor;
    self.mheadimg.layer.borderWidth = 1.0f;
    self.mheadimg.layer.cornerRadius = 20.0f;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
