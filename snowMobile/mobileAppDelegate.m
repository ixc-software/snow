//
//  mobileAppDelegate.m
//  snowMobile
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "mobileAppDelegate.h"

#import "FirstPageController.h"
#import "EventsTableViewController.h"
#import "InfoViewController.h"
#import "DestinationsListPushListTableViewController.h"
#import "AddRoutesTableViewController.h"
#import "CarrierListConroller.h"
#import "AuthorizationView.h"
#import "CarrierListConroller.h"

#import "DestinationsListViewController.h"

#import "ClientController.h"
#import "Reachability.h"
#import "TwitterUpdateDataController.h"

@implementation mobileAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

@synthesize eventListController,tabBarController;

@synthesize reachabilityImageView,isWiFiConnection,isWWANconnection,isInternetUnavaialble;

@synthesize isCompanyGraphUpdating,download;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    NSString *firstViewNibName = nil;
    if ([self isPad]) firstViewNibName = @"FirstPageControllerIPad";
    else firstViewNibName = @"FirstPageController";
    FirstPageController *firstPage = [[FirstPageController alloc] initWithNibName:firstViewNibName bundle:nil];
    [self.window addSubview:firstPage.view];
    
    [self.window makeKeyAndVisible];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            UIImageView *reachabilityView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stop-32.png"]];
            
            self.reachabilityImageView = reachabilityView;
            [reachabilityView release];
            NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
            if (!help) {
                NSMutableDictionary *helpDict = [NSMutableDictionary dictionary];
                [helpDict setValue:[NSNumber numberWithBool:YES] forKey:@"isInfoSheet"];
                [helpDict setValue:[NSNumber numberWithBool:YES] forKey:@"isConfigSheet"];
                [helpDict setValue:[NSNumber numberWithBool:YES] forKey:@"isEventsSheet"];
                [helpDict setValue:[NSNumber numberWithBool:YES] forKey:@"isAddRoutesSheet"];
                [helpDict setValue:[NSNumber numberWithBool:YES] forKey:@"isRoutesListSheet"];
                [helpDict setValue:[NSNumber numberWithBool:YES] forKey:@"isCarriersListSheet"];
                [[NSUserDefaults standardUserDefaults] setObject:helpDict forKey:@"help"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            UITabBarController *tabBar = [[UITabBarController alloc] init];
            EventsTableViewController *events = [[EventsTableViewController alloc] initWithNibName:@"EventsTableViewController" bundle:nil];
            self.eventListController = events;
            UITabBarItem *eventsBar = [[UITabBarItem alloc] initWithTitle:@"Events" image:nil tag:0];
            events.tabBarItem = eventsBar;
            
            [eventsBar release];
            
            InfoViewController *infoAndConfig = [[InfoViewController alloc] init];
            infoAndConfig.managedObjectContext = self.managedObjectContext;        
            UITabBarItem *infoBar = [[UITabBarItem alloc] initWithTitle:@"Info" image:nil tag:1];
            infoAndConfig.tabBarItem = infoBar;
            
            [infoBar release];
            
            DestinationsListViewController *routesTableViewController = [[DestinationsListViewController alloc] initWithNibName:@"DestinationsListViewController" bundle:nil];
            
            routesTableViewController.managedObjectContext = self.managedObjectContext;
            
            UITabBarItem *routesBar = [[UITabBarItem alloc] initWithTitle:@"Routes" image:nil tag:2];
            routesTableViewController.tabBarItem = routesBar;
            [routesBar release];
            
            CarrierListConroller *carriersList = [[CarrierListConroller alloc] initWithStyle:UITableViewStylePlain];
            //        CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
            CompanyStuff *admin = [clientController authorization];
            
            UITabBarItem *carriersBar = [[UITabBarItem alloc] initWithTitle:@"Carriers" image:nil tag:3];
            carriersList.tabBarItem = carriersBar;
            [carriersBar release];
            
            
            
            UINavigationController *navigationControllerForPromo = [[UINavigationController alloc] initWithRootViewController:infoAndConfig];
            UINavigationController *navigationControllerForEvents = [[UINavigationController alloc] initWithRootViewController:events];
            UINavigationController *navigationControllerForDestinations = [[UINavigationController alloc] initWithRootViewController:routesTableViewController];
            UINavigationController *navigationControllerForCarriers = [[UINavigationController alloc] initWithRootViewController:carriersList];
            
            [tabBar setViewControllers:[NSArray arrayWithObjects:navigationControllerForPromo,navigationControllerForEvents,navigationControllerForDestinations,navigationControllerForCarriers,nil]];        
            self.tabBarController = tabBar;
            self.tabBarController.delegate = self;
            
            eventListController.managedObjectContext = self.managedObjectContext;
            eventListController.persistentStoreCoordinator = self.persistentStoreCoordinator;
            
            
            //            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
            //            CompanyStuff *admin = [clientController authorization];
            if (!admin || ![[clientController localStatusForObjectsWithRootGuid:admin.GUID ] isEqualToString:@"registered"]) {
                AuthorizationView *authView = [[AuthorizationView alloc] init];
                authView.view.alpha = 0;
                tabBarController.view.alpha = 0;
                
                [self.window addSubview:tabBarController.view];
                [self.window addSubview:authView.view];
                //[firstPage.view removeFromSuperview];
                
                //[firstPage removeFromParentViewController];
                
                [UIView animateWithDuration:1 delay:0 options: 0  animations:^{
                    authView.view.alpha = 1;
                    firstPage.view.alpha = 0;
                    
                } completion:^(BOOL finished) {
                    tabBarController.view.alpha = 1;
                    authView.view.alpha = 1;
                    firstPage.view.alpha = 0;
                    //[firstPage.view removeFromSuperview];
                    //[firstPage release];
                    
                    //[firstPage removeFromParentViewController];
                }
                 ];
                
                
                
            } else {
                tabBarController.view.alpha = 0;
                
                [self.window addSubview:tabBarController.view];
                
                [UIView animateWithDuration:1 delay:0 options: 0  animations:^{
                    
                    tabBarController.view.alpha = 1;
                    firstPage.view.alpha = 0;
                    
                } completion:^(BOOL finished) {
                    tabBarController.view.alpha = 1;
                    firstPage.view.alpha = 0;
                    //[firstPage.view removeFromSuperview];
                    //[firstPage release];
                    //[firstPage removeFromParentViewController];
                }
                 ];
                
                
            }
            [clientController release];
            
            [events release];
            [navigationControllerForEvents release];
            [navigationControllerForPromo release];
            [navigationControllerForCarriers release];
            
            [tabBar release];
            [infoAndConfig release];
            [routesTableViewController release];
            [carriersList release];
            
            [self updateExternalData];
            
            [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
            hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
            [hostReach startNotifier];
            [self updateInterfaceWithReachability: hostReach];
            
            internetReach = [[Reachability reachabilityForInternetConnection] retain];
            [internetReach startNotifier];
            [self updateInterfaceWithReachability: internetReach];
            
            wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
            [wifiReach startNotifier];
            [self updateInterfaceWithReachability: wifiReach];
            //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            //    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyStuff"
            //                                              inManagedObjectContext:[self managedObjectContext]];
            //    [fetchRequest setEntity:entity];
            //    
            //    NSError *error = nil;
            //    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
            //    if (fetchedObjects == nil) {
            //        NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
            //    }
            //    
            //    [fetchRequest release];
            //    CompanyStuff *lastObject = [fetchedObjects lastObject];
            //    NSLog(@"tested:%@/%@",lastObject.email, lastObject);
            //
            //    NSData *photoTest = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
            //    lastObject.photo = photoTest;
            //    NSLog(@"tested:%@",lastObject);
            
            
            float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(iOSVersion <= 4.3){
                //[[tabBarController tabBar] insertSubview:viewa aboveSubview:self.tabBarController.view];
                
            } else {
                //iOS5
                CGRect frame = CGRectMake(0, 0, 768, 148);
                UIView *viewa = [[UIView alloc] initWithFrame:frame];
                UIImage *tabBarBackgroundImage = [UIImage imageNamed:@"background.png"];
                UIColor *color = [[UIColor alloc] initWithPatternImage:tabBarBackgroundImage];
                [viewa setBackgroundColor:color];
                [viewa setAlpha:0.5];
                [[self.tabBarController tabBar] insertSubview:viewa aboveSubview:self.tabBarController.view];
                
                [color release];
                [viewa release];
                
            }
            
            
            
            for(UIView *view in self.tabBarController.tabBar.subviews) {  
                if([view isKindOfClass:[UIImageView class]]) {  
                    [view removeFromSuperview];  
                }  
            }  
            
            
            UIImageView *newViewInfo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_30x30.png"]] autorelease];
            
            UIImageView *newViewEvents = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"events.png"]] autorelease];
            
            UIImageView *newViewRoutes = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apple-update_0_30x30-1.png"]] autorelease];
            
            UIImageView *newViewCarriers = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NotesMailbox.png"]] autorelease];
            
            
            if ([self isPad]) {
                newViewInfo.frame = CGRectMake(200, 5, 30, 30);
                newViewEvents.frame = CGRectMake(315, 5, 30, 30);
                newViewRoutes.frame = CGRectMake(424, 5, 30, 30);
                newViewCarriers.frame = CGRectMake(534, 5, 30, 30);
                
            } else {
                newViewInfo.frame = CGRectMake(25, 5, 30, 30);
                newViewEvents.frame = CGRectMake(107, 5, 30, 30);
                newViewRoutes.frame = CGRectMake(185, 5, 30, 30);
                newViewCarriers.frame = CGRectMake(265, 5, 30, 30);
                
            }
            
            [self.tabBarController.tabBar insertSubview:newViewInfo belowSubview:self.tabBarController.view];
            [self.tabBarController.tabBar insertSubview:newViewEvents belowSubview:self.tabBarController.view];
            [self.tabBarController.tabBar insertSubview:newViewRoutes belowSubview:self.tabBarController.view];
            [self.tabBarController.tabBar insertSubview:newViewCarriers belowSubview:self.tabBarController.view];
            
            UIBarItem *info = [self.tabBarController.tabBar.items objectAtIndex:0];
            info.title = @"Info and config";
            
            info = [self.tabBarController.tabBar.items objectAtIndex:1];
            info.title = @"Events";
            
            info = [self.tabBarController.tabBar.items objectAtIndex:2];
            info.title = @"Routes";
            
            info = [self.tabBarController.tabBar.items objectAtIndex:3];
            info.title = @"Carriers";
            
        });
        
    });
    
    [firstPage release];
    return YES;
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"snow" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"snowMobile.sqlite"];
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [pragmaOptions setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    NSDictionary *options = [NSDictionary dictionaryWithDictionary:pragmaOptions];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Check iPad iPhone

-(BOOL)isPad;
{
    BOOL isPad;
    NSRange range = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if(range.location==NSNotFound)
    {
        isPad=NO;
        
        
    }
    else {
        isPad=YES;
    }
    
    return isPad;
}

#pragma mark - Reachabillity

- (void) configureImageView: (UIImageView*) imageView reachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            imageView.image = [UIImage imageNamed: @"stop-32.png"] ;
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            isWiFiConnection = NO;
            isWWANconnection = NO;
            isInternetUnavaialble = YES;
            //userController.requestsToServerTimeouts = [NSNumber numberWithInt:10000000];
            //userControllerForCycle.requestsToServerTimeouts = [NSNumber numberWithInt:10000000];
            connectionRequired= NO;  
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            imageView.image = [UIImage imageNamed: @"WWAN5.png"];
            isWiFiConnection = NO;
            isWWANconnection = YES;
            isInternetUnavaialble = NO;
            //userController.requestsToServerTimeouts = [NSNumber numberWithInt:60];
            //userControllerForCycle.requestsToServerTimeouts = [NSNumber numberWithInt:60];
            
            
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            isWiFiConnection = YES;
            isWWANconnection = NO;
            isInternetUnavaialble = NO;
            //userController.requestsToServerTimeouts = [NSNumber numberWithInt:5];
            //userControllerForCycle.requestsToServerTimeouts = [NSNumber numberWithInt:5];
            
            imageView.image = [UIImage imageNamed: @"Airport.png"];
            break;
        }
    }
    
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
    }
    NSLog(@"REACHABILITY:%@",statusString);
    
}


