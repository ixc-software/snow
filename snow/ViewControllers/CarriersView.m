//
//  CarriersView.m
//  snow
//
//  Created by Oleksii Vynogradov on 1/26/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "CarriersView.h"
#import "AVResizedTableHeaderView.h"
#import "AVTableHeaderView.h"
#import "AVGradientBackgroundView.h"
#import "ClientController.h"
#import "desctopAppDelegate.h"

#import "CurrentCompany.h"
#import "CompanyStuff.h"
#import "Carrier.h"
#import "CarrierStuff.h"
#import "Financial.h"

#import "MySQLIXC.h"
#import "UpdateDataController.h"
#import "ProgressUpdateController.h"


@implementation CarriersView
@synthesize carrier;
@synthesize twitterWebView,twitterController,linkedinController;
@synthesize pin;
@synthesize authorizeButton;
@synthesize twitterAuthViewController;
@synthesize networkTypeTab;
@synthesize networksUpdateProgress;
@synthesize linkedinWebView;
@synthesize twitterEnabled;
@synthesize linkedinEnabled;
@synthesize groupsListController;
@synthesize messageTitle;
@synthesize messageBody;
@synthesize messageSignature;
@synthesize messageIncludePrice;
@synthesize messagePriceCorrectionPercentTitle;
@synthesize infoTab;
@synthesize contactsTableView;
@synthesize contactsScrollView;
@synthesize contactsChoice;
@synthesize responsibleTableView;
@synthesize responsibleProgress;
@synthesize responsibleChoice;
@synthesize responsibleChoiceLabelInfo;
@synthesize detailsTableView;
@synthesize financialDetailsTableView;
@synthesize financialDetailsScrollView;
@synthesize financialChoice;
@synthesize companyDetailsTableView;
@synthesize statisticChoicePeriod;
@synthesize statisticChoiceDateFrom;
@synthesize statisticProgress;
@synthesize statisticTotalMysqlRecords;
@synthesize statisticTotalLocalRecords;
@synthesize statisticTotalMysqlRecordsWeBuy;
@synthesize statisticTotalLocalRecordsWeBuy;
@synthesize infoContacts;
@synthesize infoResponsible;
@synthesize infoDetails;
@synthesize infoFinansialDetails;
@synthesize infoCompanyDetails;
@synthesize errorPanel;
@synthesize errorText;
@synthesize linkedinGroups;
@synthesize twitterAuthorizationButton;
@synthesize addCarrier;
@synthesize removeCarrier;
@synthesize status;
@synthesize profit;
@synthesize progress;
@synthesize globalSearch;
@synthesize syncCarrier;
@synthesize financialInfo;
@synthesize filterByRating;
@synthesize globalSearchProgress;
@synthesize filterText;
@synthesize infoViewController;
@synthesize financialViewController;
@synthesize carriersTableView;
@synthesize infoCarrierButton;
@synthesize introductionShowAgain;
@synthesize introductionInfo;
@synthesize introductionText;
@synthesize introductionPanel;
@synthesize introductionButton;
@synthesize introductionPopover;
@synthesize messageIncludePriceValue,messagePriceCorrectionPercent;
@synthesize delegate,moc,mainMoc;

@synthesize infoViewPopover,financialViewPopover,infoViewPanel,financialViewPanel,financialView;
@synthesize importRatesPanel,importRatesMainPanel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        mainMoc = delegate.managedObjectContext;
        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
        introductionShowAgain = [[NSNumber alloc] init];
        groupListObjectsForCollectAllGroups = [[NSMutableArray alloc] init];
        groupListObjects  = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

#pragma mark -
#pragma mark CORE DATA methods


- (void)importerDidSave:(NSNotification *)saveNotification {
    NSLog(@"MERGE in carriers view controller");
    
    
    //[delegate.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
    //NSManagedObjectContext *mainMoc = [delegate managedObjectContext];
    
    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                              withObject:saveNotification
                           waitUntilDone:YES];
 
    //    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    @synchronized (delegate) {
//    }
//    
//    if ([NSThread isMainThread]) {
//        
//        [[delegate managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
//        @synchronized (delegate) {
//            
//            delegate.isAnyControllersMakeMerge = NO;
//        }
//        
//    } else {
//        while (delegate.isAnyControllersMakeMerge) {
//            sleep(2);
//            //NSLog(@"MERGE in destination controller waiting");
//            
//        } 
//        delegate.isAnyControllersMakeMerge = YES;
//        
//        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
//    }
}


- (void)logError:(NSError*)error;
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

-(void) finalSaveForMoc:(NSManagedObjectContext *)mocForSave {
    //BOOL success = YES;
    
    if ([mocForSave hasChanges]) {
        NSError *error = nil;
        if (![mocForSave save: &error]) {
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0)
            {
                for(NSError* detailedError in detailedErrors)
                {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else
            {
                NSLog(@"  %@", [error userInfo]);
            }
            [self logError:error];
            //success = NO;
        }
    }
    return;
    
}
-(void)localMocMustUpdate;
{
    
//    NSLog(@"CARRIERS VIEW:local moc will update");
    
//    [self finalSaveForMoc:moc];
//    NSManagedObject *selectedObject = [[carrier selectedObjects] lastObject];
//    NSManagedObjectID *selectedDestinationsID = selectedObject.objectID;
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
//    
//    [moc release];
//    moc = [[NSManagedObjectContext alloc] init];
//    [moc setUndoManager:nil];
//    [moc setMergePolicy:NSOverwriteMergePolicy];
//    [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
//        
//        
//        [carrier bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//            
//            sleep(1);
//            NSArray *allObjects = [carrier arrangedObjects];
//            if (selectedDestinationsID) {
//                NSInteger selectionsIndex = [allObjects indexOfObject:[moc objectWithID:selectedDestinationsID]];
//                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    
//                    [carrier setSelectionIndex:selectionsIndex];
//                });
//            }
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                
//                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//                CompanyStuff *admin = [clientController authorization];
//                if (admin) {
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyStuff.currentCompany.GUID == %@",admin.currentCompany.GUID];
//                    carrier.filterPredicate = predicate;
//                } 
//                [clientController release];
//            });
//        });
//    });
    
}

#pragma mark - internal methods
-(void) updateTableView:(NSTableView *)tableView;
{
    NSTableHeaderView *currentTableHeader = [tableView headerView];
    //AVResizedTableHeaderView *newView = [[[AVResizedTableHeaderView alloc] init] autorelease];
    NSRect currentRect = [currentTableHeader frame];
    
    [currentTableHeader setFrame:NSRectFromCGRect(CGRectMake(currentRect.origin.x, currentRect.origin.y, currentRect.size.width, currentRect.size.height + 5))];
    [currentTableHeader setBounds:[currentTableHeader bounds]];
    [tableView setHeaderView:currentTableHeader];
    
    for (NSTableColumn *column in [tableView tableColumns]) {
        NSString *info = [[column headerCell] stringValue];
        NSFont *myFont = [NSFont systemFontOfSize:12];
        
        AVTableHeaderView *newHeader = [[[AVTableHeaderView alloc]
                                         initTextCell:info] autorelease];
        [newHeader setTextColor:[NSColor whiteColor]];
        [newHeader setFont:myFont];
        //NSSize myStringSize = [info sizeWithAttributes:nil];
        //NSSize cellSize = [[column headerCell] cellSize];
        //if (myStringSize.width > cellSize.width) NSLog(@"gare it for %@",info);
        
        [newHeader setControlSize:NSRegularControlSize];
        [newHeader setAlignment:NSCenterTextAlignment];
        
        //[column set
        [column setHeaderCell:newHeader];
        
    }
    [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [tableView setBackgroundColor:[NSColor colorWithDeviceRed:0.52 green:0.54 blue:0.70 alpha:1]];
    NSRect frame = [[tableView cornerView] frame];
    //NSLog(@"Corner frame:%@",NSStringFromRect(frame));
    
    [tableView setCornerView:nil];
    AVGradientBackgroundView *newView = [[[AVGradientBackgroundView alloc] initWithFrame:frame] autorelease];
    [tableView setCornerView:newView];
    
}
-(void) sortCarrierForCurrentUserAndUpdate;
{
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        CompanyStuff *admin = [clientController authorization];
        if (admin) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyStuff.currentCompany.GUID == %@",admin.currentCompany.GUID];
            carrier.filterPredicate = predicate;
        } 
        
        [clientController release];
    });
#endif

}

