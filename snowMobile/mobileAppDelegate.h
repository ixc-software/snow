//
//  mobileAppDelegate.h
//  snowMobile
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "DownloadExternalData.h"

@class EventsTableViewController;

@interface mobileAppDelegate : UIResponder <UIApplicationDelegate,UIActionSheetDelegate,DownloadExternalDataDelegate,UITabBarControllerDelegate>
{
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;

}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// view properties
@property (nonatomic, retain) IBOutlet EventsTableViewController *eventListController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

// reachability
@property (nonatomic, retain) UIImageView* reachabilityImageView;
@property (readwrite) BOOL isInternetUnavaialble;
@property (readwrite) BOOL isWWANconnection;
@property (readwrite) BOOL isWiFiConnection;

// sync
@property (readwrite) BOOL isCompanyGraphUpdating;
@property (nonatomic, retain) IBOutlet DownloadExternalData *download;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(BOOL)isPad;
- (void) updateExternalData;
- (void) updateInterfaceWithReachability: (Reachability*) curReach;
-(void) updateTwitterMessagesForText:(NSString *)text;
-(void) updateTwitterMessagesForDestinations:(NSArray *)destinations;

@end