- (void) updateInterfaceWithReachability: (Reachability*) curReach;
{
    if(curReach == hostReach)
	{
		[self configureImageView:self.reachabilityImageView reachability: curReach];
        
        BOOL connectionRequired= [curReach connectionRequired];
        
        NSString* baseLabel=  @"";
        if(connectionRequired)
        {
            baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
        }
        else
        {
            baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
        }
        NSLog(@"REACHABILITY:%@",baseLabel);
    }
	if(curReach == internetReach)
	{	
		[self configureImageView:self.reachabilityImageView reachability: curReach];
	}
	if(curReach == wifiReach)
	{	
		[self configureImageView:self.reachabilityImageView reachability: curReach];
	}
	
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}


#pragma mark -
#pragma mark Update external data Methods

- (void) updateExternalData;
{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    self.download = [[[DownloadExternalData alloc] init] autorelease];
    download.managedObjectContext = context;
    NSPersistentStoreCoordinator *psc = self.persistentStoreCoordinator;
    download.persistentStoreCoordinator = psc;
    download.delegateData = self;
    [download downloadAndPutInLocalDatabaseEventsArray];
    
}

//-(void) updateTwitterMessagesForText:(NSArray *)managedObjectIDs;
//{
//    NSArray *viewControllers = self.tabBarController.viewControllers;
//    UINavigationController *info = [viewControllers objectAtIndex:0];
//    
//    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
//    
//    if ([infoObject.socialNetworksViewController isTwitterAuthorized]) [infoObject.socialNetworksViewController sendTwitterUpdate:managedObjectIDs];
//    
//    
//}
-(BOOL)isTwitterAuthorized;
{
    NSArray *viewControllers = self.tabBarController.viewControllers;
    UINavigationController *info = [viewControllers objectAtIndex:0];
    
    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
    
    return [infoObject.socialNetworksViewController isTwitterAuthorized];
}


