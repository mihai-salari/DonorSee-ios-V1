//
//  CoreHelper.h
//  Salon01
//
//  Created by jian on 7/28/15.
//  Copyright (c) 2015 jian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreHelper : NSObject
{
    
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+ (CoreHelper*)sharedInstance;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//User.
- (NSManagedObject*) getGlobalInfo;
- (void) setCurrentUserId: (int) user_id;
- (void) setIsShowDonatedAmount: (BOOL) is_show;
- (BOOL) getIsShowDonatedAmount;

- (void) addUser: (User*) u;
- (void) updateUserInfo: (User*) u;
- (void) addPaypal: (User*) u paypal: (NSString*) paypal;
- (NSManagedObject*) getUser: (int) user_id;
- (void) logout;

//Feed.
- (void) addFeed: (Feed*) f;
- (NSArray*) fetchFeeds: (int) limit offset: (int) offset;
- (int) getHistoryCountPerDay: (NSDate*) currentDate;
- (void) addPostHistory: (int) user_id post_date: (NSDate*) post_date;
/*
//Event.
- (void) addEvent: (Event*) e;
- (void) updateEvent: (Event*) e;
- (void) deleteEvent: (Event*) e;
- (void) deleteAllEvents;
- (NSArray*) loadEvents;
- (NSManagedObject*) getEvent: (NSNumber*) eventId;
- (NSArray*) getMyEvents: (NSNumber*) user_id;
- (NSArray*) getAttendedEvents: (NSNumber*) user_id;

//Shop
- (void) addShop: (Shop*) s;
- (NSArray*) getAllShops;
- (void) deleteAllShops;

//Attend.
- (void) addAttendee: (Attendee*) attendee;
- (NSManagedObject*) getAttendee: (NSNumber*) attendee_id;
- (NSManagedObject*) getAttendeeForEvent: (NSNumber*) event_id user_id: (NSNumber*) user_id;
- (NSArray*) getAttendeedUserList: (Event*) e;
- (void) deleteAllAttendees;
- (void) deleteAttendWithId: (NSNumber*) attendee_id;
 */
@end
