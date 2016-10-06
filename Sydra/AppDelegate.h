//
//  AppDelegate.h
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

