//
//  desctopAppDelegate.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/24/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "desctopAppDelegate.h"

#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

#import "ClientController.h"
#import "UpdateDataController.h"
#import "ProgressUpdateController.h"
#import "MySQLIXC.h"
#import "FirstAuthorizationSetup.h"

#import "CurrentCompany.h"
#import "CompanyStuff.h"
#import "DestinationsListPushList.h"

#import <QuartzCore/QuartzCore.h>
#import "CalendarStore/CalendarStore.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation desctopAppDelegate

@synthesize window = _window;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;

@synthesize startupPosition;

@synthesize currentUserInfoList = _currentUserInfoList;
@synthesize showHideUserCompanyInfo = _showHideUserCompanyInfo;
@synthesize mainLogo = _mainLogo;
@synthesize mainLogoTitle = _mainLogoTitle;
@synthesize mainLogoSubTitle = _mainLogoSubTitle;
@synthesize mainLogoSubSubTitle = _mainLogoSubSubTitle;
@synthesize getExternalInfoButton = _getExternalInfoButton;
@synthesize getExternalInfoProgress;
@synthesize mainProgressIndicator;
@synthesize totalProfit;

@synthesize carriersView,importRatesView,destinationsView,getExternalInfoView,userCompanyInfo;

@synthesize loggingLevel;

@synthesize updateForMainThread,progressForMainThread;

@synthesize queueForUpdatesBusy,cancelAllOperations,isSearchProcessing;

@synthesize numberForSQLQueries,numberForHardJobConcurentLines;


#pragma mark - application lifecycle
-(void)createNecessaryDirectories;
{
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[self applicationFilesDirectory].path isDirectory:NULL]) {
		if (![fileManager createDirectoryAtPath:[self applicationFilesDirectory].path withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", [self applicationFilesDirectory],error]));
            NSLog(@"Error creating application support directory at %@ : %@",[self applicationFilesDirectory],error);
		}
    }
    
    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Rates",[self applicationFilesDirectory].path] isDirectory:NULL]) {
		if (![fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/Rates",[self applicationFilesDirectory].path] withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", [self applicationFilesDirectory],error]));
            NSLog(@"Error creating application support directory at %@ : %@",[self applicationFilesDirectory],error);
		}
    }
    
    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Invoices",[self applicationFilesDirectory].path] isDirectory:NULL]) {
		if (![fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/Invoices",[self applicationFilesDirectory].path] withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", [self applicationFilesDirectory],error]));
            NSLog(@"Error creating application support directory at %@ : %@",[self applicationFilesDirectory],error);
		}
    }
    
    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/VoiceFiles",[self applicationFilesDirectory].path] isDirectory:NULL]) {
		if (![fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/VoiceFiles",[self applicationFilesDirectory].path] withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", [self applicationFilesDirectory],error]));
            NSLog(@"Error creating application support directory at %@ : %@",[self applicationFilesDirectory],error);
		}
    }
    
    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/CompaniesLogos",[self applicationFilesDirectory].path] isDirectory:NULL]) {
		if (![fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/CompaniesLogos",[self applicationFilesDirectory].path] withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", [self applicationFilesDirectory],error]));
            NSLog(@"Error creating application support directory at %@ : %@",[self applicationFilesDirectory],error);
		}
    }
    
    //    // for compatibility
    //    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:[self managedObjectContext]];
    //    [fetchRequest setEntity:entity];
    //
    //    NSError *error = nil;
    //    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    //    [fetchedObjects enumerateObjectsWithOptions:NSSortStable usingBlock:^(CurrentCompany *company, NSUInteger idx, BOOL *stop) {
    //        company.isInvisibleForCommunity = [NSNumber numberWithBool:YES]; 
    //    }];
    //
    //    [fetchRequest release];
    //    [self safeSave];
    //    //NSString *title = [checkEvents title];
    
}
-(void)updateServerConnections
{
    [totalProfit setHidden:NO];
    totalProfit.title = [NSString stringWithFormat:@"Conn:%@",[NSNumber numberWithUnsignedInteger:[httpServer numberOfHTTPConnections]]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    loggingLevel = [[NSNumber alloc] initWithInt:1];

    [self.showHideUserCompanyInfo setHidden:YES];
    [getExternalInfoProgress setHidden:YES];
    [self.getExternalInfoButton setHidden:YES];
    [totalProfit setHidden:YES];
    
    
    [self.window center];
    destinationsView = [[DestinationsView alloc] initWithNibName:@"DestinationsView" bundle:nil];
    importRatesView = [[ImportRatesView alloc] initWithNibName:@"ImportRatesView" bundle:nil];
    carriersView = [[CarriersView alloc] initWithNibName:@"CarriersView" bundle:nil];
    
#if defined (SNOW_CLIENT_ENTERPRISE) || defined(SNOW_CLIENT_APPSTORE)
    [mainProgressIndicator setHidden:NO];
    [mainProgressIndicator startAnimation:self];
#endif
    
    loggingLevel = [[[NSNumber alloc] initWithInt:1] autorelease];
    [self.window setBackgroundColor:[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1]];
    [self.window setContentBorderThickness:40.0 forEdge:NSMinYEdge];     //[self.window setOpaque:NO];
    
    [self createNecessaryDirectories];
#ifdef SNOW_SERVER

    [self.window setTitle:@"snow server distribution"];
    
#endif

#ifdef SNOW_CLIENT_ENTERPRISE
    [self.window setTitle:@"snow enterprise"];
    [self.mainLogoSubSubTitle setHidden:NO];
#endif
    
#ifdef SNOW_CLIENT_APPSTORE
    [self.window setTitle:@"snow IXC"];
    
#endif

#if defined(SNOW_SERVER)

	// Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	//[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [httpServer setPort:8081];
	
	// We're going to extend the base HTTPConnection class with our MyHTTPConnection class.
	// This allows us to do all kinds of customizations.
	[httpServer setConnectionClass:[MyHTTPConnection class]];
	
	// Serve files from our embedded Web folder
//	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
//	DDLogInfo(@"Setting document root: %@", webPath);
//	
//	[httpServer setDocumentRoot:webPath];
	
	
	NSError *error = nil;
	if(![httpServer start:&error])
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}
    
    if (!durationRefreasher) {
        durationRefreasher = [NSTimer	scheduledTimerWithTimeInterval:1
                                                              target:self 
                                                            selector:@selector(updateServerConnections) 
                                                            userInfo:nil 
                                                             repeats:YES];
        
    }

#endif
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
#if defined(SNOW_SERVER)
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[self managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[self managedObjectContext]];
        [clientController firstSetup];
        [clientController release];
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            destinationsView.view.frame = NSMakeRect(395, 46, destinationsView.view.frame.size.width, destinationsView.view.frame.size.height);
            [self.window.contentView addSubview:destinationsView.view];
            carriersView.view.frame = NSMakeRect(15, 36, carriersView.view.frame.size.width, carriersView.view.frame.size.height);
            [self.window.contentView addSubview:carriersView.view];
            [self.mainLogo setHidden:YES];
            [self.mainLogoTitle setHidden:YES];
            [self.mainLogoSubTitle setHidden:YES];
            [self.mainLogoSubSubTitle setHidden:YES];
            [self.getExternalInfoButton setHidden:NO];
            [self.showHideUserCompanyInfo setHidden:NO];
            
        });