- (void)awakeFromNib
{
//    delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    allCarrierContactIDs = [[NSMutableArray alloc] init];
    allCarrierFinancialIDs = [[NSMutableArray alloc] init];
    allCarrierCompanyStufffIDs = [[NSMutableArray alloc] init];
    allUpdatedObjectIDs = [[NSMutableArray alloc] init];
    [carriersTableView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];

    [self updateTableView:carriersTableView];
    // info block
    [self updateTableView:contactsTableView];
    [self updateTableView:responsibleTableView];
    [self updateTableView:detailsTableView];
    [self updateTableView:financialDetailsTableView];
    [self updateTableView:companyDetailsTableView];
    [self updateTableView:linkedinGroups];
    [statisticChoicePeriod removeAllItems];
    [statisticChoicePeriod addItemsWithTitles:[NSArray arrayWithObjects:@"last day",@"last week",@"last month", nil]];
    //[twitterAuthorizationButton setAlphaValue:0.5];

    
    [self sortCarrierForCurrentUserAndUpdate];

#if defined(SNOW_CLIENT_APPSTORE)
    [infoTab removeTabViewItem:[infoTab tabViewItemAtIndex:5]];
    [syncCarrier setHidden:YES];
    [financialInfo setHidden:YES];
    [filterByRating setHidden:YES];
    [profit setHidden:YES];
    [filterText setHidden:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];        
        self.carrier.sortDescriptors = [NSArray arrayWithObject:descriptor];
        [descriptor release];
    });

#else
    [addCarrier setEnabled:NO];
    [removeCarrier setEnabled:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"latestUpdateTime" ascending:NO];        
        carrier.sortDescriptors = [NSArray arrayWithObject:descriptor];
        [descriptor release];
    });
    
#endif
    
#if defined(SNOW_SERVER)
    [addCarrier setEnabled:YES];
    [removeCarrier setEnabled:YES];

#endif
//    [twitterWebView setDrawsBackground:NO];
//    [[[twitterWebView mainFrame] frameView] setAllowsScrolling:NO];
    
//    NSLog(@">>>>>>>>> %@ %@",carrier.arrangedObjects,carrier.filterPredicate);
    [carrier setFilterPredicate:nil];
//    NSLog(@">>>>>>>>> %@ %@",carrier.arrangedObjects,carrier.filterPredicate);

}

-(id) userDefaultsObjectForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}


-(NSString *)localStatusForObjectsWithRootGuid:(NSString *)rootObjectGUID;
{
    //NSString *objectGUID = [objects valueForKey:@"rootObjectGUID"];
    NSDictionary *objectStatus =[self userDefaultsObjectForKey:rootObjectGUID];
    NSString *statusLocal = nil;
    if (objectStatus) { 
        if ([objectStatus valueForKey:@"update"]) statusLocal = [objectStatus valueForKey:@"update"];
        if ([objectStatus valueForKey:@"new"]) statusLocal =  [objectStatus valueForKey:@"new"]; 
        if ([objectStatus valueForKey:@"login"]) statusLocal =  [objectStatus valueForKey:@"login"]; 
        
    }
    return statusLocal;
}

-(void)showErrorBoxWithText:(NSString *)error
{
    
    [errorPanel setBackgroundColor:[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1]];
    [errorText setStringValue:error];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [NSApp beginSheet:errorPanel 
           modalForWindow:delegate.window
            modalDelegate:nil 
           didEndSelector:nil
              contextInfo:nil];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        sleep(4);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [errorPanel orderOut:delegate.window];
            [NSApp endSheet:errorPanel];
            
        });
    });
    
}

- (NSArray *) transformContentFromHorizontalToVerticalDataForBinding:(NSManagedObject *)content;
{
    
    NSMutableArray *columns = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMM"];
    
    for (NSString *attribute in [[content entity] attributeKeys])
    {
        //[attribute isEqualToString:@"GUID"]
        if ( [attribute isEqualToString:@"deviceToken"] || [attribute isEqualToString:@"isCompanyAdmin"]|| [attribute isEqualToString:@"login"]|| [attribute isEqualToString:@"password"]|| [attribute isEqualToString:@"companyAdminGUID"]) ; else {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            [row setValue:attribute forKey:@"attribute"];
            
            if ([content valueForKey:attribute]){ 
                id object = [content valueForKey:attribute];
                if ([[object class] isSubclassOfClass:[NSDate class]]) {
                    [row setValue:[formatter stringFromDate:object] forKey:@"data"]; 
                } else [row setValue:[content valueForKey:attribute] forKey:@"data"]; 
                
            }
            else [row setValue:@"" forKey:@"data"];
            [columns addObject:row];
        }
    }
    [formatter release];
    return [NSArray arrayWithArray:columns];
}

- (void) doUpdatesUIwithDateFrom:(NSDate *)dateFrom withDateTo:(NSDate *)dateTo
{
    [statisticChoicePeriod setEnabled:NO];
    [statisticChoiceDateFrom setEnabled:NO];
    [statisticProgress setHidden:NO];
    [statisticProgress startAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        Carrier *selectedCarrier = carrier.selectedObjects.lastObject;
        
        //        NSDate *dateFromTodayToCheck = nil;
        //        NSInteger selectedIndex = [statisticPeriodChoicer indexOfSelectedItem];
        //        if (selectedIndex == 0) dateFromTodayToCheck = [NSDate dateWithTimeIntervalSinceNow:-86400];
        //        if (selectedIndex == 1) dateFromTodayToCheck = [NSDate dateWithTimeIntervalSinceNow:-604800];
        //        if (selectedIndex == 2) dateFromTodayToCheck = [NSDate dateWithTimeIntervalSinceNow:-2419200];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationPerHourStat"
                                                  inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date > %@) and (date < %@) and (destinationsListForSale.carrier.GUID == %@)",dateFrom,dateTo,selectedCarrier.GUID];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSUInteger countLocalForSale = [[delegate managedObjectContext] countForFetchRequest:fetchRequest error:&error];
        predicate = [NSPredicate predicateWithFormat:@"(date > %@) and (date < %@) and (destinationsListWeBuy.carrier.GUID == %@)",dateFrom,dateTo,selectedCarrier.GUID];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setPredicate:predicate];
        
        NSUInteger countLocalWeBuy = [[delegate managedObjectContext] countForFetchRequest:fetchRequest error:&error];
        
        MySQLIXC *databaseForCountStatistic = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
        NSArray *connections = [[NSArray alloc] initWithArray:[delegate.updateForMainThread databaseConnections]];
        databaseForCountStatistic.connections = connections;
        [connections release];
        
        NSUInteger countMysqlForSale = [databaseForCountStatistic countOfStatisticForSalePerHourForCarrier:selectedCarrier.name fromDate:dateFrom toDate:dateTo]; 
        
        NSUInteger countMysqlWeBuy = [databaseForCountStatistic countOfStatisticWeBuyPerHourForCarrier:selectedCarrier.name fromDate:dateFrom toDate:dateTo]; 
        [databaseForCountStatistic release];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [statisticChoicePeriod setEnabled:YES];
            [statisticChoiceDateFrom setEnabled:YES];
            [statisticProgress setHidden:YES];
            [statisticProgress stopAnimation:self];
            
            [statisticTotalLocalRecords setTitle:[NSString stringWithFormat:@"Total local for sale hour records:%@",[NSNumber numberWithUnsignedInteger:countLocalWeBuy]]];
            [statisticTotalLocalRecordsWeBuy setTitle:[NSString stringWithFormat:@"Total local we buy hour records:%@",[NSNumber numberWithUnsignedInteger:countLocalForSale]]];
            [statisticTotalMysqlRecords setTitle:[NSString stringWithFormat:@"Total mysql for sale hour records:%@",[NSNumber numberWithUnsignedInteger:countMysqlForSale]]];
            [statisticTotalLocalRecordsWeBuy setTitle:[NSString stringWithFormat:@"Total mysql we buy hour records:%@",[NSNumber numberWithUnsignedInteger:countMysqlWeBuy]]];
        });
        [fetchRequest release];
    });
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    //if ([delegate.loggingLevel intValue] == 1) NSLog( @">>>> CARRIER VIEW:Detected Change in keyPath: %@, change:%@", keyPath,change );
    id new = [change valueForKey:@"new"];
    id old = [change valueForKey:@"old"];
    if ([new isEqualTo:old]) { 
        //NSLog(@"nothing to change, return");
        return;
    }
    NSManagedObject *changedObject = nil;
    if (context) changedObject = [moc objectWithID:context];
    else changedObject = object;
    
    if (!changedObject) NSLog(@"CARRIER VIEW:warning, object not found");
    else {
        if ([[changedObject class] isSubclassOfClass:[Carrier class]]) {
            [changedObject removeObserver:self forKeyPath:@"name"];
            Carrier *necessaryCarrier = (Carrier *)[self.moc objectWithID:changedObject.objectID];
            [necessaryCarrier setValue:new forKey:keyPath];
            
#if defined(SNOW_CLIENT_APPSTORE) 
            [self finalSaveForMoc:self.moc];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[changedObject objectID]] mustBeApproved:NO];
        [clientController release];
    });
#endif

        } else {
            [allUpdatedObjectIDs addObject:changedObject.objectID];
            [changedObject setValue:[object valueForKey:@"data"] forKeyPath:[object valueForKey:@"attribute"]];
        }
    }
        
    //[self finalSaveForMoc:self.moc];
    
