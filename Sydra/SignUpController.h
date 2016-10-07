//
//  SignUpController.h
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@interface SignUpController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,weak) IBOutlet UITableView* signUpTable;
@property (nonatomic,weak) IBOutlet UIView* container;
@property (nonatomic,strong) ViewController* controller;
@end