#endif
        
        
        
        
#ifdef SNOW_CLIENT_APPSTORE
        
        
#endif
        
#if defined (SNOW_CLIENT_ENTERPRISE) || defined(SNOW_CLIENT_APPSTORE)
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[self managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[self managedObjectContext]];
        CompanyStuff *authorizedUser = [clientController authorization];
        //if ([delegate.loggingLevel intValue] == 1) NSLog(@"CLIENT:current authorized user:%@",authorizedUser.firstName);
        if (!authorizedUser) {
            NSLog(@"APP DELEGATE:authorized user is starting to create.");
            [clientController firstSetup];
            [clientController getCompaniesListWithImmediatelyStart:YES];
            //[clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES isUserAuthorized:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                destinationsView.view.frame = NSMakeRect(395, 46, destinationsView.view.frame.size.width, destinationsView.view.frame.size.height);
                [self.window.contentView addSubview:destinationsView.view];
                
                carriersView.view.frame = NSMakeRect(15, 36, carriersView.view.frame.size.width, carriersView.view.frame.size.height);
                [self.window.contentView addSubview:carriersView.view];
                
                FirstAuthorizationSetup *setup = [[FirstAuthorizationSetup alloc] initWithNibName:@"FirstAuthorizationSetup" bundle:nil];
                //    NSLog(@"view:%@",setup);
                startupPosition = self.window.frame;
                
                [self.window.contentView addSubview:setup.view];
                [mainProgressIndicator setHidden:YES];
                [mainProgressIndicator stopAnimation:self];
                [self.mainLogo setHidden:YES];
                [self.mainLogoTitle setHidden:YES];
                [self.mainLogoSubTitle setHidden:YES];
                [self.mainLogoSubSubTitle setHidden:YES];
                
                //NSLog(@"APP DELEGATE: old window rect:%@",NSStringFromRect(self.window.frame));
                //[[self.window toolbar] setVisible:NO];
                NSRect newWindowRect = NSMakeRect(self.window.frame.origin.x + setup.view.frame.size.width / 2, self.window.frame.origin.y, setup.view.frame.size.width, setup.view.frame.size.height);
                //NSLog(@"APP DELEGATE: new window rect:%@",NSStringFromRect(newWindowRect));
                
                [self.window setFrame:newWindowRect display:YES animate:YES];
#if defined (SNOW_CLIENT_ENTERPRISE)
                [setup.enterprise setHidden:NO];
                
#endif
                
            });
            
            
        } else {
            
            if (![[clientController localStatusForObjectsWithRootGuid:authorizedUser.GUID] isEqualToString:@"registered"]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) { 
                    destinationsView.view.frame = NSMakeRect(395, 46, destinationsView.view.frame.size.width, destinationsView.view.frame.size.height);
                    [self.window.contentView addSubview:destinationsView.view];
                    carriersView.view.frame = NSMakeRect(15, 36, carriersView.view.frame.size.width, carriersView.view.frame.size.height);
                    [self.window.contentView addSubview:carriersView.view];
                    
                    FirstAuthorizationSetup *setup = [[FirstAuthorizationSetup alloc] initWithNibName:@"FirstAuthorizationSetup" bundle:nil];
                    //    NSLog(@"view:%@",setup);
                    startupPosition = self.window.frame;
                    [self.window.contentView addSubview:setup.view];
                    
                    //NSLog(@"APP DELEGATE: old window rect:%@",NSStringFromRect(self.window.frame));
                    
                    //[[self.window toolbar] setVisible:NO];
                    NSRect newWindowRect = NSMakeRect(self.window.frame.origin.x + setup.view.frame.size.width / 2, self.window.frame.origin.y, setup.view.frame.size.width, setup.view.frame.size.height);
                    //NSLog(@"APP DELEGATE: new window rect:%@",NSStringFromRect(newWindowRect));
                    [mainProgressIndicator setHidden:YES];
                    [mainProgressIndicator stopAnimation:self];
                    [self.mainLogo setHidden:YES];
                    [self.mainLogoTitle setHidden:YES];
                    [self.mainLogoSubTitle setHidden:YES];
                    [self.mainLogoSubSubTitle setHidden:YES];
                    
#if defined (SNOW_CLIENT_ENTERPRISE)
                    [setup.enterprise setHidden:NO];
                    
#endif
                    
                    
                    [self.window setFrame:newWindowRect display:YES animate:YES];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void) { 
                    [self.currentUserInfoList setHidden:NO];
                    [self updateWellcomeTitle];
                    [self.showHideUserCompanyInfo setHidden:NO];
                    
                    [mainProgressIndicator setHidden:YES];
                    [mainProgressIndicator stopAnimation:self];
                    [self.mainLogo setHidden:YES];
                    [self.mainLogoTitle setHidden:YES];
                    [self.mainLogoSubTitle setHidden:YES];
                    [self.mainLogoSubSubTitle setHidden:YES];
#if defined (SNOW_CLIENT_ENTERPRISE)
                    [self.getExternalInfoButton setHidden:NO];
                    [totalProfit setHidden:NO];
                    
#endif
                    
                    destinationsView.view.frame = NSMakeRect(395, 46, destinationsView.view.frame.size.width, destinationsView.view.frame.size.height);
                    [self.window.contentView addSubview:destinationsView.view];
                    carriersView.view.frame = NSMakeRect(15, 36, carriersView.view.frame.size.width, carriersView.view.frame.size.height);
                    [self.window.contentView addSubview:carriersView.view];
                    
                });
                [carriersView introductionShowFromOutsideView];
            }
            
        }
        
