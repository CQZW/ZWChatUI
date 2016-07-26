//
//  ZWMsgCellLeft.m
//  testChatVC
//
//  Created by zzl on 16/7/25.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import "ZWMsgCellLeft.h"
#import "M80AttributedLabel.h"

@implementation ZWMsgCellLeft

- (void)awakeFromNib {
    // Initialization code
    self.mmsglabel.font = [UIFont systemFontOfSize:14];
    self.mmsglabel.textColor = [UIColor blackColor];
    self.mmsglabel.backgroundColor = [UIColor clearColor];
    self.mmsglabel.textAlignment =  kCTTextAlignmentLeft;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