//#if defined(SNOW_CLIENT_APPSTORE) || defined(SNOW_CLIENT_ENTERPRISE)
//    
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    [appDelegate safeSave];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[changedObject objectID]] mustBeApproved:NO];
//        [clientController release];
//    });
//#endif
    
}


#pragma mark - main block functions
- (IBAction)addCarrier:(id)sender {
    CompanyStuff *companyStuffForNewCarrier = nil;
#if defined (SNOW_SERVER)
    companyStuffForNewCarrier = (CompanyStuff *)[moc objectWithID:delegate.userCompanyInfo.selectedUserID];

#endif
    
    
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *user = [clientController authorization];    
    companyStuffForNewCarrier = (CompanyStuff *)[moc objectWithID:[user objectID]];    
#endif
    
    Carrier *newCarrier = (Carrier *)[NSEntityDescription 
                                      insertNewObjectForEntityForName:@"Carrier" 
                                      inManagedObjectContext:self.moc];
    newCarrier.name = [NSString stringWithFormat:@"new carrier %@",[NSNumber numberWithInteger:[[carrier arrangedObjects] count]]];
    newCarrier.companyStuff = companyStuffForNewCarrier;
    [self finalSaveForMoc:moc];
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    NSString *statusForCompanyStuff = [self localStatusForObjectsWithRootGuid:newCarrier.companyStuff.GUID];
    if ([statusForCompanyStuff isEqualToString:@"registered"]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
            
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[newCarrier objectID]] mustBeApproved:NO];
            [clientController release];
            
        });
    } else [self showErrorBoxWithText:@"Please register yourself,changes was not uploaded. For registration you can just change default email and company name."];
    
    [clientController release];
#endif
    
}

- (IBAction)removeCarrier:(id)sender {
    NSArray *removedObjects = [carrier selectedObjects];
#if defined(SNOW_SERVER)
    [carrier removeObjects:removedObjects];
    [self finalSaveForMoc:moc];
    return;
#endif
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *admin = [clientController authorization];
    if ([[clientController localStatusForObjectsWithRootGuid:admin.GUID] isEqualToString:@"registered"]) { 
        
        //        [removeCarrier setEnabled:NO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            [removedObjects enumerateObjectsUsingBlock:^(Carrier *carrierToRemove, NSUInteger idx, BOOL *stop) {
                NSString *statusLocal = [self localStatusForObjectsWithRootGuid:carrierToRemove.GUID];
                
                if ([statusLocal isEqualToString:@"external server"]) {
                    [self showErrorBoxWithText:@"You can't remove server registered carriers."];
                } else
                {
                    NSString *guidToCheckUser = carrierToRemove.companyStuff.GUID;
                    
                    if (guidToCheckUser) {
                        NSString *statusForCompanyStuff = [self localStatusForObjectsWithRootGuid:guidToCheckUser];
                        if ([statusForCompanyStuff isEqualToString:@"registered"]) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                //NSLog(@"CARRIER: >>>>>>>DISABLE");
                                [removeCarrier setEnabled:NO];
                            });
                            
                            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                            [clientController removeObjectWithID:[carrierToRemove objectID]];
                            [clientController release];
                        } else { 
                            
                            [self showErrorBoxWithText:@"Please register yourself first."];
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                //NSLog(@"CARRIER: >>>>>>>ENABLE");
                                
                                [removeCarrier setEnabled:YES];
                            });
                            *stop = YES;
                        }
                    } else [self showErrorBoxWithText:@"Carier removing process."];
                } 

            }];
        });
    } else {
        [self showErrorBoxWithText:@"To remove carriers please register yourself first."];
        
    }
    [clientController release];

}

- (IBAction)infoCarrier:(id)sender {
    [infoCarrierButton setEnabled:NO];
#if defined(SNOW_CLIENT_APPSTORE)
#else
    [statisticChoiceDateFrom setDateValue:[NSDate date]];
#endif
    [allCarrierContactIDs removeAllObjects];
    [allCarrierFinancialIDs removeAllObjects];
    [allCarrierCompanyStufffIDs removeAllObjects];
    [allUpdatedObjectIDs removeAllObjects];
    
    NSUInteger selectedRow = carrier.selectionIndex;
    Carrier *selectedCarrier = [carrier.arrangedObjects objectAtIndex:selectedRow];
    selectedCarrierID = selectedCarrier.objectID;
    
    // carrier contacts 
    NSSet *allCarrierContact = selectedCarrier.carrierStuff;
    if (allCarrierContact.count > 1) {
        [contactsChoice removeAllItems];
        
        __block NSMutableArray *adminsForMenu = [NSMutableArray arrayWithCapacity:[allCarrierContact count]];
        __block NSUInteger idx = 0;
        
        [allCarrierContact enumerateObjectsUsingBlock:^(CarrierStuff *stuff, BOOL *stop) {
            [allCarrierContactIDs addObject:stuff.objectID];
            NSString *firstName = stuff.firstName;
            NSString *lastName = stuff.lastName;
            
            if (!firstName) firstName = @"";
            if (!lastName) lastName = @"";
            
            [adminsForMenu addObject:[NSString stringWithFormat:@"%@ %@",firstName,lastName]];
            if (idx == 0) {
                infoContacts.content = [self transformContentFromHorizontalToVerticalDataForBinding:stuff];
            }
            idx++;
        }];
        [contactsChoice addItemsWithTitles:[NSArray arrayWithArray:adminsForMenu]];
        [contactsChoice setHidden:NO];
        [contactsChoice setEnabled:YES];
        [contactsScrollView setHidden:NO];

    } else { 
        if (allCarrierContact.count == 0) {
            [contactsChoice removeAllItems];
            [contactsChoice setHidden:NO];
            [contactsChoice setEnabled:NO];
            [contactsChoice addItemWithTitle:@"NO CONTACTS"];
            [contactsScrollView setHidden:YES];
        } else {
            infoContacts.content = [self transformContentFromHorizontalToVerticalDataForBinding:selectedCarrier.carrierStuff.anyObject];
            [contactsScrollView setHidden:NO];
            [contactsChoice setHidden:YES];
        }
    }
    for (id verticalViewObject in infoContacts.arrangedObjects) [verticalViewObject addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  context:selectedCarrierID]; 

    
    // fill responsible for carrier inside company 
    CompanyStuff *currentStuff = (CompanyStuff *)selectedCarrier.companyStuff;
    infoResponsible.content = [self transformContentFromHorizontalToVerticalDataForBinding:currentStuff];
#if defined(SNOW_CLIENT_APPSTORE) || defined(SNOW_CLIENT_ENTERPRISE)
    
    if ([currentStuff.GUID isEqualToString:currentStuff.currentCompany.companyAdminGUID]) {
#endif
        [responsibleChoiceLabelInfo setStringValue:@"Change responsible to:"];
        [responsibleChoice removeAllItems];
        NSSet *currentCompanyStuff = currentStuff.currentCompany.companyStuff;
        //NSLog(@"CARRIER TABLE VIEW:all stuff is:%@",currentCompanyStuff);
        
        __block NSMutableArray *adminsForMenu = [NSMutableArray arrayWithCapacity:[currentCompanyStuff count]];
        __block NSUInteger indexToSelect = 0;
        __block NSUInteger idx = 0;
        [currentCompanyStuff enumerateObjectsUsingBlock:^(CompanyStuff *stuff, BOOL *stop) {
            [allCarrierCompanyStufffIDs addObject:stuff.objectID];

            NSString *firstName = stuff.firstName;
            NSString *lastName = stuff.lastName;
            
            if (!firstName) firstName = @"@";
            if (!lastName) lastName = @"@";
            
            [adminsForMenu addObject:[NSString stringWithFormat:@"%@ %@",firstName,lastName]];
            if ([stuff isEqual:currentStuff]) indexToSelect = idx;
            idx++;
        }];
        [responsibleChoice addItemsWithTitles:[NSArray arrayWithArray:adminsForMenu]];
        [responsibleChoice selectItemAtIndex:indexToSelect];
        [responsibleChoice setEnabled:YES];
        
#if defined(SNOW_CLIENT_APPSTORE) || defined(SNOW_CLIENT_ENTERPRISE)       
    } else {
        [responsibleChoiceLabelInfo setStringValue:@"Change responsible allow only for admin."];
        [responsibleChoice removeAllItems];
        [responsibleChoice setHidden:YES];
        
    }
#endif
    for (id verticalViewObject in infoResponsible.arrangedObjects) [verticalViewObject addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:selectedCarrierID]; 

    // fill carrier details
    infoDetails.content = [self transformContentFromHorizontalToVerticalDataForBinding:selectedCarrier];
    for (id verticalViewObject in infoDetails.arrangedObjects) [verticalViewObject addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:selectedCarrierID]; 

    // fill financialDetails
    NSSet *allCarriersFinancials = selectedCarrier.financial;
    if (allCarriersFinancials.count > 1) {
        [financialChoice removeAllItems];
        
        __block NSMutableArray *adminsForMenu = [NSMutableArray arrayWithCapacity:[allCarrierContact count]];
        __block NSUInteger idx = 0;
        
        [allCarriersFinancials enumerateObjectsUsingBlock:^(Financial *financial, BOOL *stop) {
            [allCarrierFinancialIDs addObject:financial.objectID];

            NSString *name = financial.name;
            NSString *bankName = financial.bankName;

            if (!name) name = @"";
            if (!bankName) bankName = @"";
            
            [adminsForMenu addObject:[NSString stringWithFormat:@"%@ - %@",name,bankName]];
            if (idx == 0) {
                infoFinansialDetails.content = [self transformContentFromHorizontalToVerticalDataForBinding:financial];
            }
            idx++;
        }];
        [financialChoice addItemsWithTitles:[NSArray arrayWithArray:adminsForMenu]];
        [financialChoice setHidden:NO];
        [financialChoice setEnabled:YES];
        [financialDetailsScrollView setHidden:NO];
        
    } else { 
        if (allCarriersFinancials.count == 0) {
            [financialChoice removeAllItems];
            [financialChoice setHidden:NO];
            [financialChoice setEnabled:NO];
            [financialChoice addItemWithTitle:@"NO FINANCIAL INFO"];
            [financialDetailsScrollView setHidden:YES];
        } else {
            infoFinansialDetails.content = [self transformContentFromHorizontalToVerticalDataForBinding:allCarriersFinancials.anyObject];
            [financialDetailsScrollView setHidden:NO];
            [financialChoice setHidden:YES];
        }
    }
    for (id verticalViewObject in infoFinansialDetails.arrangedObjects) [verticalViewObject addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:selectedCarrierID]; 
    
    // fill company details
    infoCompanyDetails.content = [self transformContentFromHorizontalToVerticalDataForBinding:selectedCarrier.companyStuff.currentCompany];
    for (id verticalViewObject in infoCompanyDetails.arrangedObjects) [verticalViewObject addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:selectedCarrier.companyStuff.currentCompany.objectID]; 
    
    if (!infoViewPopover) infoViewPopover = [[NSPopover alloc] init];
    //                NSRect frameOfTestingCell = [sender frame];

    NSRect frameOfSender = [carriersTableView frameOfCellAtColumn:0 row:selectedRow]; 
    
    if (infoViewPopover) {
        infoViewPopover.contentViewController = infoViewController;
        infoViewPopover.behavior = NSPopoverBehaviorApplicationDefined;
        [infoViewPopover showRelativeToRect:frameOfSender ofView:carriersTableView preferredEdge:NSMaxYEdge];
    } else
    {
        infoViewPanel = [[[NSPanel alloc] initWithContentRect:infoViewController.view.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
        [infoViewPanel.contentView addSubview:infoViewController.view];
        [NSApp beginSheet:infoViewPanel 
           modalForWindow:delegate.window
            modalDelegate:nil 
           didEndSelector:nil
              contextInfo:nil];
    }

}

- (IBAction)syncCarrier:(id)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ProgressUpdateController *progressForDaylySync = [[ProgressUpdateController alloc] initWithDelegate:delegate];
        progressForDaylySync.cycleSyncType = @"dayly";
        NSManagedObjectID *selectedCarrierIDforSync = [carrier.selectedObjects.lastObject objectID];
        [delegate.getExternalInfoView startUserChoiceSyncForCarriers:[NSArray arrayWithObject:selectedCarrierIDforSync] withProgress:progressForDaylySync withOperationName:@"once"];
        [progressForDaylySync release];
    });
}

