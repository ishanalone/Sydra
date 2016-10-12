//
//  NewTaskViewController.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task+CoreDataClass.h"
#import "TimelineViewController.h"

@interface NewTaskViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UITableView* taskTable;
@property (nonatomic,weak) IBOutlet UILabel* titleHeader;
@property (nonatomic,weak) IBOutlet UIButton* createButton;
@property (nonatomic,strong) NSDictionary* locationDictionary;
@property (nonatomic,strong) TimelineViewController* controller;
@property (nonatomic) BOOL isEdit;
-(void)fillLocationDetails;
-(void)fillAllDetailsWithTask:(Task*)task;
@end
