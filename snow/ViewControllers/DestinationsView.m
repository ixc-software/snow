//
//  DestinationsView.m
//  snow
//
//  Created by Oleksii Vynogradov on 04.01.12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//
//#import <AVFoundation/AVFoundation.h>

#import "DestinationsView.h"
#import "AVResizedTableHeaderView.h"
#import "AVTableHeaderView.h"
#import "AVGradientBackgroundView.h"

#import "desctopAppDelegate.h"
#import "ClientController.h"
//#import "ProjectArrays.h"
#import "ParseCSV.h"

#import "Carrier.h"
#import "DestinationsListForSale.h"
#import "DestinationsListWeBuy.h"
#import "DestinationsListTargets.h"
#import "DestinationsListPushList.h"
#import "DestinationsListWeBuyTesting.h"
#import "CompanyStuff.h"
#import "CurrentCompany.h"
#import "CodesvsDestinationsList.h"
#import "CountrySpecificCodeList.h"
#import "CodesList.h"

#import "MySQLIXC.h"
#import "UpdateDataController.h"

@interface DestinationsView()

@property (readwrite) BOOL isAddDestinationsPanelShort;
@property (readwrite) BOOL isAddDestinationsAddNewOutPeerToGroupList;

@end


@implementation DestinationsView
@synthesize addDestinationsChangeOutPeerController;
@synthesize addDestinationsWeBuyForChangeOutPeers;
@synthesize addDestinationsChangeOutPeerView;
@synthesize addDestinationsChangeOutPeerTableView;
@synthesize addDestinationsAddNewPeerToOutGroupList;
@synthesize addDestinationsBox;
@synthesize delegate,moc,s;
//@synthesize importRatesView;
//@synthesize importRatesColumnSelectPanel;
//@synthesize importRatesViewController;
//@synthesize importRatesColumnSelectViewController;
//@synthesize importRatesImportedRoutes;
//@synthesize importRatesParsedRows;
//@synthesize importRatesParsedCodes;
//@synthesize importRatesCarrierList;
//@synthesize importRatesCarriersRateSheet;
//@synthesize importRatesEffectiveDate;
//@synthesize importRatesSelectionList;
//@synthesize importRatesRelationshipName;
//@synthesize importRatesStartParsing;
//@synthesize importRatesRatesheetList;
//@synthesize importRatesProgress;
//@synthesize importRatesPrefix;
//@synthesize importRatesFirsParserResult;
//@synthesize importRatesCodesTableView;
//@synthesize importRatesSecondParserResult;
//@synthesize importRatesDestinationChoice;
//@synthesize importRatesApply;
@synthesize importRatesPanel;
//@synthesize importRatesCarrierName;
//@synthesize importRatesSelectedCountryForParsing;
@synthesize addDestinationsView;
@synthesize addDestinationsMainPanel;
@synthesize addDestinationsRoutesListTableView;
@synthesize addDestinationsGroupsView;
@synthesize addDestinationsCarriersAndRatesheetsView;
@synthesize addDestinationsRateSheetsView;
@synthesize addDestinationsStartButton;
@synthesize addDestinationsList;
@synthesize addDestinationsListTableView;
@synthesize addDestinationsOutGroupTableView;
@synthesize addDestinationsOutGroupDestinationsTableView;
@synthesize addDestinationsCarriersListTableView;
@synthesize addDestinationsCarriersRateSheetsTableView;
@synthesize addDestinationCarriersList;
@synthesize addDestinationsStepper;
@synthesize addDestinationsPercent;
@synthesize addDestinationsOutGroups;
@synthesize addDestinationsOutGroupsOutPeerList;
@synthesize addDestinationsProgress;
@synthesize addDestinationsChangeOutPeer;
@synthesize errorPanel;
@synthesize errorText;
@synthesize testingResults;
@synthesize testingResultsController;
@synthesize testingResultInfo1;
@synthesize testingResultInfo2;
@synthesize testingResultInfo3;
@synthesize testingResultInfo4;
@synthesize testingResultInfo5;
@synthesize testingResultIPlay1;
@synthesize testingResultIPlay2;
@synthesize testingResultIPlay3;
@synthesize testingResultIPlay4;
@synthesize testingResultIPlay5;
@synthesize testingResultShortInfo;
@synthesize pushListInfo;
@synthesize pushListProgress;
@synthesize pushListTableView;
@synthesize pushListCodesTableView;
@synthesize pushListRemoveDestinations;
@synthesize addDestinationsPushlistButton;
@synthesize twitIt;
@synthesize linkedinIn;
@synthesize targetsInfo;
@synthesize targetsProgress;
@synthesize targetsTableView;
@synthesize targetsCodesTableView;
@synthesize targetsRoutingTableView;
@synthesize routingPushList;
@synthesize routingChangedDate;
@synthesize routingEnabled;
@synthesize routingPrefix;
@synthesize routingRateSheet;
@synthesize routingProgress;
@synthesize addDestinationsTargetsBlock;
@synthesize addDestinationsTargetsNew;
@synthesize weBuyTableView;
@synthesize weBuyCodesTableView;
@synthesize weBuyPerHourStatisticTableView;
@synthesize weBuyTestingTableView;
@synthesize weBuyTestingResultsTableView;
@synthesize weBuyPushlist;
@synthesize weBuyChangedDate;
@synthesize weBuyEnabled;
@synthesize weBuyPrefix;
@synthesize weBuyRatesheet;
@synthesize weBuyProgress;
@synthesize weBuyCodesRatesheet;
@synthesize weBuyCodesRateSheetID;
@synthesize weBuyCodesPeerID;
@synthesize addDestinationsWeBuyButton;
@synthesize importRatesProgress;
@synthesize importRatesLabelFirs;
@synthesize importRatesLabelSecond;
@synthesize importRatesButton;

@synthesize destinationsListForSale,destinationsListWeBuy,destinationsListTargets,destinationsListPushList;
@synthesize codesvsDestinationsList;
@synthesize destinationPerHourStat;
@synthesize destinationsListWeBuyForTargets;
@synthesize destinationsListWeBuyResults;
@synthesize destinationsListWeBuyTesting;
@synthesize mainBox;
@synthesize destinationsTab;
@synthesize forSaleTableView;
@synthesize forSaleCodesTableView;
@synthesize forSaleStatisticTableView;
@synthesize ivr;
@synthesize puslist;
@synthesize changedDate;
@synthesize enabled;
@synthesize prefix;
@synthesize rateSheetList;
@synthesize codesRatesheet;
@synthesize codesRateSheetID;
@synthesize codesPeerID;
@synthesize destinationsForSaleProgress;
@synthesize callPathWebView;
@synthesize destinationsForSaleCodesStatisticRoutingBlock;
@synthesize addDestinationsButton;
@synthesize addDestinationsPanel;
@synthesize addRoutesViewController;
@synthesize isAddDestinationsPanelShort;
@synthesize isAddDestinationsAddNewOutPeerToGroupList;
@synthesize currentObservedDestination;
@synthesize importRatesMainPanel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];

    }
    
    return self;
}

#pragma mark -
#pragma mark CORE DATA methods


- (void)importerDidSave:(NSNotification *)saveNotification {
    //NSLog(@"MERGE in destinations view controller");
    
    if ([NSThread isMainThread]) {
        
        [[delegate managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
    } else {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
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
            NSLog(@"DESTINATIONS VIEW:Failed to save to data store: %@", [error localizedDescription]);
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
    
//    NSLog(@"DESTINATIONS VIEW:local moc will update");
//    
//    [self finalSaveForMoc:moc];
////    @synchronized (self) {
//#if defined (SNOW_CLIENT_ENTERPRISE)
//    NSUInteger selectedIndex = destinationsListWeBuy.selectionIndex;
////        NSManagedObject *selectedObject = [[destinationsListWeBuy selectedObjects] lastObject];
////        NSManagedObjectID *selectedDestinationsID = selectedObject.objectID;
//        //    NSArray *allObjects = [destinationsListWeBuy arrangedObjects];
//        //    NSInteger selectionsIndex = [allObjects indexOfObject:[moc objectWithID:selectedDestinationsID]];
//        //    [destinationsListWeBuy setSelectionIndex:selectionsIndex];
//        
//        //    [destinationsListTargets bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        //    [destinationsListWeBuy bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        //    [destinationsListWeBuyForTargets bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        //    
//        //    [destinationPerHourStat bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        //    [destinationsListWeBuyResults bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        //    [destinationsListWeBuyTesting bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//#endif
////        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//
//        //    NSManagedObject *selectedObject = [[destinationsListPushList selectedObjects] lastObject];
//        //    NSManagedObjectID *selectedDestinationsID = selectedObject.objectID;
//        //    NSArray *allObjects = [destinationsListPushList arrangedObjects];
//        //    NSInteger selectionsIndex = [allObjects indexOfObject:[moc objectWithID:selectedDestinationsID]];
//        //    [destinationsListPushList setSelectionIndex:selectionsIndex];
//        
//        //    [codesvsDestinationsList bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        if (currentObservedDestination) {
//            DestinationsListPushList *previousSelected = (DestinationsListPushList *)[moc objectWithID:currentObservedDestination];
//            [previousSelected removeObserver:self forKeyPath:@"rate"];
//            [previousSelected removeObserver:self forKeyPath:@"asr"];
//            [previousSelected removeObserver:self forKeyPath:@"acd"];
//            [previousSelected removeObserver:self forKeyPath:@"minutesLenght"];
//            
//        }
//        //dispatch_async(dispatch_get_main_queue(), ^(void) {
//            
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
//            
//            [moc release];
//            
//            moc = [[NSManagedObjectContext alloc] init];
//            [moc setUndoManager:nil];
//            [moc setMergePolicy:NSOverwriteMergePolicy];
//            [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
//            
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
//            
//            
//#if defined (SNOW_CLIENT_ENTERPRISE)
//            [destinationsListForSale bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//            [destinationsListTargets bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//            [destinationsListWeBuy bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//            //NSArray *allObjects = [destinationsListWeBuy arrangedObjects];
////            if (selectedDestinationsID) {
//                //NSInteger selectionsIndex = [allObjects indexOfObject:[moc objectWithID:selectedDestinationsID]];
//                [destinationsListWeBuy setSelectionIndex:selectedIndex];
////            }
//            [destinationsListWeBuyForTargets bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//            
//            [destinationPerHourStat bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//            [destinationsListWeBuyResults bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//            [destinationsListWeBuyTesting bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//#endif
//            [destinationsListPushList bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//            [codesvsDestinationsList bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//            if (currentObservedDestination) {
//                DestinationsListPushList *selected = (DestinationsListPushList *)[moc objectWithID:currentObservedDestination];
//                [selected addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//                [selected addObserver:self forKeyPath:@"asr" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//                [selected addObserver:self forKeyPath:@"acd" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//                [selected addObserver:self forKeyPath:@"minutesLenght" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//            } 
            //        [destinationsListWeBuy setManagedObjectContext:moc];
            //        [destinationsListWeBuyForTargets setManagedObjectContext:moc];
            //        [destinationsListPushList setManagedObjectContext:moc];
            //        [codesvsDestinationsList setManagedObjectContext:moc];
            //        [destinationPerHourStat setManagedObjectContext:moc];
            //        [destinationsListWeBuyResults setManagedObjectContext:moc];
            //        [destinationsListWeBuyTesting setManagedObjectContext:moc];
//        });
//    }
}

#pragma mark - internal methods


-(id) userDefaultsObjectForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(NSString *)localStatusForObjectsWithRootGuid:(NSString *)rootObjectGUID;
{
    //NSString *objectGUID = [objects valueForKey:@"rootObjectGUID"];
    NSDictionary *objectStatus =[self userDefaultsObjectForKey:rootObjectGUID];
    NSString *status = nil;
    if (objectStatus) { 
        if ([objectStatus valueForKey:@"update"]) status = [objectStatus valueForKey:@"update"];
        if ([objectStatus valueForKey:@"new"]) status =  [objectStatus valueForKey:@"new"]; 
        if ([objectStatus valueForKey:@"login"]) status =  [objectStatus valueForKey:@"login"]; 
        
    }
    return status;
}

-(void)showErrorBoxWithText:(NSString *)error
{
    //    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    
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

- (void)awakeFromNib
{
    
#if defined(SNOW_CLIENT_APPSTORE)

    [destinationsTab removeTabViewItem:[destinationsTab tabViewItemAtIndex:0]];
    [destinationsTab removeTabViewItem:[destinationsTab tabViewItemAtIndex:0]];
    [destinationsTab removeTabViewItem:[destinationsTab tabViewItemAtIndex:0]];
    [destinationsTab setControlTint:NSClearControlTint];
    [destinationsTab selectTabViewItemAtIndex:0];
#endif
//    delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [self updateTableView:forSaleTableView];
    [self updateTableView:forSaleCodesTableView];
    [self updateTableView:forSaleStatisticTableView];
    [self updateTableView:weBuyTableView];
    [self updateTableView:weBuyCodesTableView];
    [self updateTableView:weBuyPerHourStatisticTableView];
    [self updateTableView:weBuyTestingTableView];
    [self updateTableView:weBuyTestingResultsTableView];
    [self updateTableView:targetsRoutingTableView];
    [self updateTableView:targetsCodesTableView];
    [self updateTableView:targetsTableView];
    [self updateTableView:pushListTableView];
    [self updateTableView:pushListCodesTableView];
    [self updateTableView:addDestinationsListTableView];
    [self updateTableView:addDestinationsOutGroupTableView];
    [self updateTableView:addDestinationsOutGroupDestinationsTableView];
    [self updateTableView:addDestinationsCarriersListTableView];
    [self updateTableView:addDestinationsCarriersRateSheetsTableView];
//    [self updateTableView:importRatesImportedRoutes];
//    [self updateTableView:importRatesParsedRows];
//    [self updateTableView:importRatesCarrierList];
//    [self updateTableView:importRatesCarriersRateSheet];
//    [self updateTableView:importRatesCodesTableView];
    [self updateTableView:addDestinationsChangeOutPeerTableView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        NSSortDescriptor *descriptorForStatistic = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        destinationPerHourStat.sortDescriptors = [NSArray arrayWithObject:descriptorForStatistic];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUsedCallAttempts" ascending:NO];
        
        destinationsListWeBuy.sortDescriptors = [NSArray arrayWithObject:descriptor];
        destinationsListForSale.sortDescriptors = [NSArray arrayWithObject:descriptor];
        
        [descriptorForStatistic release];
        [descriptor release];
    });
//    importRatesRelationshipName = [[NSMutableString alloc] init];
//    importRatesCarrierName = [[NSMutableString alloc] init];
//    importRatesSelectedCountryForParsing = [[NSMutableString alloc] init];;
//    mainBox.backgroundColor = [NSColor colorWithDeviceRed:0.53 green:0.53 blue:0.70 alpha:1];
//    mainBox.borderColor = [NSColor blackColor];
//    mainBox.titleColor = [NSColor whiteColor];
//    moc = [[NSManagedObjectContext alloc] init];
//    [moc setUndoManager:nil];
//    //[moc setMergePolicy:NSOverwriteMergePolicy];
//    [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
#if defined(SNOW_CLIENT_APPSTORE)
//    [destinationsTab removeTabViewItem:[destinationsTab tabViewItemAtIndex:0]];
//    [destinationsTab removeTabViewItem:[destinationsTab tabViewItemAtIndex:0]];
//    [destinationsTab setControlTint:NSClearControlTint];

#endif

}
- (void)viewDidMoveToSuperview
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    NSArray *selectedCarriers = [delegate.carrierArrayController selectedObjects];
//    Carrier *selectedCarrier = [selectedCarriers lastObject];
//    NSPredicate *predicateForDestinations = [NSPredicate predicateWithFormat:@"carrier = %@",selectedCarrier];
//    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUsedCallAttempts" ascending:NO];
//    destinationsListWeBuy.sortDescriptors = [NSArray arrayWithObject:descriptor];
//    destinationsListForSale.sortDescriptors = [NSArray arrayWithObject:descriptor];
//    [descriptor release];
    
}


-(void)updateGroupListStartImmediately:(BOOL)isStartImmediately;
{
#if defined (SNOW_CLIENT_ENTERPRISE)

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [addDestinationsProgress setHidden:NO];
            [addDestinationsProgress startAnimation:self];
        });
  
        MySQLIXC *databaseForGetGroupsList = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
        UpdateDataController *updateForGetGroupsList = [[UpdateDataController alloc] initWithDatabase:databaseForGetGroupsList];
        
        NSArray *connections = [[NSArray alloc] initWithArray:[updateForGetGroupsList databaseConnections]];
        databaseForGetGroupsList.connections = connections;
        [connections release];
        [updateForGetGroupsList release];
        
        NSString *country = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"country"];
        NSString *specific = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"specific"];
        NSDate *groupDateUpdates = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"outGroupsUpdateTime"];
        NSDate *groupDateUpdatesPlus24H = [groupDateUpdates dateByAddingTimeInterval:86400];
        if (isStartImmediately || !groupDateUpdates || [groupDateUpdatesPlus24H timeIntervalSinceDate:[NSDate date]] < 0) {
            NSArray *outGroups = [databaseForGetGroupsList getOutGroupsListWithOutPeersListInsideForCountry:country forSpecific:specific];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [addDestinationsProgress setHidden:YES];
                [addDestinationsProgress stopAnimation:self];
            });
   
                NSMutableDictionary *selectedDestination = [[addDestinationsList selectedObjects] lastObject];
                if (selectedDestination) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [selectedDestination setValue:outGroups forKey:@"outGroups"];
                        [selectedDestination setValue:[NSDate date] forKey:@"outGroupsUpdateTime"];
                    });
                    
                    NSLog(@"DESTINATIONS VIEW:new groups is:%@",outGroups);
                    NSString *pathForSaveArray = [[delegate applicationFilesDirectory].path stringByAppendingString:@"/myCountrySpecificCodeList.ary"];
                    NSArray *allContent = [addDestinationsList arrangedObjects];
                    BOOL error = [allContent writeToFile:pathForSaveArray atomically:YES];
                    if (!error) NSLog(@"DESTINATIONS VIEW:write to file error");
                } else NSLog(@"DESTINATIONS VIEW: groups update was not, bcs selected destinations not found");
        } else { 
            dispatch_async(dispatch_get_main_queue(), ^(void) {                
                [addDestinationsProgress setHidden:YES];
                [addDestinationsProgress stopAnimation:self];
            });
            NSLog(@"DESTINATIONS VIEW: groups update was not, waiting 24 hours");
        }
        
        [databaseForGetGroupsList release];
    });
#endif
    
}