- (IBAction)financialInfo:(id)sender {
    if (!financialViewPopover) financialViewPopover = [[NSPopover alloc] init];
    //                NSRect frameOfTestingCell = [sender frame];
    NSUInteger selectedRow = carrier.selectionIndex;

    NSRect frameOfSender = [carriersTableView frameOfCellAtColumn:0 row:selectedRow]; 
    if (!financialView) financialView = [[FinancialView alloc] initWithNibName:@"FinancialView" bundle:nil];
    [financialView prepare];
    financialViewController.view = financialView.view;
    
    if (financialViewPopover) {
        financialViewPopover.contentViewController = financialViewController;
        financialViewPopover.behavior = NSPopoverBehaviorApplicationDefined;
        [financialViewPopover showRelativeToRect:frameOfSender ofView:carriersTableView preferredEdge:NSMaxYEdge];
    } else
    {
        financialViewPanel = [[[NSPanel alloc] initWithContentRect:financialViewController.view.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
        [financialViewPanel.contentView addSubview:financialViewController.view];
        [NSApp beginSheet:financialViewPanel 
           modalForWindow:delegate.window
            modalDelegate:nil 
           didEndSelector:nil
              contextInfo:nil];
    }

}

- (IBAction)filterByRating:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSInteger selectedSegment = [sender selectedSegment];
        
        if (selectedSegment == 0) {
            [carrier setFilterPredicate:nil];
            
            NSNumber *rate = [NSNumber numberWithDouble:0.1];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"financialRate > %@",rate];
            [carrier setFilterPredicate:predicate];
        }
        if (selectedSegment == 1) {
            [carrier setFilterPredicate:nil];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"financialRate =< %@ AND (financialRate > %@)",[NSNumber numberWithDouble:0.1],[NSNumber numberWithDouble:0]];
            [carrier setFilterPredicate:predicate];
        }
        if (selectedSegment == 2) {
            [carrier setFilterPredicate:nil];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"financialRate == 0"];
            [carrier setFilterPredicate:predicate];
        }
    });

}



- (IBAction)globalSearch:(id)sender {
    [globalSearchProgress setHidden:NO];
    [globalSearchProgress startAnimation:self];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        
        NSMutableString *searchText = [NSMutableString stringWithString:[globalSearch stringValue]];
        
        // Remove extraenous whitespace
        while ([searchText rangeOfString:@"Â  "].location != NSNotFound) {
            [searchText replaceOccurrencesOfString:@"Â  " withString:@" " options:0 range:NSMakeRange(0, [searchText length])];
        }
        
        //Remove leading space
        if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0,1)];
        
        //Remove trailing space
        if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange([searchText length]-1, 1)];
        
        if ([searchText length] == 0) {
            //@synchronized (self) {
            
            if (delegate.isSearchProcessing == NO) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [globalSearchProgress setHidden:NO];
                    [globalSearchProgress startAnimation:self];
                });
                
                delegate.isSearchProcessing = YES;
                
                [delegate.destinationsView.destinationsListForSale setFilterPredicate:nil];
                [delegate.destinationsView.destinationsListTargets setFilterPredicate:nil];
                [delegate.destinationsView.destinationsListWeBuy setFilterPredicate:nil];
                [delegate.destinationsView.destinationsListPushList setFilterPredicate:nil];
                [self.carrier setFilterPredicate:nil];
                
                delegate.isSearchProcessing = NO;
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [globalSearchProgress setHidden:YES];
                    [globalSearchProgress stopAnimation:self];
                });

            }

            
            return;
        }
        
        NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
        
        if ([searchTerms count] == 1) {
            
            NSPredicate *p = [NSPredicate predicateWithFormat:@"(country contains[cd] %@) OR (specific contains[cd] %@) OR (carrier.name contains[cd] %@)", searchText,searchText,searchText];
            //@synchronized (self) {
            
            if (delegate.isSearchProcessing == NO) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [globalSearchProgress setHidden:NO];
                    [globalSearchProgress startAnimation:self];
                });

                delegate.isSearchProcessing = YES;
                
                [delegate.destinationsView.destinationsListForSale setFilterPredicate:p];
                [delegate.destinationsView.destinationsListTargets setFilterPredicate:p];
                [delegate.destinationsView.destinationsListWeBuy setFilterPredicate:p];
                [delegate.destinationsView.destinationsListPushList setFilterPredicate:p];
                p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@)",searchText];
                [self.carrier setFilterPredicate:p];
                delegate.isSearchProcessing = NO;
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [globalSearchProgress setHidden:YES];
                    [globalSearchProgress stopAnimation:self];
                });

            }
            //};
            
        } else {
            
            NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
            for (NSString *term in searchTerms) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"(country contains[cd] %@) OR (specific contains[cd] %@)  OR (carrier.name contains[cd] %@)", term,term,term];
                
                [subPredicates addObject:p];
            }
            NSPredicate *cp = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
            //@synchronized (self) {
            
            if (delegate.isSearchProcessing == NO) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [globalSearchProgress setHidden:NO];
                    [globalSearchProgress startAnimation:self];
                });

                delegate.isSearchProcessing = YES;
                
                [delegate.destinationsView.destinationsListForSale setFilterPredicate:cp];
                [delegate.destinationsView.destinationsListTargets setFilterPredicate:cp];
                [delegate.destinationsView.destinationsListWeBuy setFilterPredicate:cp];
                [delegate.destinationsView.destinationsListPushList setFilterPredicate:cp];
                NSMutableArray *subPredicatesForCountry = [[NSMutableArray alloc] init];
                for (NSString *term in searchTerms) {
                    NSPredicate *p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@)",searchText];
                    [subPredicatesForCountry addObject:p];
                }
                cp = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicatesForCountry];
                
                [carrier setFilterPredicate:cp];
                [subPredicatesForCountry release];

                delegate.isSearchProcessing = NO;
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [globalSearchProgress setHidden:YES];
                    [globalSearchProgress stopAnimation:self];
                });

            }
                
            
            [subPredicates release];
            //};

            
        }
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            [globalSearchProgress setHidden:YES];
//            [globalSearchProgress stopAnimation:self];
//        });

    });
    //} else NSLog(@"APP DELEGATE: search working with isSearchProcessing = YES");
}