-(BOOL)isLinkedinAuthoruzed;
{
    NSArray *viewControllers = self.tabBarController.viewControllers;
    UINavigationController *info = [viewControllers objectAtIndex:0];
    
    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
    
    return [infoObject.socialNetworksViewController isLinkedinAuthorized];
}

-(void) postToLinkedinGroupsForDestinations:(NSArray *)managedObjectIDs;
{
    NSArray *viewControllers = self.tabBarController.viewControllers;
    UINavigationController *info = [viewControllers objectAtIndex:0];
    
    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
    
    if ([infoObject.socialNetworksViewController isLinkedinAuthorized]) [infoObject.socialNetworksViewController postToLinkedinGroups:managedObjectIDs];
    
    
}


-(void) updateTwitterMessagesForDestinations:(NSArray *)destinations;
{
    NSArray *viewControllers = self.tabBarController.viewControllers;
    UINavigationController *info = [viewControllers objectAtIndex:0];
    
    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
    //NSLog(@"updateTwitterMessagesForDestinations");

    if ([infoObject.socialNetworksViewController isTwitterAuthorized]) {
        //NSLog(@"postTwitterMessageForDestinations:%@",destinations);

        [infoObject.socialNetworksViewController sendTwitterUpdate:destinations];
    }
}

#pragma mark <DownloadExternalDataDelegate> Implementation