#endif        
        [self createAndConnectMainThreadControllers];
        //        MysqlSpreamingController *cont = [[MysqlSpreamingController alloc] init];
        //        cont.connections = [updateForMainThread databaseConnections];
        //        [cont test];
        //        
        [self.updateForMainThread readExternalCountryCodesListWithProgressUpdateController:self.progressForMainThread];
        
#if defined (SNOW_CLIENT_ENTERPRISE) || defined(SNOW_CLIENT_APPSTORE)
        
        [clientController getCompaniesListWithImmediatelyStart:YES];
        //[clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES isUserAuthorized:NO];
        
        //CurrentCompany *necessaryCompany = authorizedUser.currentCompany;
        //if ([delegate.loggingLevel intValue] == 1) NSLog(@"CLIENT:current company for authorized user is%@",necessaryCompany.name);
        [self updateWellcomeTitle];
        
        [clientController release];
#endif
//        [pool drain];
    });

}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "snow" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"snow"];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    // Save changes in the application's managed object context before the application terminates.
    
    if (!__managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

#pragma mark - CoreData methods

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"snow" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    NSURL *url = nil;
    
#if defined(SNOW_CLIENT_APPSTORE)

    url = [applicationFilesDirectory URLByAppendingPathComponent:@"snowClientAppstore.storedata"];
#endif
#if defined(SNOW_SERVER)
 
   url = [applicationFilesDirectory URLByAppendingPathComponent:@"snowServer.storedata"];
    
#endif
#if defined(SNOW_CLIENT_ENTERPRISE)
    url = [applicationFilesDirectory URLByAppendingPathComponent:@"snowClientEnterprise.storedata"];
#endif
    
    NSMutableDictionary *pragmaOptions = [NSMutableDictionary dictionary];
    [pragmaOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [pragmaOptions setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    NSDictionary *options = [NSDictionary dictionaryWithDictionary:pragmaOptions];

    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:options error:&error]) {
            [[NSApplication sharedApplication] presentError:error];
            [coordinator release];
            return nil;
        }
    }
    __persistentStoreCoordinator = coordinator;

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

