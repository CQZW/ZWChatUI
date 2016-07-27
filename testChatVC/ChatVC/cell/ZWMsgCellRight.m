//
//  ZWMsgCellRight.m
//  testChatVC
//
//  Created by zzl on 16/7/26.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import "ZWMsgCellRight.h"
#import "M80AttributedLabel.h"
@implementation ZWMsgCellRight

- (void)awakeFromNib {
    // Initialization code
    
    self.mmsglabel.font = [UIFont systemFontOfSize:14];
    self.mmsglabel.textColor = [UIColor blackColor];
    self.mmsglabel.backgroundColor = [UIColor clearColor];
    self.mmsglabel.textAlignment =  kCTTextAlignmentLeft;
    
    
    self.mheadimg.layer.borderColor = [UIColor clearColor].CGColor;
    self.mheadimg.layer.borderWidth = 1.0f;
    self.mheadimg.layer.cornerRadius = 20.0f;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

    
    
}

@end
