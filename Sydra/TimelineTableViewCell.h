//
//  TimelineTableViewCell.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIView* colorView;
@property (nonatomic,weak) IBOutlet UILabel* desclabel;
@property (nonatomic,weak) IBOutlet UILabel* timeLabel;
@property (nonatomic,weak) IBOutlet UILabel* locationLabel;
@end
