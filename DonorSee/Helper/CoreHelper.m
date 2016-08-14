//
//  CoreHelper.m
//  Salon01
//
//  Created by jian on 7/28/15.
//  Copyright (c) 2015 jian. All rights reserved.
//

#import "CoreHelper.h"
#import <CoreData/CoreData.h>

@implementation CoreHelper
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//====================================================================================================
+ (CoreHelper*)sharedInstance
{
    static CoreHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CoreHelper alloc] init];
    });
    return sharedInstance;
}
#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.

//====================================================================================================
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.

//====================================================================================================
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.

//====================================================================================================
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GlobalMission.sqlite"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

//====================================================================================================
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

//====================================================================================================
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark Global.

//====================================================================================================
- (void) logout
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Global"
                                        inManagedObjectContext:context]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    NSManagedObject* object;
    if ([results count] > 0)
    {
        object = [results firstObject];
        
    }
    else
    {
        object = [NSEntityDescription insertNewObjectForEntityForName:@"Global" inManagedObjectContext:context];
    }
    
    [object setValue: [NSNumber numberWithInt: -1] forKey:@"current_user_id"];
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else
    {
        
    }

}

//====================================================================================================
- (void) setCurrentUserId: (int) user_id
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Global"
                                        inManagedObjectContext:context]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    NSManagedObject* object;
    if ([results count] > 0)
    {
        object = [results firstObject];
        
    }
    else
    {
        object = [NSEntityDescription insertNewObjectForEntityForName:@"Global" inManagedObjectContext:context];
    }
    
    [object setValue: [NSNumber numberWithInt: user_id] forKey:@"current_user_id"];
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else
    {
        
    }
}

//====================================================================================================
- (NSManagedObject*) getGlobalInfo
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Global"
                                        inManagedObjectContext:context]];
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    
    if([results count] > 0)
    {
        return [results firstObject];
    }
    
    return nil;
}

- (void) setIsShowDonatedAmount: (BOOL) is_show
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Global"
                                        inManagedObjectContext:context]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    NSManagedObject* object;
    if ([results count] > 0)
    {
        object = [results firstObject];
        
    }
    else
    {
        object = [NSEntityDescription insertNewObjectForEntityForName:@"Global" inManagedObjectContext:context];
    }
    
    [object setValue: [NSNumber numberWithBool: is_show] forKey:@"is_show_donated_amount"];
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else
    {
        
    }
}

- (BOOL) getIsShowDonatedAmount
{
    NSManagedObject* objGlobal = [self getGlobalInfo];
    if(objGlobal != nil)
    {
        return [[objGlobal valueForKey: @"is_show_donated_amount"] boolValue];
    }

    return NO;
}

#pragma mark User.

//====================================================================================================
- (void) addUser: (User*) u
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user_id == %d", u.user_id]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    NSManagedObject* object;
    if ([results count] > 0)
    {
        object = [results firstObject];
        
    }
    else
    {
        object = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    }
    
    [object setValue: [NSNumber numberWithInt: u.user_id] forKey:@"user_id"];
    [object setValue: u.fb_id forKey:@"fb_id"];
    [object setValue: u.name forKey:@"name"];
    [object setValue: u.email forKey:@"email"];
    [object setValue: u.avatar forKey:@"avatar"];
    [object setValue: [NSNumber numberWithFloat: u.received_amount] forKey:@"received_amount"];
    [object setValue: [NSNumber numberWithFloat: u.pay_amount] forKey:@"pay_amount"];
    [object setValue: [NSNumber numberWithInt: u.follower] forKey:@"follower"];
    [object setValue: [NSNumber numberWithInt: u.following] forKey:@"following"];
    [object setValue: u.paypal forKey: @"paypal"];
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else
    {
        
    }
}

//====================================================================================================
- (void) updateUserInfo: (User*) u
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user_id == %d", u.user_id]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    NSManagedObject* object;
    if ([results count] > 0)
    {
        object = [results firstObject];
        [object setValue: [NSNumber numberWithInt: u.user_id] forKey:@"user_id"];
        [object setValue: u.fb_id forKey:@"fb_id"];
        [object setValue: u.name forKey:@"name"];
        [object setValue: u.email forKey:@"email"];
        [object setValue: u.avatar forKey:@"avatar"];
        [object setValue: [NSNumber numberWithFloat: u.received_amount] forKey:@"received_amount"];
        [object setValue: [NSNumber numberWithFloat: u.pay_amount] forKey:@"pay_amount"];
        [object setValue: [NSNumber numberWithInt: u.follower] forKey:@"follower"];
        [object setValue: [NSNumber numberWithInt: u.following] forKey:@"following"];
        [object setValue: u.paypal forKey: @"paypal"];
        
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            
        }
    }
}

//====================================================================================================
- (void) addPaypal: (User*) u paypal: (NSString*) paypal
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user_id == %d", u.user_id]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    NSManagedObject* object;
    if ([results count] > 0)
    {
        object = [results firstObject];
        [object setValue: u.paypal forKey: @"paypal"];
        
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

//====================================================================================================
- (NSManagedObject*) getUser: (int) user_id
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"User"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user_id == %d", user_id]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    
    if([results count] > 0)
    {
        return [results firstObject];
    }
    
    return nil;
}

#pragma mark - Event.

- (void) addFeed: (Feed*) f
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Feed"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"feed_id == %@", f.feed_id]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    NSManagedObject* object;
    if ([results count] > 0)
    {
        object = [results firstObject];
        
    }
    else
    {
        object = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
    }
    
    [object setValue: f.feed_id forKey:@"feed_id"];
    [object setValue: f.photo forKey:@"photo"];
    [object setValue: f.feed_description forKey:@"feed_description"];
    [object setValue: [NSNumber numberWithFloat: f.pre_amount] forKey:@"pre_amount"];
    [object setValue: [NSNumber numberWithFloat: f.donated_amount] forKey:@"donated_amount"];
    [object setValue: [NSNumber numberWithInteger: f.register_date] forKey:@"register_date"];
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else
    {
        
    }
}

- (NSArray*) fetchFeeds: (int) limit offset: (int) offset
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Feed" inManagedObjectContext:context]];
    fetchRequest.fetchLimit = limit;
    fetchRequest.fetchOffset = offset;
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    return results;
}

- (void) addPostHistory: (int) user_id post_date: (NSDate*) post_date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    NSString* strPostDate = [formatter stringFromDate: post_date];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError * error;
    NSManagedObject* object = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
    
    [object setValue: [NSNumber numberWithInt: user_id] forKey:@"user_id"];
    [object setValue: strPostDate forKey:@"post_date"];
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else
    {
        
    }
}

- (int) getHistoryCountPerDay: (NSDate*) currentDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    NSString* strPostDate = [formatter stringFromDate: currentDate];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"History"
                                        inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"post_date == %@", strPostDate]];
    
    // if get a entity, that means exists, so fetch it.
    NSError * error;
    NSArray* results = [context executeFetchRequest: fetchRequest error: &error];
    return (int)[results count];
}
@end
