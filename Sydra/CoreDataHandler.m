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
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"taskId", taskDictionary[@"id"]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [[AppDelegate getAppDelegate].persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    Task *task;
    if (result.count > 0) {
        task = result[0];
    }else{
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
        task = (Task*)[[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    }
    
    task.taskId = [NSString stringWithFormat:@"%d",[[taskDictionary objectForKey:@"id"] intValue]];
    task.taskDate = [taskDictionary objectForKey:@"date"];
    task.taskTime = [taskDictionary objectForKey:@"time"];
    task.taskLocation = [taskDictionary objectForKey:@"location"];
    task.taskCordinates = [taskDictionary objectForKey:@"coordinates"];
    NSDictionary* colorDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ColorList" ofType:@"plist"]];
    NSString* color = taskDictionary[@"color"];
    if ([color isEqualToString:@"-1"] || [color integerValue] > 12) {
        color = @"0";
    }
    task.taskColor = [[colorDictionary allKeys] objectAtIndex:[color integerValue]];
    if ([taskDictionary objectForKey:@"desc"] != [NSNull null]) {
        task.taskDetail = [taskDictionary objectForKey:@"desc"];
    }
    

    task.taskState = NO;
    if (result.count == 0) {
        [[AppDelegate getAppDelegate] addNotification:taskDictionary];
    }
    
}

-(Task*)updateTask:(NSDictionary*)taskDictionary withId:(NSString*)tid{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"taskId", tid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [[AppDelegate getAppDelegate].persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    Task* task;
    if (result) {
        task = result[0];
        task.taskId = [NSString stringWithFormat:@"%d",[[taskDictionary objectForKey:@"id"] intValue]];
        task.taskDate = [taskDictionary objectForKey:@"date"];
        task.taskTime = [taskDictionary objectForKey:@"time"];
        task.taskLocation = [taskDictionary objectForKey:@"location"];
        task.taskCordinates = [taskDictionary objectForKey:@"coordinates"];
        task.taskColor = [taskDictionary objectForKey:@"color"];
        task.taskDetail = [taskDictionary objectForKey:@"desc"];
        task.taskState = NO;
    }
    [[AppDelegate getAppDelegate] saveContext];
    
    return task;
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
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"taskDate" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
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
       
        return result;
    }
    return nil;
}

-(void)setTaskDone:(NSString*)tid{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"taskId", tid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [[AppDelegate getAppDelegate].persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    if (result) {
        Task* task = result[0];
        task.taskState = YES;
    }
    [[AppDelegate getAppDelegate] saveContext];
}

-(void)deleteTaskWithId:(NSString*)tid{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"taskId", tid];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [[AppDelegate getAppDelegate].persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
    if (result) {
        Task* task = result[0];
        [[AppDelegate getAppDelegate].persistentContainer.viewContext deleteObject:task];
    }
    [[AppDelegate getAppDelegate] saveContext];
}

-(void)clearAllData{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:[AppDelegate getAppDelegate].persistentContainer.viewContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [[AppDelegate getAppDelegate].persistentContainer.viewContext executeFetchRequest:fetchRequest error:&error];
   
    
    
    for (NSManagedObject *managedObject in items) {
        [[AppDelegate getAppDelegate].persistentContainer.viewContext deleteObject:managedObject];
        
    }
    [[AppDelegate getAppDelegate]saveContext];
    
}

@end
