//
//  NewTaskViewController.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTaskViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UITableView* taskTable;
@property (nonatomic,strong) NSDictionary* locationDictionary;
@property (nonatomic) BOOL isEdit;
-(void)fillLocationDetails;
@end