//START:logError
- (void)logError:(NSError*)error
{
    id sub = [[error userInfo] valueForKey:@"NSUnderlyingException"];
    
    if (!sub) {
        sub = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
    }
    
    if (!sub) {
        NSLog(@"%@:%@ Error Received: %@", [self class], NSStringFromSelector(_cmd), 
              [error localizedDescription]);
        return;
    }
    
    if ([sub isKindOfClass:[NSArray class]] || 
        [sub isKindOfClass:[NSSet class]]) {
        for (NSError *subError in sub) {
            NSLog(@"%@:%@ SubError: %@", [self class], NSStringFromSelector(_cmd), 
                  [subError localizedDescription]);
        }
    } else {
        NSLog(@"%@:%@ exception %@", [self class], NSStringFromSelector(_cmd), [sub description]);
    }
}
//END:logError


- (BOOL)safeSave; 
{
    BOOL success = YES;
    NSManagedObjectContext *moc = [self managedObjectContext];
    
    
    // [moc setStalenessInterval:1];
    if ([moc hasChanges]) {
        NSError *error = nil;
        if (![moc save: &error]) {
            NSLog(@"Failed to save to data store: %@\n with userInfo:%@", [error localizedDescription],[error userInfo]);
            
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0)
            {
                for(NSError* detailedError in detailedErrors)
                {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                    NSManagedObject *object = [[detailedError userInfo] objectForKey:@"NSValidationErrorObject"];
                    
                    [moc deleteObject:object];
                    
                }
            }
            else
            {
                NSLog(@"  %@", [error userInfo]);
            }
            [self logError:error];
            success = NO;
        }
        if (![moc save: &error]) NSLog(@"Failed to save to data store: %@\n with userInfo:%@", [error localizedDescription],[error userInfo]);
    }
    
    return success;
}


#pragma mark - Main view actions
-(IBAction) removeAlllocalData:(id)sender
{
    NSURL *url = nil;
    
#if defined(SNOW_CLIENT_APPSTORE)
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];

   url = [applicationFilesDirectory URLByAppendingPathComponent:@"snowClientAppstore.storedata"];
#endif
#if defined(SNOW_SERVER)
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];

    url = [applicationFilesDirectory URLByAppendingPathComponent:@"snowServer.storedata"];
    
#endif
#if defined(SNOW_CLIENT_ENTERPRISE)
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];

    url = [applicationFilesDirectory URLByAppendingPathComponent:@"snowClientEnterprise.storedata"];
#endif
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"processingPool"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"recordsStack"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastGraphUpdatingTime"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"showAgain"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastGraphUpdatingTime"];
    NSString *keyOfAuthorized = @"authorizedUserGUID";
    
#if defined(SNOW_CLIENT_APPSTORE)
    keyOfAuthorized = @"authorizedUserGUIDclient";
#endif
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyOfAuthorized];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSApp terminate:self];
    //abort();
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

-(NSMutableDictionary *) clearNullKeysForDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj class] == [NSNull class]) [result removeObjectForKey:key];
    }];
    return result;
    
}


