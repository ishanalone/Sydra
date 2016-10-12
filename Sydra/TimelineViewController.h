//
//  TimelineViewController.h
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
@interface TimelineViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MGSwipeTableCellDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeightConstraint;
-(void)reloadCalendar;
@end
