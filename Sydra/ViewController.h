//
//  ViewController.h
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+Shake.h"

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UITableView* loginTable;
@property (nonatomic,weak) IBOutlet UIView* container;
@property (nonatomic,weak) IBOutlet UILabel* logoLabel;
@property (nonatomic,weak) IBOutlet UIImageView* logoImage;
-(void)fillLoginValues:(NSArray*)array;
@end