- (BOOL) isAnyRateNotFilledOrNothingSelected;
{
    NSArray *currentObjects = [addDestinationsList arrangedObjects];
    NSArray *selectedObjects = [currentObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool:YES]]];
    if ([selectedObjects count] == 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *warning = [NSString stringWithFormat:@"WARNING: nothing was checked, nothing will add"];
        [dict setValue:warning forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error for insert new destination." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return YES;
    }
    if ([selectedObjects valueForKeyPath:@"@min.rate"] == 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSString *warning = [NSString stringWithFormat:@"WARNING: rate can't be nil"];
        [dict setValue:warning forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error for insert new destination." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return YES;
    }
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog( @">>>> Detected Change in keyPath: %@", keyPath );
    if ([keyPath isEqual:@"rate"] || [keyPath isEqual:@"asr"] || [keyPath isEqual:@"acd"] || [keyPath isEqual:@"minutesLenght"]) {
        id new = [change valueForKey:@"new"];
        id old = [change valueForKey:@"old"];
        if ([new isEqualTo:old]) { 
            //NSLog(@"nothing to change, return");
            return;
        }
        [self finalSaveForMoc:moc];
        
        NSManagedObjectID  *changedID = [object objectID];
        
        if (changedID) {
            DestinationsListPushList *changedDestination = (DestinationsListPushList *)[self.moc objectWithID:changedID];
            if (changedDestination) {
                [changedDestination setValue:new forKey:keyPath];
                [self finalSaveForMoc:moc];
                //sleep(1);
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                NSString *changedDestinationCarrierGUID = changedDestination.carrier.GUID;
                NSString *changedDestinationCompanyStuffGUID = changedDestination.carrier.companyStuff.GUID;
                if (!changedDestinationCarrierGUID || !changedDestinationCompanyStuffGUID) {
                    [clientController release];
                    //NSLog(@"DESTINATIONS LIST TABLE VIEW: warning for object we don't find carrier or company stuff guid");
                    return;
                }
                
                if ([[self localStatusForObjectsWithRootGuid:changedDestinationCarrierGUID] isEqualToString:@"registered"] && [[self localStatusForObjectsWithRootGuid:changedDestinationCompanyStuffGUID] isEqualToString:@"registered"]) { 
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                        
                        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[changedDestination objectID]] mustBeApproved:NO];
                    });
                    
                }
                else [self showErrorBoxWithText:@"carrier or admin not registered on server, just do it to make changes"];
                [clientController release];
            } else NSLog(@"DESTINATIONS VIEW: object for id not found (possible id is wrong)");
        } else NSLog(@"DESTINATIONS VIEW: object id not found (possible changes not in managed object");
        
    }
}


#pragma mark - actions for all tabs

- (IBAction)importDestinations:(id)sender {
    NSOpenPanel *savePanel = [NSOpenPanel openPanel]; 
    NSArray *fileTypes = [NSArray arrayWithObjects:@"csv",@"xls",nil];
    //[savePanel setFloatingPanel:YES];
    [savePanel setCanCreateDirectories:NO]; 
    [savePanel setCanChooseFiles:YES];
    [savePanel setAllowedFileTypes:fileTypes];
    
    [savePanel beginSheetModalForWindow:delegate.window completionHandler:^(NSInteger result) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        //if ([delegate.loggingLevel intValue] == 1) NSLog(@"RATES IMPORT:result is:%@",[NSNumber numberWithInteger:result]);
        
        if (result == NSFileHandlingPanelOKButton) { 
            //            if ([carriers count] == 1)
            //            {
            //                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            //                NSString *warning = [NSString stringWithFormat:@"HMMM... you like to add for more than two carriers once? i didn't hear about is it nessesary"];
            //                [dict setValue:warning forKey:NSLocalizedDescriptionKey];
            //                [dict setValue:@"There was an error for insert new destination." forKey:NSLocalizedFailureReasonErrorKey];
            //                NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            //                [[NSApplication sharedApplication] presentError:error];
            //                return ;
            //                
            //            }
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Sell"]) {
                    [delegate.destinationsView.destinationsForSaleProgress setHidden:NO];
                    [delegate.destinationsView.destinationsForSaleProgress startAnimation:self];
                }                
                if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Buy"]) {
                    [delegate.destinationsView.weBuyProgress setHidden:NO];
                    [delegate.destinationsView.weBuyProgress startAnimation:self];
                }                
                if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Targets"]) {
                    [delegate.destinationsView.targetsProgress setHidden:NO];
                    [delegate.destinationsView.targetsProgress startAnimation:self];
                }                
                if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Pushlist"]) {
                    [delegate.destinationsView.pushListProgress setHidden:NO];
                    [delegate.destinationsView.pushListProgress startAnimation:self];
                }                

                //[delegate.progressForMainThread startProgressIndicatorCountSeeWebRouting];
            });
            
            //NSURL *choicedFile = [savePanel URL];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                delegate.importRatesView.parsedFileURL = [savePanel URL];
                [delegate.importRatesView loadView];
                
                if (!importRatesPanel) importRatesPanel = [[NSPopover alloc] init];
                else {
                    [importRatesPanel release];
                    importRatesPanel = [[NSPopover alloc] init];
                }
                //                NSRect frameOfTestingCell = [sender frame]; 
                NSRect frameOfSender = [sender frame]; 
                frameOfSender = NSMakeRect(frameOfSender.origin.x + 15, frameOfSender.origin.y + 20, frameOfSender.size.width, frameOfSender.size.height);

                if (importRatesPanel) {
                    importRatesPanel.contentViewController = delegate.importRatesView;
                    importRatesPanel.behavior = NSPopoverBehaviorApplicationDefined;
                    [importRatesPanel showRelativeToRect:frameOfSender ofView:self.view preferredEdge:NSMaxYEdge];
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
            });
            
//            NSString *extension = [choicedFile pathExtension];
//            NSMutableArray *parsedFinal = [NSMutableArray arrayWithCapacity:0];
//            
//            if ([delegate.loggingLevel intValue] == 1) NSLog(@"RATES IMPORT:%@",extension);
//            if ([extension isEqualToString:@"xls"] || [extension isEqualToString:@"XLS"] || [extension isEqualToString:@"xlsx"]) {
//                NSArray *allSheets = [delegate.updateForMainThread allExcelBookSheetsForUSR:[choicedFile path]];
//                
//                NSMutableArray *parsed = [NSMutableArray array];
//                if ([allSheets count] == 1) {
//                    [parsed addObjectsFromArray:[delegate.updateForMainThread parseToExcelwithSaveUrl:[choicedFile path] forSheetNumber:0]];
//                    [importRatesRatesheetList setHidden:YES];
//                    //[importCSVprefix setHidden:NO];
//                    
//                    [importRatesRatesheetList removeAllItems];
//                    
//                } else {
//                    delegate.importCSVselectedURL = choicedFile;
//                    Carrier *updated = [carriers lastObject];
//                    [delegate.importCSVselectedCarrierName setString:updated.name];
//                    
//                    [importRatesRatesheetList setHidden:NO];
//                    //[importCSVprefix setHidden:NO];
//                    
//                    [importRatesRatesheetList removeAllItems];
//                    for (NSString *sheetName in allSheets)
//                    {
//                        [importRatesRatesheetList addItemWithTitle:sheetName];
//                    }
//                    [parsed addObjectsFromArray:[delegate.updateForMainThread parseToExcelwithSaveUrl:[choicedFile path] forSheetNumber:0]];
//                    
//                }
//                [parsedFinal addObjectsFromArray:parsed];
//            }
//            if ([extension isEqualToString:@"csv"]) {
//                // start parsing cvs file 
//                ParseCSV *parser = [[ParseCSV alloc] init];
//                [parser openFile:[choicedFile path]];
//                NSMutableArray *parsed = [parser parseFile];
//                [parser release];
//                [parsedFinal addObjectsFromArray:parsed];
//                
//            }
//            
//            
//            //[parsed writeToFile:@"/Users/alex/Documents/rulesParsed.ary" atomically:YES];
//            Carrier *carrierToImport = [carriers lastObject];
//            NSString *carrierToImportName = carrierToImport.name;
//            [importRatesCarrierName setString:carrierToImportName];
//            // read current choices and update tableview
//            NSMutableDictionary *importRatesUserChoices = [NSMutableDictionary dictionary];
//            [importRatesUserChoices addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationSupportDirectory]]]];
//            NSMutableDictionary *carrierChoisesList = [importRatesUserChoices valueForKey:importRatesCarrierName];
//            NSArray *allColumns = [carrierChoisesList valueForKey:importRatesRelationshipName];
//            NSArray *allTableColumns = [importRatesImportedRoutes tableColumns];
//            
//            if (allColumns) {
//                [allTableColumns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
//                    [[column headerCell] setStringValue:[allColumns objectAtIndex:idx]];
//                }];
//            } else {
//                [allTableColumns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
//                    [[column headerCell] setStringValue:@"click to select"];
//                }];
//                
//            }
//            
//            [delegate.updateForMainThread parseCVSimported:parsedFinal forCarrier:carrierToImportName withRelationshipName:relationShipName];
//            [addDestinationCarriersList setContent:[delegate.updateForMainThread fillCarriersForAddArrayForCarriers:carriers withRelationShipName:relationShipName forCurrentContent:[addDestinationCarriersList arrangedObjects]]];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Sell"]) {
                    [delegate.destinationsView.destinationsForSaleProgress setHidden:YES];
                    [delegate.destinationsView.destinationsForSaleProgress stopAnimation:self];
                }                
                if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Buy"]) {
                    [delegate.destinationsView.weBuyProgress setHidden:YES];
                    [delegate.destinationsView.weBuyProgress stopAnimation:self];
                }                
                if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Targets"]) {
                    [delegate.destinationsView.targetsProgress setHidden:YES];
                    [delegate.destinationsView.targetsProgress stopAnimation:self];
                }                
                if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Pushlist"]) {
                    [delegate.destinationsView.pushListProgress setHidden:YES];
                    [delegate.destinationsView.pushListProgress stopAnimation:self];
                }                
                
                //[delegate.progressForMainThread startProgressIndicatorCountSeeWebRouting];
            });
            
        }
    }];

//                importRatesPanel = [[[NSPopover alloc] init] autorelease];
//                //                NSRect frameOfTestingCell = [sender frame]; 
//                NSRect frameOfSender = [sender frame]; 
//
//                if (importRatesPanel) {
//                    importRatesPanel.contentViewController = delegate.importRatesView;
//                    importRatesPanel.behavior = NSPopoverBehaviorApplicationDefined;
//                    [importRatesPanel showRelativeToRect:frameOfSender ofView:self.view preferredEdge:NSMaxYEdge];
//                } else
//                {
//                    delegate.importRatesView.view.frame = NSMakeRect(frameOfSender.origin.x, frameOfSender.origin.y, addRoutesViewController.view.frame.size.width, addRoutesViewController.view.frame.size.height);
//                    [self.view addSubview:delegate.importRatesView.view];
//                }

}


- (IBAction)syncSelectedDestinations:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];

        NSArray *selectedCarriers = [delegate.carriersView.carrier selectedObjects];
        NSUInteger selectionIndex = [delegate.carriersView.carrier selectionIndex];
        [delegate.carriersView.carrier setSelectedObjects:nil];
        NSMutableArray *carriersToExecute = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSArray *selectedDestinations = nil;
        
        NSInteger destinationType = 0;
        if ([sender tag] == 1) {
            destinationType = 1;
            selectedDestinations = [destinationsListWeBuy selectedObjects];
            
        } else selectedDestinations = [destinationsListForSale selectedObjects];
        [selectedDestinations enumerateObjectsUsingBlock:^(NSManagedObject *object, NSUInteger idx, BOOL *stop) {
            NSManagedObject *carrier = [object valueForKey:@"carrier"];
            if (![carriersToExecute containsObject:[carrier objectID]]) [carriersToExecute addObject:[carrier objectID]];
        }];
        
        
        for (NSManagedObject *carrier in selectedCarriers) 
        {
            if (![carriersToExecute containsObject:[carrier objectID]]) [carriersToExecute addObject:[carrier objectID]];
        }
        
        
        [delegate.progressForMainThread startSync];
        NSNumber *carrierIndex = nil;
        
        for (NSManagedObjectID *carrierID in carriersToExecute)
        {
            NSManagedObject *carrier = [delegate.managedObjectContext objectWithID:carrierID];
            NSLog(@"DESTINATIONS VIEW: starting sync for carrier:%@",[carrier valueForKey:@"name"]);
            
            NSNumber *currentIndex = [NSNumber numberWithInt:([carrierIndex intValue] + 1)];
            MySQLIXC *database = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
            database.connections = [delegate.updateForMainThread databaseConnections];
            
            ProgressUpdateController *progress = [[ProgressUpdateController alloc] initWithDelegate:delegate withQueuePosition:currentIndex withIndexOfUpdatedObject:currentIndex];
            UpdateDataController *update = [[UpdateDataController alloc] initWithDatabase:database];
            [progress updateCarrierName:[[delegate.managedObjectContext objectWithID:carrierID] valueForKey:@"name"]];
            NSArray *currentSortDescriptors = [destinationsListForSale sortDescriptors];
            [destinationsListForSale setSortDescriptors:nil];
            //[progress hideTables];
            [update updateDestinationListforCarrier:carrierID destinationType:destinationType withProgressUpdateController:progress];
            [update updateStatisticforCarrierGUID:[carrier valueForKey:@"GUID"] andCarrierName:[carrier valueForKey:@"name"] destinationType:destinationType withProgressUpdateController:progress];
            
            //[progress unHideTables];
            [destinationsListForSale setSortDescriptors:currentSortDescriptors];
            [database release],[progress release],[update release];
            
        }
        [delegate.progressForMainThread stopSync];
        [delegate.progressForMainThread clearPoll];
        [delegate.carriersView.carrier setSelectionIndex:selectionIndex];
    });
    

}

- (IBAction)addRemoveToPushList:(id)sender {
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];

    NSArray *destinations =  nil;
    if ([sender tag] == 0) destinations = [destinationsListForSale selectedObjects];
    if ([sender tag] == 1) destinations = [destinationsListWeBuy selectedObjects];
    if ([sender tag] == 2) destinations = [destinationsListWeBuyForTargets selectedObjects];
    
    
    [destinations enumerateObjectsUsingBlock:^(NSManagedObject *selectedDestination, NSUInteger idx, BOOL *stop) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListPushList"
                                                  inManagedObjectContext:delegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSString *carrierGUID = [selectedDestination valueForKeyPath:@"carrier.GUID"];
        NSString *country = [selectedDestination valueForKey:@"country"];
        NSString *specific = [selectedDestination valueForKey:@"specific"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(carrier.GUID == %@) and (country == %@) and (specific == %@)",carrierGUID,country,specific];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] == 0) {
            entity = [NSEntityDescription entityForName:@"Carrier"
                                 inManagedObjectContext:delegate.managedObjectContext];
            [fetchRequest setEntity:entity];
            predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",carrierGUID];
            [fetchRequest setPredicate:predicate];
            fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            Carrier *carrierForPushlist = [fetchedObjects lastObject];
            
            DestinationsListPushList *newPushList = (DestinationsListPushList *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListPushList" inManagedObjectContext:delegate.managedObjectContext];
            newPushList.carrier = carrierForPushlist;
            newPushList.country = country;
            newPushList.specific = specific;
            newPushList.acd = [selectedDestination valueForKey:@"lastUsedACD"];
            newPushList.rate = [selectedDestination valueForKey:@"rate"];
            newPushList.asr = [selectedDestination valueForKey:@"lastUsedASR"];
            newPushList.minutesLenght = [selectedDestination valueForKey:@"lastUsedMinutesLenght"];
            newPushList.callAttempts = [selectedDestination valueForKey:@"lastUsedCallAttempts"];
            [delegate safeSave];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[newPushList objectID]] mustBeApproved:NO];
                [clientController release];
            });
            
        } else
        {
            //[self.managedObjectContext deleteObject:[fetchedObjects lastObject]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                [clientController removeObjectWithID:[[fetchedObjects lastObject] objectID]];
                [clientController release];
                
                sleep(20);
                [delegate.managedObjectContext deleteObject:[fetchedObjects lastObject]];
            });
        }
        [fetchRequest release];

    }];
    [self localMocMustUpdate];
    //[self safeSave];

    
}