- (void)updateUIForThread:(NSNumber *) result
{
    NSLog(@"DONE!");
    self.download = nil;
    //[result release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastStoreUpdate"];
    NSArray *viewControllers = self.tabBarController.viewControllers;
    UINavigationController *info = [viewControllers objectAtIndex:0];
    //info.navigationItem.title = @"test";
    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
    [infoObject.operationProgress setHidden:YES]; 
    //NSLog(@"progess hidden from delegate");
//    UINavigationController *routes = [viewControllers objectAtIndex:2];
    
//    DestinationsListPushListTableViewController *destinationsObject = [routes.viewControllers objectAtIndex:0];
//    if (addRoutesSearchTableView != nil) {
//        dispatch_async(dispatch_get_main_queue(), ^(void) { [addRoutesSearchTableView reloadData]; });
//    } //else NSLog(@"UPDATE:addRoutesSearchTableView is nil");

    
    
    
    //NSError *error = nil;
    //    NSFetchedResultsController *routesController = destinationsObject.addRoutesView.fetchedResultsController;
    //    //NSFetchedResultsController *routesControllerSearch = destinationsObject.addRoutesView.fetchResultControllerSearch;
    //    NSError *error = nil;
    //    UITableView *addRoutesTableView = destinationsObject.addRoutesView.tableView;
    
    //    if (routesController != nil) {
    //
    //        if (![routesController performFetch:&error]) {
    //             NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    //             abort();
    //         }
    //
    //
    //    } //else NSLog(@"UPDATE:routesController is nil");
    /*if (routesControllerSearch != nil) {
     
     if (![routesControllerSearch performFetch:&error]) {
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }
     
     
     } else NSLog(@"UPDATE:routesControllerSearch is nil");*/
    
    //    if (addRoutesTableView != nil) {
    //        dispatch_async(dispatch_get_main_queue(), ^(void) { 
    //            
    //            [addRoutesTableView reloadData]; });
    //    } //else NSLog(@"UPDATE:addRoutesTableView is nil");
    
//    if (addRoutesSearchTableView != nil) {
//        dispatch_async(dispatch_get_main_queue(), ^(void) { [addRoutesSearchTableView reloadData]; });
//    } //else NSLog(@"UPDATE:addRoutesSearchTableView is nil");
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
    ////        NSManagedObjectContext *mocForCycle =  [[NSManagedObjectContext alloc] init];
    ////        [mocForCycle setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    ////        [mocForCycle setUndoManager:nil];
    ////        [mocForCycle setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    ////        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
    ////        [nc addObserver:self
    ////               selector:@selector(mergeChanges:) 
    ////                   name:NSManagedObjectContextDidSaveNotification
    ////                 object:mocForCycle];
    ////        
    ////        userControllerForCycle.context = mocForCycle;
    ////        [mocForCycle release];
    //        userControllerForCycle.context = self.managedObjectContext;
    //        [userControllerForCycle updateInternalGraphCycleForSender:self];
    //        [userControllerForCycle startProcessingForObjectsSavedInProcessingPoolForClientStuffGUID:[[userController authorization] valueForKey:@"GUID"]];
    //
    //    });
    
}
-(void) reloadLocalDataFromUserDataControllerForObject:(id)object;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // here is update company and user info tableview
        NSArray *vieControllers = self.tabBarController.viewControllers;
        UINavigationController *info = [vieControllers objectAtIndex:0];
        InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
        UINavigationController *companyAndUserNav = infoObject.companyInfoAndConfig;
        CompanyAndUserConfiguration *companyAndUser = [companyAndUserNav.viewControllers objectAtIndex:0];
        if (!companyAndUser.isEditingNow) if (!companyAndUser.isEditedCarriers) [[companyAndUser tableView] reloadData];
        
    });
}