- (IBAction)sendEmailToDeveloper:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[self managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[self managedObjectContext]];
        
        CompanyStuff *stuff = [clientController authorization];
        
        NSMutableArray *finalData = [NSMutableArray array];
        // email to developer
        __block NSArray *keys = [[[stuff entity] attributesByName] allKeys];
        __block NSDictionary *volumes = [stuff dictionaryWithValuesForKeys:keys];
        NSMutableDictionary *cleaned = [self clearNullKeysForDictionary:volumes];
        [cleaned setValue:[clientController localStatusForObjectsWithRootGuid:stuff.GUID] forKey:@"currentStatus"];
        [finalData addObject:cleaned];
        
        keys = [[[stuff.currentCompany entity] attributesByName] allKeys];
        volumes = [stuff.currentCompany dictionaryWithValuesForKeys:keys];
        cleaned = [self clearNullKeysForDictionary:volumes];
        [cleaned setValue:[clientController localStatusForObjectsWithRootGuid:stuff.currentCompany.GUID] forKey:@"currentStatus"];
        
        [finalData addObject:cleaned];
        
        NSSet *stuffs = stuff.currentCompany.companyStuff;
        [stuffs enumerateObjectsUsingBlock:^(CompanyStuff *stuffForDebug, BOOL *stop) {
            keys = [[[stuffForDebug entity] attributesByName] allKeys];
            volumes = [stuffForDebug dictionaryWithValuesForKeys:keys];
            NSDictionary *cleaned = [self clearNullKeysForDictionary:volumes];
            [cleaned setValue:[clientController localStatusForObjectsWithRootGuid:stuffForDebug.GUID] forKey:@"currentStatus"];
            
            [finalData addObject:cleaned];
        }];
        
        NSSet *carriers = stuff.carrier;
        [carriers enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
            keys = [[[carrier entity] attributesByName] allKeys];
            volumes = [carrier dictionaryWithValuesForKeys:keys];
            NSDictionary *cleaned = [self clearNullKeysForDictionary:volumes];
            [cleaned setValue:[clientController localStatusForObjectsWithRootGuid:carrier.GUID] forKey:@"currentStatus"];
            
            [finalData addObject:cleaned];
            NSSet *destinations = carrier.destinationsListPushList;
            [destinations enumerateObjectsUsingBlock:^(DestinationsListPushList *destination, BOOL *stop) {
                keys = [[[destination entity] attributesByName] allKeys];
                volumes = [destination dictionaryWithValuesForKeys:keys];
                NSDictionary *cleaned = [self clearNullKeysForDictionary:volumes];
                [cleaned setValue:[clientController localStatusForObjectsWithRootGuid:destination.GUID] forKey:@"currentStatus"];
                [finalData addObject:cleaned];
            }];
        }];
        //iphoneAppDelegate *delegate = (iphoneAppDelegate *)[UIApplication sharedApplication].delegate;
        //NSString *storePath = [[delegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"debug.info"];
        //[finalData writeToFile:storePath atomically:YES];
        //        NSData *finalDataToSend = [NSData dataWithContentsOfFile:@"/Users/alex/Download/debugInfo.bin"];
        [clientController release];
        
        NSMutableString *error;
        NSData *data = [NSPropertyListSerialization dataFromPropertyList:[NSArray arrayWithArray:finalData] format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
        NSString *fileName = [NSString stringWithFormat:@"%@/debugInfo.bin",[self applicationFilesDirectory]];
        [data writeToFile:fileName atomically:YES];
        
        
        NSString *subject = [NSString stringWithFormat:@"debug information for snow mobile"];
        
        [updateForMainThread sendEmailMessageTo:@"iphone@ixcglobal.com" 
                                    withSubject:subject 
                                    withContent:[NSString stringWithFormat:@"This is debug info:"] 
                                       withFrom:nil 
                                  withFilePaths:[NSArray arrayWithObject:fileName]];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
        });
    });
}
- (IBAction)showHideUserCompanyInfo:(id)sender {
    if (!userCompanyInfo) {
        userCompanyInfo = [[UserCompanyInfo alloc] initWithNibName:@"UserCompanyInfo" bundle:nil];
        userCompanyInfo.isViewHidden = NO;
        [self.destinationsView localMocMustUpdate];
        [self.carriersView localMocMustUpdate];
        [self.userCompanyInfo localMocMustUpdate];
        
//#if defined(SNOW_SERVER)
//        //userCompanyInfo.view.frame = NSMakeRect(userCompanyInfo.view.frame.origin.x - userCompanyInfo.view.frame.size.width + 15, userCompanyInfo.view.frame.origin.y, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
////        [self.window.contentView addSubview:userCompanyInfo.view];
//        
//#else 
        if (!userCompanyInfoPopover)  userCompanyInfoPopover = [[NSPopover alloc] init];
        NSRect frameOfSender = [sender frame];
        
        if (userCompanyInfoPopover) {
            //userCompanyInfo.view.frame = NSMakeRect(0, 0, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
            
            userCompanyInfoPopover.contentViewController = userCompanyInfo;
            userCompanyInfoPopover.behavior = NSPopoverBehaviorApplicationDefined;
            [userCompanyInfoPopover showRelativeToRect:frameOfSender ofView:self.window.contentView preferredEdge:NSMaxXEdge];
        } else
        {
            userCompanyInfo.view.frame = NSMakeRect(userCompanyInfo.view.frame.origin.x + userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.origin.y, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
            
            [self.window.contentView addSubview:userCompanyInfo.view];
            
            CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
            controlPosAnim.delegate = self;
            controlPosAnim.duration = 0.5;
            NSRect viewRect =  [userCompanyInfo.view frame];
            
            NSPoint startingPoint = viewRect.origin;
            NSPoint endingPoint = startingPoint;
            endingPoint.x -= userCompanyInfo.view.frame.size.width - 15;
            controlPosAnim.fromValue = [NSValue valueWithPoint:startingPoint];
            controlPosAnim.toValue = [NSValue valueWithPoint:endingPoint];
            [[userCompanyInfo.view layer] addAnimation:controlPosAnim forKey:@"controlViewPosition"];
            
            userCompanyInfo.view.frame = NSMakeRect(userCompanyInfo.view.frame.origin.x - userCompanyInfo.view.frame.size.width + 15, userCompanyInfo.view.frame.origin.y, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
        }
//#endif
        //        [self.destinationsView localMocMustUpdate];
        //        [self.carriersView localMocMustUpdate];
        //        [self.userCompanyInfo localMocMustUpdate];
        
    } else {
        if (userCompanyInfo.isViewHidden) {
            [self.destinationsView localMocMustUpdate];
            [self.carriersView localMocMustUpdate];
            [self.userCompanyInfo localMocMustUpdate];
            
            userCompanyInfo.isViewHidden = NO;
#if defined(SNOW_SERVER)
            //userCompanyInfo.view.frame = NSMakeRect(userCompanyInfo.view.frame.origin.x - userCompanyInfo.view.frame.size.width + 15, userCompanyInfo.view.frame.origin.y, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
            [self.window.contentView addSubview:userCompanyInfo.view];
            
#else 
            if (!userCompanyInfoPopover) userCompanyInfoPopover = [[NSPopover alloc] init];
            NSRect frameOfSender = [sender frame];
            
            if (userCompanyInfoPopover) {
                //userCompanyInfo.view.frame = NSMakeRect(0, 0, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
                
                userCompanyInfoPopover.contentViewController = userCompanyInfo;
                userCompanyInfoPopover.behavior = NSPopoverBehaviorApplicationDefined;
                [userCompanyInfoPopover showRelativeToRect:frameOfSender ofView:self.window.contentView preferredEdge:NSMaxXEdge];
            } else
            {
                userCompanyInfo.view.frame = NSMakeRect(userCompanyInfo.view.frame.origin.x + userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.origin.y, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
                
                [self.window.contentView addSubview:userCompanyInfo.view];
                
                CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
                controlPosAnim.delegate = self;
                controlPosAnim.duration = 0.5;
                NSRect viewRect =  [userCompanyInfo.view frame];
                
                NSPoint startingPoint = viewRect.origin;
                NSPoint endingPoint = startingPoint;
                endingPoint.x -= userCompanyInfo.view.frame.size.width - 15;
                controlPosAnim.fromValue = [NSValue valueWithPoint:startingPoint];
                controlPosAnim.toValue = [NSValue valueWithPoint:endingPoint];
                [[userCompanyInfo.view layer] addAnimation:controlPosAnim forKey:@"controlViewPosition"];
                userCompanyInfo.view.frame = NSMakeRect(userCompanyInfo.view.frame.origin.x - userCompanyInfo.view.frame.size.width + 15, userCompanyInfo.view.frame.origin.y, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
            }
#endif
            //            [self.destinationsView localMocMustUpdate];
            //            [self.carriersView localMocMustUpdate];
            //            [self.userCompanyInfo localMocMustUpdate];
            
            
        } else {
            userCompanyInfo.isViewHidden = YES;
            
            if (userCompanyInfoPopover) { 
                [userCompanyInfoPopover close];
                
            }
            else {
                
                [userCompanyInfo.view removeFromSuperview];
                
#if defined(SNOW_SERVER)
#else
                userCompanyInfo.view.frame = NSMakeRect(userCompanyInfo.view.frame.origin.x - 15, userCompanyInfo.view.frame.origin.y, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
#endif           
            }
            
        }
    }
    
    
}

- (IBAction)showHideGetExternalInfo:(id)sender {

    if (!getExternalInfoView) {
        getExternalInfoView = [[GetExternalInfoView alloc] initWithNibName:@"GetExternalInfoView" bundle:nil];
        
        if (!getExternalCompanyInfoPopover) getExternalCompanyInfoPopover = [[NSPopover alloc] init];
        NSRect frameOfSender = [sender frame];
        if (getExternalCompanyInfoPopover) {
            //userCompanyInfo.view.frame = NSMakeRect(0, 0, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
            
            getExternalCompanyInfoPopover.contentViewController = getExternalInfoView;
            getExternalCompanyInfoPopover.behavior = NSPopoverBehaviorApplicationDefined;
            [getExternalCompanyInfoPopover showRelativeToRect:frameOfSender ofView:self.window.contentView preferredEdge:NSMaxXEdge];
        } else
        {
            
            getExternalInfoView.view.frame = NSMakeRect(getExternalInfoView.view.frame.origin.x - getExternalInfoView.view.frame.size.width, getExternalInfoView.view.frame.origin.y, getExternalInfoView.view.frame.size.width, getExternalInfoView.view.frame.size.height);
            [self.window.contentView addSubview:getExternalInfoView.view];
            
            CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
            controlPosAnim.delegate = self;
            controlPosAnim.duration = 0.5;
            NSRect viewRect =  [getExternalInfoView.view frame];
            
            NSPoint startingPoint = viewRect.origin;
            NSPoint endingPoint = startingPoint;
            endingPoint.x += getExternalInfoView.view.frame.size.width + 20;
            controlPosAnim.fromValue = [NSValue valueWithPoint:startingPoint];
            controlPosAnim.toValue = [NSValue valueWithPoint:endingPoint];
            [[getExternalInfoView.view layer] addAnimation:controlPosAnim forKey:@"controlViewPosition"];
            getExternalInfoView.view.frame = NSMakeRect(getExternalInfoView.view.frame.origin.x + getExternalInfoView.view.frame.size.width + 20, getExternalInfoView.view.frame.origin.y, getExternalInfoView.view.frame.size.width, getExternalInfoView.view.frame.size.height);
        }
        getExternalInfoView.isViewHidden = NO;
        
        
    } else {
        if (getExternalInfoView.isViewHidden) {
            if (!getExternalCompanyInfoPopover) getExternalCompanyInfoPopover = [[NSPopover alloc] init];
            NSRect frameOfSender = [sender frame];
            if (getExternalCompanyInfoPopover) {
                //userCompanyInfo.view.frame = NSMakeRect(0, 0, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
                
                getExternalCompanyInfoPopover.contentViewController = getExternalInfoView;
                getExternalCompanyInfoPopover.behavior = NSPopoverBehaviorApplicationDefined;
                [getExternalCompanyInfoPopover showRelativeToRect:frameOfSender ofView:self.window.contentView preferredEdge:NSMaxXEdge];
            } else {
                
                getExternalInfoView.view.frame = NSMakeRect(getExternalInfoView.view.frame.origin.x - getExternalInfoView.view.frame.size.width, getExternalInfoView.view.frame.origin.y, getExternalInfoView.view.frame.size.width, getExternalInfoView.view.frame.size.height);
                
                [self.window.contentView addSubview:getExternalInfoView.view];
                CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
                controlPosAnim.delegate = self;
                controlPosAnim.duration = 0.5;
                NSRect viewRect =  [getExternalInfoView.view frame];
                
                NSPoint startingPoint = viewRect.origin;
                NSPoint endingPoint = startingPoint;
                endingPoint.x += getExternalInfoView.view.frame.size.width + 20;
                controlPosAnim.fromValue = [NSValue valueWithPoint:startingPoint];
                controlPosAnim.toValue = [NSValue valueWithPoint:endingPoint];
                [[getExternalInfoView.view layer] addAnimation:controlPosAnim forKey:@"controlViewPosition"];
                getExternalInfoView.view.frame = NSMakeRect(getExternalInfoView.view.frame.origin.x + getExternalInfoView.view.frame.size.width + 20, getExternalInfoView.view.frame.origin.y, getExternalInfoView.view.frame.size.width, getExternalInfoView.view.frame.size.height);
            }
            getExternalInfoView.isViewHidden = NO;
            
        } else {
            //            CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
            //            controlPosAnim.delegate = self;
            //            controlPosAnim.duration = 0.5;
            //            NSRect viewRect =  [userCompanyInfo.view frame];
            //            
            //            NSPoint startingPoint = viewRect.origin;
            //            NSPoint endingPoint = startingPoint;
            //            endingPoint.x += userCompanyInfo.view.frame.size.width;
            //            controlPosAnim.fromValue = [NSValue valueWithPoint:startingPoint];
            //            controlPosAnim.toValue = [NSValue valueWithPoint:endingPoint];
            //            [[userCompanyInfo.view layer] addAnimation:controlPosAnim forKey:@"controlViewPosition"];
            //            userCompanyInfo.view.frame = NSMakeRect(userCompanyInfo.view.frame.origin.x + userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.origin.y, userCompanyInfo.view.frame.size.width, userCompanyInfo.view.frame.size.height);
            //
            getExternalInfoView.isViewHidden = YES;
            
            if (getExternalCompanyInfoPopover) { 
                [getExternalCompanyInfoPopover close];
                
            } else {
                
                [getExternalInfoView.view removeFromSuperview];
                getExternalInfoView.view.frame = NSMakeRect(getExternalInfoView.view.frame.origin.x - 20, getExternalInfoView.view.frame.origin.y, getExternalInfoView.view.frame.size.width, getExternalInfoView.view.frame.size.height);
            }
            
            
        }
    }
    
}
- (IBAction)updateEventsList:(id)sender {

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:1]; // From January 2012
    [components setYear:2012];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *startDateDate = [gregorian dateFromComponents:components];
    
    //NSDate *startDateDate = [NSDate date];
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:+6004800];
    
    CalCalendarStore *myStore = [CalCalendarStore defaultCalendarStore];
    NSArray *calendars = [myStore calendars];
    
    NSPredicate *eventsForNextTwoWeeks = [CalCalendarStore eventPredicateWithStartDate:startDateDate endDate:endDate calendars:calendars];
    NSArray *eventsTwoWeeks = [myStore eventsWithPredicate:eventsForNextTwoWeeks];
    
    NSPredicate *filterCalendars = [NSPredicate predicateWithFormat:@"calendar.title contains[cd] '_'"];
    
    NSArray *filteredEvents = [eventsTwoWeeks filteredArrayUsingPredicate:filterCalendars];
    [updateForMainThread fillEventsListInternallyAndSaveToDiskForExternalUsing:filteredEvents];
    if ([self.loggingLevel intValue] == 1) NSLog(@"APP DELEGATE:Calendar events list to udpate:%@",filteredEvents);
    [components release];
}


#pragma mark - Main view update methods
-(void) createAndConnectMainThreadControllers;
{
    //NSLog(@"APP DELEGATE:main thread controllers created");
    if (!databaseForMainThread) databaseForMainThread = [[MySQLIXC alloc] initWithDelegate:self withProgress:nil];
    if (!updateForMainThread) updateForMainThread = [[UpdateDataController alloc] initWithDatabase:databaseForMainThread];
    
    NSArray *connections = [self.updateForMainThread databaseConnections];
    if ([connections count] == 0) { 
#if defined (SNOW_CLIENT_ENTERPRISE) || defined(SNOW_SERVER)
        [self.updateForMainThread setupDefaultDatabaseConnections];
#endif
        
#if defined(SNOW_CLIENT_APPSTORE)
        //        userDataControllerForMainThread = [[UserDataController alloc] init];
        //        userDataControllerForMainThread.context = [self managedObjectContext];
#endif
        [self performSelectorOnMainThread:@selector(safeSave) withObject:nil waitUntilDone:YES];
        connections = [updateForMainThread databaseConnections];
    }
    databaseForMainThread.connections = connections;
    if (!progressForMainThread) progressForMainThread = [[ProgressUpdateController alloc] initWithDelegate:self];
}


-(void)updateWellcomeTitle;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        //NSLog(@"APP DELEGATE:update title will update");
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[self managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[self managedObjectContext]];
        
        CompanyStuff *admin = [clientController authorization];
        NSString *title = nil;
        
        if (admin && [admin.GUID isEqualToString:admin.currentCompany.companyAdminGUID]) title = [NSString stringWithFormat:@"Welcome, %@ %@. With email %@ you are admin of the company %@",admin.firstName,admin.lastName,admin.email,admin.currentCompany.name];
        else title = [NSString stringWithFormat:@"Welcome, %@ %@. With email %@ you are part of the community of the company %@",admin.firstName,admin.lastName,admin.email,admin.currentCompany.name];
        if (!admin || !admin.email || [admin.email isEqualToString:@"you@email"]) title = nil;
        self.currentUserInfoList.title = title;
        // });
        [clientController release];
        
    });
}


@end