#pragma mark - social network start functions
//-(NSArray*)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems{
//    NSArray *empty = [NSArray array];
//    return empty;
//}
//- (void)webView:(WebView *)sender resource:(id)identifier did
- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    [networksUpdateProgress startAnimation:self];
    [networksUpdateProgress setHidden:NO];
    //if ([identifier isEqualToString:@"linkedin"]) {
        BOOL requestForCallbackURL = ([request.URL.absoluteString rangeOfString:@"hdlinked://linkedin/oauth"].location != NSNotFound);
        if ( requestForCallbackURL )
        {
            BOOL userAllowedAccess = ([request.URL.absoluteString  rangeOfString:@"user_refused"].location == NSNotFound);
            
            if ( userAllowedAccess )
            {            
                //self.linkedinController.accessToken.verifier =  url;
                [linkedinController finishAuthorization:self withUrl:request.URL];
                //NSLog(@"VERIFIER URL:%@",self.linkedinController.accessToken.verifier);
                
            }
        }
        NSLog(@"finished linkedin:%@",request);
        
    //}
    return request;
}
- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource
{
    [networksUpdateProgress stopAnimation:self];
    [networksUpdateProgress setHidden:YES];
    //if ([identifier isEqualToString:@"linkedin"]) {
        
        NSLog(@"finished linkedin:%@",sender.mainFrameURL);

    //}
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//
//    [sender becomeFirstResponder];
//    });
    //NSLog(@"all data received");
}
- (IBAction)twitterAuthStart:(id)sender {
    
    NSRect frameOfSender = [twitterAuthorizationButton frame]; 
    if (!twitterViewPopover) twitterViewPopover = [[NSPopover alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        if (twitterViewPopover) {
            twitterViewPopover.contentViewController = twitterAuthViewController;
            twitterViewPopover.behavior = NSPopoverBehaviorApplicationDefined;
            [twitterViewPopover showRelativeToRect:frameOfSender ofView:self.view preferredEdge:NSMaxYEdge];
        } else
        {
            twitterViewPanel = [[[NSPanel alloc] initWithContentRect:twitterAuthViewController.view.frame styleMask:NSHUDWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
            [twitterViewPanel.contentView addSubview:twitterAuthViewController.view];
            [twitterViewPanel makeFirstResponder:twitterWebView];

            [NSApp beginSheet:twitterViewPanel 
               modalForWindow:delegate.window
                modalDelegate:nil 
               didEndSelector:nil
                  contextInfo:nil];
            
        }
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        [twitterAuthorizationButton setEnabled:NO];
        if (!twitterController) { 
            twitterController = [[TwitterUpdateDataController alloc] init];
            twitterController.delegate = self;
        }

        if (!twitterController.isAuthorized) [twitterController startAuthorization:self];

        // linkedin
        NSMutableArray *finalGroupsList = [[NSUserDefaults standardUserDefaults] valueForKey:@"allGroupList"];
        [groupsListController setContent:finalGroupsList];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"enabled" ascending:NO];
        [groupsListController setSortDescriptors:[NSArray arrayWithObject:sort]];
        [sort release];
        
        if (!linkedinController) { 
            linkedinController = [[LinkedinUpdateDataController alloc] init];
            linkedinController.delegate = self;
        }
        
        if (!linkedinController.isAuthorized)[linkedinController startAuthorization:self];
        NSNumber *includeRates = [[NSUserDefaults standardUserDefaults] valueForKey:@"includeRates"];
        messageIncludePriceValue = includeRates;
        NSNumber *priceCorrection = [[NSUserDefaults standardUserDefaults] valueForKey:@"priceCorrection"];
        messagePriceCorrectionPercent = priceCorrection;
        NSString *postingTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"postingTitle"];
        NSString *bodyForEdit = [[NSUserDefaults standardUserDefaults] valueForKey:@"bodyForEdit"];
        NSString *signature = [[NSUserDefaults standardUserDefaults] valueForKey:@"signature"];
        
        if (postingTitle) messageTitle.stringValue = postingTitle;
        if (bodyForEdit) messageBody.stringValue = bodyForEdit;
        if (signature) messageSignature.stringValue = signature;
        if (!priceCorrection) priceCorrection = [NSNumber numberWithInt:0];
        messagePriceCorrectionPercentTitle.stringValue = [NSString stringWithFormat:@"Percent correction:%@%%",priceCorrection];
        [messageIncludePrice bind:@"value" toObject:self withKeyPath:@"messageIncludePriceValue" options:nil];
    });

}

- (IBAction)twitterAuthorizeCancel:(id)sender {
    if (twitterViewPopover) [twitterViewPopover close];
    
    if (twitterViewPanel) {
        [twitterViewPanel orderOut:sender];
        [NSApp endSheet:twitterViewPanel];
    }
    [twitterAuthorizationButton setEnabled:YES];
    
}
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([tabViewItem.identifier isEqualToString:@"1"]) {
        // twitter start
    }
    if ([tabViewItem.identifier isEqualToString:@"2"]) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
//            if (!linkedinController) { 
//                linkedinController = [[LinkedinUpdateDataController alloc] init];
//                linkedinController.delegate = self;
//            }
//            
//            [linkedinController startAuthorization:self];
//        NSMutableArray *finalGroupsList = [[NSUserDefaults standardUserDefaults] valueForKey:@"allGroupList"];
//        [groupsListController setContent:finalGroupsList];
            
        //});
    }
    if ([tabViewItem.identifier isEqualToString:@"3"]) {
//        NSNumber *includeRates = [[NSUserDefaults standardUserDefaults] valueForKey:@"includeRates"];
//        messageIncludePriceValue = includeRates;
//        NSNumber *priceCorrection = [[NSUserDefaults standardUserDefaults] valueForKey:@"priceCorrection"];
//        messagePriceCorrectionPercent = priceCorrection;
//        NSString *postingTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"postingTitle"];
//        NSString *bodyForEdit = [[NSUserDefaults standardUserDefaults] valueForKey:@"bodyForEdit"];
//        NSString *signature = [[NSUserDefaults standardUserDefaults] valueForKey:@"signature"];
//        messageTitle.stringValue = postingTitle;
//        messageBody.stringValue = bodyForEdit;
//        messageSignature.stringValue = signature;
//        

    }

    
}
-(NSMutableString *)stringFromObjectIDs:(NSArray *)objecIDs includeRates:(BOOL) isIncludeRates;
{
    NSManagedObjectContext *context = delegate.managedObjectContext;
    //NSMutableString *finalString = [NSMutableString string];
    NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init];
    [rateFormatter setMaximumFractionDigits:5];
    [rateFormatter setMinimumIntegerDigits:1];

    //[rateFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *priceCorrection = [[NSUserDefaults standardUserDefaults] valueForKey:@"priceCorrection"];
    NSMutableString *finalString = [NSMutableString string];

    [objecIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
        //DestinationsListPushList *object = (DestinationsListPushList *)[context objectWithID:objectID];
        NSManagedObject *object = [context objectWithID:objectID];
        NSString *country = [object valueForKey:@"country"];
        NSString *specific = [object valueForKey:@"specific"];
        NSNumber *rateNumber = [object valueForKey:@"rate"];
        NSNumber *rateNew = [NSNumber numberWithDouble:rateNumber.doubleValue * (1 + priceCorrection.doubleValue / 100)];
        [rateFormatter setMaximumFractionDigits:5];
        [rateFormatter setMinimumIntegerDigits:1];

        NSString *rate = [rateFormatter stringFromNumber:rateNew];
        [rateFormatter setMaximumFractionDigits:0];
        
        NSString *minutesLenght = nil;
        if ([object.entity.name isEqualToString:@"DestinationsListPushList"]) {
            minutesLenght = [rateFormatter stringFromNumber:[object valueForKey:@"minutesLenght"]];
        } else {
            minutesLenght = [rateFormatter stringFromNumber:[object valueForKey:@"lastUsedMinutesLenght"]];
        }
        [finalString appendString:[NSString stringWithFormat:@"%@/%@",country,specific]];
        if (isIncludeRates) [finalString appendString:[NSString stringWithFormat:@" with price $%@",rate]];
        if (minutesLenght && minutesLenght.doubleValue > 0) [finalString appendString:[NSString stringWithFormat:@" and volume %@",minutesLenght]];
        if (objecIDs.count > 1 && idx != objecIDs.count -1) [finalString appendString:@"\n"]; 
    }];
    
    return finalString;
}


