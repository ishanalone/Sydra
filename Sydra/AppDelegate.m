//
//  AppDelegate.m
//  Sydra
//
//  Created by Ishan Alone on 06/10/16.
//  Copyright © 2016 Ishan Alone. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import "Task+CoreDataClass.h"
#import <UserNotifications/UserNotifications.h>
#import "CoreDataHandler.h"

@interface AppDelegate ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *notifLocation;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:settings];
    [self setupLocationMonitoring];
    return YES;
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    NSLog(@"Registered");
}
+(AppDelegate*)getAppDelegate{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

-(void)showActivityIndicator:(BOOL)show{
    if (show) {
        [SVProgressHUD show];
    }else{
        [SVProgressHUD dismiss];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"Did recieve local notifcation");
}

- (void)buildAgreeTextViewFromString:(NSString *)localizedString atContainer:(UIView*)container andController:(UIViewController*)controller
{
    // 1. Split the localized string on the # sign:
    NSArray *localizedStringPieces = [localizedString componentsSeparatedByString:@"#"];
    
    // 2. Loop through all the pieces:
    NSUInteger msgChunkCount = localizedStringPieces ? localizedStringPieces.count : 0;
    CGPoint wordLocation = CGPointMake(0.0, 0.0);
    for (NSUInteger i = 0; i < msgChunkCount; i++)
    {
        NSString *chunk = [localizedStringPieces objectAtIndex:i];
        if ([chunk isEqualToString:@""])
        {
            continue;     // skip this loop if the chunk is empty
        }
        
        // 3. Determine what type of word this is:
        
        BOOL isSignUp  = [chunk hasPrefix:@"<si>"];
        BOOL isLink =  isSignUp;
        
        // 4. Create label, styling dependent on whether it's a link:
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:11.0f];
        label.text = chunk;
        label.userInteractionEnabled = isLink;
        [label setTextAlignment:NSTextAlignmentCenter];
        
        if (isLink)
        {
            label.textColor = [UIColor blackColor];
            label.highlightedTextColor = [UIColor blackColor];
            
            // 5. Set tap gesture for this clickable text:
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:controller
                                                                                         action:@selector(tapOnLink:)];
            
            [label addGestureRecognizer:tapGesture];
            
            // Trim the markup characters from the label:
            
            label.text = [label.text stringByReplacingOccurrencesOfString:@"<si>" withString:@""];
            
            
        }
        else
        {
            label.textColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0];
        }
        
        // 6. Lay out the labels so it forms a complete sentence again:
        
        // If this word doesn't fit at end of this line, then move it to the next
        // line and make sure any leading spaces are stripped off so it aligns nicely:
        
        [label sizeToFit];
        
        if (container.frame.size.width < wordLocation.x + label.bounds.size.width)
        {
            wordLocation.x = 0.0;                       // move this word all the way to the left...
            wordLocation.y += label.frame.size.height;  // ...on the next line
            
            // And trim of any leading white space:
            NSRange startingWhiteSpaceRange = [label.text rangeOfString:@"^\\s*"
                                                                options:NSRegularExpressionSearch];
            if (startingWhiteSpaceRange.location == 0)
            {
                label.text = [label.text stringByReplacingCharactersInRange:startingWhiteSpaceRange
                                                                 withString:@""];
                [label sizeToFit];
            }
        }
        
        // Set the location for this label:
        label.frame = CGRectMake(wordLocation.x,
                                 wordLocation.y,
                                 label.frame.size.width,
                                 label.frame.size.height);
        // Show this label:
        [container addSubview:label];
        
        // Update the horizontal position for the next word:
        wordLocation.x += label.frame.size.width;
    }
}

- (void) setupLocationMonitoring
{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.pausesLocationUpdatesAutomatically=NO;
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10.0f; // meters
    
    // iOS 8+ request authorization to track the user’s location
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // check status to see if we’re authorized
    BOOL canUseLocationNotifications = (status == kCLAuthorizationStatusAuthorizedWhenInUse);
    if (canUseLocationNotifications) {
        //[self registerLocationNotification];
    }
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSArray* taskArr = [[CoreDataHandler sharedInstance] getAllTask];
    CLLocation* location = [locations lastObject];
    for (int i = 0; i<taskArr.count; i++) {
        Task* task = taskArr[i];
        if (!task.taskState) {
            NSArray* locArray = [task.taskCordinates componentsSeparatedByString:@","];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([locArray[0] floatValue], [locArray[1] floatValue]);
            CLLocation* taskLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            CLLocationDistance distnace = [location distanceFromLocation:taskLocation];
            if (distnace < 1000) {
               UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                localNotification.alertBody = task.taskDetail;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            }
        }
    }
}

