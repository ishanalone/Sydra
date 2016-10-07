//
//  CoreDataHandler.m
//  Sydra
//
//  Created by Ishan Alone on 07/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "CoreDataHandler.h"
#import "Task+CoreDataClass.h"
#import "AppDelegate.h"

@implementation CoreDataHandler
static CoreDataHandler *sharedInstance = nil;
+ (instancetype)sharedInstance
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoreDataHandler alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(void)addTask:(NSDictionary*)taskDictionary{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    Task *task = (Task*)[[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    task.taskId = [NSString stringWithFormat:@"%d",[[taskDictionary objectForKey:@"id"] intValue]];
    task.taskDate = [taskDictionary objectForKey:@"date"];
    task.taskTime = [taskDictionary objectForKey:@"time"];
    task.taskLocation = [taskDictionary objectForKey:@"location"];
    task.taskCordinates = [taskDictionary objectForKey:@"coordinates"];
    task.taskColor = [taskDictionary objectForKey:@"color"];
    task.taskDetail = [taskDictionary objectForKey:@"desc"];
    [[AppDelegate getAppDelegate] saveContext];
}

-(NSArray*)getAllTask{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *result = [[AppDelegate getAppDelegate].persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        NSLog(@"%@", result);
        return result;
    }
    return nil;

}

-(NSArray*)getAllDate{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    
    // Required! Unless you set the resultType to NSDictionaryResultType, distinct can't work.
    // All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
    // Since you only want distinct names, only ask for the 'name' property.
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"taskDate"]];
    fetchRequest.returnsDistinctResults = YES;
    
    // Now it should yield an NSArray of distinct values in dictionaries.
    NSArray *dictionaries = [[AppDelegate getAppDelegate].persistentContainer.viewContext executeFetchRequest:fetchRequest error:nil];
    return dictionaries;
}

-(NSArray*)getallTaskForDate:(NSString*)date{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"taskDate", date];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [[AppDelegate getAppDelegate].persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        NSLog(@"%@", result);
        return result;
    }
    return nil;
}

@end