#pragma mark - twitter block functions



-(void)startTwitterAuthForURL:(NSURL *)url
{
    [[twitterWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];

}
- (IBAction)twitterAuthorizeFinal:(id)sender {
    twitterController.twitterPIN = [pin stringValue];
    
//    if (twitterViewPopover) [twitterViewPopover close];
//
//    if (twitterViewPanel) {
//        [twitterViewPanel orderOut:sender];
//        [NSApp endSheet:twitterViewPanel];
//    }
    [twitterController finishAuthorization:self];
    
    //[self getAccessToken:sender];
    
}

-(void)twitterAuthSuccess;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //NSLog(@"twitterAuthSuccess");
        twitterEnabled.image = [NSImage imageNamed:@"enabledPoint.png"];
        [twitterWebView setHidden:YES];
        [[delegate.destinationsView.twitIt layer] setOpacity:1.0];
        [delegate.destinationsView.twitIt setEnabled:YES];

    });
}

-(void) sendTwitterUpdate:(NSArray *)managedObjectIDs;
{
    //    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    //    NSManagedObjectContext *moc = delegate.managedObjectContext;
    
    [managedObjectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
        NSMutableString *finalDestinationsListString = [self stringFromObjectIDs:[NSArray arrayWithObject:objectID] includeRates:YES];
        NSMutableString *twitterText = [[NSMutableString alloc] initWithCapacity:0];
        [twitterText appendString:@"I'm currently interesting for those destination:"];
        [twitterText appendString:@"\n"];
        
        [twitterText appendString:finalDestinationsListString];
        [twitterText appendString:@"\n"];
        
        [twitterText appendString:@"(posted from snow ixc)"];
        if (twitterText.length > 139) [twitterText replaceCharactersInRange:NSMakeRange(139,twitterText.length - 139) withString:@""];
        NSLog(@"SOCIAL NETWORK CONTROLLER: twitter message to post:%@",twitterText);
        
        if (twitterController) [twitterController postTwitterMessageWithText:twitterText];
        [twitterText release];
        
    }];
    
    //    if (twitterController) [twitterController postTwitterMessageWithText:text];
}

#pragma mark - Linkedin controller delegates

-(void)linkedinAuthSuccess;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //NSLog(@"twitterAuthSuccess");
        linkedinEnabled.image = [NSImage imageNamed:@"enabledPoint.png"];
        [networksUpdateProgress setHidden:YES];
        [networksUpdateProgress stopAnimation:self];
        [linkedinWebView setHidden:YES];
        ////[[delegate.destinationsView.linkedinIn layer] setOpacity:1.0];
        [delegate.destinationsView.linkedinIn setEnabled:YES];
    });
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLinedinGroupsUpdatingTime"];
    if (lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] > 86400)  [linkedinController getGroupsStart:0 count:10];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"lastLinedinGroupsUpdatingTime"];
    NSMutableArray *finalGroupsList = [[NSUserDefaults standardUserDefaults] valueForKey:@"allGroupList"];
    [groupsListController setContent:finalGroupsList];
}

-(void)linkedinAuthFailed;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [self showErrorBoxWithText:@"linkedin authorization failed"];
    });
}

-(void)linkedinAuthForURL:(NSURL *)url;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        NSLog(@"LINKEDIN START URL:%@",url);
        
        [[linkedinWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];

    });
    
}

-(void)linkedinGroupsList:(NSDictionary *)parsedGroups withLatestGroups:(NSNumber *)isLatestGroup;
{
    NSLog(@"CARRIER VIEW: isLatestGroup:%@ ",isLatestGroup);

    //[self.groupListObjects removeAllObjects];
    NSMutableArray *finalGroupsList = [[NSUserDefaults standardUserDefaults] valueForKey:@"allGroupList"];
    //    
    //NSMutableArray *finalGroupsList = 
    NSArray *groupsListParsed = [parsedGroups valueForKey:@"values"];
    [groupsListParsed enumerateObjectsUsingBlock:^(NSDictionary *group, NSUInteger idx, BOOL *stop) {
        NSDictionary *groupInfo = [group valueForKey:@"group"];
        NSMutableDictionary *groupInfoMutable = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
        [groupInfoMutable setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
        
        NSNumber *idNumber = [groupInfo valueForKey:@"id"];
        //NSString *name = [groupInfo valueForKey:@"name"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@",idNumber];
        NSArray *filteredFinalGroupList = [finalGroupsList filteredArrayUsingPredicate:predicate];
        if (filteredFinalGroupList.count > 0) [groupInfoMutable setValue:[filteredFinalGroupList.lastObject valueForKey:@"enabled"] forKey:@"enabled"]; 
        else [groupInfoMutable setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
        [groupListObjectsForCollectAllGroups addObject:groupInfoMutable];
        //NSLog(@"SOCIAL NETWORKS AUTH: ADD NEW group name:%@ id:%@",idNumber,name);
        
    }];
    //    [[NSUserDefaults standardUserDefaults] setValue:self.groupListObjects forKey:@"allGroupList"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (isLatestGroup.boolValue == YES) {
        // ok buffer is done now, time to check 
        [groupListObjects removeAllObjects];
        [groupListObjects addObjectsFromArray:groupListObjectsForCollectAllGroups];
        
        [[NSUserDefaults standardUserDefaults] setValue:groupListObjects forKey:@"allGroupList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [groupsListController setContent:groupListObjects];
        [networksUpdateProgress setHidden:YES];
        [linkedinGroups reloadData];
    } else [groupListObjectsForCollectAllGroups setValuesForKeysWithDictionary:parsedGroups];
}

-(BOOL)isLinkedinAuthorized;
{
    if (linkedinController) return linkedinController.isAuthorized;
    else return NO;
}
-(void) postToLinkedinGroups:(NSArray *)managedObjectIDs;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"enabled = %@",[NSNumber numberWithBool:YES]];
    NSArray *enabledGroups = [groupsListController.arrangedObjects filteredArrayUsingPredicate:predicate];
    NSString *postingTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"postingTitle"];
    NSNumber *includeRates = [[NSUserDefaults standardUserDefaults] valueForKey:@"includeRates"];
    NSString *bodyForEdit = [[NSUserDefaults standardUserDefaults] valueForKey:@"bodyForEdit"];
    NSString *signature = [[NSUserDefaults standardUserDefaults] valueForKey:@"signature"];
    
    [enabledGroups enumerateObjectsUsingBlock:^(NSMutableDictionary *group, NSUInteger idx, BOOL *stop) {
        NSString *groupID = [group valueForKey:@"id"];
        NSString *name = [group valueForKey:@"name"];
        
        NSMutableString *linkedinText = [[NSMutableString alloc] initWithCapacity:0];
        [linkedinText appendString:bodyForEdit];
        [linkedinText appendString:@"\n"];
        NSMutableString *finalDestinationsListString = [self stringFromObjectIDs:managedObjectIDs includeRates:includeRates.boolValue];
        [linkedinText appendString:finalDestinationsListString];
        [linkedinText appendString:@"\n"];
        [linkedinText appendString:@"\n"];
        
        [linkedinText appendString:signature];
        [linkedinText appendString:@"\n"];
        
        [linkedinText appendString:@"(posted from snow ixc)"];
        
        NSLog(@"SOCIAL NETWORK CONTROLLER: linkedin message for group:%@ to post:%@",linkedinText,name);
        
        if (linkedinController.isAuthorized) [linkedinController postToGroupID:groupID withTitle:postingTitle withSummary:linkedinText];  
        [linkedinText release];
    }];
}

