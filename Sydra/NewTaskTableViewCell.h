//
//  NewTaskTableViewCell.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Material;

@interface NewTaskTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet TextField* inputField;
@property (nonatomic,weak) IBOutlet UILabel* placeholderLabel;
@end