-(void)addNotification:(NSDictionary*)dictionary{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
   
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"IST"]];
    NSDate* date = [formatter dateFromString:dictionary[@"date"]];
    //date = [self toLocalTime:date];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSDate* time = [formatter dateFromString:dictionary[@"time"]];
    
    NSDate* combined = [self combineDate:date withTime:time];
    //combined = [self toLocalTime:combined];
    localNotification.fireDate = combined;
    localNotification.alertBody = dictionary[@"desc"];
    localNotification.timeZone = [NSTimeZone timeZoneWithName:@"IST"];
    localNotification.soundName = @"notify.m4r";//UILocalNotificationDefaultSoundName;
    localNotification.regionTriggersOnce = NO;
    localNotification.userInfo = @{@"id":[NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"id"] intValue]]};
    NSArray* corArray = [dictionary[@"coordinates"] componentsSeparatedByString:@","];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([corArray[0] floatValue], [corArray[1] floatValue]);
    CLRegion* region =   [[CLCircularRegion alloc] initWithCenter:coordinate radius:1000 identifier:@"target"];
    localNotification.region = region;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    /*UNNotificationAction *okAction = [UNNotificationAction actionWithIdentifier:@"OKIdentifier" title:@"Ok" options:UNNotificationActionOptionForeground];;
    UNNotificationAction *cancelAction = [UNNotificationAction actionWithIdentifier:@"CancelIdentifier" title:@"Ok" options:UNNotificationActionOptionForeground];*/
    
   /* UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = dictionary[@"desc"];
    content.sound = [UNNotificationSound defaultSound];
    
    
    NSCalendar *calendar            = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear  |
                                                         NSCalendarUnitMonth |
                                                         NSCalendarUnitDay   |
                                                         NSCalendarUnitHour  |
                                                         NSCalendarUnitMinute|
                                                         NSCalendarUnitSecond) fromDate:combined];
    
    UNCalendarNotificationTrigger* timeTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"LocalNotification" content:content trigger:timeTrigger];
    
    CLLocationCoordinate2D cordinate = CLLocationCoordinate2DMake([[[[dictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue], [[[[dictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue]);
    CLCircularRegion* triggerRegion = [[CLCircularRegion alloc] initWithCenter:coordinate radius:1000 identifier:@"location"];
    
    UNLocationNotificationTrigger* locTrigger = [UNLocationNotificationTrigger triggerWithRegion:triggerRegion repeats:NO];
    UNNotificationRequest* request1 = [UNNotificationRequest requestWithIdentifier:@"LocalNotification" content:content trigger:locTrigger];*/
    
    
}

-(void)removeNotificationWithTask:(Task*)task{
    NSString *myIDToCancel = task.taskId;
    UILocalNotification *notificationToCancel=nil;
    for(UILocalNotification *aNotif in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if([[aNotif.userInfo objectForKey:@"id"] isEqualToString:myIDToCancel]) {
            notificationToCancel=aNotif;
            break;
        }
    }
    if(notificationToCancel) [[UIApplication sharedApplication] cancelLocalNotification:notificationToCancel];
}

-(NSDate *) toLocalTime:(NSDate*)date
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

- (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:
                             NSCalendarIdentifierGregorian];
    [gregorian setTimeZone:[NSTimeZone timeZoneWithName:@"IST"]];
    unsigned unitFlagsDate = NSCalendarUnitYear | NSCalendarUnitMonth
    |  NSCalendarUnitDay;
    NSDateComponents *dateComponents = [gregorian components:unitFlagsDate
                                                    fromDate:date];
    unsigned unitFlagsTime = NSCalendarUnitHour | NSCalendarUnitMinute
    |  NSCalendarUnitSecond;
    NSDateComponents *timeComponents = [gregorian components:unitFlagsTime
                                                    fromDate:time];
    
    [dateComponents setSecond:[timeComponents second]];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    
    NSDate *combDate = [gregorian dateFromComponents:dateComponents];   
    
    return combDate;
}




#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Sydra"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        if (error) {
            
        }
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        //abort();
    }
}

-(void)dealloc{
    
    NSLog(@"App killed");
}

@end