- (IBAction)routesListIncludePriceChanged:(id)sender {
    NSNumber *includeRates = [[NSUserDefaults standardUserDefaults] valueForKey:@"includeRates"];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:!includeRates.boolValue] forKey:@"includeRates"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)priceCorrectionChange:(id)sender {
    NSStepper *senderStep = sender;
    NSNumber *newValue = [NSNumber numberWithDouble:senderStep.doubleValue];
    [[NSUserDefaults standardUserDefaults] setValue:newValue forKey:@"priceCorrection"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    messagePriceCorrectionPercentTitle.stringValue = [NSString stringWithFormat:@"Percent correction:%@%%",newValue];
}

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    [[NSUserDefaults standardUserDefaults] setValue:messageBody.stringValue forKey:@"bodyForEdit"];
    [[NSUserDefaults standardUserDefaults] setValue:messageSignature.stringValue forKey:@"signature"];
    [[NSUserDefaults standardUserDefaults] setValue:messageTitle.stringValue forKey:@"postingTitle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
    
}

//- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
//{
//    NSMutableDictionary *row = [groupsListController.arrangedObjects objectAtIndex:rowIndex];
//    NSNumber *enabled = [row valueForKey:@"enabled"];
//    [row setValue:[NSNumber numberWithBool:!enabled.boolValue] forKey:@"enabled"];
//    [[NSUserDefaults standardUserDefaults] setValue:groupsListController.arrangedObjects forKey:@"allGroupList"];
//
//}
#pragma mark - info block functions

- (IBAction)closeInforBlock:(id)sender {
    if (infoViewPopover) [infoViewPopover close];
    
    if (infoViewPanel) { 
        [infoViewPanel orderOut:sender];
        [NSApp endSheet:infoViewPanel];
    }
    for (id verticalViewObject in [infoContacts arrangedObjects]) [verticalViewObject removeObserver:self forKeyPath:@"data"]; 
    for (id verticalViewObject in [infoResponsible arrangedObjects]) [verticalViewObject removeObserver:self forKeyPath:@"data"]; 
    for (id verticalViewObject in [infoDetails arrangedObjects]) [verticalViewObject removeObserver:self forKeyPath:@"data"]; 
    for (id verticalViewObject in [infoFinansialDetails arrangedObjects]) [verticalViewObject removeObserver:self forKeyPath:@"data"]; 
    for (id verticalViewObject in [infoCompanyDetails arrangedObjects]) [verticalViewObject removeObserver:self forKeyPath:@"data"]; 
    [infoCarrierButton setEnabled:YES];
    [self finalSaveForMoc:moc];
    //sleep(3);
#if defined(SNOW_CLIENT_APPSTORE)   
    [allUpdatedObjectIDs enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSManagedObjectID *updatedObjectID, NSUInteger idx, BOOL *stop) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:updatedObjectID] mustBeApproved:NO];
            [clientController release];
        });
        
    }];
#endif

}
- (IBAction)changeCarrierContact:(id)sender {
    
    NSManagedObjectID * selectedContact =[allCarrierContactIDs objectAtIndex:contactsChoice.indexOfSelectedItem ];
    for (id verticalViewObject in [infoContacts arrangedObjects]) [verticalViewObject removeObserver:self forKeyPath:@"data"]; 
    CarrierStuff *selectedCarrierContact = (CarrierStuff *)[self.moc objectWithID:selectedContact];
    
    infoContacts.content = [self transformContentFromHorizontalToVerticalDataForBinding:selectedCarrierContact];

}

- (IBAction)changeResponsibeForCarrier:(id)sender {
    NSManagedObjectID * selectedContact =[allCarrierCompanyStufffIDs objectAtIndex:responsibleChoice.indexOfSelectedItem ];
    for (id verticalViewObject in [infoResponsible arrangedObjects]) [verticalViewObject removeObserver:self forKeyPath:@"data"]; 
    CompanyStuff *selectedResponsible = (CompanyStuff *)[self.moc objectWithID:selectedContact];
    
    infoResponsible.content = [self transformContentFromHorizontalToVerticalDataForBinding:selectedResponsible];
    
    Carrier *selectedCarrier = carrier.selectedObjects.lastObject;
    selectedCarrier.companyStuff = selectedResponsible;
    [self finalSaveForMoc:carrier.managedObjectContext];
#if defined(SNOW_SERVER)
#else 
    // only clients mys update outside something
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        CompanyStuff *admin = [clientController authorization];
        // only admin can change responsible
        if ([admin.GUID isEqualToString:selectedCarrier.companyStuff.currentCompany.companyAdminGUID]) 
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[selectedCarrier objectID]] mustBeApproved:NO];
        [clientController release];
    });
    
#endif

}
- (IBAction)changeFinancial:(id)sender {
    NSManagedObjectID * selectedFinancial =[allCarrierFinancialIDs objectAtIndex:financialChoice.indexOfSelectedItem ];
    for (id verticalViewObject in [infoFinansialDetails arrangedObjects]) [verticalViewObject removeObserver:self forKeyPath:@"data"]; 
    Financial *selectedCarrierFinancial = (Financial *)[self.moc objectWithID:selectedFinancial];
    
    infoFinansialDetails.content = [self transformContentFromHorizontalToVerticalDataForBinding:selectedCarrierFinancial];

}

- (IBAction)statisticChangePeriod:(id)sender {
    NSDate *dateFromTodayToCheck = nil;
    NSInteger selectedIndex = [statisticChoicePeriod indexOfSelectedItem];
    if (selectedIndex == 0) dateFromTodayToCheck = [NSDate dateWithTimeIntervalSinceNow:-86400];
    if (selectedIndex == 1) dateFromTodayToCheck = [NSDate dateWithTimeIntervalSinceNow:-604800];
    if (selectedIndex == 2) dateFromTodayToCheck = [NSDate dateWithTimeIntervalSinceNow:-2419200];
    [self doUpdatesUIwithDateFrom:dateFromTodayToCheck withDateTo:[NSDate date]];

}

- (IBAction)statisticChangeDateFrom:(id)sender {
    NSDate *selectedDate = [statisticChoiceDateFrom dateValue];
    NSDate *datePlus24h = [selectedDate dateByAddingTimeInterval:86400];
    [self doUpdatesUIwithDateFrom:selectedDate withDateTo:datePlus24h];

}
#pragma mark - global info block functions
- (IBAction)introductionShow:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [introductionButton setEnabled:NO];
        NSNumber *showAgain = [[NSUserDefaults standardUserDefaults] valueForKey:@"showAgain"];
        self.introductionShowAgain = showAgain;
        //NSLog(@"%@",showAgain);
        
        NSRect frameOfSender = [sender frame]; 
        if (!introductionPopover) introductionPopover = [[NSPopover alloc] init];
        [introductionInfo setBackgroundColor:[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1]];
        [introductionText setBackgroundColor:[NSColor colorWithDeviceRed:0.52 green:0.54 blue:0.70 alpha:1]];
        [introductionText setEditable:NO];
        [introductionText changeColor:[NSColor whiteColor]];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Introduction" ofType:@"rtfd" ];
        [introductionText readRTFDFromFile:path];
        
        if (introductionPopover) {
            introductionPopover.contentViewController = introductionViewController;
            introductionPopover.behavior = NSPopoverBehaviorApplicationDefined;
            [introductionPopover showRelativeToRect:frameOfSender ofView:self.view preferredEdge:NSMaxYEdge];
        } else
        {
            introductionPanel = [[[NSPanel alloc] initWithContentRect:introductionViewController.view.frame styleMask:NSHUDWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
            [introductionPanel.contentView addSubview:introductionViewController.view];
            [introductionPanel makeFirstResponder:introductionViewController];
            
            [NSApp beginSheet:introductionPanel 
               modalForWindow:delegate.window
                modalDelegate:nil 
               didEndSelector:nil
                  contextInfo:nil];
            
        }
    });

    
}
- (IBAction)introductionClose:(id)sender {
    if (introductionPopover) [introductionPopover close];
    
    if (introductionPanel) {
        [introductionPanel orderOut:sender];
        [NSApp endSheet:introductionPanel];
    }
    [introductionButton setEnabled:YES];

    [[NSUserDefaults standardUserDefaults] setValue:self.introductionShowAgain forKey:@"showAgain"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) introductionShowFromOutsideView;
{
    NSNumber *showAgain = [[NSUserDefaults standardUserDefaults] valueForKey:@"showAgain"];
    if (!showAgain || [showAgain boolValue] == NO) {
        [self introductionShow:introductionButton];
    } //else NSLog(@"CARRIER VIEW - sorry we don't have to show intro");
}


#pragma mark - NSTableViewDelegate
// main carrier table - tag = 0
// info block - from 10 to 14
// financial block - from 20 to ..

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    if (aTableView.tag == 0) {
    if (delegate.isSearchProcessing == YES) return NO; 
    else {
        [globalSearchProgress setHidden:NO];
        [globalSearchProgress startAnimation:self];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            Carrier *selectedCarrier = [carrier.arrangedObjects objectAtIndex:rowIndex];

            //@synchronized (self) {
                
                delegate.isSearchProcessing = YES;

                [delegate.destinationsView.destinationsListWeBuy setFilterPredicate:[NSPredicate predicateWithFormat:@"carrier.GUID == %@",selectedCarrier.GUID]];
                [delegate.destinationsView.destinationsListForSale setFilterPredicate:[NSPredicate predicateWithFormat:@"carrier.GUID == %@",selectedCarrier.GUID]];
                [delegate.destinationsView.destinationsListTargets setFilterPredicate:[NSPredicate predicateWithFormat:@"carrier.GUID == %@",selectedCarrier.GUID]];
                [delegate.destinationsView.destinationsListPushList setFilterPredicate:[NSPredicate predicateWithFormat:@"carrier.GUID == %@",selectedCarrier.GUID]];

                delegate.isSearchProcessing = NO;
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [globalSearchProgress setHidden:YES];
                [globalSearchProgress stopAnimation:self];

            });
            //}
#if defined(SNOW_CLIENT_ENTERPRISE)
            
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"dd MMM"];
            //[formatter setLocale:[NSLocale currentLocale]];
            //[formatter setDoesRelativeDateFormatting:YES];
            if ([[delegate.destinationsView.destinationsListForSale arrangedObjects] count] != 0) {
                NSNumber *profitNumber = [[delegate.destinationsView.destinationsListForSale arrangedObjects] valueForKeyPath:@"@sum.lastUsedProfit"];
                NSNumberFormatter *profitFormatter = [[[NSNumberFormatter alloc] init] autorelease];
                [profitFormatter setMinimumFractionDigits:2];
                
                [profit setTitle:[profitFormatter stringFromNumber:profitNumber]];
                //[carrier setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
            }
