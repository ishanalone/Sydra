//
//  LoginTableViewCell.m
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "LoginTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
@implementation LoginTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //[self SetTextFieldBorder:self.inputField];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)SetTextFieldBorder :(UITextField *)textfield{
    CGRect rect = CGRectMake(([AppDelegate getAppDelegate].window.frame.size.width - 300)/2, 51, 300, 2.0f);
    UIView *bottomBorder = [[UIView alloc]
                            initWithFrame:rect];
    bottomBorder.backgroundColor = [UIColor colorWithRed:243/255.0f
                                                   green:243/255.0f
                                                    blue:243/255.0f
                                                   alpha:1.0f];
    [self.contentView addSubview:bottomBorder];
}
@end