//- (IBAction)importRatesColumnChoice:(id)sender {
//
//    NSString  *currentIdentifier = importRatesColumnSelectViewController.view.identifier;
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]  init];
//    NSNumber *tableColumnNumber = [formatter numberFromString:currentIdentifier];
//    NSTableColumn *changedColumn = [[ importRatesImportedRoutes tableColumns] objectAtIndex:[tableColumnNumber unsignedIntegerValue]];
//    NSString *finalColumnTitle = nil;
//    
//    switch ([sender tag]) {
//        case 0:
//            finalColumnTitle = @"NONE";
//            break;
//        case 1:
//            finalColumnTitle = @"Price";
//            break;
//        case 2:
//            finalColumnTitle = @"Code";
//            break;
//        case 3:
//            finalColumnTitle = @"subcode";
//            break;
//        case 4:
//            finalColumnTitle = @"ACD";
//            break;
//        case 5:
//            finalColumnTitle = @"ASR";
//            break;
//        case 6:
//            finalColumnTitle = @"Country";
//            break;
//        case 7:
//            finalColumnTitle = @"Specific";
//            break;
//        case 8:
//            finalColumnTitle = @"Minutes";
//            break;
//        case 9:
//            finalColumnTitle = @"Attempts";
//            break;
//        case 10:
//            finalColumnTitle = @"Date";
//            break;
//            
//        default:
//            break;
//    }
//    [[changedColumn headerCell] setStringValue:finalColumnTitle];
//    [[importRatesImportedRoutes headerView] setNeedsDisplay:YES];
//
//    if (importRatesColumnSelectPanel) [importRatesColumnSelectPanel close];
//
////    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    // get current choices
//    NSMutableDictionary *importRatesUserChoices = [NSMutableDictionary dictionary];
//    [importRatesUserChoices addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationSupportDirectory]]]];
//    // fill current titles
//    NSMutableArray *allColumnsTitles = [NSMutableArray arrayWithCapacity:9];
//    for (NSTableColumn *column in [importRatesImportedRoutes tableColumns]) { 
//        NSString *title = [[column headerCell] stringValue];
//        [allColumnsTitles addObject:title];
//    }
//    //NSLog(@"i will write:%@",allColumnsTitles);
//    
//    NSMutableDictionary *relationshipAndChoises = [NSMutableDictionary dictionary];
//    [relationshipAndChoises setValue:allColumnsTitles forKey:importRatesRelationshipName];
//    [importRatesUserChoices setValue:relationshipAndChoises forKey:importRatesCarrierName];
//
//    [importRatesUserChoices writeToFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationSupportDirectory]] atomically:YES];
//    
//}
//
//#pragma TODO - do excel change ratesheet issues.
//
//- (IBAction)importDestinationsParsing:(id)sender;
//{
////    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//    [importRatesProgress setHidden:NO];
//    [importRatesProgress startAnimation:self];
//    [importRatesStartParsing setEnabled:NO];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        
//        [delegate.updateForMainThread importCSVstartWithRelationshipName:importRatesRelationshipName];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            
////            [importRatesStartParsing setAction:@selector(applyRateSheet:)];
////            [importRatesStartParsing setTitle:@"Apply"];
//            [importRatesProgress setHidden:YES];
//            [importRatesProgress stopAnimation:self];
//            [importRatesStartParsing setEnabled:YES];
//
//        });
//
//    });
//    
//}
//- (IBAction)importDestinationsApply:(id)sender {
//    NSTabViewItem *selectedItem = [destinationsTab selectedTabViewItem];
//
//    if ([[selectedItem label] isEqualToString:@"Targets"]){
//        [targetsProgress setHidden:NO];
//        [targetsProgress startAnimation:self];
//
//     }
//    if ([[selectedItem label] isEqualToString:@"Buy"]){
//        [weBuyProgress setHidden:NO];
//        [weBuyProgress startAnimation:self];
//
//    }
//    if ([[selectedItem label] isEqualToString:@"Pushlist"]){
//        [pushListProgress setHidden:NO];
//        [pushListProgress startAnimation:self];
//    }
//    if (importRatesPanel) [importRatesPanel close];
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        [delegate.updateForMainThread importCSVfinishWithProgress:delegate.progressForMainThread withRelationship:importRatesRelationshipName];
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            if ([[selectedItem label] isEqualToString:@"Targets"]){
//                [targetsProgress setHidden:YES];
//                [targetsProgress stopAnimation:self];
//                
//            }
//            if ([[selectedItem label] isEqualToString:@"Buy"]){
//                [weBuyProgress setHidden:YES];
//                [weBuyProgress stopAnimation:self];
//                
//            }
//            if ([[selectedItem label] isEqualToString:@"Pushlist"]){
//                [pushListProgress setHidden:YES];
//                [pushListProgress stopAnimation:self];
//            }
//
//        });
//        
//        return;
//    });
//
//}

//- (IBAction)importDestinationsUserSelectDestination:(id)sender {
//    NSArray *countrySpecific = [[sender title] componentsSeparatedByString:@"/"];
//    NSString *countrySelected = [countrySpecific objectAtIndex:0];
//    if ([countrySelected isEqualToString:@"PLEASE SELECT"] || [countrySelected isEqualToString:@"Destinations choice"]) return;
//    
//    
//    NSMutableDictionary *row = [[importRatesSecondParserResult selectedObjects] lastObject];
//    NSString *countryFirstVersion = [row valueForKey:@"country"];
//    NSString *specificFirstVersion = [row valueForKey:@"specific"];
//    if (!specificFirstVersion) specificFirstVersion = @"";
//    //NSArray *userSpecificDictionaries = [[NSUserDefaults standardUserDefaults] valueForKey:@"userSpecificDictionaries"];
//    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(externalCountry == %@) and (externalSpecific == %@)",countryFirstVersion,specificFirstVersion];
//    //NSArray *userSpecificDictionariesForLocalChoice = [userSpecificDictionaries filteredArrayUsingPredicate:predicate];
//    NSArray *userSpecificDictionariesForLocalChoice = [[NSUserDefaults standardUserDefaults] valueForKey:@"userSpecificDictionaries"];
//    /*NSMutableArray *finalVersion = [NSMutableArray arrayWithArray:otherUserSpecificDictionaries];
//     predicate = [NSPredicate predicateWithFormat:@"(externalCountry == %@) and (externalSpecific == %@)",countryFirstVersion,specificFirstVersion];
//     NSArray *currentUserSpecificDictionaries = [userSpecificDictionaries filteredArrayUsingPredicate:predicate];*/
//    NSMutableArray *finalVersion = [NSMutableArray arrayWithArray:userSpecificDictionariesForLocalChoice];
//    
//    NSPredicate *predicate = nil;
//    NSArray *result = nil;
//    NSArray *codes = nil;
//    NSMutableArray *codesCollection = [NSMutableArray array];
//    if ([countrySelected isEqualToString:@"SELECT ALL"]) {
//        predicate = [NSPredicate predicateWithFormat:@"(country contains[cd] %@)",importRatesSelectedCountryForParsing];
//        result = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:predicate];
//        //codes = [NSArray arrayWithArray:codesCollection];
//        
//        NSString *countryName = [[result lastObject] valueForKey:@"country"];
//        
//        for (NSDictionary *specifics in result) {
//            [codesCollection addObjectsFromArray:[specifics valueForKey:@"code"]];
//            NSString *specific = [specifics valueForKey:@"specific"];
//            // add select to saved area
//            NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:countryFirstVersion,@"externalCountry",specificFirstVersion,@"externalSpecific", countryName,@"localCountry",specific,@"localSpecific", nil];
//            NSArray *filteredCurrentUserSpecificDictionaries = [userSpecificDictionariesForLocalChoice filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@) AND (externalCountry == %@) AND (externalSpecific == %@)",countryName,specific,countryFirstVersion,specificFirstVersion]];
//            
//            if ([filteredCurrentUserSpecificDictionaries count] == 0) [finalVersion addObject:newObject];
//            
//            
//        }
//        [[NSUserDefaults standardUserDefaults] setObject:finalVersion forKey:@"userSpecificDictionaries"];
////        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        NSString *applicationSupportDirectory = [delegate applicationSupportDirectory];
//        [finalVersion writeToFile:[NSString stringWithFormat:@"%@/userSpecificDictionaries_IMPORT_DESTINATIONS.ary",applicationSupportDirectory] atomically:YES];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        
//        
////        NSInteger selectedRow = [parsingResultTableView selectedRow];
////        [self tableView:parsingResultTableView shouldSelectRow:selectedRow];
//        return;
//        
//    } 
//    
//    
//    if ([countrySelected isEqualToString:@"DESELECT ALL"])
//    {
//        
//        NSMutableDictionary *row = [[importRatesSecondParserResult selectedObjects ] lastObject];
//        NSMutableArray *currentCodesList = [NSMutableArray arrayWithArray:[row valueForKey:@"codes"]];
//        [currentCodesList removeAllObjects];
//        [row setValue:currentCodesList forKey:@"codes"];
//        
//        [finalVersion removeAllObjects];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:finalVersion forKey:@"userSpecificDictionaries"];
////        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        NSString *applicationSupportDirectory = [delegate applicationSupportDirectory];
//        [finalVersion writeToFile:[NSString stringWithFormat:@"%@/userSpecificDictionaries_IMPORT_DESTINATIONS.ary",applicationSupportDirectory] atomically:YES];
//        
////        NSInteger selectedRow = [parsingResultTableView selectedRow];
////        [self tableView:parsingResultTableView shouldSelectRow:selectedRow];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        
//        return;
//    }
//    NSString *specificSelected = [countrySpecific objectAtIndex:1];
//    
//    if ([codes count] == 0)
//    {
//        
//        // just one country/specific pair selected
//        NSString *countryFinal = nil;
//        NSRange range = [countrySelected rangeOfString:@"ADD"];
//        if (range.location != NSNotFound) {
//            countryFinal = [countrySelected stringByReplacingOccurrencesOfString:@"ADD: " withString:@""];
//            
//            NSArray *filteredCurrentUserSpecificDictionaries = [userSpecificDictionariesForLocalChoice filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@) AND (externalCountry == %@) AND (externalSpecific == %@)",countryFinal,specificSelected,countryFirstVersion,specificFirstVersion]];
//            
//            //predicate = [NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)",countryFinal,specificSelected];
//            //result = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:predicate];
//            //codes = [[result lastObject] valueForKey:@"code"];
//            
//            NSMutableDictionary *newObject = [NSMutableDictionary dictionaryWithCapacity:4];
//            [newObject setValue:countryFirstVersion forKey:@"externalCountry"];
//            if (specificFirstVersion) [newObject setValue:specificFirstVersion forKey:@"externalSpecific"];
//            else [newObject setValue:@"" forKey:@"externalSpecific"];
//            [newObject setValue:countryFinal forKey:@"localCountry"];
//            [newObject setValue:specificSelected forKey:@"localSpecific"];
//            
//            if ([filteredCurrentUserSpecificDictionaries count] == 0)  [finalVersion addObject:newObject];
//            
//            // to prevent duplicate records we must check before add and delete appropriate object.
//            
//            [[NSUserDefaults standardUserDefaults] setObject:finalVersion forKey:@"userSpecificDictionaries"];
////            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//            NSString *applicationSupportDirectory = [delegate applicationSupportDirectory];
//            [finalVersion writeToFile:[NSString stringWithFormat:@"%@/userSpecificDictionaries_IMPORT_DESTINATIONS.ary",applicationSupportDirectory] atomically:YES];
//            
//            // codes must add to view 
//            /*NSMutableArray *currentCodesList = [NSMutableArray arrayWithArray:[row valueForKey:@"codes"]];
//             [currentCodesList addObjectsFromArray:codes];
//             [row setValue:currentCodesList forKey:@"codes"];
//             NSInteger selectedRow = [parsingResultTableView selectedRow];
//             NSArray *allParsedObjects = [importedCSVparsedSource arrangedObjects];
//             NSMutableArray *allParsedObjectsMutable = [NSMutableArray arrayWithArray:allParsedObjects];
//             [allParsedObjectsMutable replaceObjectAtIndex:selectedRow withObject:row];*/
//            //[importedCSVparsedSource setContent:allParsedObjectsMutable];     
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
////            NSInteger selectedRow = [parsingResultTableView selectedRow];
////            [self tableView:parsingResultTableView shouldSelectRow:selectedRow];
//            
//            
//        }
//        else { 
//            
//            countryFinal = [countrySelected stringByReplacingOccurrencesOfString:@"REMOVE: " withString:@""];
//            
//            NSArray *filteredCurrentUserSpecificDictionaries = [userSpecificDictionariesForLocalChoice filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@) AND (externalCountry == %@) AND (externalSpecific == %@)",countryFinal,specificSelected,countryFirstVersion,specificFirstVersion]];
//            
//            
//            
//            if ([filteredCurrentUserSpecificDictionaries count] > 0)  [finalVersion removeObjectsInArray:filteredCurrentUserSpecificDictionaries];
//            
//            // to prevent duplicate records we must check before add and delete appropriate object.
//            
//            [[NSUserDefaults standardUserDefaults] setObject:finalVersion forKey:@"userSpecificDictionaries"];
////            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//            NSString *applicationSupportDirectory = [delegate applicationSupportDirectory];
//            [finalVersion writeToFile:[NSString stringWithFormat:@"%@/userSpecificDictionaries_IMPORT_DESTINATIONS.ary",applicationSupportDirectory] atomically:YES];
//            
//            
//            predicate = [NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)",countryFinal,specificSelected];
//            result = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:predicate];
//            codes = [[result lastObject] valueForKey:@"code"];
//            
//            NSMutableArray *currentCodesList = [NSMutableArray arrayWithArray:[row valueForKey:@"codes"]];
//            [codes enumerateObjectsUsingBlock:^(NSString *code, NSUInteger idx, BOOL *stop) {
//                NSArray *removedObject = [currentCodesList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@",code]];
//                [currentCodesList removeObjectsInArray:removedObject];
//            }];
//            
//            [row setValue:currentCodesList forKey:@"codes"];
////            NSInteger selectedRow = [parsingResultTableView selectedRow];
////            [self tableView:parsingResultTableView shouldSelectRow:selectedRow];
//            
//            
//        }
//        
//    }
//    
//    
//    /*NSMutableArray *finalCodesList = [NSMutableArray arrayWithArray:[row valueForKey:@"codes"]];
//     
//     for (NSString *code in codes) {
//     NSDictionary *codeRow = [NSDictionary dictionaryWithObjectsAndKeys:code,@"code", nil];
//     [finalCodesList addObject:codeRow];
//     }
//     [row setValue:finalCodesList forKey:@"codes"];*/
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//}

//- (IBAction)importDestinationsClose:(id)sender {
//    if (importRatesPanel) [importRatesPanel close];
//    
//}
//
//- (IBAction)importDestinations:(id)sender {
////    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//
//#if defined(SNOW_CLIENT_APPSTORE)
//    [importRatesEffectiveDate setHidden:YES];
//    [importRatesRatesheetList setHidden:YES];
//    [importRatesPrefix setHidden:YES];
//#endif
//    
//    
//    importRatesEffectiveDate.dateValue = [NSDate dateWithTimeIntervalSinceNow:-86400];
//    NSMutableArray *carriers = [NSMutableArray arrayWithCapacity:0];
//    NSTabViewItem *selectedItem = [destinationsTab selectedTabViewItem];
//    NSString *relationShipName = nil;
//    NSArray *selectedDestinations = nil;
//    if ([[selectedItem label] isEqualToString:@"Targets"]){
//        relationShipName = @"destinationsListTargets";
//        selectedDestinations = [destinationsListTargets selectedObjects];
//        [destinationsListTargets setSelectedObjects:nil];
//        for (DestinationsListTargets *target in selectedDestinations) if (![carriers containsObject:target.carrier]) [carriers addObject:target.carrier];
//        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"selectionChoices", nil];
//        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
//        [importRatesViewController setTitle:@"import targets"];
//    }
//    if ([[selectedItem label] isEqualToString:@"Buy"]){
//        relationShipName = @"destinationsListWeBuy";
//        
//        selectedDestinations = [destinationsListWeBuy selectedObjects];
//        [destinationsListWeBuy setSelectedObjects:nil];
//        for (DestinationsListWeBuy *destinationWeBuy in selectedDestinations) if (![carriers containsObject:destinationWeBuy.carrier]) [carriers addObject:destinationWeBuy.carrier];
//        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"selectionChoices", nil];
//        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
//        [importRatesViewController setTitle:@"import rates to destination we buy"];
//        
//    }
//    if ([[selectedItem label] isEqualToString:@"Pushlist"]){
//        relationShipName = @"destinationsListPushList";
//        selectedDestinations = [destinationsListPushList selectedObjects];
//        [destinationsListPushList setSelectedObjects:nil];
//        for (DestinationsListPushList *destinationsPushList in selectedDestinations) if (![carriers containsObject:destinationsPushList.carrier]) [carriers addObject:destinationsPushList.carrier];
//        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"selectionChoices", nil];
//        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
//        [importRatesViewController setTitle:@"import push list"];
//        
//        
//    }
//    
//    for (Carrier *carrier in [delegate.carrierArrayController selectedObjects]) if (![carriers containsObject:carrier]) [carriers addObject:carrier];
//    if (carriers.count == 0) [carriers addObject:[delegate.carrierArrayController.arrangedObjects lastObject]];
//    
//    [importRatesRelationshipName setString:relationShipName];
//    
//    [importRatesStartParsing setAction:@selector(importDestinationsParsing:)];
//    [importRatesStartParsing setTitle:@"Start parsing"];
//    
//    NSOpenPanel *savePanel = [NSOpenPanel openPanel]; 
//    NSArray *fileTypes = [NSArray arrayWithObjects:@"csv",@"xls",nil];
//    //[savePanel setFloatingPanel:YES];
//    [savePanel setCanCreateDirectories:NO]; 
//    [savePanel setCanChooseFiles:YES];
//    [savePanel setAllowedFileTypes:fileTypes];
//    
//    [savePanel beginSheetModalForWindow:delegate.window completionHandler:^(NSInteger result) {
//        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        
////        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        if ([delegate.loggingLevel intValue] == 1) NSLog(@"RATES IMPORT:result is:%@",[NSNumber numberWithInteger:result]);
//        
//        if (result == NSFileHandlingPanelOKButton) { 
////            if ([carriers count] == 1)
////            {
////                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
////                NSString *warning = [NSString stringWithFormat:@"HMMM... you like to add for more than two carriers once? i didn't hear about is it nessesary"];
////                [dict setValue:warning forKey:NSLocalizedDescriptionKey];
////                [dict setValue:@"There was an error for insert new destination." forKey:NSLocalizedFailureReasonErrorKey];
////                NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
////                [[NSApplication sharedApplication] presentError:error];
////                return ;
////                
////            }
//            //[self createAndConnectMainThreadControllers];
//            [delegate.progressForMainThread startProgressIndicatorCountSeeWebRouting];
//            
//            //[queneForMainThreadBackground addOperationWithBlock:^{
//            NSURL *choicedFile = [savePanel URL];
//            NSString *extension = [choicedFile pathExtension];
//            NSMutableArray *parsedFinal = [NSMutableArray arrayWithCapacity:0];
//            
////            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//            if ([delegate.loggingLevel intValue] == 1) NSLog(@"RATES IMPORT:%@",extension);
//            if ([extension isEqualToString:@"xls"] || [extension isEqualToString:@"XLS"] || [extension isEqualToString:@"xlsx"]) {
//                NSArray *allSheets = [delegate.updateForMainThread allExcelBookSheetsForUSR:[choicedFile path]];
//                
//                NSMutableArray *parsed = [NSMutableArray array];
//                if ([allSheets count] == 1) {
//                    [parsed addObjectsFromArray:[delegate.updateForMainThread parseToExcelwithSaveUrl:[choicedFile path] forSheetNumber:0]];
//                    [importRatesRatesheetList setHidden:YES];
//                    //[importCSVprefix setHidden:NO];
//                    
//                    [importRatesRatesheetList removeAllItems];
//                    
//                } else {
//                    delegate.importCSVselectedURL = choicedFile;
//                    Carrier *updated = [carriers lastObject];
//                    [delegate.importCSVselectedCarrierName setString:updated.name];
//                    
//                    [importRatesRatesheetList setHidden:NO];
//                    //[importCSVprefix setHidden:NO];
//                    
//                    [importRatesRatesheetList removeAllItems];
//                    for (NSString *sheetName in allSheets)
//                    {
//                        [importRatesRatesheetList addItemWithTitle:sheetName];
//                    }
//                    [parsed addObjectsFromArray:[delegate.updateForMainThread parseToExcelwithSaveUrl:[choicedFile path] forSheetNumber:0]];
//                    
//                }
//                [parsedFinal addObjectsFromArray:parsed];
//            }
//            if ([extension isEqualToString:@"csv"]) {
//                // start parsing cvs file 
//                ParseCSV *parser = [[ParseCSV alloc] init];
//                [parser openFile:[choicedFile path]];
//                NSMutableArray *parsed = [parser parseFile];
//                [parser release];
//                [parsedFinal addObjectsFromArray:parsed];
//                
//            }
//            
//                                                       
//            //[parsed writeToFile:@"/Users/alex/Documents/rulesParsed.ary" atomically:YES];
//            Carrier *carrierToImport = [carriers lastObject];
//            NSString *carrierToImportName = carrierToImport.name;
//            [importRatesCarrierName setString:carrierToImportName];
//            // read current choices and update tableview
//            NSMutableDictionary *importRatesUserChoices = [NSMutableDictionary dictionary];
//            [importRatesUserChoices addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationSupportDirectory]]]];
//            NSMutableDictionary *carrierChoisesList = [importRatesUserChoices valueForKey:importRatesCarrierName];
//            NSArray *allColumns = [carrierChoisesList valueForKey:importRatesRelationshipName];
//            NSArray *allTableColumns = [importRatesImportedRoutes tableColumns];
//
//            if (allColumns) {
//                [allTableColumns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
//                    [[column headerCell] setStringValue:[allColumns objectAtIndex:idx]];
//                }];
//            } else {
//                [allTableColumns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
//                    [[column headerCell] setStringValue:@"click to select"];
//                }];
//
//            }
//            //            dispatch_async(dispatch_get_main_queue(), ^(void) {
//            //                
////                [[importRatesImportedRoutes headerView] setNeedsDisplay:YES];
////            });
//            //for (NSTableColumn *column in [importRatesImportedRoutes tableColumns]) [allColumnsTitles addObject:[[changedColumn headerCell] stringValue]];
//            
//
//            
//            
//            
//            [delegate.updateForMainThread parseCVSimported:parsedFinal forCarrier:carrierToImportName withRelationshipName:relationShipName];
//            [addDestinationCarriersList setContent:[delegate.updateForMainThread fillCarriersForAddArrayForCarriers:carriers withRelationShipName:relationShipName forCurrentContent:[addDestinationCarriersList arrangedObjects]]];
//            
//            [delegate.progressForMainThread stopProgressIndicatorCountSeeWebRouting];
//            //[importCSV setBackgroundColor:[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1]];
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                
//                importRatesPanel = [[[NSPopover alloc] init] autorelease];
//                //                NSRect frameOfTestingCell = [sender frame]; 
//                NSRect frameOfSender = [sender frame]; 
//
//                if (importRatesPanel) {
//                    importRatesPanel.contentViewController = importRatesViewController;
//                    importRatesPanel.behavior = NSPopoverBehaviorApplicationDefined;
//                    [importRatesPanel showRelativeToRect:frameOfSender ofView:self.view preferredEdge:NSMaxYEdge];
//                } else
//                {
//                    importRatesViewController.view.frame = NSMakeRect(frameOfSender.origin.x, frameOfSender.origin.y, addRoutesViewController.view.frame.size.width, addRoutesViewController.view.frame.size.height);
//                    [self.view addSubview:importRatesViewController.view];
//                }
//                
//                //            [NSApp beginSheet:addDestinationsMainPanel 
//                //               modalForWindow:delegate.window
//                //                modalDelegate:nil 
//                //               didEndSelector:nil
//                //                  contextInfo:nil];
//            });
//            
//            //return;
//        }
//        //});
//    }];
//    //[savePanel runModal];
//    
//    //NSArray *carriers = [NSArray arrayWithArray:[carrierArrayController selectedObjects]];
//    //[carrierArrayController setSelectedObjects:nil];
//    //DestinationsListTargets *selectedTarget = [[destinationsListTargets selectedObjects] lastObject];
//    //NSArray *newCarriers = nil;
// 
//    
//}


-(void)addDestinationsSwitchViewSizeToSmall:(BOOL)isSizeMustBeSmall
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {

    if (isSizeMustBeSmall && !isAddDestinationsPanelShort) {
        //NSLog(@"MAKE SMALL");

        [addDestinationsGroupsView setHidden:YES];
        [addDestinationsRateSheetsView setHidden:YES];
        addDestinationsCarriersAndRatesheetsView.frame = NSMakeRect(addDestinationsCarriersAndRatesheetsView.frame.origin.x, addDestinationsCarriersAndRatesheetsView.frame.origin.y + addDestinationsGroupsView.frame.size.height, addDestinationsCarriersAndRatesheetsView.frame.size.width, addDestinationsCarriersAndRatesheetsView.frame.size.height);
        
        addDestinationsView.frame = NSMakeRect(addDestinationsView.frame.origin.x, addDestinationsView.frame.origin.y, addDestinationsView.frame.size.width, addDestinationsView.frame.size.height - addDestinationsGroupsView.frame.size.height);
        addDestinationsBox.frame = NSMakeRect(addDestinationsBox.frame.origin.x, addDestinationsBox.frame.origin.y + addDestinationsGroupsView.frame.size.height, addDestinationsBox.frame.size.width, addDestinationsBox.frame.size.height - addDestinationsGroupsView.frame.size.height );

        isAddDestinationsPanelShort = YES;
    }

    if (!isSizeMustBeSmall && isAddDestinationsPanelShort) {
        NSLog(@"MAKE BIG");
        [addDestinationsGroupsView setHidden:NO];
        [addDestinationsRateSheetsView setHidden:NO];
        addDestinationsCarriersAndRatesheetsView.frame = NSMakeRect(addDestinationsCarriersAndRatesheetsView.frame.origin.x, addDestinationsCarriersAndRatesheetsView.frame.origin.y - addDestinationsGroupsView.frame.size.height, addDestinationsCarriersAndRatesheetsView.frame.size.width, addDestinationsCarriersAndRatesheetsView.frame.size.height);
        
        addDestinationsView.frame = NSMakeRect(addDestinationsView.frame.origin.x, addDestinationsView.frame.origin.y, addDestinationsView.frame.size.width, addDestinationsView.frame.size.height  + addDestinationsGroupsView.frame.size.height);
        
        addDestinationsBox.frame = NSMakeRect(addDestinationsBox.frame.origin.x, addDestinationsBox.frame.origin.y - addDestinationsGroupsView.frame.size.height, addDestinationsBox.frame.size.width, addDestinationsBox.frame.size.height + addDestinationsGroupsView.frame.size.height );

        isAddDestinationsPanelShort = NO;

    }
    });
}