- (void)dataWasUpdateWithResult:(DownloadOperation *)importer;
{
    NSNumber *result = [[NSNumber alloc] initWithBool:!importer.downloadExternalDataWasUnsucceseful];
    BOOL isItLatestMessage = importer.isItLatestMessage;
    if (isItLatestMessage) self.isCompanyGraphUpdating = !isItLatestMessage;
    
    [self performSelectorOnMainThread:@selector(updateUIForThread:) withObject:result waitUntilDone:YES];
    [result release];
}

-(void) hideProgressIndicator;
{
    NSArray *vieControllers = self.tabBarController.viewControllers;
    UINavigationController *info = [vieControllers objectAtIndex:0];
    //info.navigationItem.title = @"test";
    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
    [infoObject.operationProgress setHidden:YES]; 
    //NSLog(@"progess hidden");
}
-(void)countUpdate:(NSArray *)array;
{
    NSArray *vieControllers = self.tabBarController.viewControllers;
    UINavigationController *info = [vieControllers objectAtIndex:0];
    //info.navigationItem.title = @"test";
    InfoViewController *infoObject = [info.viewControllers objectAtIndex:0];
    infoObject.operation.text = [array objectAtIndex:0];
    if ([array count] == 2) { 
        [infoObject.operationProgress setHidden:NO]; 
        NSNumber *progress = [array objectAtIndex:1];
        [infoObject.operationProgress setProgress:[progress floatValue]];
        //[infoObject.operationProgress setTintColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0]];
    }
    else [infoObject.operationProgress setHidden:YES]; 
}

- (void)countWasUpdateWithResult:(DownloadOperation *)importer;
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    NSString *text = nil;
    NSNumber *percentDone = importer.percentDone;
    if (percentDone && [percentDone doubleValue] != 0)
    {
        text = [NSString stringWithFormat:@"%@, completed:%@%",importer.operationName,[formatter stringFromNumber:importer.percentDone]];
        
    } else
    {
        text = [NSString stringWithFormat:@"%@",importer.operationName];
        [self performSelectorOnMainThread:@selector(hideProgressIndicator) withObject:nil waitUntilDone:YES];
        
    }
    
    [self performSelectorOnMainThread:@selector(countUpdate:) withObject:[NSArray arrayWithObjects:text,percentDone, nil] waitUntilDone:YES];
    [formatter release],formatter = nil;
}

@end
