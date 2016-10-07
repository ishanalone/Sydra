//
//  NewTaskTableViewCell.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTaskTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UITextField* inputField;
@property (nonatomic,weak) IBOutlet UILabel* placeholderLabel;
@end