- (IBAction)addDestinationsCancel:(id)sender {
    if (addDestinationsPanel) [addDestinationsPanel close];
    else {
        [addDestinationsMainPanel orderOut:sender];
        [NSApp endSheet:addDestinationsMainPanel];

    }
#if defined (SNOW_CLIENT_ENTERPRISE)

    [addDestinationsButton setEnabled:YES];
    [addDestinationsWeBuyButton setEnabled:YES];
    [addDestinationsTargetsBlock setEnabled:YES];
    [addDestinationsTargetsNew setEnabled:YES];    

#endif

    [addDestinationsPushlistButton setEnabled:YES];
}

- (IBAction)addDestinationsFinish:(id)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        if ([self isAnyRateNotFilledOrNothingSelected]) return; 
        
        //[delegate.progressForMainThread startAddDestinations];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool:YES]];
        NSArray *carrierListForAdd = [[addDestinationCarriersList arrangedObjects] filteredArrayUsingPredicate:predicate];
        NSArray *destinationsListForAdd = [[addDestinationsList arrangedObjects] filteredArrayUsingPredicate:predicate];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (addDestinationsPanel) [addDestinationsPanel close];
            else {
                [addDestinationsMainPanel orderOut:sender];
                [NSApp endSheet:addDestinationsMainPanel];
                
            }
#if defined (SNOW_CLIENT_ENTERPRISE)
            [addDestinationsButton setEnabled:YES];
            [addDestinationsWeBuyButton setEnabled:YES];
            [addDestinationsTargetsBlock setEnabled:YES];
            [addDestinationsTargetsNew setEnabled:YES];
#endif
            [addDestinationsPushlistButton setEnabled:YES];
            if ([sender tag] == 0) { 
                [destinationsForSaleProgress setHidden:NO];
                [destinationsForSaleProgress startAnimation:self];

            }
            if ([sender tag] == 1) { 
                [targetsProgress setHidden:NO];
                [targetsProgress startAnimation:self];
                
            }
            if ([sender tag] == 2) { 
                [pushListProgress setHidden:NO];
                [pushListProgress startAnimation:self];
                
            }

        });
        NSArray *addedIDs = nil;
        MySQLIXC *database = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
        database.connections = [delegate.updateForMainThread databaseConnections];

        UpdateDataController *update = [[UpdateDataController alloc] initWithDatabase:database];
        [database release];
        
        if ([sender tag] == 0)  [update inserDestinationsForCarriers:carrierListForAdd andDestinations:destinationsListForAdd forEntity:@"DestinationsListForSale" withPercent:nil withLinesForActivation:nil]; 
        if ([sender tag] == 1) [update inserDestinationsForCarriers:carrierListForAdd andDestinations:destinationsListForAdd forEntity:@"DestinationsListTargets" withPercent:[NSNumber numberWithDouble:0.07] withLinesForActivation:[NSNumber numberWithInt:4]];
        if ([sender tag] == 2) { addedIDs = [update inserDestinationsForCarriers:carrierListForAdd andDestinations:destinationsListForAdd forEntity:@"DestinationsListPushList" withPercent:[NSNumber numberWithDouble:0.07] withLinesForActivation:[NSNumber numberWithInt:4]];
        }
        
        
        //[delegate.progressForMainThread stopAddDestinations];

        //[updateForMainThread finalSave];
//        [progressForMainThread updateSystemMessage:[NSString stringWithFormat:@"Insert destinations was finished  %@ for %@ destinations in %@ carriers.",[NSDate date],[NSNumber numberWithUnsignedInteger:[destinationsListForAdd count]],[NSNumber numberWithUnsignedInteger:[carrierListForAdd count]]]];
//        [progressForMainThread stopAddDestinations];
        [update finalSave];
        sleep(3);
        [self localMocMustUpdate];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            if ([sender tag] == 0) { 
                [destinationsForSaleProgress setHidden:YES];
                [destinationsForSaleProgress stopAnimation:self];
                
            }
            if ([sender tag] == 1) { 
                [targetsProgress setHidden:YES];
                [targetsProgress stopAnimation:self];
                
            }
            if ([sender tag] == 2) { 
                [pushListProgress setHidden:YES];
                [pushListProgress stopAnimation:self];
                
            }
        });
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
        
        //[self updateDestinationsList];
        //        UserDataController *userController = [[UserDataController alloc] init];
        //        userController.context = [self managedObjectContext];
        //        [userController processIDs:addedIDs];
        //        //[userController release];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            if (addedIDs) {
                //            AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                [clientController putObjectWithTimeoutWithIDs:addedIDs mustBeApproved:NO];
                [clientController release];
            }
        });
        
#endif       
        [update release];
        
        return;
    });

}

- (IBAction)addDestinations:(id)sender {
    NSButton *senderButton = sender;
    [senderButton setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        [addDestinationsStartButton setTag:0];
        __block NSRect frameOfSender = [sender frame]; 
        MySQLIXC *databaseForAddDestinations = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
        UpdateDataController *updateForAddDestinations = [[UpdateDataController alloc] initWithDatabase:databaseForAddDestinations];
        
        NSArray *connections = [[NSArray alloc] initWithArray:[updateForAddDestinations databaseConnections]];
        databaseForAddDestinations.connections = connections;
        [databaseForAddDestinations release];
        [connections release];
        
        //[delegate.progressForMainThread startAddDestinations];
        
        //NSMutableArray *currentCountrySpecificCodeList = [NSMutableArray arrayWithArray:[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList];
        NSError *error = nil;

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList"
                                                  inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];
        
//        NSArray *ethalonDestinationsList = [NSArray arrayWithArray:fetchedObjects];
        
        NSMutableArray *finalDestinationsList = [NSMutableArray array];
        
        
        [fetchedObjects enumerateObjectsUsingBlock:^(CountrySpecificCodeList *countryLine, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            [row setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [row setValue:countryLine.country forKey:@"country"];
            [row setValue:countryLine.specific forKey:@"specific"];
            [finalDestinationsList addObject:row];
        }];
        
        
        NSMutableArray *carriersWithSelectedDestinationCarrier = [NSMutableArray array];
        NSArray *carriers = [NSArray arrayWithArray:[delegate.carriersView.carrier selectedObjects]];
//        NSPredicate *filterCountryList = nil;
        NSNumber *proposedRate = nil;
        // destinations for sell tag = 0
        // destinations we buy tag = 1
        // destinations target list add destination inside target list tag = 2
        // destinations target list add destination based on target list tag = 3
        // destinations pushlist tag = 4
        
        // destinations for sale new button
        if ([sender tag] == 0) { 
            [self addDestinationsSwitchViewSizeToSmall:NO];

            Carrier *selectedCarrier = nil;
            DestinationsListTargets *selected = [[destinationsListForSale selectedObjects] lastObject];
            if (selected) selectedCarrier = selected.carrier;
            else selectedCarrier = [[delegate.carriersView.carrier selectedObjects] lastObject];
            if (!selectedCarrier) selectedCarrier = [[delegate.carriersView.carrier arrangedObjects] lastObject];
            if (selectedCarrier) carriers = [NSArray arrayWithObject:selectedCarrier];

            NSArray *selectedDestinations = [destinationsListForSale selectedObjects];
            [selectedDestinations enumerateObjectsUsingBlock:^(DestinationsListForSale *destination, NSUInteger idx, BOOL *stop) {
                NSPredicate *filterCountryList = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",destination.country,destination.specific];
                NSArray *filteredDestinations = [finalDestinationsList filteredArrayUsingPredicate:filterCountryList];
                if ([filteredDestinations count] > 0) {
                    NSMutableDictionary *filteredCountry = [filteredDestinations lastObject];
                    [filteredCountry setValue:destination.rate forKey:@"rate"];
                    [filteredCountry setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
                    filterCountryList = [NSPredicate predicateWithFormat:@"(country != %@) and (specific != %@)",destination.country,destination.specific];
                    [finalDestinationsList filterUsingPredicate:filterCountryList];
                    [finalDestinationsList addObject:filteredCountry];
                    

                } else NSLog(@"APP DELEGATE: warning, country:%@ specific:%@ not found in country list",destination.country,destination.specific);   
                //if (![carriers containsObject:destination.carrier])  [carriersWithSelectedDestinationCarrier addObject:destination.carrier];
                
            }];
            [addDestinationCarriersList setContent:[updateForAddDestinations fillCarriersForAddArrayForCarriers:carriers withRelationShipName:@"destinationsListForSale" forCurrentContent:[addDestinationCarriersList arrangedObjects]]];
        }
        // destinations we buy new button
        if ([sender tag] == 1) { 
            [self addDestinationsSwitchViewSizeToSmall:NO];

            Carrier *selectedCarrier = nil;
            DestinationsListTargets *selected = [[destinationsListWeBuy selectedObjects] lastObject];
            if (selected) selectedCarrier = selected.carrier;
            else selectedCarrier = [[delegate.carriersView.carrier selectedObjects] lastObject];
            if (!selectedCarrier) selectedCarrier = [[delegate.carriersView.carrier arrangedObjects] lastObject];
            if (selectedCarrier) carriers = [NSArray arrayWithObject:selectedCarrier];
            
            NSArray *selectedDestinations = [destinationsListWeBuy selectedObjects];
            [selectedDestinations enumerateObjectsUsingBlock:^(DestinationsListWeBuy *destination, NSUInteger idx, BOOL *stop) {
                NSPredicate *filterCountryList = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",destination.country,destination.specific];
                NSArray *filteredDestinations = [finalDestinationsList filteredArrayUsingPredicate:filterCountryList];
                if ([filteredDestinations count] > 0) {
                    NSMutableDictionary *filteredCountry = [filteredDestinations lastObject];
                    [filteredCountry setValue:destination.rate forKey:@"rate"];
                    [filteredCountry setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
                    filterCountryList = [NSPredicate predicateWithFormat:@"(country != %@) and (specific != %@)",destination.country,destination.specific];
                    [finalDestinationsList filterUsingPredicate:filterCountryList];
                    [finalDestinationsList addObject:filteredCountry];
                    

                } else NSLog(@"APP DELEGATE: warning, country:%@ specific:%@ not found in country list",destination.country,destination.specific);   
            }];
            [addDestinationCarriersList setContent:[updateForAddDestinations fillCarriersForAddArrayForCarriers:carriers withRelationShipName:@"destinationsListForSale" forCurrentContent:[addDestinationCarriersList arrangedObjects]]];

        }
        
        // add targets button
        if ([sender tag] == 2) { 
            [self addDestinationsSwitchViewSizeToSmall:YES];
            [addDestinationsStartButton setTag:1];
            
            DestinationsListTargets *selected = [[destinationsListTargets selectedObjects] lastObject];
            if (selected) [carriersWithSelectedDestinationCarrier addObject:selected.carrier];
            [addDestinationCarriersList setContent:[updateForAddDestinations fillCarriersForAddArrayForCarriers:carriersWithSelectedDestinationCarrier withRelationShipName:@"destinationsListTargets" forCurrentContent:[addDestinationCarriersList arrangedObjects]]];
            
        }
        
        // add destination based on targets button
        if ([sender tag] == 3) { 
            [self addDestinationsSwitchViewSizeToSmall:NO];
            
            Carrier *selectedCarrier = nil;
            DestinationsListTargets *selected = [[destinationsListTargets selectedObjects] lastObject];
            if (selected) selectedCarrier = selected.carrier;
            else selectedCarrier = [[delegate.carriersView.carrier selectedObjects] lastObject];
            if (!selectedCarrier) selectedCarrier = [[delegate.carriersView.carrier arrangedObjects] lastObject];
            if (selectedCarrier) carriers = [NSArray arrayWithObject:selectedCarrier];

            
            //if (!selected) return;
            carriers = [NSArray arrayWithObject:selected.carrier];
            [addDestinationCarriersList setContent:[updateForAddDestinations fillCarriersForAddArrayForCarriers:carriers withRelationShipName:@"destinationsListTargets" forCurrentContent:[addDestinationCarriersList arrangedObjects]]];
            NSPredicate *filterCountryList = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",selected.country,selected.specific];
            NSArray *filteredDestinations = [finalDestinationsList filteredArrayUsingPredicate:filterCountryList];
            if ([filteredDestinations count] > 0) {
                NSMutableDictionary *filteredCountry = [filteredDestinations lastObject];
                [filteredCountry setValue:selected.rate forKey:@"rate"];
                [filteredCountry setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
                filterCountryList = [NSPredicate predicateWithFormat:@"(country != %@) and (specific != %@)",selected.country,selected.specific];
                [finalDestinationsList filterUsingPredicate:filterCountryList];
                [finalDestinationsList addObject:filteredCountry];
                
                
            } else NSLog(@"APP DELEGATE: warning, country:%@ specific:%@ not found in country list",selected.country,selected.specific);   

            proposedRate = selected.rate;
        }
        
        // add destination based on pushlists button
        if ([sender tag] == 4) {
            [self addDestinationsSwitchViewSizeToSmall:YES];
            [addDestinationsStartButton setTag:2];
            Carrier *selectedCarrier = nil;
            DestinationsListPushList *selected = [[destinationsListPushList selectedObjects] lastObject];
            if (selected) selectedCarrier = selected.carrier;
            else selectedCarrier = [[delegate.carriersView.carrier selectedObjects] lastObject];
            if (!selectedCarrier) selectedCarrier = [[delegate.carriersView.carrier arrangedObjects] lastObject];
            if (selectedCarrier) carriers = [NSArray arrayWithObject:selectedCarrier];
            
#if defined(SNOW_CLIENT_APPSTORE)
            if (!selectedCarrier) {
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                CompanyStuff *currentAdmin = [clientController authorization];
                NSSet *allCarriers = currentAdmin.carrier;
                __block NSMutableArray *carriersForCheck = [NSMutableArray arrayWithCapacity:0];
                [allCarriers enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    [carriersForCheck addObject:obj];
                }];
                selectedCarrier = [allCarriers anyObject];
                [clientController release];
            }
            if (!selectedCarrier) {
                NSLog(@"APP DELEGATE: carrier not found to add destination");
                [self showErrorBoxWithText:@"carrier not found to add destination"];
                [addDestinationsButton setEnabled:YES];
                return;
            }
            if (selectedCarrier) carriers = [NSArray arrayWithObject:selectedCarrier];
            
#endif
            [addDestinationCarriersList setContent:[updateForAddDestinations fillCarriersForAddArrayForCarriers:carriers withRelationShipName:@"destinationsListPushList" forCurrentContent:[addDestinationCarriersList arrangedObjects]]];
 
        }
        
        [addDestinationsList setSelectionIndex:0];
        [updateForAddDestinations release];
        
//        if (filterCountryList) { 
//            [finalDestinationsList filterUsingPredicate:filterCountryList];
//            NSMutableDictionary *selected = [filteredCodeList lastObject];
//            [selected setValue:proposedRate forKey:@"rate"];
//            [selected setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
//        }  
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"selected" ascending:NO];
        [finalDestinationsList sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [sortDescriptor release];
        [addDestinationsList setContent:finalDestinationsList];
//        NSLog(@"%@",finalDestinationsList);
                
        [delegate.progressForMainThread stopAddDestinations];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {

            if (!addDestinationsPanel) addDestinationsPanel = [[NSPopover alloc] init];
            frameOfSender = NSMakeRect(frameOfSender.origin.x + 15, frameOfSender.origin.y + 20, frameOfSender.size.width, frameOfSender.size.height);
            
            if (addDestinationsPanel) {
                addDestinationsPanel.contentViewController = addRoutesViewController;
                addDestinationsPanel.behavior = NSPopoverBehaviorApplicationDefined;
                [addDestinationsPanel showRelativeToRect:frameOfSender ofView:self.view preferredEdge:NSMaxYEdge];
            } else
            {
                addDestinationsMainPanel = [[[NSPanel alloc] initWithContentRect:addRoutesViewController.view.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
                [addDestinationsMainPanel.contentView addSubview:addRoutesViewController.view];
                [NSApp beginSheet:addDestinationsMainPanel 
                   modalForWindow:delegate.window
                    modalDelegate:nil 
                   didEndSelector:nil
                      contextInfo:nil];

            }

        });
    });

}

- (IBAction)removeDestinations:(id)sender {
    
    
#if defined(SNOW_CLIENT_APPSTORE) || SNOW_CLIENT_ENTERPRISE
    NSArray *destinations = nil;
    
    if ([sender tag] == 0) {
        
        destinations =  [destinationsListForSale selectedObjects];
        [destinationsListForSale removeObjects:destinations];
        [self finalSaveForMoc:[destinationsListForSale managedObjectContext]];

    }
    if ([sender tag] == 2) {
        destinations =  [destinationsListTargets selectedObjects];
        [destinationsListTargets removeObjects:destinations];
        [self finalSaveForMoc:[destinationsListTargets managedObjectContext]];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
//
//        [moc release];
//        moc = [[NSManagedObjectContext alloc] init];
//        [moc setUndoManager:nil];
//        //[moc setMergePolicy:NSOverwriteMergePolicy];
//        [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
//
//        [destinationsListTargets setManagedObjectContext:moc];
        //NSLog(@"current targets is :%@",[destinationsListTargets arrangedObjects]);
    }

    
    if ([sender tag] == 3) {
        [pushListRemoveDestinations setEnabled:NO];

        destinations =  [destinationsListPushList selectedObjects];
        
        if ([[sender title] isEqualToString:@"Remove local"]) {
            for (id obj in destinations) 
            {
//                [obj removeObserver:self forKeyPath:@"rate"];
//                [obj removeObserver:self forKeyPath:@"asr"];
//                [obj removeObserver:self forKeyPath:@"acd"];
//                [obj removeObserver:self forKeyPath:@"minutesLenght"];
                [destinationsListPushList removeObject:obj];
            }
            
            [self finalSaveForMoc:[destinationsListPushList managedObjectContext]];
            
        } else {
            for (id obj in destinations) {
//                [obj removeObserver:self forKeyPath:@"rate"];
//                [obj removeObserver:self forKeyPath:@"asr"];
//                [obj removeObserver:self forKeyPath:@"acd"];
//                [obj removeObserver:self forKeyPath:@"minutesLenght"];
                //NSLog(@"removed from observe:%@",obj);
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                
                //CompanyStuff *admin = [clientController authorization];
                for (id obj in destinations) {
//                    [obj removeObserver:self forKeyPath:@"rate"];
//                    [obj removeObserver:self forKeyPath:@"asr"];
//                    [obj removeObserver:self forKeyPath:@"acd"];
//                    [obj removeObserver:self forKeyPath:@"minutesLenght"];
                    
                    NSString *guid = [obj valueForKey:@"GUID"];
                    
                    if ([[self localStatusForObjectsWithRootGuid:guid] isEqualToString:@"external server"]) {
//                        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                        if ([delegate.loggingLevel intValue] == 1) NSLog(@"you can't remove server registered destinations");
                        [self showErrorBoxWithText:[NSString stringWithFormat:@"you can't remove server registered destinations"]];
                        
                        continue;
                    }
                    [clientController removeObjectWithID:[obj objectID]];
                    
                    //                if (![[obj valueForKeyPath:@"carrier.companyStuff.currentCompany.companyAdminGUID"] isEqualToString:admin.GUID]) {
                    //                    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                    //                    if ([delegate.loggingLevel intValue] == 1) NSLog(@"you can't remove destinations where u not admin");
                    //                    return;
                    //                } 
                    
                    
                }
                [clientController release];
            });
            
        }
    }
    
#endif
    
#if defined(SNOW_SERVER) 
    NSArray *destinations = nil;
    
    if ([sender tag] == 3) {
        destinations =  [destinationsListPushList selectedObjects];
    }
    if ([sender tag] == 3) [destinationsListPushList removeObjects:destinations];
    [self finalSaveForMoc:[destinationsListPushList managedObjectContext]];
    
    
#endif
    
    
//#ifdef SNOW_CLIENT_ENTERPRISE
//    destinations = nil;
//    
////    if ([sender tag] == 0) {
////        destinations =  [destinationsListForSale selectedObjects];
////        [destinationsListForSale removeObjects:destinations];
////        [self finalSaveForMoc:[destinationsListPushList managedObjectContext]];
////    }
//    
//#endif


}

- (IBAction)addDestinationsAddOutPeerToGroup:(id)sender {
    isAddDestinationsPanelShort = YES;
    NSDictionary *selected = [[addDestinationsList selectedObjects] lastObject];
    NSString *country = [selected valueForKey:@"country"];
    NSString *specific = [selected valueForKey:@"specific"];
    //NSNumber *rate = [selected valueForKey:@"rate"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country == %@ and specific == %@", country,specific];
    
    if ([[addDestinationsWeBuyForChangeOutPeers sortDescriptors] count] == 0) {
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"lastUsedCallAttempts" ascending:NO] autorelease];
        NSSortDescriptor *sortDescriptorRate = [[[NSSortDescriptor alloc] initWithKey:@"rate" ascending:NO] autorelease];
        [addDestinationsWeBuyForChangeOutPeers setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor,sortDescriptorRate,nil]];
    }
    [addDestinationsWeBuyForChangeOutPeers setFilterPredicate:predicate];
    
    if (!addDestinationsChangeOutPeer) addDestinationsChangeOutPeer = [[NSPopover alloc] init];
    if (addDestinationsChangeOutPeer) {
        addDestinationsChangeOutPeer.contentViewController = addDestinationsChangeOutPeerController;
        addDestinationsChangeOutPeer.behavior = NSPopoverBehaviorTransient;
        NSRect frame = addDestinationsAddNewPeerToOutGroupList.frame;
        frame.origin.x -= 60;
        frame.origin.y += 140;
        [addDestinationsChangeOutPeer showRelativeToRect:frame ofView:self.view preferredEdge:NSMinYEdge];
    } else
    {
        addDestinationsChangeOutPeerController.view.frame = NSMakeRect([sender frame].origin.x, [sender frame].origin.y, addDestinationsChangeOutPeerController.view.frame.size.width, addDestinationsChangeOutPeerController.view.frame.size.height);
        [self.view addSubview:addDestinationsChangeOutPeerController.view];
        
    }

    
}

