//
//  ZWChatVC.h
//  testChatVC
//
//  Created by zzl on 16/7/25.
//  Copyright © 2016年 zzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWChatVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *mtopview;
@property (weak, nonatomic) IBOutlet UILabel *mtoptitle;


@property (weak, nonatomic) IBOutlet UITableView *mtableview;

@property (weak, nonatomic) IBOutlet UIView *minputview;
@property (weak, nonatomic) IBOutlet UIButton *mleftvoicebt;
@property (weak, nonatomic) IBOutlet UIButton *mfacebt;
@property (weak, nonatomic) IBOutlet UIButton *mmorebt;

@property (weak, nonatomic) IBOutlet UITextView *minputtext;
@property (weak, nonatomic) IBOutlet UIButton *mvoicebtpress;

@property (weak, nonatomic) IBOutlet UIView *mmoreinputpan;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mmorepanconsth;


@property (weak, nonatomic) IBOutlet UIScrollView *mmoremoreview;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *minputbarconsth;


@end