//            [formatter release];
            
#endif
#if  defined(SNOW_CLIENT_APPSTORE) || defined(SNOW_CLIENT_ENTERPRISE)
//            NSRect currentFrame = [status frame];
            
//            if (updateInfoInitialFrame.origin.x == 0) updateInfoInitialFrame = currentFrame;
//            [statusInfo setFrame:NSMakeRect(updateInfoInitialFrame.origin.x - 130, updateInfoInitialFrame.origin.y, updateInfoInitialFrame.size.width + 130, updateInfoInitialFrame.size.height)];
            
            NSString *statusForCarrier = [self localStatusForObjectsWithRootGuid:selectedCarrier.GUID];
            [status setTitle:statusForCarrier];
            
            
#endif

        });
    }
    } 
    
    if (aTableView.tag == 1) {
        NSArray *allGroups = groupsListController.arrangedObjects;
        
        NSMutableDictionary *row = [allGroups objectAtIndex:rowIndex];
        NSNumber *enabled = [row valueForKey:@"enabled"];
        [row setValue:[NSNumber numberWithBool:!enabled.boolValue] forKey:@"enabled"];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id != %@",[row valueForKey:@"id"]];
//        NSArray *filteredAllGroups = [allGroups filteredArrayUsingPredicate:predicate];
//        NSMutableArray *finalGroups = [NSMutableArray arrayWithArray:filteredAllGroups];
//        [finalGroups addObject:row];
//        [groupsListController setContent:finalGroups];
        [[NSUserDefaults standardUserDefaults] setValue:groupsListController.arrangedObjects forKey:@"allGroupList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    // carriers table
    if (aTableView.tag == 0) {
#if defined(SNOW_CLIENT_APPSTORE) 
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        
        CompanyStuff *admin = [clientController authorization];
        [clientController release];
        Carrier *selectedCarrier = [carrier.arrangedObjects objectAtIndex:rowIndex];

        if ([selectedCarrier.companyStuff.GUID isEqualToString:admin.GUID] || [selectedCarrier.companyStuff.currentCompany.companyAdminGUID isEqualToString:admin.GUID]) {
            [selectedCarrier addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL]; 

            // do all
            
        } else return NO;
#endif

        
    }
    // info block
    if (aTableView.tag == 10 || aTableView.tag == 11 || aTableView.tag == 12 || aTableView.tag == 13 || aTableView.tag == 14) {
        id editedObject = nil;
#if defined(SNOW_CLIENT_APPSTORE) 
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        
        CompanyStuff *admin = [clientController authorization];
        [clientController release];
        Carrier *selectedCarrier = [carrier.arrangedObjects objectAtIndex:rowIndex];
        if ([selectedCarrier.companyStuff.GUID isEqualToString:admin.GUID] || [selectedCarrier.companyStuff.currentCompany.companyAdminGUID isEqualToString:admin.GUID]) {
            // do all
        } else return NO;
#endif

        
        if (aTableView.tag == 10)  editedObject = [[infoContacts arrangedObjects] objectAtIndex:rowIndex];
        if (aTableView.tag == 11)  editedObject = [[infoResponsible arrangedObjects] objectAtIndex:rowIndex];
        if (aTableView.tag == 12)  editedObject = [[infoDetails arrangedObjects] objectAtIndex:rowIndex];
        if (aTableView.tag == 13)  editedObject = [[infoFinansialDetails arrangedObjects] objectAtIndex:rowIndex];
        if (aTableView.tag == 14)  editedObject = [[infoCompanyDetails arrangedObjects] objectAtIndex:rowIndex];
        if ([[editedObject valueForKey:@"attribute"] isEqualToString:@"creationDate"]) return NO;
        if ([[editedObject valueForKey:@"attribute"] isEqualToString:@"modificationDate"]) return NO;
        if ([[editedObject valueForKey:@"attribute"] isEqualToString:@"financialRate"]) return NO;
        if ([[editedObject valueForKey:@"attribute"] isEqualToString:@"latestUpdateTime"]) return NO;
        if ([[editedObject valueForKey:@"attribute"] isEqualToString:@"isCompanyAdmin"]) return NO;
        if ([[editedObject valueForKey:@"attribute"] isEqualToString:@"isRegistrationDone"]) return NO;
        if ([[editedObject valueForKey:@"attribute"] isEqualToString:@"isRegistrationProcessed"]) return NO;
        if ([[editedObject valueForKey:@"attribute"] isEqualToString:@"companyAdminGUID"]) return NO;

    }
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id )info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
    // Add code here to validate the drop
    
    return NSDragOperationEvery;
}
//- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes         toPasteboard:(NSPasteboard*)pboard
//{
//    return YES;
//}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id )info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    if ([delegate.loggingLevel intValue] == 1) NSLog(@"DRAG:properties:%@ class:%@",files,NSStringFromClass([[files lastObject] class]));
    NSString *gragged = [files lastObject];
    
    //[self.draggedURL setString:gragged];
    
    //    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    if ([carrier.arrangedObjects count] <= row) return NO;
    [carrier setSelectionIndex:row];
    delegate.importRatesView.parsedFileURL = [NSURL URLWithString:gragged];
    delegate.importRatesView.dragToCarrier = [[carrier.arrangedObjects objectAtIndex:row] objectID];
    [delegate.importRatesView loadView];
    
    importRatesPanel = [[[NSPopover alloc] init] autorelease];
    //                NSRect frameOfTestingCell = [sender frame]; 
    NSRect frameOfSender = [aTableView frameOfCellAtColumn:0 row:row]; 
    
    if (importRatesPanel) {
        importRatesPanel.contentViewController = delegate.importRatesView;
        importRatesPanel.behavior = NSPopoverBehaviorApplicationDefined;
        [importRatesPanel showRelativeToRect:frameOfSender ofView:aTableView preferredEdge:NSMaxYEdge];
    } else
    {
        importRatesMainPanel = [[[NSPanel alloc] initWithContentRect:delegate.importRatesView.view.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
        [importRatesMainPanel.contentView addSubview:delegate.importRatesView.view];
        [NSApp beginSheet:importRatesMainPanel 
           modalForWindow:delegate.window
            modalDelegate:nil 
           didEndSelector:nil
              contextInfo:nil];
    }
    
    return YES;
}



#pragma mark - client controller delegate
-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    //    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    //    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    NSString *statusUpdate = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {  
        [self showErrorBoxWithText:statusUpdate];
        //NSLog(@"error:%@",status);
    }
    
    if ([isItLatestMessage boolValue]) {
        // need to get all objects, for update registrations
        [delegate.userCompanyInfo refreshUsersAvaitingApproveList:nil];

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //NSLog(@"CARRIER: >>>>>>>ENABLE");
            [removeCarrier setEnabled:YES];
//            CompanyStuff *currentStuff = (CompanyStuff *)selectedCarrier.companyStuff;
//            if ([currentStuff.GUID isEqualToString:currentStuff.currentCompany.companyAdminGUID]) [responsibleList setEnabled:YES];
//            
        });
        
    }
    
    NSManagedObjectID *objectID = nil;
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    if (objectID) {
        //if ([idsWithProgress containsObject:objectID] && ![isItLatestMessage boolValue]) return;
        //[idsWithProgress addObject:objectID];
        delegate.destinationsView.currentObservedDestination = nil;
        //[delegate.destinationsView localMocMustUpdate];
        [self localMocMustUpdate];
        NSManagedObject *object = [self.moc objectWithID:objectID];
        //NSLog(@"CARRIER:update object entity:%@",object.entity.name);

        if (object) {
            if ([[[object entity] name] isEqualToString:@"Carrier"]) {
                if ([statusUpdate isEqualToString:@"remove object finish"] || [statusUpdate isEqualToString:@"carrier for removing not found"]) { 
                    NSLog(@"CARRIER:remove object entity:%@",[object valueForKey:@"name"]);
                    //dispatch_async(dispatch_get_main_queue(), ^(void) {

                    [self.moc deleteObject:[self.moc objectWithID:objectID]];
                    //[carrier removeObject:object];
                    [self finalSaveForMoc:self.moc];
                    //[carrier removeObject:object];
                    //[self.carriersTableView reloadData]; 
                    //});
                    //[self sortCarrierForCurrentUserAndUpdate];
                }
                
            }
        }
        
        
    }
    //NSLog(@"CARRIER:update UI:%@ latest message:%@",statusUpdate,isItLatestMessage);
    
}


@end