- (IBAction)addDestinationsRemoveOutPeerFromGroup:(id)sender {
    [addDestinationsProgress setHidden:NO];
    [addDestinationsProgress startAnimation:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
//        DestinationsListWeBuy *selected = [[addDestinationsWeBuyForChangeOutPeers selectedObjects] lastObject];
//        CodesvsDestinationsList *anyCode = selected.codesvsDestinationsList.anyObject;
        
        MySQLIXC *databaseForGetGroupsList = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
        UpdateDataController *updateForGetGroupsList = [[UpdateDataController alloc] initWithDatabase:databaseForGetGroupsList];
        
        NSArray *connections = [[NSArray alloc] initWithArray:[updateForGetGroupsList databaseConnections]];
        databaseForGetGroupsList.connections = connections;
        
        NSDictionary *selectedGroup = [[addDestinationsOutGroups selectedObjects] lastObject];
        //NSLog(@"current selected out groups:%@",selectedGroup);
        NSString *groupID = [selectedGroup valueForKey:@"id"];
        NSArray *disabledOutPeers = [addDestinationsOutGroupsOutPeerList selectedObjects];
//        NSArray *enabledOutPeers = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:anyCode.peerID.stringValue,@"outId", nil]];
        
        if (isAddDestinationsPanelShort) disabledOutPeers = nil;
        [databaseForGetGroupsList updateOutGroupsListWithOutPeersListInsideForOutGroup:groupID forEnabledOutPeers:nil forDisabledOutPeers:disabledOutPeers];
        [self updateGroupListStartImmediately:YES];
        isAddDestinationsPanelShort = NO;
        
        [updateForGetGroupsList release], [connections release],[databaseForGetGroupsList release];
    });

}


- (IBAction)copy:(id)sender {
    if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Buy"]) {
        NSArray *selected = [destinationsListWeBuy selectedObjects];
        NSMutableString *stringForCopy = [NSMutableString stringWithCapacity:0];
        NSNumberFormatter *formatterRate = [[NSNumberFormatter alloc] init];
        [formatterRate setFormat:@"#0.0####"];
        
        NSNumberFormatter *formatterACDandMinutes = [[NSNumberFormatter alloc] init];
        [formatterACDandMinutes setFormat:@"#0.0#"];
        
        [selected enumerateObjectsWithOptions:NSSortStable usingBlock:^(DestinationsListWeBuy *object, NSUInteger idx, BOOL *stop) {
            
            [stringForCopy appendFormat:@"%@/%@ $%@",object.country,object.specific,[formatterRate stringFromNumber:object.rate]];
            if (object.lastUsedACD) [stringForCopy appendFormat:@" ACD:%@",[formatterACDandMinutes stringFromNumber:object.lastUsedACD]];
            if (object.lastUsedMinutesLenght) [stringForCopy appendFormat:@" Minutes:%@",[formatterACDandMinutes stringFromNumber:object.lastUsedMinutesLenght]];
            if (object.lastUsedCallAttempts) [stringForCopy appendFormat:@" Attempts:%@",[formatterACDandMinutes stringFromNumber:object.lastUsedCallAttempts]];
//            [stringForCopy appendFormat:@"RatesheetID:%@",object.rateSheetID];
            [stringForCopy appendFormat:@"\n"];
        }];
        [[formatterRate release],formatterACDandMinutes release];
        if (stringForCopy != nil)
        {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            NSArray *copiedObjects = [NSArray arrayWithObject:stringForCopy];
            [pasteboard writeObjects:copiedObjects];
        }
        
    }
    if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Sell"]) {
        NSArray *selected = [destinationsListForSale selectedObjects];
        NSMutableString *stringForCopy = [NSMutableString stringWithCapacity:0];
        NSNumberFormatter *formatterRate = [[NSNumberFormatter alloc] init];
        [formatterRate setFormat:@"#0.0####"];
        
        NSNumberFormatter *formatterACDandMinutes = [[NSNumberFormatter alloc] init];
        [formatterACDandMinutes setFormat:@"#0.0#"];

        [selected enumerateObjectsWithOptions:NSSortStable usingBlock:^(DestinationsListForSale *object, NSUInteger idx, BOOL *stop) {
            [stringForCopy appendFormat:@"%@/%@ $%@",object.country,object.specific,[formatterRate stringFromNumber:object.rate]];
            if (object.lastUsedACD) [stringForCopy appendFormat:@" ACD:%@",[formatterACDandMinutes stringFromNumber:object.lastUsedACD]];
            if (object.lastUsedMinutesLenght) [stringForCopy appendFormat:@" Minutes:%@",[formatterACDandMinutes stringFromNumber:object.lastUsedMinutesLenght]];
            if (object.lastUsedCallAttempts) [stringForCopy appendFormat:@" Attempts:%@",[formatterACDandMinutes stringFromNumber:object.lastUsedCallAttempts]];
            [stringForCopy appendFormat:@"\n"];
        }];
        [[formatterRate release],formatterACDandMinutes release];

        if (stringForCopy != nil)
        {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            NSArray *copiedObjects = [NSArray arrayWithObject:stringForCopy];
            [pasteboard writeObjects:copiedObjects];
        }
        
    }
    if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Targets"]) {
        NSArray *selected = [destinationsListTargets selectedObjects];
        NSMutableString *stringForCopy = [NSMutableString stringWithCapacity:0];
        NSNumberFormatter *formatterRate = [[NSNumberFormatter alloc] init];
        [formatterRate setFormat:@"#0.0####"];
        
        NSNumberFormatter *formatterACDandMinutes = [[NSNumberFormatter alloc] init];
        [formatterACDandMinutes setFormat:@"#0.0#"];

        [selected enumerateObjectsWithOptions:NSSortStable usingBlock:^(DestinationsListTargets *object, NSUInteger idx, BOOL *stop) {
            [stringForCopy appendFormat:@"%@/%@ $%@",object.country,object.specific,[formatterRate stringFromNumber:object.rate]];
            if (object.acd) [stringForCopy appendFormat:@" ACD:%@",[formatterACDandMinutes stringFromNumber:object.acd]];
            if (object.minutesLenght) [stringForCopy appendFormat:@" Minutes:%@",[formatterACDandMinutes stringFromNumber:object.minutesLenght]];
            if (object.callAttempts) [stringForCopy appendFormat:@" Attempts:%@",[formatterACDandMinutes stringFromNumber:object.callAttempts]];
            [stringForCopy appendFormat:@"\n"];
        }];
        [[formatterRate release],formatterACDandMinutes release];

        if (stringForCopy != nil)
        {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            NSArray *copiedObjects = [NSArray arrayWithObject:stringForCopy];
            [pasteboard writeObjects:copiedObjects];
        }
        
    }
    
    if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"PushList"]) {
        NSArray *selected = [destinationsListPushList selectedObjects];
        NSMutableString *stringForCopy = [NSMutableString stringWithCapacity:0];
        NSNumberFormatter *formatterRate = [[NSNumberFormatter alloc] init];
        [formatterRate setFormat:@"#0.0####"];

        NSNumberFormatter *formatterACDandMinutes = [[NSNumberFormatter alloc] init];
        [formatterACDandMinutes setFormat:@"#0.0#"];

        [selected enumerateObjectsWithOptions:NSSortStable usingBlock:^(DestinationsListPushList *object, NSUInteger idx, BOOL *stop) {
            [stringForCopy appendFormat:@"%@/%@ $%@",object.country,object.specific,[formatterRate stringFromNumber:object.rate]];
            if (object.acd) [stringForCopy appendFormat:@" ACD:%@",[formatterACDandMinutes stringFromNumber:object.acd]];
            if (object.minutesLenght) [stringForCopy appendFormat:@" Minutes:%@",[formatterACDandMinutes stringFromNumber:object.minutesLenght]];
            if (object.callAttempts) [stringForCopy appendFormat:@" Attempts:%@",[formatterACDandMinutes stringFromNumber:object.callAttempts]];
            [stringForCopy appendFormat:@"\n"];
        }];
        [[formatterRate release],formatterACDandMinutes release];

        if (stringForCopy != nil)
        {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            NSArray *copiedObjects = [NSArray arrayWithObject:stringForCopy];
            [pasteboard writeObjects:copiedObjects];
        }
        
    }
#if defined(SNOW_CLIENT_APPSTORE)
    NSArray *selected = [destinationsListPushList selectedObjects];
    NSMutableString *stringForCopy = [NSMutableString stringWithCapacity:0];
    NSNumberFormatter *formatterRate = [[NSNumberFormatter alloc] init];
    [formatterRate setFormat:@"#0.0####"];
    
    NSNumberFormatter *formatterACDandMinutes = [[NSNumberFormatter alloc] init];
    [formatterACDandMinutes setFormat:@"#0.0#"];
    
    [selected enumerateObjectsWithOptions:NSSortStable usingBlock:^(DestinationsListPushList *object, NSUInteger idx, BOOL *stop) {
        [stringForCopy appendFormat:@"%@/%@ $%@",object.country,object.specific,[formatterRate stringFromNumber:object.rate]];
        if (object.acd) [stringForCopy appendFormat:@" ACD:%@",[formatterACDandMinutes stringFromNumber:object.acd]];
        if (object.minutesLenght) [stringForCopy appendFormat:@" Minutes:%@",[formatterACDandMinutes stringFromNumber:object.minutesLenght]];
        if (object.callAttempts) [stringForCopy appendFormat:@" Attempts:%@",[formatterACDandMinutes stringFromNumber:object.callAttempts]];
        [stringForCopy appendFormat:@"\n"];
    }];
    [[formatterRate release],formatterACDandMinutes release];
    
    if (stringForCopy != nil)
    {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray *copiedObjects = [NSArray arrayWithObject:stringForCopy];
        [pasteboard writeObjects:copiedObjects];
    }

    
#endif

    
}

#pragma mark - destinations for sale actions

- (IBAction)sendRatesForSelectedDestinations:(id)sender {
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    NSArray *selectedCarriers = [delegate.carriersView.carrier selectedObjects];
    NSArray *selectedDestinations = nil;
    NSButton *send = sender;
    DestinationsListWeBuy *anySelectedWeBuyObject = nil;
    DestinationsListForSale *anySelectedForSellObject = nil;
    
    if ([[send alternateTitle] isEqualToString: @"Send selling rates"]) { 
        selectedDestinations = [destinationsListForSale selectedObjects];
        anySelectedForSellObject = [selectedDestinations lastObject];
    }
    if ([[send alternateTitle] isEqualToString:@"Send buying rates"]) { 
        selectedDestinations = [destinationsListWeBuy selectedObjects];
        anySelectedWeBuyObject = [selectedDestinations lastObject];
    }
    
    
    /*if ([selectedCarriers count] != 1 || [selectedCarriers count] == 0 )
     {
     NSArray *selectedDestinationsForSale = [destinationsListForSale selectedObjects];
     
     NSMutableDictionary *dict = [NSMutableDictionary dictionary];
     NSString *warning = [NSString stringWithFormat:@"HMMM... you like to send rates for more than one carriers once? i didn't hear about is it nessesary"];
     [dict setValue:warning forKey:NSLocalizedDescriptionKey];
     [dict setValue:@"There was an error for insert new destination." forKey:NSLocalizedFailureReasonErrorKey];
     NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
     [[NSApplication sharedApplication] presentError:error];
     return ;
     }*/
    NSString *carrierName = nil;
    NSString *ratesEmail = nil;    
    NSString *companyName = nil;
    NSString *companyRatesEmail = nil;
    
    if ([selectedCarriers count] == 1) {
        Carrier *selectedCarrier = [selectedCarriers lastObject];
        carrierName = selectedCarrier.name;
        ratesEmail = selectedCarrier.ratesEmail;
        companyName = selectedCarrier.companyStuff.currentCompany.name;
        companyRatesEmail = selectedCarrier.companyStuff.currentCompany.ratesEmail;
    } else {
        if ([selectedCarriers count] == 0) {
            
            if (anySelectedForSellObject) {
                carrierName = anySelectedForSellObject.carrier.name;
                ratesEmail = anySelectedForSellObject.carrier.ratesEmail;
                companyName = anySelectedForSellObject.carrier.companyStuff.currentCompany.name;
                companyRatesEmail = anySelectedForSellObject.carrier.companyStuff.currentCompany.ratesEmail;
            }
            if (anySelectedWeBuyObject) {
                carrierName = anySelectedWeBuyObject.carrier.name;
                ratesEmail = anySelectedWeBuyObject.carrier.ratesEmail;
                companyName = anySelectedWeBuyObject.carrier.companyStuff.currentCompany.name;
                companyRatesEmail = anySelectedWeBuyObject.carrier.companyStuff.currentCompany.ratesEmail;
            }
            
        }
    }
    
    if (carrierName) {
        NSArray *parsedResult = [delegate.updateForMainThread destinationsArrayDictionariesToArrayArrays:selectedDestinations];
        NSString *savedURL = [[delegate applicationFilesDirectory].path stringByAppendingString:[NSString stringWithFormat:@"/Rates/%@.%@.%@.xls",carrierName,[send alternateTitle],[NSDate date]]];
        [delegate.updateForMainThread parseToExcelArray:parsedResult withSaveUrl:savedURL];
        [delegate.updateForMainThread sendEmailMessageTo:ratesEmail withSubject:[NSString stringWithFormat:@"Rates from %@",companyName] withContent:@"here is attached rates" withFrom:companyRatesEmail withFilePaths:[NSArray arrayWithObject:savedURL]];
    } else NSLog(@"sendRatesToCustomer: can't be done for selectedCarriers:%@ and selectedDestinations:%@ ",selectedCarriers, selectedDestinations);

}

