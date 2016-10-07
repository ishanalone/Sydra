//
//  TealButton.m
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "TealButton.h"

@implementation TealButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [[UIColor colorWithRed:80.0f/255.0f green:210.0f/255.0f blue:194.0f/255.0f alpha:1] set];
    UIRectFill(rect);
}


@end
