//
//  AppDelegate.h
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Task+CoreDataClass.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

+(AppDelegate*)getAppDelegate;
- (void)buildAgreeTextViewFromString:(NSString *)localizedString atContainer:(UIView*)container andController:(UIViewController*)controller;
-(void)showActivityIndicator:(BOOL)show;
-(void)addNotification:(NSDictionary*)dictionary;
-(void)showAlertOnViewController:(UIViewController*)controller WithMessage:(NSString*)message andTitle:(NSString*)title;
-(void)removeNotificationWithTask:(Task*)task;
@end