- (IBAction)getRouting:(id)sender {
    [destinationsForSaleProgress setHidden:NO];
    [destinationsForSaleProgress startAnimation:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        ProgressUpdateController *progress = [[ProgressUpdateController alloc] initWithDelegate:self];
//        [progress startProgressIndicatorCountSeeWebRouting];
//        
        
        NSArray *selectedDestinationForSale = [NSArray arrayWithArray:[destinationsListForSale selectedObjects]];
        //[destinationsListForSale setSelectedObjects:nil];
//        if ([selectedDestinationForSale count] != 1) {
//            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            [dict setValue:@"U can see routing only for one destination" forKey:NSLocalizedDescriptionKey];
//            [dict setValue:@"There was an error when u try to sync while other sync processes coming." forKey:NSLocalizedFailureReasonErrorKey];
//            NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//            [[NSApplication sharedApplication] presentError:error];
//            [progress stopProgressIndicatorCountSeeWebRouting];
//            [progress release];
//            return;
//        }
        if ([selectedDestinationForSale count] != 1) [self showErrorBoxWithText:@"U can see routing only for one destination"];
        
        NSString *carrierName = [[[selectedDestinationForSale lastObject] valueForKey:@"carrier"] valueForKey:@"name"];
        
        NSManagedObject *destinationForSale = [selectedDestinationForSale lastObject];
        NSSet *codes = [destinationForSale valueForKey:@"codesvsDestinationsList"];
        NSManagedObject *code = [codes anyObject];
        if (!code) [self showErrorBoxWithText:@"We don't have any codes for choice"];
        
        NSString *codeStr = [NSString stringWithString:[[code valueForKey:@"code"] stringValue]];
        NSString *countryStr = [NSString stringWithString:[destinationForSale valueForKey:@"country"]];
        NSString *specificStr = [NSString stringWithString:[destinationForSale valueForKey:@"specific"]];
        NSString *prefixStr = [NSString stringWithString:[destinationForSale valueForKey:@"prefix"]];
        
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];

        MySQLIXC *database = [[MySQLIXC alloc] initWithDelegate:nil withProgress:nil];
        database.connections = [delegate.updateForMainThread databaseConnections];
        
        NSArray *routingTable = [database receiveRoutingTableForCode:codeStr 
                                                              prefix:prefixStr 
                                                             carrier:carrierName];
        [database release];
        
        NSLog (@"Routing for Code: %@ for Destination:%@/%@ for Carrier: %@ with prefix:%@ is:%@",
               codeStr,
               countryStr,
               specificStr,
               carrierName,
               prefixStr,
               routingTable
               );
        NSString *uid = [[routingTable lastObject] valueForKey:@"uid"];
        
        //NSString *url = [[database.connections objectAtIndex:0] valueForKey:@"urlForRouting"];
        
        NSString *callPathUrl = [NSString stringWithFormat:@"http://alexv:Manual@avoice447.interexc.com/callpath.php?gw=all&peer=1%%3A%@&dest=%@&anumber=&rprice=&m_date=2012-01-05+15%%3A19%%3A13&proto=5060&xml=0&submit=GO",uid,codeStr];
        
        //[callPathUrlField setStringValue:[NSString stringWithFormat:@"http://alexv:Manual12@a.avoiceweb.interexc.com/callpath.php?gw=2&peer=1%%3A%@&dest=%@&rprice=&m_date=2011-02-03+15%%3A19%%3A13&proto=5060&xml=0&submit=GO",uid,codeStr]];
        NSLog (@"Routing for Code: %@ for Destination:%@/%@ for Carrier: %@ with prefix:%@ is:%@, final url is:%@",
               codeStr,
               countryStr,
               specificStr,
               carrierName,
               prefixStr,
               routingTable,
               callPathUrl
               );
        
        [[callPathWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:callPathUrl]]];
        //NSLog (@"URL: %@",[callPathUrlField stringValue]);
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            [destinationsForSaleProgress setHidden:YES];
            [destinationsForSaleProgress stopAnimation:self];
            [destinationsForSaleCodesStatisticRoutingBlock selectTabViewItemAtIndex:2];
        });

    });

}

#pragma mark - destinations we buy actions

#pragma TODO selection can change while test will processed.
#pragma TODO save doesnt work for test results,moc update dont show results 

- (IBAction)testDestination:(id)sender {
// tag 0 - destinations we buy
    // tag 1 - targets destinations we buy
    //tag 2 - testing results re-test session
    //tag 3 - testing results re-test one number
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

        NSArray *selectedDestinations = nil;

//        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            
            if ([sender tag] == 0) { 
                // here is from destinationWeBuy
                [weBuyProgress setHidden:NO];
                [weBuyProgress startAnimation:self];
                selectedDestinations = [destinationsListWeBuy selectedObjects];
                
            }
            if ([sender tag] == 1) { 
                // here is from destinationWeBuyForTesting
                [routingProgress setHidden:NO];
                [routingProgress startAnimation:self];
                selectedDestinations = [destinationsListWeBuyForTargets selectedObjects];
                
            }
            
//        });
        
        MySQLIXC *databaseForTestDestinations = [[MySQLIXC alloc] initWithDelegate:nil withProgress:nil];
        UpdateDataController *updateForTestDestinations = [[UpdateDataController alloc] initWithDatabase:databaseForTestDestinations];
        databaseForTestDestinations.connections = [updateForTestDestinations databaseConnectionCTP];
        [databaseForTestDestinations release];

        __block NSMutableArray *allDestinationsIDs = [NSMutableArray array];
        [selectedDestinations enumerateObjectsUsingBlock:^(NSManagedObject *destination, NSUInteger idx, BOOL *stop) {
            [allDestinationsIDs addObject:destination.objectID];
        }];
        
        [updateForTestDestinations testDestinations:[NSArray arrayWithArray:allDestinationsIDs]];
        
        sleep(3);
        [self localMocMustUpdate];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            if ([sender tag] == 0) { 
                [weBuyProgress setHidden:YES];
                [weBuyProgress stopAnimation:self];
            }
            if ([sender tag] == 1) { 
                [routingProgress setHidden:YES];
                [routingProgress stopAnimation:self];
            }

        });
        [updateForTestDestinations release];
        
    });
}

#pragma mark - destinations we buy testing actions
- (IBAction)mailToCarrier:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        [delegate.updateForMainThread testResultMailToCustomer:[destinationsListWeBuyTesting selectedObjects]];
    });

}

- (IBAction)reTest:(id)sender {
    // HIDDEN
    [self testDestination:sender];

}
- (IBAction)reTestOneNumber:(id)sender {
    // HIDDEN
    [self testDestination:sender];

}
- (IBAction)showLogs:(id)sender {
    NSString *path = [delegate.updateForMainThread testResultWriteLogToFile:[[destinationsListWeBuyResults selectedObjects] lastObject]];
    if (path) [[NSWorkspace sharedWorkspace] openFile:path];

}

- (IBAction)playRingMediaStop:(id)sender {
    if (self.s) [self.s stop];
    [sender setTitle:@"Play ring media"];
    [sender setAction:@selector(testResultPlayRingMedia:)];
}


- (IBAction)playRingMedia:(id)sender {
    NSDictionary *result = [delegate.updateForMainThread testResultWriteMediaToFile:[[destinationsListWeBuyResults selectedObjects] lastObject]];
    if (result) { 
        NSSound *sound = [[[NSSound alloc] initWithContentsOfFile:[result valueForKey:@"media_ogg_ring"] byReference:NO] autorelease];
        if (sound) {
            s = [[[NSSound alloc] initWithContentsOfFile:[result valueForKey:@"media_ogg_ring"] byReference:NO] autorelease];
            [s play];
            
            [sender setTitle:@"Stop"];
            [sender setAction:@selector(playRingMediaStop:)];
        }
        // [[NSWorkspace sharedWorkspace] openFile:[result valueForKey:@"media_ogg_ring"]];
    }

}
- (IBAction)playMediaStop:(id)sender {
    if (self.s) [self.s stop];
    [sender setTitle:@"Play ring media"];
    [sender setAction:@selector(testResultPlayRingMedia:)];
    
}

- (IBAction)playMedia:(id)sender {
    NSDictionary *result = [delegate.updateForMainThread testResultWriteMediaToFile:[[destinationsListWeBuyResults selectedObjects] lastObject]];
    if (result) { 
        NSSound *sound = [[[NSSound alloc] initWithContentsOfFile:[result valueForKey:@"media_ogg"] byReference:NO] autorelease];
        if (sound) {
            s = [[[NSSound alloc] initWithContentsOfFile:[result valueForKey:@"media_ogg"] byReference:NO] autorelease];
            [s play];
            
            [sender setTitle:@"Stop"];
            [sender setAction:@selector(playMediaStop:)];
        }
        // [[NSWorkspace sharedWorkspace] openFile:[result valueForKey:@"media_ogg_ring"]];
    }

}

#pragma mark - destinations targets actions
//- (IBAction)removeDestination:(id)sender {
//    NSArray *selectedDestinations = [destinationsListTargets selectedObjects];
////    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//    [selectedDestinations enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
//        [destinationsListTargets.managedObjectContext deleteObject:[delegate.managedObjectContext objectWithID:obj.objectID]];
//    }];
//    [self finalSaveForMoc:destinationsListTargets.managedObjectContext];
//    NSLog(@"current targets is :%@",destinationsListTargets);
//}


#pragma mark - destinations pushlist actions
- (IBAction)linkedinSelectedDestinations:(id)sender {
    NSMutableArray *selectedIDs = [NSMutableArray array];
    NSArray *selectedDestintions = destinationsListPushList.selectedObjects; 
    [selectedDestintions enumerateObjectsUsingBlock:^(DestinationsListPushList *destination, NSUInteger idx, BOOL *stop) {
        [selectedIDs addObject:destination.objectID];        
    }];
    [delegate.carriersView postToLinkedinGroups:selectedIDs];
    
}
- (IBAction)twitSelectedDestinations:(id)sender {
    NSMutableArray *selectedIDs = [NSMutableArray array];
    NSArray *selectedDestintions = destinationsListPushList.selectedObjects; 
    [selectedDestintions enumerateObjectsUsingBlock:^(DestinationsListPushList *destination, NSUInteger idx, BOOL *stop) {
        [selectedIDs addObject:destination.objectID];        
    }];
    [delegate.carriersView sendTwitterUpdate:selectedIDs];
}


#pragma mark - testing result actions
- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
{
    [testingResultIPlay1 setEnabled:YES];
    [testingResultIPlay2 setEnabled:YES];
    [testingResultIPlay3 setEnabled:YES];
    [testingResultIPlay4 setEnabled:YES];
    [testingResultIPlay5 setEnabled:YES];
    [testingResultIPlay1 setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];
    [testingResultIPlay2 setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];
    [testingResultIPlay3 setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];
    [testingResultIPlay4 setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];
    [testingResultIPlay5 setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];

}

- (IBAction)startPlayCallRecord:(id)sender {
    NSString *imageName = [[sender image] name];
    if ([imageName isEqualToString:@"NSStopProgressTemplate"]) { 
        [s stop];
        [sender setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];
        return;
    }
    NSArray *selectedDestinations = nil;

    if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Buy"]) { 
        selectedDestinations = destinationsListWeBuy.selectedObjects;
    }
    if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Targets"]) { 
        selectedDestinations = destinationsListWeBuyForTargets.selectedObjects;
    }
    

//    NSArray *selectedDestinations = destinationsListWeBuy.selectedObjects;
    DestinationsListWeBuy *selectedDestination = [selectedDestinations lastObject];
    
    NSSet *allTests = selectedDestination.destinationsListWeBuyTesting;
    
    NSArray *allTestsArray = [allTests allObjects];
    
    NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    NSArray *allTestsArraySorted = [allTestsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
    [sortByDate release];
    
    
    DestinationsListWeBuyTesting *testing = allTestsArraySorted.lastObject;
    //NSLog(@"latest test:%@",testing);
    NSSet *results = testing.destinationsListWeBuyResults;

//    NSUInteger idx = [sender tag];
//    testingResultIPlay1.tag = result.dstnum.integerValue;
    NSUInteger tag = [sender tag];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dstnum == %@",[NSNumber numberWithInteger:tag].stringValue];
   
    NSSet *filteredResults = [results filteredSetUsingPredicate:predicate];
    DestinationsListWeBuyResults *necessaryResult = filteredResults.anyObject;
    
//    NSError *error = nil;
//    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:necessaryResult.media_ogg error:&error];
//    if (error) NSLog(@"error%@",[error localizedDescription]);
//    [player play];
//    NSData *mediaData = necessaryResult.media_ogg;
    
    NSDictionary *result = [delegate.updateForMainThread testResultWriteMediaToFile:necessaryResult];
    s = [[[NSSound alloc] initWithContentsOfFile:[result valueForKey:@"media_ogg"] byReference:NO] autorelease];
    s.name = [NSNumber numberWithInteger:tag].stringValue;
    s.delegate = self;
    
    if (s) {
        [testingResultIPlay1 setEnabled:NO];
        [testingResultIPlay2 setEnabled:NO];
        [testingResultIPlay3 setEnabled:NO];
        [testingResultIPlay4 setEnabled:NO];
        [testingResultIPlay5 setEnabled:NO];
        
        [s play];
//        [sender setTag:0];

        NSButton *button = sender;
        [button setEnabled:YES];
        [sender setImage:[NSImage imageNamed:@"NSStopProgressTemplate"]];
//            [sender setTag:tag];
        //            [sender setImage:[NSImage imageNamed:@"NSRightFacingTriangleTemplate"]];
        
        //        [sender setTitle:@"Stop"];
        //        [sender setAction:@selector(testResultPlayRingMediaStop:)];
    }

}

#pragma mark - NSTabViewDelegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    NSString *selectedLabel = tabViewItem.label;
    
    
    if ([selectedLabel isEqualToString:@"Sell"]) codesvsDestinationsList.content = [destinationsListForSale.selection valueForKey:@"codesvsDestinationsList"];
    if ([selectedLabel isEqualToString:@"Buy"]) codesvsDestinationsList.content = [destinationsListWeBuy.selection valueForKey:@"codesvsDestinationsList"];
    if ([selectedLabel isEqualToString:@"Targets"]) codesvsDestinationsList.content = [destinationsListTargets.selection valueForKey:@"codesvsDestinationsList"];
    if ([selectedLabel isEqualToString:@"Pushlist"]) codesvsDestinationsList.content = [destinationsListPushList.selection valueForKey:@"codesvsDestinationsList"];
    
    if ([selectedLabel isEqualToString:@"Sell"]) destinationPerHourStat.content = [destinationsListForSale.selection valueForKey:@"destinationPerHourStat"];
    if ([selectedLabel isEqualToString:@"Buy"]) destinationPerHourStat.content = [destinationsListWeBuy.selection valueForKey:@"destinationPerHourStat"];
    if ([selectedLabel isEqualToString:@"Targets"]) destinationPerHourStat.content = nil;
    if ([selectedLabel isEqualToString:@"Pushlist"]) destinationPerHourStat.content = nil;

    if ([selectedLabel isEqualToString:@"Targets"]) { 
        DestinationsListTargets *selected = [[destinationsListTargets selectedObjects] lastObject];
        NSNumber *comparingRate = [NSNumber numberWithDouble:([selected.rate doubleValue] * 1.3)];
        [destinationsListWeBuyForTargets setFilterPredicate:[NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)  AND (rate < %@)",selected.country,selected.specific,comparingRate]]; 
    }
}

#pragma mark - NSTableViewDelegate
// table numeration:
// from 0 Sell 10 buy 20 targets 30 pushlist
// from 100 addDestinations
// from 200  importDestinations

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if ([aTableView tag] < 100) {
        
        if ([[aTableColumn identifier] isEqualToString:@"Testing result"]) {
            
            NSManagedObject *selected = nil;
            
            if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Buy"]) { 
                selected = [[destinationsListWeBuy arrangedObjects] objectAtIndex:rowIndex];
            }
            if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Targets"]) { 
                selected = [[destinationsListWeBuyForTargets arrangedObjects] objectAtIndex:rowIndex];
                
            }
            
            if ([[selected valueForKey:@"testingRestultInfo"] length] < 1) { 
                [aCell setBordered:NO];
                [aCell setBezeled:NO];
            } else {
                [aCell setBordered:YES];
                [aCell setBezeled:YES];
            }
        }
    }
}


- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    
    // main view tableviews

    if ([aTableView tag] < 100) {
        
        if ([aTableView tag] == 0) {             
            
            if ([[destinationsListForSale arrangedObjects] count] < rowIndex) return NO;
            
            DestinationsListForSale *selected = [[destinationsListForSale arrangedObjects] objectAtIndex:rowIndex];
            //[destinationsListForSale setFilterPredicate:nil];
            [delegate.carriersView.carrier setSelectedObjects:[NSArray arrayWithObject:selected.carrier]];
            
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"dd MMM"];
            [changedDate setTitle:[formatter stringFromDate:selected.changeDate]];
            
            [enabled setTitle:selected.enabled ? @"Enabled" : @"Disabled"];
            [prefix setTitle:selected.prefix];
            [rateSheetList setTitle:selected.rateSheet];
            [puslist setTitle:selected.postInSalesChat ? @"SalesChat" : @""];
            
            CodesvsDestinationsList *anyCode = selected.codesvsDestinationsList.anyObject;
            
            [codesPeerID setTitle:[NSString stringWithFormat:@"PeerID:%@",anyCode.peerID]];
            [codesRateSheetID setTitle:[NSString stringWithFormat:@"RatesheetID:%@",anyCode.rateSheetID]];
            
            NSMutableDictionary *tableOfIVRConfig = [delegate.updateForMainThread getIVRConfigurationTable];
            
            NSMutableDictionary *carrierDestinationsList = [tableOfIVRConfig valueForKey:selected.carrier.name];
            NSString *destinationCountryAndSpecific = [NSString stringWithFormat:@"%@/%@",selected.country,selected.specific];
            
            NSMutableString *currentLinesAndPercent = [carrierDestinationsList valueForKey:destinationCountryAndSpecific];
            [ivr setTitle:currentLinesAndPercent];
            [destinationsListForSale setSelectionIndex:rowIndex];
            
            codesvsDestinationsList.content = [destinationsListForSale.selection valueForKey:@"codesvsDestinationsList"];
            destinationPerHourStat.content = [destinationsListForSale.selection valueForKey:@"destinationPerHourStat"];
            
        }

        if ([aTableView tag] == 1) { 
            [codesvsDestinationsList setSelectionIndex:rowIndex];
            CodesvsDestinationsList *selected = [[codesvsDestinationsList selectedObjects] lastObject];
            [codesPeerID setTitle:[NSString stringWithFormat:@"PeerID:%@",[selected.peerID stringValue]]];
            [codesRateSheetID setTitle:[NSString stringWithFormat:@"RatesheetID:%@",selected.rateSheetID]];
            [codesRatesheet setTitle:[NSString stringWithFormat:@"Ratesheet name:%@",selected.rateSheetName]];
            
        }
        
        if ([aTableView tag] == 10) {             
            if ([[destinationsListWeBuy arrangedObjects] count] < rowIndex) return NO;
            DestinationsListWeBuy *selected = [[destinationsListWeBuy arrangedObjects] objectAtIndex:rowIndex];
            [delegate.carriersView.carrier setSelectedObjects:[NSArray arrayWithObject:selected.carrier]];
            
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"dd MMM"];
            [weBuyChangedDate setTitle:[formatter stringFromDate:selected.changeDate]];
            
            [weBuyEnabled setTitle:selected.enabled ? @"Enabled" : @"Disabled"];
            [weBuyPrefix setTitle:selected.prefix];
            [weBuyRatesheet setTitle:selected.rateSheet];
            
            CodesvsDestinationsList *anyCode = selected.codesvsDestinationsList.anyObject;
            
            [weBuyCodesPeerID setTitle:[NSString stringWithFormat:@"PeerID:%@",anyCode.peerID]];
            [weBuyCodesRateSheetID setTitle:[NSString stringWithFormat:@"RatesheetID:%@",anyCode.rateSheetID]];

            if (selected.postInSalesChat == [NSNumber numberWithBool:YES]) [weBuyPushlist setTitle:@"SalesChat"];
            else [weBuyPushlist setTitle:@""];
            //NSLog(@"%@, %@",[destinationsListWeBuySalesChat title],selected.postInSalesChat);
            [destinationsListWeBuy setSelectionIndex:rowIndex];
            
            codesvsDestinationsList.content = [destinationsListWeBuy.selection valueForKey:@"codesvsDestinationsList"];
            destinationPerHourStat.content = [destinationsListWeBuy.selection valueForKey:@"destinationPerHourStat"];
            
        }
        if ([aTableView tag] == 11) {    
            [codesvsDestinationsList setSelectionIndex:rowIndex];
            CodesvsDestinationsList *selected = [[codesvsDestinationsList selectedObjects] lastObject];
            [weBuyCodesPeerID setTitle:[NSString stringWithFormat:@"PeerID:%@",[selected.peerID stringValue]]];
            [weBuyCodesRateSheetID setTitle:[NSString stringWithFormat:@"RatesheetID:%@",selected.rateSheetID]];
            [weBuyCodesRatesheet setTitle:[NSString stringWithFormat:@"Ratesheet name:%@",selected.rateSheetName]];

        }
        
        if ([aTableView tag] == 20) {             
            
            
            //            NSLog(@"DESTINATIONS VIEW:selected targets have codes:%@",[NSNumber numberWithInteger:[destinationsTargetsListListInfo state]]);
            
            // targets main table
            //            if ([aTableView tag] == 20) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                
                DestinationsListTargets *selected = [[destinationsListTargets arrangedObjects] objectAtIndex:rowIndex];
                //NSSet *allCodes = selected.codesvsDestinationsList;
                //NSLog(@"DESTINATIONS VIEW:selected targets have code:%@",[allCodes anyObject]);
                [codesvsDestinationsList setContent:selected.codesvsDestinationsList];
                [delegate.carriersView.carrier setSelectedObjects:[NSArray arrayWithObject:selected.carrier]];
                NSNumber *comparingRate = [NSNumber numberWithDouble:([selected.rate doubleValue] * 1.3)];
                //NSLog(@"%@",[[destinationsListWeBuyForTargets arrangedObjects] lastObject]);
                [destinationsListWeBuyForTargets setFilterPredicate:[NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)  AND (rate < %@)",selected.country,selected.specific,comparingRate]]; 
                //NSLog(@"%@",[[destinationsListWeBuyForTargets arrangedObjects] lastObject]);
                //NSLog(@"Predicate:%@",[destinationsListWeBuyForTargets filterPredicate]);
                
                Carrier *carrierForCheck = selected.carrier;
                NSSet *destinationsForSale = carrierForCheck.destinationsListForSale;
                __block BOOL updated = NO;
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setPositiveFormat:@"$0.#####"];
                if ([destinationsForSale count] > 0) {
                    [destinationsForSale enumerateObjectsWithOptions:NSSortStable usingBlock:^(DestinationsListForSale *checking , BOOL *stop) {
                        if ([selected.country isEqualToString:checking.country] && [selected.specific isEqualToString:checking.specific]) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                                [targetsInfo setTitle:[NSString stringWithFormat:@"opened with rate: %@, click it",[formatter stringFromNumber:checking.rate]]]; });
                            updated = YES;
                            *stop = YES;
                        }
                    }];
                }
                [formatter release];
                if (!updated) dispatch_async(dispatch_get_main_queue(), ^(void) { [targetsInfo setTitle:@""];});
            });
            
        }
        
        // destinations we buy for targets
        if ([aTableView tag] == 21) {
            DestinationsListWeBuy *selected = [[destinationsListWeBuyForTargets arrangedObjects] objectAtIndex:rowIndex];
            if (!selected) return NO;
            //                AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
            
            //[selected addObserver:delegate forKeyPath:@"selectionTestingResult" options:NSKeyValueObservingOptionNew context:nil];
            
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            [formatter setDateFormat:@"dd MMM"];
            [routingChangedDate setTitle:[formatter stringFromDate:selected.changeDate]];
            
            [routingEnabled setTitle:selected.enabled ? @"Enabled" : @"Disabled"];
            [routingPrefix setTitle:selected.prefix];
            [routingRateSheet setTitle:selected.rateSheet];
            [routingPushList setTitle:selected.postInSalesChat ? @"SalesChat" : @""];
        }
        //        }
        
        if ([aTableView tag] == 30) {
            DestinationsListPushList *selected = [[destinationsListPushList arrangedObjects] objectAtIndex:rowIndex];
            NSString *statusDestinationsListPushList = [self localStatusForObjectsWithRootGuid:selected.GUID];
            [pushListInfo setTitle:statusDestinationsListPushList];
            [codesvsDestinationsList setContent:selected.codesvsDestinationsList];

        } 
//            if (currentObservedDestination) { 
//                //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//#if defined(SNOW_CLIENT_APPSTORE) || defined(SNOW_CLIENT_ENTERPRISE)
////                DestinationsListPushList *previousSelected = [[destinationsListPushList arrangedObjects] objectAtIndex:previousSelectedIndex];
//                DestinationsListPushList *previousSelected = (DestinationsListPushList *)[self.moc objectWithID:currentObservedDestination];
//                [[destinationsListPushList arrangedObjects] indexOfObject:previousSelected];
//                
//                [previousSelected removeObserver:self forKeyPath:@"rate"];
//                [previousSelected removeObserver:self forKeyPath:@"asr"];
//                [previousSelected removeObserver:self forKeyPath:@"acd"];
//                [previousSelected removeObserver:self forKeyPath:@"minutesLenght"];
//                // registration is here
//                if ([previousSelected isUpdated]) {
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                        
////                        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//                        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//                        if ([[self localStatusForObjectsWithRootGuid:previousSelected.carrier.GUID] isEqualToString:@"registered"] && [[self localStatusForObjectsWithRootGuid:previousSelected.carrier.companyStuff.GUID] isEqualToString:@"registered"]) [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[previousSelected objectID]] mustBeApproved:NO];
//                        else [self showErrorBoxWithText:@"carrier or admin not registered on server, just do it to make changes"];
//                        [clientController release];
//                    });
//                    
//                }
//                
//            }
//            DestinationsListPushList *selected = [[destinationsListPushList arrangedObjects] objectAtIndex:rowIndex];
////            DestinationsListPushList *currentSelected = (DestinationsListPushList *)[self.moc objectWithID:currentSelected.objectID];
//
////            [currentSelected addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
////            [currentSelected addObserver:self forKeyPath:@"asr" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
////            [currentSelected addObserver:self forKeyPath:@"acd" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
////            [currentSelected addObserver:self forKeyPath:@"minutesLenght" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//            currentObservedDestination = selected.objectID;
//            
//            // in case we must delete other routes from observer:
//            //previousSelectedIndex = rowIndex;
//            NSString *statusDestinationsListPushList = [self localStatusForObjectsWithRootGuid:selected.GUID];
//            [pushListInfo setTitle:statusDestinationsListPushList];
//#endif
//            
//#if defined(SNOW_SERVER)
//        }
//#endif
//    }
}    
// add destinations list

    if ([aTableView tag] == 100) {
#if defined (SNOW_CLIENT_ENTERPRISE)

        [addDestinationsProgress setHidden:NO];
        [addDestinationsProgress startAnimation:self];
#endif
        [addDestinationsList setSelectionIndex:rowIndex];
        [self updateGroupListStartImmediately:NO];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
//            MySQLIXC *databaseForGetGroupsList = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
//            UpdateDataController *updateForGetGroupsList = [[UpdateDataController alloc] initWithDatabase:databaseForGetGroupsList];
//
//            NSArray *connections = [[NSArray alloc] initWithArray:[updateForGetGroupsList databaseConnections]];
//            databaseForGetGroupsList.connections = connections;
////            [addDestinationsList setSelectionIndex:rowIndex];
//            NSString *country = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"country"];
//            NSString *specific = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"specific"];
//            NSDate *groupDateUpdates = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"outGroupsUpdateTime"];
//            NSDate *groupDateUpdatesPlus24H = [groupDateUpdates dateByAddingTimeInterval:86400];
//            if (!groupDateUpdates || [groupDateUpdatesPlus24H timeIntervalSinceDate:[NSDate date]] < 0) {
//                NSArray *outGroups = [databaseForGetGroupsList getOutGroupsListWithOutPeersListInsideForCountry:country forSpecific:specific];
//                
//                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    [addDestinationsProgress setHidden:YES];
//                    [addDestinationsProgress stopAnimation:self];
//                    
//                    NSMutableDictionary *selectedDestination = [[addDestinationsList selectedObjects] lastObject];
//                    [selectedDestination setValue:outGroups forKey:@"outGroups"];
//                    [selectedDestination setValue:[NSDate date] forKey:@"outGroupsUpdateTime"];
//                    
//                    NSLog(@"DESTINATIONS VIEW:new groups is:%@",outGroups);
//                    NSString *pathForSaveArray = [[delegate applicationSupportDirectory] stringByAppendingString:@"/myCountrySpecificCodeList.ary"];
//                    NSArray *allContent = [addDestinationsList arrangedObjects];
//                    BOOL error = [allContent writeToFile:pathForSaveArray atomically:YES];
//                    if (!error) NSLog(@"DESTINATIONS VIEW:write to file error");
//
//                });
//            } else { 
//                [addDestinationsProgress setHidden:YES];
//                [addDestinationsProgress stopAnimation:self];
//                
//                NSLog(@"DESTINATIONS VIEW: update was not, waiting 24 hours");
//            }
//        });
    }

// group list selected
    
    if ([aTableView tag] == 101) {
        [addDestinationsStepper setIncrement:0.01];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

            NSArray *outGroupsContent = [addDestinationsOutGroups arrangedObjects] ;
            
            NSMutableDictionary *selectedGroup = [outGroupsContent objectAtIndex:rowIndex];
            NSString *country = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"country"];
            NSString *specific = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"specific"];
            NSNumber *rateForOpen = [[[addDestinationsList selectedObjects] lastObject] valueForKey:@"rate"];
            
//            MySQLIXC *databaseForDaylySync = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
            
            NSMutableArray *outPeerList = [selectedGroup valueForKey:@"outPeerList"];
            //        appDelegate = [[NSApplication sharedApplication] delegate];
            //NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CodesvsDestinationsList" inManagedObjectContext:delegate.managedObjectContext];
            
            NSMutableArray *newOutPeerList = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *ratesCollection = [NSMutableArray arrayWithCapacity:0];
            
            for (NSMutableDictionary *outPeer in outPeerList) {
                NSMutableDictionary *newOutPeer = [NSMutableDictionary dictionaryWithDictionary:outPeer];
                [fetchRequest setEntity:entity];
                NSString *outId = [outPeer valueForKey:@"outId"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(peerID == %@) AND (country == %@) AND (specific == %@)",
                                          outId,country,specific];
                
                [fetchRequest setPredicate:predicate];
                NSError *error = nil;
                NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
                CodesvsDestinationsList *oneCode = [fetchedObjects lastObject];
                if (!oneCode) { 
//                    dispatch_async(dispatch_get_main_queue(), ^(void) {
//                        
//                        [addDestinationsProgress setHidden:NO];
//                        [addDestinationsProgress startAnimation:self];
//                        [addDestinationsOutGroups setSelectionIndex:rowIndex];
//                        
//                    });
//                    NSLog(@"DESTINATIONS VIEW: warning, code not found for country:%@, specific:%@ and peerID = %@",country,specific,outId);
//                    MySQLIXC *databaseForGetGroupsList = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
//                    UpdateDataController *updateForGetGroupsList = [[UpdateDataController alloc] initWithDatabase:databaseForGetGroupsList];
//                    
//                    NSArray *connections = [[NSArray alloc] initWithArray:[updateForGetGroupsList databaseConnections]];
//                    databaseForGetGroupsList.connections = connections;
//
//                    NSArray *allGroupsForThisCountry = [databaseForGetGroupsList getOutGroupsListWithOutPeersListInsideForCountry:country forSpecific:specific];
//                    NSMutableDictionary *selectedOutGroup = [allGroupsForThisCountry objectAtIndex:rowIndex];
                    
                    [self updateGroupListStartImmediately:NO];
                } else {
                    DestinationsListWeBuy *destination = oneCode.destinationsListWeBuy;
                    NSString *carrierName = [destination valueForKeyPath:@"carrier.name"];
                    NSString *rateSheet = [destination valueForKey:@"rateSheet"];
                    NSString *prefixDestination = [destination valueForKey:@"prefix"];
                    
                    NSNumber *rate = [destination valueForKey:@"rate"];
                    [ratesCollection addObject:[NSDictionary dictionaryWithObjectsAndKeys:rate,@"rate", nil]];
                    
                    NSNumber *acd = [destination valueForKey:@"lastUsedACD"];
                    NSNumber *attempts = [destination valueForKey:@"lastUsedCallAttempts"];
                    
                    if (!carrierName) { 
                        carrierName = [NSString stringWithFormat:@"firstName:%@",[outPeer valueForKey:@"firstName"]];
                        rateSheet = [NSString stringWithFormat:@"secondName:%@ OutPeerID:",[outPeer valueForKey:@"secondName"]];
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        rate = [formatter numberFromString:[outPeer valueForKey:@"outId"]];
                        [formatter release], formatter = nil;
                    }
                    [newOutPeer setValue:carrierName forKey:@"carrierName"];
                    [newOutPeer setValue:rateSheet forKey:@"rateSheet"];
                    [newOutPeer setValue:prefixDestination forKey:@"prefix"];
                    [newOutPeer setValue:rate forKey:@"rate"];
                    [newOutPeer setValue:acd forKey:@"acd"];
                    [newOutPeer setValue:attempts forKey:@"attempts"];
                    
//                    [newOutPeer addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
                    [newOutPeerList addObject:newOutPeer];
                }
            }
            
    //        [selectedGroup setValue:newOutPeerList forKey:@"outPeerList"];
    //        [addDestinationsOutGroupsOutPeerList rearrangeObjects];
            [fetchRequest release];
            
            NSNumber *maxRate = [ratesCollection valueForKeyPath:@"@max.rate"];
            double devide = [maxRate doubleValue]/[rateForOpen doubleValue] - 1 ;
            if (devide < 0) devide = 0;
        });
    }

// carriers list selected

    if ([aTableView tag] == 103) {
        [addDestinationsList setSelectionIndex:rowIndex];
        NSMutableDictionary *selectedCarrier = [[addDestinationCarriersList arrangedObjects] objectAtIndex:rowIndex];
        //NSString *guidOfSelectedCarrier = [selectedCarrier valueForKey:@"GUID"];
        //NSLog(@"DESTINATIONS VIEW: selectedCarrier is:%@",selectedCarrier);
        NSManagedObjectID *selectedCarrierID = [selectedCarrier valueForKey:@"objectID"];
        
        MySQLIXC *databaseForDaylySync = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
        NSArray *connections = [[NSArray alloc] initWithArray:[delegate.updateForMainThread databaseConnections]];
        databaseForDaylySync.connections = connections;
        [connections release];
        
        UpdateDataController *updateEveryDaySync = [[UpdateDataController alloc] initWithDatabase:databaseForDaylySync];
        
        NSArray *rateSheetListForCarrier = [updateEveryDaySync getRateSheetsAndPrefixListToChoiceByUserForCarrierID:selectedCarrierID withRelationShipName:@"destinationsListForSale"];
        NSMutableArray *rateSheetsAndPrefixesTogether = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *rateSheetAndPrefix in rateSheetListForCarrier)
        {
            NSMutableDictionary *rateSheetAndPrefixMut = [NSMutableDictionary dictionaryWithDictionary:rateSheetAndPrefix];
            [rateSheetAndPrefixMut setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [rateSheetsAndPrefixesTogether addObject:rateSheetAndPrefixMut];
        }
        
        [selectedCarrier setValue:rateSheetsAndPrefixesTogether forKey:@"rateSheetsAndPrefixes"];
        //NSLog(@"DESTINATIONS VIEW: selectedCarrier after update is:%@",selectedCarrier);

//        NSLog(@"AddDestinationsCheckOutGroupTableViewDelegate: rateSheetsAndPrefixes was set to:%@",rateSheetsAndPrefixesTogether);
        NSString *pathFileToSave = [[delegate applicationFilesDirectory].path stringByAppendingString:@"/carrierListForAddDestination.ary"];
        [[addDestinationCarriersList arrangedObjects] writeToFile:pathFileToSave atomically:YES];
        [databaseForDaylySync release];
        [updateEveryDaySync release];
        
    }

// change out peer group popup select
    if ([aTableView tag] == 104) {
        [addDestinationsChangeOutPeer close];
        [addDestinationsWeBuyForChangeOutPeers setSelectionIndex:rowIndex];
        [addDestinationsProgress setHidden:NO];
        [addDestinationsProgress startAnimation:self];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            DestinationsListWeBuy *selected = [[addDestinationsWeBuyForChangeOutPeers selectedObjects] lastObject];
            CodesvsDestinationsList *anyCode = selected.codesvsDestinationsList.anyObject;
            
            MySQLIXC *databaseForGetGroupsList = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
            UpdateDataController *updateForGetGroupsList = [[UpdateDataController alloc] initWithDatabase:databaseForGetGroupsList];
            
            NSArray *connections = [[NSArray alloc] initWithArray:[updateForGetGroupsList databaseConnections]];
            databaseForGetGroupsList.connections = connections;
            [connections release];
            
            NSDictionary *selectedGroup = [[addDestinationsOutGroups selectedObjects] lastObject];
            //NSLog(@"current selected out groups:%@",selectedGroup);
            NSString *groupID = [selectedGroup valueForKey:@"id"];
            NSArray *disabledOutPeers = [addDestinationsOutGroupsOutPeerList selectedObjects];
            NSArray *enabledOutPeers = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:anyCode.peerID.stringValue,@"outId", nil]];
            
            if (isAddDestinationsPanelShort) disabledOutPeers = nil;
            [databaseForGetGroupsList updateOutGroupsListWithOutPeersListInsideForOutGroup:groupID forEnabledOutPeers:enabledOutPeers forDisabledOutPeers:disabledOutPeers];
            [self updateGroupListStartImmediately:YES];
            isAddDestinationsPanelShort = NO;
            [databaseForGetGroupsList release];
            [updateForGetGroupsList release];
            
        });
    }


// importRatesSecondParsedResult

