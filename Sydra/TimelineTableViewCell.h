//
//  TimelineTableViewCell.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task+CoreDataClass.h"
#import "MGSwipeTableCell.h"



@interface TimelineTableViewCell : MGSwipeTableCell
//@property (nonatomic,weak) id<TaskDelegate> delegate;
@property (nonatomic,weak) IBOutlet UIView* colorView;
@property (nonatomic,weak) IBOutlet UILabel* desclabel;
@property (nonatomic,weak) IBOutlet UILabel* timeLabel;
@property (nonatomic,weak) IBOutlet UILabel* locationLabel;
@property (nonatomic,weak) IBOutlet UIButton* doneButton;
@property (nonatomic) Task* task;
-(void)setTaskDone;
@end
