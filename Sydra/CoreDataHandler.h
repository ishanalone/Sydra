//
//  CoreDataHandler.h
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface CoreDataHandler : NSObject
+ (instancetype)sharedInstance;
-(void)addTask:(NSDictionary*)taskDictionary;
-(NSArray*)getAllTask;
-(NSArray*)getAllDate;
-(NSArray*)getallTaskForDate:(NSString*)date;
@end