//    if ([aTableView tag] == 201) {
//        NSMutableDictionary *row = [[importRatesSecondParserResult arrangedObjects ] objectAtIndex:rowIndex];
//        //NSArray *codeList = [row valueForKey:@"codes"];
//        NSString *countryFirstVersion = [row valueForKey:@"country"];
//        NSString *specificFirstVersion = [row valueForKey:@"specific"];
//        if (!specificFirstVersion) specificFirstVersion = @"";
//        NSArray *userSpecificDictionaries = [[NSUserDefaults standardUserDefaults] valueForKey:@"userSpecificDictionaries"];
//        __block NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(externalCountry == %@) and (externalSpecific == %@)",countryFirstVersion,specificFirstVersion];
//        NSArray *filteredUserSpecificDictionaries = [userSpecificDictionaries filteredArrayUsingPredicate:predicate];
//        
//        if ([filteredUserSpecificDictionaries count] > 0) {
//            //NSDictionary *userSpecififcDictionary = [filteredUserSpecificDictionaries lastObject];
////            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//            //NSManagedObjectContext *moc = [delegate managedObjectContext];
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList"
//                                                      inManagedObjectContext:moc];
//            [fetchRequest setEntity:entity];
//            //NSArray *fetchedObjectsForTest = [moc executeFetchRequest:fetchRequest error:nil];
//            /*[fetchedObjectsForTest enumerateObjectsWithOptions:NSSortConcurrent usingBlock:^(CountrySpecificCodeList *obj, NSUInteger idx, BOOL *stop) {
//             NSLog(@"%@/%@",obj.country,obj.specific);
//             }];*/
//            //NSMutableDictionary *row = [[importedCSVparsedSource selectedObjects ] lastObject];
//            NSMutableArray *finalCodesList = [NSMutableArray arrayWithCapacity:0];
//            //arrayWithArray:[row valueForKey:@"codes"]];
//            
//            [filteredUserSpecificDictionaries enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *userSpecificDictionary, NSUInteger idx, BOOL *stop) {
//                
//                
//                NSString *localCountry = [userSpecificDictionary valueForKey:@"localCountry"];
//                NSString *localSpecific = [userSpecificDictionary valueForKey:@"localSpecific"];
//                
//                
//                predicate = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",localCountry,localSpecific];
//                [fetchRequest setPredicate:predicate];
//                
//                NSError *error = nil;
//                NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
//                CountrySpecificCodeList *fetchedList = [fetchedObjects lastObject];
//                NSSet *codes = fetchedList.codesList;
//                
//                [codes enumerateObjectsWithOptions:NSSortStable usingBlock:^(CodesList *codesList, BOOL *stop) {
//                    
//                    //for (NSString *code in codes) {
//                    NSDictionary *codeRow = [NSDictionary dictionaryWithObjectsAndKeys:[codesList.code stringValue],@"code", nil];
//                    
//                    
//                    [finalCodesList addObject:codeRow];
//                    //}
//                    
//                }];
//                
//            }];
//            [row setValue:finalCodesList forKey:@"codes"];
//            
//            [fetchRequest release];
//            
//        }
//        
//        //if ([[proposeCountryToSelect itemArray] count] == 1)
//        //{
//        //NSLog(@"PARSING RESULT VIEW: add items");
//        NSString *countryWithoutMinus = [countryFirstVersion stringByReplacingOccurrencesOfString:@"-" withString:@" "];
//        NSArray *countryAllWorlds = [countryWithoutMinus componentsSeparatedByString:@" "];
//        importRatesSelectedCountryForParsing = [countryAllWorlds objectAtIndex:0];
//        predicate = [NSPredicate predicateWithFormat:@"country contains[cd] %@",importRatesSelectedCountryForParsing];
//        NSArray *result = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:predicate];
//        predicate = [NSPredicate predicateWithFormat:@"specific contains[cd] %@",specificFirstVersion];
//        NSArray *requltWithSpecific = [result filteredArrayUsingPredicate:predicate];
//        if ([requltWithSpecific count] == 0) 
//        {
//            [importRatesDestinationChoice removeAllItems];
//            [importRatesDestinationChoice addItemWithTitle:@"PLEASE SELECT"];
//            [importRatesDestinationChoice addItemWithTitle:@"SELECT ALL"];
//            [importRatesDestinationChoice addItemWithTitle:@"DESELECT ALL"];
//            
//            for (NSDictionary *countryDict in result)
//            {
//                NSString *localCountry = [countryDict valueForKey:@"country"];
//                NSString *localSpecific = [countryDict valueForKey:@"specific"];
//                
//                NSArray *presentInSaved = [filteredUserSpecificDictionaries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@)",localCountry,localSpecific]];
//                
//                NSString *addOrRemove = nil;
//                if ([presentInSaved count] == 0) addOrRemove = @"ADD";
//                else addOrRemove = @"REMOVE";
//                
//                [importRatesDestinationChoice addItemWithTitle:[NSString stringWithFormat:@"%@: %@/%@",addOrRemove,localCountry,localSpecific]];
//                
//            }
//        } else 
//        {
//            [importRatesDestinationChoice removeAllItems];
//            [importRatesDestinationChoice addItemWithTitle:@"PLEASE SELECT"];
//            [importRatesDestinationChoice addItemWithTitle:@"DESELECT ALL"];
//            
//            for (NSDictionary *countryDict in requltWithSpecific)
//            {
//                NSString *localCountry = [countryDict valueForKey:@"country"];
//                NSString *localSpecific = [countryDict valueForKey:@"specific"];
//                
//                NSArray *presentInSaved = [filteredUserSpecificDictionaries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@)",localCountry,localSpecific]];
//                
//                NSString *addOrRemove = nil;
//                if ([presentInSaved count] == 0) addOrRemove = @"ADD";
//                else addOrRemove = @"REMOVE";
//                [importRatesDestinationChoice addItemWithTitle:[NSString stringWithFormat:@"%@: %@/%@",addOrRemove,localCountry,localSpecific]];
//                
//            }
//            
//        }
//        //}
//        return YES;
//
//    }
return YES;

}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if ([aTableView tag] < 100) {
        
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
        if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Pushlist"]) {
            DestinationsListPushList *selected = [[destinationsListPushList arrangedObjects] objectAtIndex:rowIndex];
            //DestinationsListPushList *selected = (DestinationsListPushList *)[self.moc objectWithID:selectedFromMainMoc.objectID];
            
//            AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
            
            CompanyStuff *localStuff = [clientController authorization];
            [clientController release];
            
            //        CompanyStuff *localStuff = [userController authorization];
            if ([selected.carrier.companyStuff.GUID isEqualToString:localStuff.GUID]) {
                if ([[[aTableColumn headerCell] title] isEqualToString:@"Rate"] || [[[aTableColumn headerCell] title] isEqualToString:@"ASR"] || [[[aTableColumn headerCell] title] isEqualToString:@"ACD"] || [[[aTableColumn headerCell] title] isEqualToString:@"Lenght"]) {
                    if (currentObservedDestination) { 
                        //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                        DestinationsListPushList *previousSelected = (DestinationsListPushList *)[delegate.managedObjectContext objectWithID:currentObservedDestination];//[[destinationsListPushList arrangedObjects] objectAtIndex:previousSelectedIndex];
                        //#if defined(SNOW_CLIENT_APPSTORE)|| defined (SNOW_CLIENT_ENTERPRISE)

                        [previousSelected removeObserver:self forKeyPath:@"rate"];
                        [previousSelected removeObserver:self forKeyPath:@"asr"];
                        [previousSelected removeObserver:self forKeyPath:@"acd"];
                        [previousSelected removeObserver:self forKeyPath:@"minutesLenght"];
                        // registration is here
//                        if ([previousSelected isUpdated]) {
//                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                                
//                                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//                                if ([[self localStatusForObjectsWithRootGuid:previousSelected.carrier.GUID] isEqualToString:@"registered"] && [[self localStatusForObjectsWithRootGuid:previousSelected.carrier.companyStuff.GUID] isEqualToString:@"registered"]) [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[previousSelected objectID]] mustBeApproved:NO];
//                                else [self showErrorBoxWithText:@"carrier or admin not registered on server, just do it to make changes"];
//                                [clientController release];
//                            });
//                        }
                        
                    }
                    [selected addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                    [selected addObserver:self forKeyPath:@"asr" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                    [selected addObserver:self forKeyPath:@"acd" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                    [selected addObserver:self forKeyPath:@"minutesLenght" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
                    currentObservedDestination = selected.objectID;
//                    NSLog(@"DESTINATIONS VIEW:add to observer destination:%@/%@ object:%@",selected.country,selected.specific,[selected description]);

                    // in case we must delete other routes from observer:
                    //previousSelectedIndex = rowIndex;
                    NSString *statusDestinationsListPushList = [self localStatusForObjectsWithRootGuid:selected.GUID];
                    [pushListInfo setTitle:statusDestinationsListPushList];
                    //#endif
                    
                    return YES;
                } else {
                    NSLog(@"CLIENT:wrong edited column");
                    return NO;
                }
            } else {
                NSLog(@"CLIENT:wrong user to edit this column");
                return NO;
            }
        }
#endif
        
#ifdef SNOW_CLIENT_ENTERPRISE
        if ([[aTableColumn identifier] isEqualToString:@"Testing result"]) {
            
            NSManagedObject *selected = nil;
            NSView *viewForPopover = nil;
            if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Buy"]) { 
                selected = [[destinationsListWeBuy arrangedObjects] objectAtIndex:rowIndex];
                destinationsListWeBuy.selectionIndex = rowIndex;
                viewForPopover = self.weBuyTableView;
            }
            if ([[[destinationsTab selectedTabViewItem] label] isEqualToString:@"Targets"]) { 
                selected = [[destinationsListWeBuyForTargets arrangedObjects] objectAtIndex:rowIndex];
                viewForPopover = self.targetsRoutingTableView;
            }
            
            if ([[selected valueForKey:@"testingRestultInfo"] length] < 1) return NO;
            
            NSSet *destinationsListWeBuyResultsList = [selected  valueForKey:@"destinationsListWeBuyTesting"];
            NSDate *maxExternalChangedDate = [destinationsListWeBuyResultsList valueForKeyPath:@"@max.date"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@",maxExternalChangedDate];
            DestinationsListWeBuyTesting *testing = [[destinationsListWeBuyResultsList filteredSetUsingPredicate:predicate] anyObject];
            NSSet *results = testing.destinationsListWeBuyResults;
            testingResultShortInfo.title = [selected valueForKey:@"testingRestultInfo"];
            
            NSUInteger idx = 1;
            testingResultInfo1.stringValue = @"";
            testingResultInfo2.stringValue = @"";
            testingResultInfo3.stringValue = @"";
            testingResultInfo4.stringValue = @"";
            testingResultInfo5.stringValue = @"";
            [testingResultIPlay1 setHidden:YES];
            [testingResultIPlay2 setHidden:YES];
            [testingResultIPlay3 setHidden:YES];
            [testingResultIPlay4 setHidden:YES];
            [testingResultIPlay5 setHidden:YES];
            
            for (DestinationsListWeBuyResults *result in results) {
                
                NSString *menuText = [NSString stringWithFormat:@"Call to +%@ duration %@sec disconnect cause is %@",result.dstnum, result.duration, result.disconnect_cause];
                
                switch (idx) {
                    case 1:
                        testingResultInfo1.stringValue = menuText;
                        if (result.duration.doubleValue > 0) [testingResultIPlay1 setHidden:NO];
                        else [testingResultIPlay1 setHidden:YES];
                        testingResultIPlay1.tag = result.dstnum.integerValue;
                        break;
                    case 2:
                        testingResultInfo2.stringValue = menuText;
                        if (result.duration.doubleValue > 0) [testingResultIPlay2 setHidden:NO];
                        else [testingResultIPlay2 setHidden:YES];
                        testingResultIPlay2.tag = result.dstnum.integerValue;
                        
                        break;
                    case 3:
                        testingResultInfo3.stringValue = menuText;            
                        if (result.duration.doubleValue > 0) [testingResultIPlay3 setHidden:NO];
                        else [testingResultIPlay3 setHidden:YES];
                        testingResultIPlay3.tag = result.dstnum.integerValue;
                        
                        break;
                    case 4:
                        testingResultInfo4.stringValue = menuText;
                        if (result.duration.doubleValue > 0) [testingResultIPlay4 setHidden:NO];
                        else [testingResultIPlay4 setHidden:YES];
                        testingResultIPlay4.tag = result.dstnum.integerValue;
                        
                        break;
                    case 5:
                        testingResultInfo5.stringValue = menuText;
                        if (result.duration.doubleValue > 0) [testingResultIPlay5 setHidden:NO];
                        else [testingResultIPlay5 setHidden:YES];
                        testingResultIPlay5.tag = result.dstnum.integerValue;
                        
                        break;
                        
                    default:
                        break;
                        
                }
                idx++;

            }
            
            if (!testingResults) testingResults = [[NSPopover alloc] init];
            
            
            NSUInteger columnsCount = [[aTableView tableColumns] count];
            NSRect frameOfTestingCell = [aTableView frameOfCellAtColumn:columnsCount - 1  row:rowIndex]; 
            
            if (testingResults) {
                testingResults.contentViewController = testingResultsController;
//                NSInteger heightDifference = (5 - [results count]) * 50;
//                
//                testingResultsController.view.frame = NSMakeRect(testingResultsController.view.frame.origin.x, testingResultsController.view.frame.origin.y, testingResultsController.view.frame.size.width,testingResultsController.view.frame.size.height - heightDifference);
                
                testingResults.behavior = NSPopoverBehaviorTransient;
                [testingResults showRelativeToRect:frameOfTestingCell ofView:viewForPopover preferredEdge:NSMaxYEdge];
            } else
            {
                testingResultsController.view.frame = NSMakeRect(frameOfTestingCell.origin.x, frameOfTestingCell.origin.y, testingResultsController.view.frame.size.width, testingResultsController.view.frame.size.height);
                [self.view addSubview:testingResultsController.view];
                
            }
            
            return NO;
        }
        return YES;
#endif
    }
    
    if ([aTableView tag] == 102) {
        
        if ([[aTableColumn identifier] isEqualToString:@"carrierName"]) {
           // NSMutableDictionary *addDestinationsOutPeerRow = [[addDestinationsOutGroupsOutPeerList arrangedObjects] objectAtIndex:rowIndex];
            [addDestinationsOutGroupsOutPeerList setSelectionIndex:rowIndex];
            
            //NSLog(@"addDestinationsWeBuyForChangeOutPeers:%lu",[[addDestinationsWeBuyForChangeOutPeers arrangedObjects] count]);
            NSDictionary *selected = [[addDestinationsList selectedObjects] lastObject];
            NSString *country = [selected valueForKey:@"country"];
            NSString *specific = [selected valueForKey:@"specific"];
            //NSNumber *rate = [selected valueForKey:@"rate"];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country == %@ and specific == %@", country,specific];
            
            if ([[addDestinationsWeBuyForChangeOutPeers sortDescriptors] count] == 0) {
                NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"lastUsedCallAttempts" ascending:NO] autorelease];
                NSSortDescriptor *sortDescriptorRate = [[[NSSortDescriptor alloc] initWithKey:@"rate" ascending:NO] autorelease];
                [addDestinationsWeBuyForChangeOutPeers setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor,sortDescriptorRate,nil]];
            }
            [addDestinationsWeBuyForChangeOutPeers setFilterPredicate:predicate];

            if (!addDestinationsChangeOutPeer) addDestinationsChangeOutPeer = [[NSPopover alloc] init];
            if (addDestinationsChangeOutPeer) {
                addDestinationsChangeOutPeer.contentViewController = addDestinationsChangeOutPeerController;
                addDestinationsChangeOutPeer.behavior = NSPopoverBehaviorTransient;
                //NSCell *cell = [aTableView frameOfCellAtColumn:1 row:rowIndex];
                //NSView *cellView = [cell controlView];
//                NSRect cellFrame = [aTableView frameOfCellAtColumn:1 row:rowIndex];
//                NSPoint origin = cellFrame.origin;
//                NSLog(@"coordinates1:%@",NSStringFromPoint(origin));
//
//                origin = [self.view convertPoint:origin fromView:aTableView];
            
                //cellFrame.origin.y -=20;
                [addDestinationsChangeOutPeer showRelativeToRect:[aTableView frameOfCellAtColumn:1 row:rowIndex] ofView:aTableView preferredEdge:NSMinYEdge];
//                NSLog(@"coordinates2:%@",NSStringFromPoint(origin));
            } else
            {
                addDestinationsChangeOutPeerController.view.frame = NSMakeRect([[aTableColumn headerCell] frame].origin.x, [[aTableColumn headerCell] frame].origin.y, addDestinationsChangeOutPeerController.view.frame.size.width, addDestinationsChangeOutPeerController.view.frame.size.height);
                [self.view addSubview:addDestinationsChangeOutPeerController.view];
                
            }

            return NO;
        }
    }
    return YES;

}



//- (BOOL)tableView:(NSTableView *)aTableView shouldSelectTableColumn:(NSTableColumn *)aTableColumn
//{
//    if ([aTableView tag] == 200) {
//        importRatesColumnSelectPanel = [[[NSPopover alloc] init] autorelease];
//
//        if (importRatesColumnSelectPanel) {
//            importRatesColumnSelectPanel.contentViewController = importRatesColumnSelectViewController;
//            importRatesColumnSelectPanel.behavior = NSPopoverBehaviorTransient;
//            id header = [aTableColumn headerCell];
//           // NSView *controlView = [header controlView];
//            NSRect cellFrame = [header currentFrame];
//            cellFrame.origin.y -= 20;
//            [importRatesColumnSelectPanel showRelativeToRect:cellFrame ofView:importRatesImportedRoutes preferredEdge:NSMinYEdge];
//            NSArray *allColumns = [aTableView tableColumns];
//            NSInteger number = [allColumns indexOfObject:aTableColumn];
//            
//            
//            importRatesColumnSelectViewController.view.identifier = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:number]];
//            
//            //NSLog(@"current header frame is:%@, control view:%@ header:%@",NSStringFromRect(cellFrame),header);
//        } else
//        {
//            importRatesColumnSelectViewController.view.frame = NSMakeRect([[aTableColumn headerCell] frame].origin.x, [[aTableColumn headerCell] frame].origin.y, importRatesColumnSelectViewController.view.frame.size.width, importRatesColumnSelectViewController.view.frame.size.height);
//            [self.view addSubview:importRatesColumnSelectViewController.view];
//            
//        }
//
//        return NO;
//    } else return YES;
//}

#pragma mark - client controller delegate

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    //NSManagedObjectContext *mocForChanges = [delegate managedObjectContext];
    
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {  
        [self showErrorBoxWithText:status];
        //NSLog(@"error:%@",status);
    }
    if ([isItLatestMessage boolValue]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [pushListRemoveDestinations setEnabled:YES];
        });
        [self localMocMustUpdate];
//        [pushListRemoveDestinations setEnabled:YES];

    }
    
    
    NSManagedObjectID *objectID = nil;
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    if (objectID) {
        //if ([idsWithProgress containsObject:objectID] && ![isItLatestMessage boolValue]) return;
        //[idsWithProgress addObject:objectID];
        
        if ([[[[moc objectWithID:objectID] entity] name] isEqualToString:@"DestinationsListPushList"]) {
            if ([status isEqualToString:@"remove object finish"] || [status isEqualToString:@"destination for removing not found"]) { 
                //                DestinationsListPushList *previousSelected = [[destinationsListPushList arrangedObjects] objectAtIndex:previousSelectedIndex];
                //                if ([previousSelected objectID] == objectID) {
                //                    [previousSelected removeObserver:self forKeyPath:@"rate"];
                //                    [previousSelected removeObserver:self forKeyPath:@"asr"];
                //                    [previousSelected removeObserver:self forKeyPath:@"acd"];
                //                    [previousSelected removeObserver:self forKeyPath:@"minutesLenght"];
                //                    NSLog(@"removed from observer before delete");
                //                }
                [moc deleteObject:[moc objectWithID:objectID]];
                sleep(1);
                [self finalSaveForMoc:moc];
                sleep(3);
                [self localMocMustUpdate];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [pushListRemoveDestinations setEnabled:YES];
                    [pushListTableView reloadData];
                    [pushListCodesTableView reloadData];
                });
            }
        }
    }
    //NSLog(@"CARRIER:update UI:%@ latest message:%@",status,isItLatestMessage);
    
}


@end
