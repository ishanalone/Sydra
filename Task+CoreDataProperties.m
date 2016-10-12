//
//  Task+CoreDataProperties.m
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "Task+CoreDataProperties.h"

@implementation Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Task"];
}

@dynamic taskColor;
@dynamic taskDate;
@dynamic taskDetail;
@dynamic taskId;
@dynamic taskLocation;
@dynamic taskTime;
@dynamic taskCordinates;
@dynamic taskState;

@end
