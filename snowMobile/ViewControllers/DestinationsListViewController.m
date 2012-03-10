//
//  DestinationsListViewController.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/28/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationsListViewController.h"
#import "AddRoutesTableViewController.h"
#import "DestinationPushListHeaderView.h"
#import "Carrier.h"
#import "CompanyStuff.h"
#import "CurrentCompany.h"
#import "DestinationsListPushList.h"
#import "DestinationsListWeBuy.h"
#import "DestinationsListForSale.h"
#import "mobileAppDelegate.h"
#import "ClientController.h"
#import "HelpForInfoView.h"
#import <QuartzCore/QuartzCore.h>
#pragma mark -
#pragma mark EmailMenuItem

@interface EmailMenuItemFor : UIMenuItem {
}
@property (nonatomic, retain) NSIndexPath* indexPath;
@end

@implementation EmailMenuItemFor
@synthesize indexPath;
- (void)dealloc {
    [indexPath release];
    [super dealloc];
}
@end

@interface DestinationsListViewController()
@property (nonatomic, retain) NSIndexPath* pinchedIndexPath;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) NSInteger closedSectionIndex;
@property (nonatomic, assign) CGFloat initialPinchHeight;
@property (readwrite) BOOL routeAddIsActive;
@property (readwrite) BOOL keyboardIsShowing;
//@property (readwrite) BOOL isRoutesWeBuyListUpdated;
//@property (readwrite) BOOL isRoutesForSaleListUpdated;
//@property (readwrite) BOOL isRoutesPushlistListUpdated;

@property (readwrite) BOOL cancelAllUpdates;

@property (readwrite) BOOL shouldBeginEditing;


@property (nonatomic, retain) NSIndexPath* selectedForChangeCarrier;
@property (nonatomic, retain) CompanyStuff *currentStuff;

@property (nonatomic, assign) NSInteger uniformRowHeight;

@property (nonatomic, retain) NSMutableString *previousSearchString;
@property (nonatomic, retain) NSManagedObjectContext *mocForUpdates;

@property (nonatomic, retain) NSMutableIndexSet *sectionOpenedAfterViewDissapier;

@property (nonatomic, retain) NSIndexPath* openedIndexPath;

@property (nonatomic, retain) NSArray* sectionsTitles;

-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath;

-(void)changeCarrierButtonPressed:(UIMenuController*)menuController;
//- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;
- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString;
-(void) safeSave;

@end

#define DEFAULT_ROW_HEIGHT 124
#define HEADER_HEIGHT 65


@implementation DestinationsListViewController
@synthesize cancelAllUpdates;
@synthesize cancelAllUpdatesButton;
@synthesize toolBarView;
@synthesize routesChangeFilterWithOrWithoutTraffic;

@synthesize managedObjectContext;
@synthesize progressView;
@synthesize carriersProgress;
@synthesize carriersProgressTitle;
@synthesize operationTitle;
@synthesize operationProgress;

@synthesize pinchedIndexPath=pinchedIndexPath_, uniformRowHeight=rowHeight_, openSectionIndex=openSectionIndex_, initialPinchHeight=initialPinchHeight_, closedSectionIndex = closedSectionIndex_,selectedForChangeCarrier,currentStuff;
@synthesize tableView;
@synthesize mySearchDisplayController;
@synthesize bar;
@synthesize fetchedResultsController;
@synthesize fetchResultControllerSearch;
@synthesize searchIsActive;
@synthesize addRoutesView;
@synthesize routeAddIsActive;
@synthesize destinationCell;
@synthesize addRoutesNavigationView;
@synthesize home;
//@synthesize userController;
@synthesize isRoutesForSaleListUpdated,isRoutesPushlistListUpdated,isRoutesWeBuyListUpdated;
@synthesize isDeleteOperation;
@synthesize forDeleteOperation;
@synthesize searchWasActive;
@synthesize deleteAlert;
@synthesize deleteAlertView;
@synthesize savedSearchTerm;
@synthesize previousSearchString;
@synthesize addRoutes,selectRoutes;
@synthesize isOpenCloseSection;
@synthesize shouldBeginEditing;
@synthesize mocForUpdates;
@synthesize sections;
@synthesize isControllerStartedFromOutsideTabbar;
@synthesize selectedCarrierID;
@synthesize sectionOpenedAfterViewDissapier;
@synthesize openedIndexPath;
@synthesize item;
//@synthesize alert;
@synthesize sectionsTitles;
@synthesize desinationsUpdateProgress;
@synthesize changedDestinationsIDs;
@synthesize configureRoutesButton;

@synthesize keyboardIsShowing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [changedDestinationsIDs release];
    [pinchedIndexPath_ release];   
    [mySearchDisplayController release];
    [deleteAlert release];
    [deleteAlertView release];
    [item release];
    [carriersProgress release];
    [carriersProgressTitle release];
    [operationTitle release];
    [operationProgress release];
    [progressView release];
    [tableView release];
    [cancelAllUpdatesButton release];
    [toolBarView release];
    [routesChangeFilterWithOrWithoutTraffic release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Own view updates
-(void) keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    CGFloat keyboardHeight = keyboardBounds.size.height;
    if (keyboardIsShowing == NO)
    {
        keyboardIsShowing = YES;
        CGRect frame = self.tableView.frame;
        frame.origin.y -= keyboardHeight - HEADER_HEIGHT;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        self.tableView.frame = frame;
        [UIView commitAnimations];
    }
}

-(void) keyboardWillHide:(NSNotification *)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    CGFloat keyboardHeight = keyboardBounds.size.height;
    if (keyboardIsShowing == YES)
    {
        keyboardIsShowing = NO;
        CGRect frame = self.tableView.frame;
        frame.origin.y += keyboardHeight - HEADER_HEIGHT;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        self.tableView.frame = frame;
        [UIView commitAnimations];
        
    }

}

-(NSArray *) indexForSectionIndexTitlesForEntity:(NSString *)entityName;
{
    __block NSString *entityNameBlock = entityName;
    
    __block NSMutableArray *countForLetters = [NSMutableArray arrayWithCapacity:0];
    __block NSMutableArray *letters = [NSMutableArray arrayWithCapacity:0];
    [letters addObject:UITableViewIndexSearch];
    __block NSUInteger total = 0;
    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    __block NSString *adminGUID = admin.GUID;
    
    [clientController release];
    __block NSArray *allLetters = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil]; 
    [allLetters enumerateObjectsUsingBlock:^(NSString *letter, NSUInteger idx, BOOL *stop) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityNameBlock
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carrier.companyStuff.GUID == %@ and country BEGINSWITH [c] %@",adminGUID,letter];
        [fetchRequest setPredicate:predicate];
        //NSLog(@"check for predicate:%@",predicate);
        
        NSError *error = nil;
        NSInteger fetchedObjects = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (fetchedObjects > 0) { 
            [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letter,@"letter",[NSNumber numberWithInteger:total],@"index", nil]];
            [letters addObject:letter];
        }
        total += fetchedObjects;
        [fetchRequest release];
        
    }];
    
    if ([letters count] == 1) [letters removeAllObjects];
    else [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letters,@"letters", nil]];  
    
    return [NSArray arrayWithArray:countForLetters];
}
-(void)updateNavigatorViews
{
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
    if (!addRoutesView) {
        
        addRoutesView = [[AddRoutesTableViewController alloc] initWithStyle:UITableViewStylePlain];
        addRoutesView.destinationsPushListView = self;
        addRoutesView.managedObjectContext = self.managedObjectContext;
        //addRoutesView.userController = self.userController;
        addRoutesNavigationView = [[UINavigationController alloc] initWithRootViewController:addRoutesView];
        
    }

    NSUInteger width = 0;
    if (isControllerStartedFromOutsideTabbar) width = 800;
    else width = 310;
    
    UIView *segmentedBlock = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];

//    if (!addRoutes) {
    CGFloat moveSearchAndAddRoutesTo = 0;
    if (isControllerStartedFromOutsideTabbar) moveSearchAndAddRoutesTo = 195;
    else moveSearchAndAddRoutesTo = 270;

    if (!configureRoutesButton) { 
        configureRoutesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        configureRoutesButton.frame = CGRectMake(configureRoutesButton.frame.origin.x + moveSearchAndAddRoutesTo, configureRoutesButton.frame.origin.y + 7, configureRoutesButton.frame.size.width, configureRoutesButton.frame.size.height);
        
        [configureRoutesButton setImage:[UIImage imageNamed:@"routesConfig.png"] forState:UIControlStateNormal];
        [configureRoutesButton addTarget:self action:@selector(didClickConfig:) forControlEvents:UIControlEventTouchUpInside];
    }
    [segmentedBlock addSubview:configureRoutesButton];
        

//        CGFloat moveSearchAndAddRoutesTo = 0;
//        if (isControllerStartedFromOutsideTabbar) moveSearchAndAddRoutesTo = 130;
//        else moveSearchAndAddRoutesTo = 250;
//        
//        if (isControllerStartedFromOutsideTabbar) moveSearchAndAddRoutesTo = 200;
//    
//        addRoutes =  [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:[UIImage imageNamed:@"settings_30x30.png"]]];
//        addRoutes.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
//        addRoutes.segmentedControlStyle = UISegmentedControlStyleBar;
//        addRoutes.frame = CGRectMake(addRoutes.frame.origin.x + moveSearchAndAddRoutesTo, addRoutes.frame.origin.y + 7, addRoutes.frame.size.width, addRoutes.frame.size.height);
//        [addRoutes addTarget:self action:@selector(addNewRoute:) forControlEvents:UIControlEventAllEvents];
        
//    }
    //    if (!isControllerStartedFromOutsideTabbar) {
    
    if (!selectRoutes) {
        
        selectRoutes = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"For sale",@"We buy",@"Pushlist", nil]];
        [selectRoutes setSelectedSegmentIndex:2];
        selectRoutes.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
        selectRoutes.segmentedControlStyle = UISegmentedControlStyleBar;
        selectRoutes.frame = CGRectMake(selectRoutes.frame.origin.x , selectRoutes.frame.origin.y + 7, selectRoutes.frame.size.width, selectRoutes.frame.size.height);
        [selectRoutes addTarget:self action:@selector(selectRoutesStart:) forControlEvents:UIControlEventAllEvents];
        //            [selectRoutes setEnabled:NO forSegmentAtIndex:0];
        //            [selectRoutes setEnabled:NO forSegmentAtIndex:1];
    }

    [segmentedBlock addSubview:selectRoutes];

//    if (!selectRoutes) [selectRoutes release];
    //        desinationsUpdateProgress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //        desinationsUpdateProgress.frame = CGRectMake(desinationsUpdateProgress.frame.origin.x + 150 , desinationsUpdateProgress.frame.origin.y, desinationsUpdateProgress.frame.size.width, desinationsUpdateProgress.frame.size.height);
    //
    //        [segmentedBlock addSubview:desinationsUpdateProgress];
    
    
    
    self.navigationItem.titleView = segmentedBlock;
    [segmentedBlock release];
//    if (!addRoutes) [addRoutes release];
//    if (!selectRoutes) [selectRoutes release];
    
    
    //    } else {
    
    //        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:addRoutes] autorelease];
    //        if (!addRoutes) [addRoutes release];
    //        
//    }
    
    
    
    
}

-(void) updateDestinations;
{
    //dispatch_async(dispatch_get_main_queue(), ^(void) {
    
    NSUInteger selectedSegmentIndex = selectRoutes.selectedSegmentIndex;
    //NSLog(@"selected index:%u isRoutesForSaleListUpdated:%@ isRoutesWeBuyListUpdated:%@ isRoutesPushlistListUpdated:%@",selectedSegmentIndex,[NSNumber numberWithBool:isRoutesForSaleListUpdated],[NSNumber numberWithBool:isRoutesWeBuyListUpdated],[NSNumber numberWithBool:isRoutesPushlistListUpdated]); 
    if (selectedSegmentIndex == 2) addRoutes.hidden = NO;
    else addRoutes.hidden = YES;
    
    if (selectedSegmentIndex == 0 && isRoutesForSaleListUpdated == YES) { 
        carriersProgress.hidden = NO;
        carriersProgressTitle.hidden = NO;
        operationTitle.hidden = NO;
        operationProgress.hidden = NO;
        cancelAllUpdatesButton.hidden = NO;

        routesChangeFilterWithOrWithoutTraffic.hidden = YES;

        
        //[self.navigationController setToolbarHidden:NO animated:YES];//progressView.hidden = NO; 
    }
    else if (selectedSegmentIndex == 1 && isRoutesWeBuyListUpdated == YES) {
        carriersProgress.hidden = NO;
        carriersProgressTitle.hidden = NO;
        operationTitle.hidden = NO;
        operationProgress.hidden = NO;
        cancelAllUpdatesButton.hidden = NO;

        routesChangeFilterWithOrWithoutTraffic.hidden = YES;

        //[self.navigationController setToolbarHidden:NO animated:YES];//progressView.hidden = NO;
    }
    else if (selectedSegmentIndex == 2 && isRoutesPushlistListUpdated == YES) { 
        carriersProgress.hidden = NO;
        carriersProgressTitle.hidden = NO;
        operationTitle.hidden = NO;
        operationProgress.hidden = NO;
        cancelAllUpdatesButton.hidden = NO;

        routesChangeFilterWithOrWithoutTraffic.hidden = YES;

        //[self.navigationController setToolbarHidden:NO animated:YES];//progressView.hidden = NO;
    }
    else { 
        carriersProgress.hidden = YES;
        carriersProgressTitle.hidden = YES;
        operationTitle.hidden = YES;
        operationProgress.hidden = YES;
        cancelAllUpdatesButton.hidden = YES;

        if (selectRoutes.selectedSegmentIndex == 2) routesChangeFilterWithOrWithoutTraffic.hidden = YES;
        else routesChangeFilterWithOrWithoutTraffic.hidden = NO;
        //NSLog(@"routesChangeFilterWithOrWithoutTraffic.hidden = NO;");


//        [self.navigationController setToolbarHidden:YES animated:YES];progressView.hidden = YES;
    }
    //});
    if (isRoutesWeBuyListUpdated || isRoutesPushlistListUpdated || isRoutesForSaleListUpdated) return;
    //else isRoutesListUpdated = YES;
    //NSUInteger selectedSegmentIndex = selectRoutes.selectedSegmentIndex;
    
    NSString *lastUpdateTimeKey = nil;
    NSString *entity = nil;
    if (selectedSegmentIndex == 0) { 
        lastUpdateTimeKey = @"lastDestinationsForSaleUpdatingTime";
        entity = @"DestinationsListForSale";

        isRoutesForSaleListUpdated = YES;
    }
    if (selectedSegmentIndex == 1) { 
        lastUpdateTimeKey = @"lastDestinationsWeBuyUpdatingTime";
        entity = @"DestinationsListWeBuy";
        isRoutesWeBuyListUpdated = YES;
    }
    if (selectedSegmentIndex == 2) { 
        lastUpdateTimeKey = @"lastDestinationsPushListUpdatingTime";
        entity = @"DestinationsListPushList";
        isRoutesPushlistListUpdated = YES;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:lastUpdateTimeKey];
        if (lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] > 3600 ) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastUpdateTimeKey];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                //[self.navigationController setToolbarHidden:NO animated:YES];
                carriersProgress.hidden = NO;
                carriersProgressTitle.hidden = NO;
                operationTitle.hidden = NO;
                operationProgress.hidden = NO;
                cancelAllUpdatesButton.hidden = NO;
                routesChangeFilterWithOrWithoutTraffic.hidden = YES;
            });
            
            mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];            
            CompanyStuff *admin = [clientController authorization];
            NSSet *allCarriers = nil;
            if (selectedCarrierID) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectID == %@",selectedCarrierID];
                allCarriers = [admin.carrier filteredSetUsingPredicate:predicate];
            } else allCarriers = admin.carrier;
            
            NSUInteger allCarriersCount = allCarriers.count;
            __block NSUInteger idxCarriers = 0;
            
            [allCarriers enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
                if (cancelAllUpdates == YES) *stop = YES;
                NSString *carrierName = [NSString stringWithFormat:@"%@",carrier.name];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    carriersProgressTitle.text = carrierName;
                    NSNumber *percentDone = [NSNumber numberWithDouble:[[NSNumber numberWithUnsignedInteger:idxCarriers] doubleValue] / [[NSNumber numberWithUnsignedInteger:allCarriersCount] doubleValue]];
                    carriersProgress.progress = percentDone.floatValue;
                    operationTitle.text = @"Download...";
                });
                idxCarriers++;
                
                NSArray *allGUIDsDestinations = [clientController getAllObjectsListWithEntityForList:entity withMainObjectGUID:carrier.GUID withMainObjectEntity:@"Carrier" withAdmin:admin withDateFrom:nil withDateTo:nil];

                NSArray *allObjectsForGUIDS = [clientController getAllObjectsWithGUIDs:allGUIDsDestinations withEntity:entity withAdmin:admin];
                if (allGUIDsDestinations && allObjectsForGUIDS && allGUIDsDestinations.count > 0 && allObjectsForGUIDS > 0) {
                    
                    NSArray *updatedDestinationsIDs = [clientController updateGraphForObjects:allObjectsForGUIDS withEntity:entity withAdmin:admin withRootObject:carrier isEveryTenPercentSave:YES];
                    [clientController finalSave:clientController.moc];
                    // remove objects which was not on server
                    NSSet *allDestinations = nil;
                    if (selectedSegmentIndex == 0) allDestinations = carrier.destinationsListForSale;
                    if (selectedSegmentIndex == 1) allDestinations = carrier.destinationsListWeBuy;
                    if (selectedSegmentIndex == 2) allDestinations = carrier.destinationsListPushList;
                    
                    [allDestinations enumerateObjectsUsingBlock:^(NSManagedObject *destination, BOOL *stop) {
                        if (cancelAllUpdates == YES) *stop = YES;

                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",[destination valueForKey:@"GUID"]];
                        NSArray *filteredDestinationsIDs = [updatedDestinationsIDs filteredArrayUsingPredicate:predicate];
                        if (filteredDestinationsIDs.count == 0) {
                            [clientController.moc deleteObject:destination];
                            NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",carrier.entity.name);
                        }
                    }];
                    [clientController finalSave:clientController.moc];
                }
            }];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                operationProgress.hidden = YES;
                carriersProgress.hidden = YES;
                carriersProgressTitle.hidden = YES;
                operationTitle.hidden = YES;
                operationProgress.hidden = YES;
                cancelAllUpdatesButton.hidden = YES;
                if (selectRoutes.selectedSegmentIndex == 2) [self.navigationController setToolbarHidden:YES animated:YES];
                    else routesChangeFilterWithOrWithoutTraffic.hidden = NO;
                cancelAllUpdates = NO;
                cancelAllUpdatesButton.enabled = YES;
                [self.tableView reloadData];
            });
            [clientController release];

            [[NSUserDefaults standardUserDefaults] synchronize];
            if (selectedSegmentIndex == 0) { 
                isRoutesForSaleListUpdated = NO;
            }
            if (selectedSegmentIndex == 1) { 
                isRoutesWeBuyListUpdated = NO;
            }
            if (selectedSegmentIndex == 2) { 
                isRoutesPushlistListUpdated = NO;
            }
        }
    });
    
}


#pragma mark - View lifecycle
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self.progressView.layer setCornerRadius:5];
//    [self.progressView.layer setBorderColor:[UIColor blackColor].CGColor];
//    [self.progressView.layer setBorderWidth:1.5f];
//    [self.progressView.layer setShadowColor:[UIColor whiteColor].CGColor];
//    [self.progressView.layer setShadowOpacity:0.8];
//    [self.progressView.layer setShadowRadius:5];
//    [self.progressView.layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    // Do any additional setup after loading the view from its nib.
    shouldBeginEditing = YES;
    
    changedDestinationsIDs = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.searchIsActive = NO;
    // Add a pinch gesture recognizer to the table view.
    UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    
    [tableView addGestureRecognizer:pinchRecognizer];
    [pinchRecognizer release]; 

//    NSLog(@"pinchRecognizer:%@",[tableView gestureRecognizers]);

//    if ([[tableView gestureRecognizers] count] == 0) {
//        UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
//
//        [tableView addGestureRecognizer:pinchRecognizer];
//        [pinchRecognizer release]; 
//    }

    
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.translucent = YES;
    
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
//    UIBarButtonItem *withTraffic = [[[UIBarButtonItem alloc] initWithTitle:@"with trattic..." style:UIBarButtonItemStyleDone target:self action:@selector(sortRoutesWithTraffic)] autorelease];
//    UIBarButtonItem *withOutTraffic = [[[UIBarButtonItem alloc] initWithTitle:@"without trattic..." style:UIBarButtonItemStyleBordered target:self action:@selector(sortRoutesWithTraffic)] autorelease];

    UIBarButtonItem *itemFor = [[[UIBarButtonItem alloc] initWithCustomView:self.toolBarView] autorelease];

    [self setToolbarItems:[NSArray arrayWithObject:itemFor]];
    [routesChangeFilterWithOrWithoutTraffic setHidden:YES];
    [self.navigationController setToolbarHidden:NO animated:NO];

    
    // Set up default values.
    self.tableView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
    self.tableView.sectionHeaderHeight = HEADER_HEIGHT;
    rowHeight_ = DEFAULT_ROW_HEIGHT;
    openSectionIndex_ = NSNotFound;
    
    NSUInteger searchBarWidth = 220;
    if (isControllerStartedFromOutsideTabbar) searchBarWidth = 160;
    
    bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0,  searchBarWidth, 45)];
    self.bar.delegate = self;
    self.bar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
    self.bar.showsCancelButton = NO;
    self.bar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.bar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.bar.placeholder = @"country,specific";
    self.tableView.tableHeaderView = self.bar;
    [self.bar sizeToFit];

    [self updateNavigatorViews];
    if (!self.previousSearchString) previousSearchString = [[NSMutableString alloc] initWithString:@""];
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:previousSearchString];
    
    isOpenCloseSection = NO;
    isRoutesWeBuyListUpdated = NO;
    isRoutesPushlistListUpdated = NO;
    isRoutesForSaleListUpdated = NO;
    
    sections = [[NSMutableIndexSet alloc] init];
//    progressView.backgroundColor = [UIColor clearColor];

}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setCancelAllUpdatesButton:nil];
    [self setToolBarView:nil];
    [self setRoutesChangeFilterWithOrWithoutTraffic:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateNavigatorViews];
    
    if ([sectionOpenedAfterViewDissapier count] > 0) {
        [sections addIndex:[sectionOpenedAfterViewDissapier lastIndex]];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:[sectionOpenedAfterViewDissapier lastIndex]]] withRowAnimation:UITableViewRowAnimationTop];
        [sectionOpenedAfterViewDissapier removeAllIndexes];
    }
    


    [changedDestinationsIDs removeAllObjects];
    self.tableView.separatorColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
    addRoutes.selectedSegmentIndex = -1;
    self.bar.placeholder = @"long press to menu";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        sleep(5);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.bar.placeholder = @"country,specific";});
    });
    HelpForInfoView *helpView = [[HelpForInfoView alloc] init];
    if (isControllerStartedFromOutsideTabbar) { 
        

        //NSLog(@"ok it's here");
        helpView.isCarriersListFromDestinationsList = YES; 
    } else selectedCarrierID = nil;

    [fetchedResultsController release],fetchedResultsController = nil;
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];

    
    helpView.isRoutesListSheet = YES;
    
    if ([helpView isHelpNecessary]) {
        self.tableView.alpha = 0.8;
        helpView.delegate = self;
        [self.navigationController.view addSubview:helpView.view];
    } else [helpView release];
    
    [self updateDestinations];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if (isRoutesListUpdated) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) { 
//            //NSLog(@"status is:%@",status);
//            
//            //            UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"get updates from server..."]] autorelease];
//            //            alert.segmentedControlStyle = UISegmentedControlStyleBar;
//            //            alert.userInteractionEnabled = NO;
//            //            alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
//            //
//            //            UIActivityIndicatorView *progess = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
//            //            [progess startAnimating];
//            //
//            //            UIView *finalView = [[[UIView alloc] init] autorelease];
//            //            alert.frame = CGRectMake(progess.frame.size.width + 10, -(self.navigationController.toolbar.bounds.size.height - alert.frame.size.height), self.navigationController.toolbar.bounds.size.width - (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height + progess.frame.size.width + 10), alert.frame.size.height);
//            //            progess.frame = CGRectMake(0, -(self.navigationController.toolbar.bounds.size.height - progess.frame.size.height)/2, progess.frame.size.width, progess.frame.size.height);
//            //
//            //            [finalView addSubview:alert];
//            //            [finalView addSubview:progess];
//            //
//            //            UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:finalView] autorelease];
//            //            
//            //            
//            //            [self setToolbarItems:[NSArray arrayWithObject:item]];
//            //            self.navigationController.toolbar.translucent = YES;
//            //            self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
//            //            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
//            //            
//            //            self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
//            //            [alert removeAllSegments];
//            //            [alert insertSegmentWithTitle:@"get updates from server..." atIndex:0 animated:NO];
//            //            [self.navigationController setToolbarHidden:NO animated:YES];
//            //            while (isRoutesListUpdated) {
//            //                sleep(1);
//            //            }
//            //            [self.navigationController setToolbarHidden:YES animated:YES]; 
//            
//        });
//        
//    } else {
//        dispatch_async(dispatch_get_main_queue(), ^(void) { 
//            //            [self.navigationController setToolbarHidden:YES animated:YES]; 
//            
//        });
//    }
    //    [self updateNavigatorViews];
    
    sectionsTitles = [[NSArray alloc] initWithArray:[self indexForSectionIndexTitlesForEntity:@"DestinationsListPushList"]];
    //NSLog(@"sectionsTitles:%@",sectionsTitles);
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([sections count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            NSUInteger lastIndex = [sections lastIndex];
            [sectionOpenedAfterViewDissapier addIndex:lastIndex];
//            [self.tableView beginUpdates];
            [sections removeAllIndexes];
            
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:lastIndex + 1]] withRowAnimation:UITableViewRowAnimationTop];
//            [self.tableView endUpdates];
        });
    }
    
    [super viewWillDisappear:animated];
    // we have new amazing function to add and wait 5 minutes to pickup all changes
    //if (isRoutesListUpdated) [userController startRegistrationForAllObjectsInFutureArrayForTableView:self.tableView sender:self clientStuffGUID:[[userController authorization] valueForKey:@"GUID"]];
    //NSLog(@"changedDestinationsIDs:%@",changedDestinationsIDs);
    
//    if ([changedDestinationsIDs count] > 0) {
//        NSMutableArray *destinationsForPost = [[NSMutableArray alloc] init];
//        
//        //NSLog(@"changedDestinationsIDs:%@",changedDestinationsIDs);
//        NSMutableString *twitterText = [[NSMutableString alloc] initWithCapacity:0];
//        [twitterText appendString:@"I'm currently interesting for those destination (s):"];
//        NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init];
//        [rateFormatter setMaximumFractionDigits:5];
//        
//        [changedDestinationsIDs enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSManagedObjectID *updatedObjectID, NSUInteger idx, BOOL *stop) {
//            DestinationsListPushList *object = (DestinationsListPushList *)[self.managedObjectContext objectWithID:updatedObjectID];
//            NSDictionary *dictionaryForPost = [NSDictionary dictionaryWithObjectsAndKeys:object.country,@"country",object.specific,@"specific",object.rate,@"rate",object.minutesLenght,@"minutesLenght", nil];
//            [destinationsForPost addObject:dictionaryForPost];
//            
//            //[twitterText appendFormat:@"%@/%@ with price %@ volume %@",object.country,object.specific,[rateFormatter stringFromNumber:object.rate],object.minutesLenght];
//            
//        }];
//        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
//        [delegate updateTwitterMessagesForDestinations:destinationsForPost];
//        //[delegate updateTwitterMessagesForText:twitterText];
//        [twitterText release];
//        [rateFormatter release];
//    }
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
    //        //NSLog(@"isRoutesListUpdated = YES;");
    //        
    //        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    //        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];            
    //        NSString *result = [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:NO isUserAuthorized:NO];
    //        if (![result isEqualToString:@"timeout"]) isRoutesListUpdated = YES;;
    //        [clientController release];
    ////        if ([result isEqualToString:@"timeout"]) isRoutesListUpdated = NO;
    //        //[clientController release];
    //        //isRoutesListUpdated = NO;
    //    });
    
    //self.searchWasActive = [self.searchDisplayController isActive];
    //self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    //self.fetchResultControllerSearch = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSArray *fetchedObjects = [[self fetchedResultsControllerForTableView:tableView] fetchedObjects];
    //NSLog(@"%@",[fetchedObjects lastObject]);
    NSInteger count = [[[self fetchedResultsController] fetchedObjects] count];
    //NSInteger count = [[[self fetchedResultsController] fetchedObjects] count] + 1;
    //NSLog(@"Number of sections:%@",[NSNumber numberWithUnsignedInteger:count]);
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (section == 0) return 0;
    
    //DestinationsListPushList *object = [[[self fetchedResultsController] fetchedObjects] objectAtIndex:section - 1 ];
    //    DestinationPushListHeaderView *sectionView = (DestinationPushListHeaderView *)[self.tableView viewWithTag:section + 100];
    //   
    NSInteger finalResult = 0;
    if ([sections lastIndex] == section) finalResult = 1;
    //    @synchronized (self) {
    
    //        if (openedIndexPath && openedIndexPath.section == section) finalResult = 1;
    //    };
    //NSInteger finalResult = [object.opened boolValue] ? 1 : 0;
    //NSLog(@"Number of rows in section:%@ for country:%@/%@ = %@",[NSNumber numberWithUnsignedInteger:section],object.country,object.specific,[NSNumber numberWithUnsignedInteger:finalResult]);
    
    return finalResult;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
//    if (section == 0) return 45;
//    else 
        return HEADER_HEIGHT;
    
}

- (void)configureCell:(DestinationsPushListCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"#####0.#"];
    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    NSIndexPath *new = [NSIndexPath indexPathForRow:indexPath.section inSection:0];    
    NSManagedObject *universalObject = [fetchController objectAtIndexPath:new];
    
    if ([universalObject.entity.name isEqualToString:@"DestinationsListPushList"]) {
        
        DestinationsListPushList *object = [fetchController objectAtIndexPath:new];
        cell.firstName.text = object.carrier.companyStuff.firstName;
        cell.lastName.text = object.carrier.companyStuff.lastName;
        cell.carrierName.text = object.carrier.name;
        cell.acd.text = [formatter stringFromNumber:object.acd];
        NSNumber *newASR = [NSNumber numberWithDouble:[object.asr doubleValue] * 100];
        cell.asr.text = [formatter stringFromNumber:newASR];
        cell.minutesLenght.text = [formatter stringFromNumber:object.minutesLenght];
        [formatter setPositiveFormat:@"#####0.#####"];
        
        cell.rate.text = [formatter stringFromNumber:object.rate];
        [formatter release];
        cell.destination = object;
        cell.delegate = self;
    }
    if ([universalObject.entity.name isEqualToString:@"DestinationsListForSale"]) {
        
        DestinationsListForSale *object = (DestinationsListForSale *)universalObject;
        cell.firstName.text = object.carrier.companyStuff.firstName;
        cell.lastName.text = object.carrier.companyStuff.lastName;
        cell.carrierName.text = object.carrier.name;
        cell.acd.text = [formatter stringFromNumber:object.lastUsedACD];
        NSNumber *newASR = [NSNumber numberWithDouble:[object.lastUsedASR doubleValue] * 100];
        cell.asr.text = [formatter stringFromNumber:newASR];
        cell.minutesLenght.text = [formatter stringFromNumber:object.lastUsedMinutesLenght];
        [formatter setPositiveFormat:@"#####0.#####"];
        
        cell.rate.text = [formatter stringFromNumber:object.rate];
        [formatter release];
        cell.rate.borderStyle = UITextBorderStyleNone;
        cell.rate.enabled = NO;
        cell.asr.borderStyle = UITextBorderStyleNone;
        cell.asr.enabled = NO;
        cell.minutesLenght.borderStyle = UITextBorderStyleNone;
        cell.minutesLenght.enabled = NO;
        cell.acd.borderStyle = UITextBorderStyleNone;
        cell.acd.enabled = NO;
        cell.notification.hidden = YES;
    }
    if ([universalObject.entity.name isEqualToString:@"DestinationsListWeBuy"]) {
        
        DestinationsListWeBuy *object = (DestinationsListWeBuy *)universalObject;
        cell.firstName.text = object.carrier.companyStuff.firstName;
        cell.lastName.text = object.carrier.companyStuff.lastName;
        cell.carrierName.text = object.carrier.name;
        cell.acd.text = [formatter stringFromNumber:object.lastUsedACD];
        NSNumber *newASR = [NSNumber numberWithDouble:[object.lastUsedASR doubleValue] * 100];
        cell.asr.text = [formatter stringFromNumber:newASR];
        cell.minutesLenght.text = [formatter stringFromNumber:object.lastUsedMinutesLenght];
        [formatter setPositiveFormat:@"#####0.#####"];
        
        cell.rate.text = [formatter stringFromNumber:object.rate];
        [formatter release];
        cell.rate.borderStyle = UITextBorderStyleNone;
        cell.rate.enabled = NO;
        cell.asr.borderStyle = UITextBorderStyleNone;
        cell.asr.enabled = NO;
        cell.minutesLenght.borderStyle = UITextBorderStyleNone;
        cell.minutesLenght.enabled = NO;
        cell.acd.borderStyle = UITextBorderStyleNone;
        cell.acd.enabled = NO;
        cell.notification.hidden = YES;

    }
    
    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    
    NSString *status = [clientController localStatusForObjectsWithRootGuid:[universalObject valueForKey:@"GUID"]];
    
    if (!status) {
        status = @"unregistered";
        //statusColor = [UIColor redColor];
        
    }
    if ([status isEqualToString:@"registered"])
    {
        status = @"registered";
        //statusColor = [UIColor greenColor];
    }
    //if (![object.carrier.companyStuff.email isEqualToString:[clientController userDefaultsObjectForKey:@"email"]]) status = @"registered";
    [clientController release];
    
    CGSize size = [status sizeWithFont:[UIFont systemFontOfSize:14]];
    
    [cell.notification removeAllSegments];
    [cell.notification insertSegmentWithTitle:status atIndex:0 animated:NO];
    cell.notification.tintColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
    if ([delegate isPad]) cell.notification.frame = CGRectMake(760.0 - size.width, 5.0, size.width, size.height); 
    else cell.notification.frame = CGRectMake(315.0 - size.width, 5.0, size.width, size.height);
    cell.activity.hidden = YES;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"DestinationsPushListCell";
    
    DestinationsPushListCell *cell = (DestinationsPushListCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        UINib *quoteCellNib;
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([delegate isPad]) quoteCellNib = [UINib nibWithNibName:@"DestinationsPushListCelliPad" bundle:nil];
        else quoteCellNib = [UINib nibWithNibName:@"DestinationsPushListCell" bundle:nil];
        
        //        UINib *quoteCellNib = [UINib nibWithNibName:@"DestinationsPushListCell" bundle:nil];
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.destinationCell;
        self.destinationCell = nil;
        
        [self configureCell:cell atIndexPath:indexPath forTableView:self.tableView];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [cell addGestureRecognizer:longPressRecognizer];      
        [longPressRecognizer release];
        
    }
    
    return cell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    BOOL isOpened = NO;
    //if (section == 0) return self.bar;
    
    if ([sections containsIndex:section]) isOpened = YES;
    
    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    //NSIndexPath *new = [NSIndexPath indexPathForRow:section - 1 inSection:0];
    NSManagedObject *managedObject = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:section inSection:0]];
    NSNumber *sectionNumber = [NSNumber numberWithInteger:section];
    //    if (openedIndexPath && openedIndexPath.section == section) isOpened = YES;
    
    //if (section < 6) NSLog(@"sections view for country/specific:%@/%@ for section:%@",[managedObject valueForKey:@"country"],[managedObject valueForKey:@"specific"],[NSNumber numberWithInteger:section]); 
    DestinationPushListHeaderView *sectionView = nil;
    
    if ([[managedObject class] isSubclassOfClass:[DestinationsListPushList class]]) {
        sectionView = [[[DestinationPushListHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, HEADER_HEIGHT) withCountry:[managedObject valueForKey:@"country"] withSpecific:[managedObject valueForKey:@"specific"]  withPrice:[managedObject valueForKey:@"rate"] withMinutes:nil withACD:nil withObjectID:managedObject.objectID section:sectionNumber isOpened:[NSNumber numberWithBool:isOpened] delegate:self isDestinationsPushList:YES] autorelease];
    }
    
    if ([[managedObject class] isSubclassOfClass:[DestinationsListForSale class]] || [[managedObject class] isSubclassOfClass:[DestinationsListWeBuy class]]) {
        sectionView = [[[DestinationPushListHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, HEADER_HEIGHT) withCountry:[managedObject valueForKey:@"country"] withSpecific:[managedObject valueForKey:@"specific"]  withPrice:[managedObject valueForKey:@"rate"] withMinutes:[managedObject valueForKey:@"lastUsedMinutesLenght"] withACD:[managedObject valueForKey:@"lastUsedACD"] withObjectID:managedObject.objectID section:sectionNumber isOpened:[NSNumber numberWithBool:isOpened] delegate:self isDestinationsPushList:NO] autorelease];
    }

    
    //NSLog(@"sections view for country/specific:%@/%@ for section:%@ isOpened:%@",managedObject.country,managedObject.specific,[NSNumber numberWithInteger:section],managedObject.opened); 
    
    
    
    return sectionView;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    //    CGFloat returnResult = 0;
    //
    //    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    //    NSIndexPath *new = [NSIndexPath indexPathForRow:indexPath.section - 1 inSection:0];
    //    DestinationsListPushList *managedObject = [fetchController objectAtIndexPath:new];
    //    returnResult = [managedObject.rowHeight floatValue];
    //NSLog(@"For section:%@ height is %@",indexPath, [NSNumber numberWithFloat:returnResult]);
    return DEFAULT_ROW_HEIGHT;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([self.bar.text length] > 0) return nil;
    return [[sectionsTitles lastObject] valueForKey:@"letters"]; 
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //NSNumber *total = [[sectionsTitles objectAtIndex:[sectionsTitles count] - 1] valueForKey:@"total"];
    if ([title isEqualToString:UITableViewIndexSearch]) return 0;
    
    NSPredicate *letterPredicate = [NSPredicate predicateWithFormat:@"letter == %@",title];
    NSArray *sectionTitlesFiltered = [sectionsTitles filteredArrayUsingPredicate:letterPredicate];
    if ([sectionTitlesFiltered count] == 0) NSLog(@"DESTINATIONS LIST: >>>> warning, for title %@ index not found",title);
    else return [[[sectionTitlesFiltered lastObject] valueForKey:@"index"] unsignedIntegerValue];
    //NSLog(@"sectionForSectionIndexTitle:%@ and index:%@ return value is:%@",title,[NSNumber numberWithUnsignedInteger:index],[NSNumber numberWithUnsignedInteger:index * 12]);
    //return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index - 1];
    return 0;
}

#pragma mark Section header delegate
-(void)sectionHeaderView:(DestinationPushListHeaderView *)sectionHeaderView 
           sectionOpened:(NSNumber *)sectionOpened 
{
    sectionHeaderView.isOpened = YES;
    [self.tableView beginUpdates];
    //if (![sections containsIndex:sectionOpened]) [sections addIndex:sectionOpened];
    if ([sections count] > 0) {
        NSUInteger previousOpenedSection = [sections lastIndex];
        NSUInteger animationDelete = 0;
        NSUInteger animationInsert = 0;
        
        if (previousOpenedSection > sectionOpened.unsignedIntegerValue){  
            animationDelete = UITableViewRowAnimationBottom;
            animationInsert = UITableViewRowAnimationTop;
        } else { 
            animationDelete = UITableViewRowAnimationTop;
            animationInsert = UITableViewRowAnimationBottom;
            
        }
        //NSLog(@"DESTINATIONS LIST: PREVIOUS OPENED:%@",[NSIndexPath indexPathForRow:0 inSection:previousOpenedSection]);

        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:previousOpenedSection]] withRowAnimation:animationDelete];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:previousOpenedSection] withRowAnimation:UITableViewRowAnimationNone];
        [sections removeAllIndexes];
        [sections addIndex:sectionOpened.unsignedIntegerValue];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:sectionOpened.unsignedIntegerValue]] withRowAnimation:animationInsert];
        //NSLog(@"DESTINATIONS LIST: OPENED:%@",[NSIndexPath indexPathForRow:0 inSection:sectionOpened.unsignedIntegerValue]);

    } else {
        [sections addIndex:sectionOpened.unsignedIntegerValue];
        //NSLog(@"DESTINATIONS LIST: OPENED:%@",[NSIndexPath indexPathForRow:0 inSection:sectionOpened.unsignedIntegerValue]);

        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:sectionOpened.unsignedIntegerValue]] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];
    
    
}

-(void)sectionHeaderView:(DestinationPushListHeaderView*)sectionHeaderView 
           sectionClosed:(NSNumber *)sectionClosed  
{
    sectionHeaderView.isOpened = NO;
    
    if ([sections containsIndex:sectionClosed.unsignedIntegerValue]) {
        
        [self.tableView beginUpdates];
        [sections removeIndex:sectionClosed.unsignedIntegerValue];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:sectionClosed.unsignedIntegerValue]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    } else NSLog(@"DESTINATIONS LIST: warning, section for close already closed  do nothing");
    //    DestinationsListPushList *destination = (DestinationsListPushList *)[self.managedObjectContext objectWithID:sectionHeaderView.objectID];
    //    
    //    if ([destination.opened boolValue]) {
    //        // section not opened, we do all 
    //        destination.opened = [NSNumber numberWithBool:NO];
    //        sectionHeaderView.isOpened = NO;
    //
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
    //            [self safeSave];
    //            
    //            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
    //            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[destination objectID]] mustBeApproved:NO];
    //            [clientController release];
    //        });
    //        
    //    } else NSLog(@"DESTINATIONS LIST: warning, section for close already closed  do nothing");
    
}
#pragma mark Handling pinches


-(void)handlePinch:(UIPinchGestureRecognizer*)pinchRecognizer {
    
    /*
     There are different actions to take for the different states of the gesture recognizer.
     * In the Began state, use the pinch location to find the index path of the row with which the pinch is associated, and keep a reference to that in pinchedIndexPath. Then get the current height of that row, and store as the initial pinch height. Finally, update the scale for the pinched row.
     * In the Changed state, update the scale for the pinched row (identified by pinchedIndexPath).
     * In the Ended or Canceled state, set the pinchedIndexPath property to nil.
     */
    
    if (pinchRecognizer.state == UIGestureRecognizerStateBegan) {
        //UITableView *currentTableView = nil;
        //if (!searchIsActive) currentTableView = self.tableView;
        //if (searchIsActive) currentTableView = self.mySearchDisplayController.searchResultsTableView;
        
        CGPoint pinchLocation = [pinchRecognizer locationInView:self.tableView];
        NSIndexPath *newPinchedIndexPath = [self.tableView indexPathForRowAtPoint:pinchLocation];
        
        if (!newPinchedIndexPath) return;
        
		self.pinchedIndexPath = newPinchedIndexPath;
        
        DestinationsListPushList *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:newPinchedIndexPath.section inSection:0]];
        //if (!searchIsActive)  object = [[self fetchedResultsControllerForTableView:currentTableView] objectAtIndexPath:[NSIndexPath indexPathForRow:newPinchedIndexPath.section inSection:0]];
        //if (searchIsActive) object = [[self fetchedResultsControllerForTableView:currentTableView] objectAtIndexPath:[NSIndexPath indexPathForRow:newPinchedIndexPath.section inSection:0]];
        
        self.initialPinchHeight = [object.rowHeight floatValue];
        // Alternatively, set initialPinchHeight = uniformRowHeight.
        
        [self updateForPinchScale:pinchRecognizer.scale atIndexPath:newPinchedIndexPath];
    }
    else {
        if (pinchRecognizer.state == UIGestureRecognizerStateChanged) {
            [self updateForPinchScale:pinchRecognizer.scale atIndexPath:self.pinchedIndexPath];
        }
        else if ((pinchRecognizer.state == UIGestureRecognizerStateCancelled) || (pinchRecognizer.state == UIGestureRecognizerStateEnded)) {
            self.pinchedIndexPath = nil;
        }
    }
}


-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath {
    
    if (indexPath && (indexPath.section != NSNotFound) && (indexPath.row != NSNotFound)) {
        
		CGFloat newHeight = round(MAX(self.initialPinchHeight * scale, DEFAULT_ROW_HEIGHT));
        
        DestinationsListPushList *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]];
        
        //if (!searchIsActive) object = [[self fetchedResultsControllerForTableView:self.tableView] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]];
        //if (searchIsActive)  object = [[self fetchedResultsControllerForTableView:self.searchDisplayController.searchResultsTableView] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]];
        
        object.rowHeight = [NSNumber numberWithFloat:newHeight];
        
        /*
         Switch off animations during the row height resize, otherwise there is a lag before the user's action is seen.
         */
        BOOL animationsEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        //if (!searchIsActive)  
        //{ 
        [self.tableView beginUpdates];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        /*}
         if (searchIsActive){
         
         [self.mySearchDisplayController.searchResultsTableView beginUpdates];
         [self.mySearchDisplayController.searchResultsTableView endUpdates];
         }*/
        
        [UIView setAnimationsEnabled:animationsEnabled];
    }
}


#pragma mark Handling long presses

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    
    /*
     For the long press, the only state of interest is Began.
     When the long press is detected, find the index path of the row (if there is one) at press location.
     If there is a row at the location, create a suitable menu controller and display it.
     */
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        //UITableView *currentTable = nil;
        //if (!searchIsActive) currentTable = self.tableView;
        //if (searchIsActive) currentTable = self.mySearchDisplayController.searchResultsTableView;
        
        NSIndexPath *pressedIndexPath = [self.tableView indexPathForRowAtPoint:[longPressRecognizer locationInView:self.tableView]];
        self.selectedForChangeCarrier = pressedIndexPath;
        
        if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
            [self becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            //if (!currentStuff) {
            //                UserDataController *data = [[UserDataController alloc] init];
            //                data.context = self.managedObjectContext;
            //                currentStuff = [data authorization];
            //                if (!currentStuff) currentStuff = [data defaultUser];
            //                [data release];
            //}
            mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
            CompanyStuff *admin = [clientController authorization];
            
            NSSet *carriers = admin.carrier;
            __block BOOL isCarriersHaveRegisteredJustOne = NO;
            
            [carriers enumerateObjectsWithOptions:NSSortStable usingBlock:^(Carrier *carrier, BOOL *stop) {
                if ([clientController localStatusForObjectsWithRootGuid:carrier.GUID]) { isCarriersHaveRegisteredJustOne = YES; *stop = YES; }
            }];
            [clientController release];
            
            NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:0];
            
            NSString *twitTitle = nil;
            NSString *linkedinTitle = nil;
            if ([delegate isLinkedinAuthoruzed]) linkedinTitle = @"Linkedin it";
            else linkedinTitle = @"Linedin (restricted)";
            if ([delegate isTwitterAuthorized]) twitTitle = @"Twit it";
            else twitTitle = @"Twit (restricted)";


            EmailMenuItemFor *menuItemTwit = [[EmailMenuItemFor alloc] initWithTitle:twitTitle action:@selector(sendToTwitter:)];
            menuItemTwit.indexPath = pressedIndexPath;
            [menuItems addObject:menuItemTwit];

            EmailMenuItemFor *menuItemLinkedin = [[EmailMenuItemFor alloc] initWithTitle:linkedinTitle action:@selector(sendToLinkedin:)];
            menuItemLinkedin.indexPath = pressedIndexPath;
            [menuItems addObject:menuItemLinkedin];

            EmailMenuItemFor *menuItemRemove = [[EmailMenuItemFor alloc] initWithTitle:@"Remove" action:@selector(removeDestinationButtonPressed:)];
            menuItemRemove.indexPath = pressedIndexPath;
            [menuItems addObject:menuItemRemove];

            
            if (isCarriersHaveRegisteredJustOne && !isControllerStartedFromOutsideTabbar) {
                EmailMenuItemFor *menuItem = [[EmailMenuItemFor alloc] initWithTitle:@"Change carrier" action:@selector(changeCarrierButtonPressed:)];
                menuItem.indexPath = pressedIndexPath;
                [menuItems addObject:menuItem];
                [menuItem release];
            }

            
            menuController.menuItems = [NSArray arrayWithArray:menuItems];
            [menuItemRemove release];
            
            [menuController setTargetRect:[self.tableView rectForRowAtIndexPath:pressedIndexPath] inView:self.tableView];
            [menuController setMenuVisible:YES animated:YES];
            
        }
    }
}


-(void)changeCarrierButtonPressed:(UIMenuController*)menuController {
    
    EmailMenuItemFor *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:3];
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        //        if (!currentStuff) {
        //            UserDataController *data = [[UserDataController alloc] init];
        //            data.context = self.managedObjectContext;
        //            currentStuff = [data authorization];
        //            if (!currentStuff) currentStuff = [data defaultUser];
        //            [data release];
        //        }
        mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        CompanyStuff *admin = [clientController authorization];
        
        NSSet *carriers = admin.carrier;
        
        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"Select carrier" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
        
        [carriers enumerateObjectsWithOptions:NSSortStable usingBlock:^(Carrier *carrier, BOOL *stop) {
            if ([clientController localStatusForObjectsWithRootGuid:carrier.GUID]) [sheet addButtonWithTitle:carrier.name];
        }];
        [clientController release];
        
        [sheet showFromTabBar:self.tabBarController.tabBar];
        
    }
}

-(void)removeDestinationButtonPressed:(UIMenuController*)menuController {
    EmailMenuItemFor *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:2];
    //if (isControllerStartedFromOutsideTabbar) menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    //else menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:1];
    
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        DestinationsListPushList *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:menuItem.indexPath.section inSection:0]];
        [changedDestinationsIDs removeObject:[object objectID]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
            [clientController removeObjectWithID:[object objectID]];
            [clientController release];
        });
        
    }
}

//-(void)removeLocalDestinationButtonPressed:(UIMenuController*)menuController 
//{
//    EmailMenuItemFor *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:2];
//    if (menuItem.indexPath) {
//        [self resignFirstResponder];
//        
//        DestinationsListPushList * object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:menuItem.indexPath.section - 1 inSection:0]];
//        //        if ([changedDestinationsIDs containsObject:[object objectID]]) [changedDestinationsIDs removeObject:[object objectID]];
//        [self.managedObjectContext deleteObject:object];
//        [self safeSave];
//        [self.tableView reloadData];
//        
//        
//    }
//    
//}


-(void)registerDestinationButtonPressed:(UIMenuController*)menuController {
    EmailMenuItemFor *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:1];
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        DestinationsListPushList *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:menuItem.indexPath.section inSection:0]];
        
        
        NSMutableDictionary *objectsForRegistration = [NSMutableDictionary dictionaryWithCapacity:0];
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:self.managedObjectContext];
        
        NSString *statusForDestination = [clientController localStatusForObjectsWithRootGuid:object.GUID];
        [objectsForRegistration setValue:object.GUID forKey:@"rootObjectGUID"];
        
        NSMutableArray *new = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        NSMutableArray *update = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
        if (statusForDestination) [update addObject:[object objectID]]; 
        else [new addObject:[object objectID]];
        
        [objectsForRegistration setObject:new forKey:@"new"];
        [objectsForRegistration setObject:update forKey:@"updated"];
        [clientController release];
        
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *selectedCarrierName = [actionSheet buttonTitleAtIndex:buttonIndex];
    //NSLog(@"selected carrier:%@",selectedCarrierName);
    
    NSIndexPath *selectedDestination = self.selectedForChangeCarrier;
    DestinationsListPushList *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:selectedDestination.section inSection:0]];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    [clientController release];
    
    NSSet *carriers = admin.carrier;
    NSSet *filteredCarriers = [carriers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@",selectedCarrierName]];
    if ([filteredCarriers count] != 1) NSLog(@"WARNING: we don't find carrier:%@ in list:%@",selectedCarrierName,carriers);
    else {
        //NSManagedObjectContext *moc = [object managedObjectContext];
        NSManagedObject *carrierToChange = [filteredCarriers anyObject];
        object.carrier = (Carrier *)[self.managedObjectContext objectWithID:carrierToChange.objectID];
    }
    
    NSNumber *rate = object.rate;
    NSNumber *newRate = [NSNumber numberWithDouble:[rate doubleValue] - 1];
    NSNumber *oldRate = [NSNumber numberWithDouble:[newRate doubleValue] + 1];
    
    object.rate = oldRate;
    
    [self safeSave];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[object objectID]] mustBeApproved:NO];
        [clientController release];
    });
    
    
}

#pragma mark -
#pragma mark UISearchDisplay Delegate Methods


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //self.bar.showsCancelButton = YES;
    //NSLog(@"searchBar:textDidChange: isFirstResponder: %i for search string:%@", [self.bar isFirstResponder],searchText);
    [fetchedResultsController release],fetchedResultsController = nil;
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:searchText];
    [self.tableView reloadData];
    
    if ([searchText isEqualToString:@""]) { 
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
    } else { 
        [self.bar becomeFirstResponder];
    }
    //NSLog(@"searchBar:textDidChange: isFirstResponder: %i for search string:%@", [self.bar isFirstResponder],searchText);
    
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{   
    [self.bar resignFirstResponder];   
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    keyboardIsShowing = YES;
    return YES;
}


#pragma mark Delegate methods of NSFetchedResultsController
- (void)importerDidSave:(NSNotification *)saveNotification {
    //NSLog(@"MERGE in destinations list controller");
    if ([NSThread isMainThread]) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
        //        [self performSelectorOnMainThread:@selector(finalSave:) withObject:self.moc waitUntilDone:YES];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
        
    } else {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:YES];
    }
    //    dispatch_async(dispatch_get_main_queue(), ^(void) { 
    //        [self.mainMoc mergeChangesFromContextDidSaveNotification:saveNotification];
    //        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
    //    });
}


- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString;
{
    //NSLog(@"fetch controller start:%@",[NSDate date]);
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country" ascending:YES];
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];//]WithObjects:sortDescriptor, nil];
                                        
    NSPredicate *filterPredicate = nil;
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = nil;
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    if (selectRoutes.selectedSegmentIndex == 0) { 
        entity = [NSEntityDescription entityForName:@"DestinationsListForSale" inManagedObjectContext:self.managedObjectContext];
        if (routesChangeFilterWithOrWithoutTraffic.selectedSegmentIndex == 0) { 
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastUsedMinutesLenght > 0)"];
            [predicateArray addObject:predicate];
            NSSortDescriptor *lastUsedMinutesLenghtDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUsedMinutesLenght" ascending:NO];
            [sortDescriptors addObject:lastUsedMinutesLenghtDescriptor];
            [sortDescriptors addObject:sortDescriptor];

            [lastUsedMinutesLenghtDescriptor release];
        }

    }
    if (selectRoutes.selectedSegmentIndex == 1) { 
        entity = [NSEntityDescription entityForName:@"DestinationsListWeBuy" inManagedObjectContext:self.managedObjectContext];
        if (routesChangeFilterWithOrWithoutTraffic.selectedSegmentIndex == 0) { 
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(lastUsedMinutesLenght > 0)"];
            [predicateArray addObject:predicate];
            NSSortDescriptor *lastUsedMinutesLenghtDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUsedMinutesLenght" ascending:NO];
            [sortDescriptors addObject:lastUsedMinutesLenghtDescriptor];
            [sortDescriptors addObject:sortDescriptor];

            [lastUsedMinutesLenghtDescriptor release];

        }

    }
    if (selectRoutes.selectedSegmentIndex == 2) entity = [NSEntityDescription entityForName:@"DestinationsListPushList" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    
    if(searchString && searchString.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(country CONTAINS[cd] %@) OR (specific CONTAINS[cd] %@)", searchString,searchString,searchString];
        [predicateArray addObject:predicate];
        

//        if(filterPredicate)
//        {
//            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
//        }
//        else
//        {
//            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
//        }
    }
    
    if (isControllerStartedFromOutsideTabbar && selectedCarrierID) {
        Carrier *selectedCarrier = (Carrier *)[self.managedObjectContext objectWithID:selectedCarrierID];
        if (selectedCarrier) { 
//            if(filterPredicate)
//            {
//                filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
//            }
//            else
//            {
//                filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
//            }
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"carrier.GUID == %@",selectedCarrier.GUID]];

//            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObject:[NSPredicate predicateWithFormat:@"carrier.GUID == %@",selectedCarrier.GUID]]];
        }
        else NSLog(@"DESTIONATIONS PUSH LIST:warning carrier not found to make predicate in fetch");
        //NSLog(@"%@",selectedCarrier.destinationsListWeBuy);
    } else {
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];

        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];            
        CompanyStuff *admin = [clientController authorization];
//        NSMutableArray *allCarriersPredicate = [NSMutableArray array];
//        NSSet *allCarriers = admin.carrier;
//        [allCarriers enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"carrier.companyStuff.GUID == %@",admin.GUID]];
//        }];
        
//        filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:allCarriersPredicate];
        [clientController release];

    }
    
    
//    if(filterPredicate)
//    {
//        filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
//    }
//    else
//    {
        filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
//    }
    //NSLog(@"DESTIONATIONS PUSH LIST:final predicate in fetch:%@ entity name:%@ sort descriptors:%@",filterPredicate,entity.name,sortDescriptors);
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    //[fetchRequest setFetchLimit:120];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    //    iphoneAppDelegate *delegate = (iphoneAppDelegate *)[UIApplication sharedApplication].delegate;
    //    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
    //    [moc setUndoManager:nil];
    //    [moc setMergePolicy:NSOverwriteMergePolicy];
    //    //[moc setMergePolicy:NSRollbackMergePolicy];
    //    [moc setPersistentStoreCoordinator:delegate.persistentStoreCoordinator];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    [fetchRequest release];[sortDescriptor release];[sortDescriptors release];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) 
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    //NSLog(@"DESTINATIONS LIST:change sections");
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    //UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            //NSLog(@"DESTINATIONS LIST:INSERT to indexpath :%@",newIndexPath);
            [tableView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeDelete:
            //NSLog(@"DESTINATIONS LIST: DELETE : %@",indexPath);
            [sections removeIndex:indexPath.row];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationFade];
            
            //[tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, tableView.numberOfSections - indexPath.row)] withRowAnimation:UITableViewRowAnimationFade];
            //self.sectionsNecessaryToReload = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.row, tableView.numberOfSections - indexPath.row)];
            break;
            
        case NSFetchedResultsChangeUpdate:
            //NSLog(@"DESTINATIONS LIST:UPDATE :%@",indexPath);
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationFade];
            //[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
        {
            //NSLog(@"DESTINATIONS LIST:CHANGE MOVE from :%@ to %@ ",indexPath,newIndexPath);
            BOOL isOpened = [sections containsIndex:indexPath.row];
            if (isOpened) {
                //NSLog(@"DESTINATIONS LIST:OPENED CHANGE MOVE from :%@ to %@ ",indexPath,newIndexPath);
                
                [sections removeIndex:indexPath.row];
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationTop];
                [sections addIndex:newIndexPath.row];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:newIndexPath.row]] withRowAnimation:UITableViewRowAnimationTop];
                [tableView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationTop];
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationFade];

            } else { 
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationFade]; 
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.row] withRowAnimation:UITableViewRowAnimationFade];

            }
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    //    sleep(1);
    //    if (self.sectionsNecessaryToReload) {
    //        NSLog(@"DESTINATIONS LIST:%@ - sections will reload",self.sectionsNecessaryToReload);
    //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:self.sectionsNecessaryToReload withRowAnimation:UITableViewRowAnimationFade];
    //    }
}

//#pragma mark TODO - move all logic to did chande section here


-(void)destinationsPushListDidChangesFor:(DestinationsListPushList *)object;
{
    //NSArray *keys = [[[object.carrier.companyStuff entity] attributesByName] allKeys];
    //NSDictionary *dict = [object.carrier.companyStuff dictionaryWithValuesForKeys:keys];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        //NSString *statusForDestination = [userController localStatusForObjectsWithRootGuid:object.GUID];
        mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
        
        NSString *statusForCarrier = [clientController localStatusForObjectsWithRootGuid:object.carrier.GUID];
        NSString *statusForCompany = [clientController localStatusForObjectsWithRootGuid:object.carrier.companyStuff.currentCompany.GUID];
        NSString *statusForStuff = [clientController localStatusForObjectsWithRootGuid:object.carrier.companyStuff.GUID];
        [clientController release];
        NSLog(@"changedDestinationsIDs addObject start:%@ - %@ - %@",statusForStuff,statusForCompany,statusForCarrier);
        
        if ( !statusForCompany || !statusForStuff || !statusForCarrier) { 
            //NSLog(@"changedDestinationsIDs addObject processing");
            
            // while company not registered, we are start for registration
            if (!statusForCarrier) {
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[object.carrier objectID]] mustBeApproved:NO];
                [clientController release];

                //NSSet *currentCarriers = object.carrier.companyStuff.carrier;
                //mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
                
                //__block ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
                
//                [currentCarriers enumerateObjectsWithOptions:NSSortStable usingBlock:^(Carrier *carrier, BOOL *stop) {
//                    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
//                    
//                    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
//
//                    NSString *statusForCarrier = [clientController localStatusForObjectsWithRootGuid:carrier.GUID];
//                    if (statusForCarrier && ![statusForCarrier isEqualToString:@"unregistered"]) [clientController release];
//                    else { 
//                        
//                        //                        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
//                        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[carrier objectID]] mustBeApproved:NO];
//                        [clientController release];
//                        
//                        //                    [userController makeRemoteChangesForObjectWithID:[carrier objectID] withAdminID:[carrier.companyStuff objectID]];
//                        
//                        //                    [userController addInRegistrationForAllObjectsInFutureArrayObject:carrier 
//                        //                                                                          forOperation:userController.controller.objectOperationNew];
//                        //                    isRoutesListUpdated = YES;
//                    }
//                }];

                
                return;
                
            }
            //        NSLog(@"u can't update routes while not register carriers");
            
            //        if (!statusForDestination)    { 
            //            //[userController addInRegistrationForAllObjectsInFutureArrayObject:object 
            //             //                                                                               forOperation:userController.controller.objectOperationNew];
            //            //isRoutesListUpdated = YES;
            //
            //        }

            return;
        }
        
        
        //    [userController addInRegistrationForAllObjectsInFutureArrayObject:object 
        //                                                         forOperation:userController.controller.objectOperationUpdate];
        //    isRoutesListUpdated = YES;
        NSLog(@"changedDestinationsIDs addObject:%@",[object objectID]);
        
        [self.changedDestinationsIDs addObject:[object objectID]];
        //    if (!isRoutesListUpdated) [self safeSave];
        [self safeSave];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[object objectID]] mustBeApproved:NO];
            [clientController release];
        });
        
    });
    //    [userController makeRemoteChangesForObjectWithID:[object objectID] withAdminID:[object.carrier.companyStuff objectID]];
    
    //    NSIndexPath *indexPath = [[self fetchedResultsController] indexPathForObject:object];
    //    //NSLog(@"indexPath.row: %@ section:%@ object opened:%@",[NSNumber numberWithUnsignedInteger:indexPath.row],[NSNumber numberWithUnsignedInteger:indexPath.section],object.opened);
    //
    //    if (object.opened) [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:indexPath.row]] withRowAnimation:UITableViewRowAnimationNone];
    //    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.row] withRowAnimation:UITableViewRowAnimationNone];
    //    NSIndexPath *updatedDestinationPath = [[self fetchedResultsController] indexPathForObject:object];
    //    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:updatedDestinationPath.section] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark change view
- (void) selectRoutesStart:(id) sender
{
//    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        NSUInteger selectedSegmentIndex = [sender selectedSegmentIndex];
//
//        if (selectedSegmentIndex == 0 && self.isRoutesForSaleListUpdated) progressView.hidden = NO; 
//        else progressView.hidden = YES;
//        if (selectedSegmentIndex == 1 && self.isRoutesWeBuyListUpdated) progressView.hidden = NO;
//        else progressView.hidden = YES;
    if (selectedSegmentIndex == 2) [self.navigationController setToolbarHidden:YES animated:YES];
    else [self.navigationController setToolbarHidden:NO animated:YES];

    //    });
    
    [fetchedResultsController release],fetchedResultsController = nil;
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    [self.tableView reloadData];
    [self updateDestinations];
}

- (void) addNewRoute:(id) sender
{
    if (sections.count > 0) {
        [self.tableView beginUpdates];
        
        NSUInteger previousOpenedSection = [sections lastIndex];
        [sections removeAllIndexes];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:previousOpenedSection]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
    [self.bar resignFirstResponder];
    //  UISegmentedControl *senderSegmented = sender;
    
    
    self.addRoutesNavigationView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:addRoutesNavigationView animated:YES]; 
}
- (IBAction)cancelUpdateStart:(id)sender {
    cancelAllUpdatesButton.enabled = NO;
    self.cancelAllUpdates = YES;
}
- (IBAction)changeRoutesWithOrWithoutTraffic:(id)sender {
    [fetchedResultsController release],fetchedResultsController = nil;
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    [self.tableView reloadData];

}
- (IBAction)sendToTwitter:(id)sender {
    EmailMenuItemFor *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    if (menuItem.indexPath) {
        DestinationsListPushList *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:menuItem.indexPath.section inSection:0]];
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([delegate isTwitterAuthorized]) [delegate updateTwitterMessagesForDestinations:[NSArray arrayWithObject:object.objectID]]; 

    }

}

- (IBAction)sendToLinkedin:(id)sender {
    EmailMenuItemFor *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:1];
    if (menuItem.indexPath) {
        DestinationsListPushList *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:menuItem.indexPath.section inSection:0]];
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([delegate isLinkedinAuthoruzed]) [delegate postToLinkedinGroupsForDestinations:[NSArray arrayWithObject:object.objectID]];

    }

    
}

- (IBAction)sendAllToTwitter:(id)sender {
    
    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListPushList"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carrier.companyStuff.GUID == %@",admin.GUID];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country"
                                                                   ascending:YES];
    NSSortDescriptor *sortDescriptorSpecific = [[NSSortDescriptor alloc] initWithKey:@"specific"
                                                                           ascending:YES];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,sortDescriptorSpecific, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setResultType:NSManagedObjectIDResultType];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    if ([delegate isTwitterAuthorized]) [delegate updateTwitterMessagesForDestinations:fetchedObjects];

    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptorSpecific release];
    [sortDescriptors release];

    
}

- (IBAction)sendAllToLinkedin:(id)sender {
    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListPushList"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carrier.companyStuff.GUID == %@",admin.GUID];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country"
                                                                   ascending:YES];
    NSSortDescriptor *sortDescriptorSpecific = [[NSSortDescriptor alloc] initWithKey:@"specific"
                                                                   ascending:YES];

    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,sortDescriptorSpecific, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setResultType:NSManagedObjectIDResultType];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    if ([delegate isLinkedinAuthoruzed]) [delegate postToLinkedinGroupsForDestinations:fetchedObjects];
    
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptorSpecific release];
    [sortDescriptors release];

    
}
- (IBAction)didClickConfig:(id)sender {
    [self becomeFirstResponder];
    NSString *twitTitle = nil;
    NSString *linkedinTitle = nil;
    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegate isLinkedinAuthoruzed]) linkedinTitle = @"Linkedin all";
    else linkedinTitle = @"Linedin (restricted)";
    if ([delegate isTwitterAuthorized]) twitTitle = @"Twit all";
    else twitTitle = @"Twit (restricted)";

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    NSMutableArray *menuItems = [NSMutableArray array];
    UIMenuItem *menuItemAdd = [[UIMenuItem alloc] initWithTitle:@"Add" action:@selector(addNewRoute:)];
    [menuItems addObject:menuItemAdd];
    UIMenuItem *menuItemTwitter = [[UIMenuItem alloc] initWithTitle:twitTitle action:@selector(sendAllToTwitter:)];
    [menuItems addObject:menuItemTwitter];
    UIMenuItem *menuItemLinkedin = [[UIMenuItem alloc] initWithTitle:linkedinTitle action:@selector(sendAllToLinkedin:)];
    [menuItems addObject:menuItemLinkedin];
    
    
    menuController.menuItems = [NSArray arrayWithArray:menuItems];
    [menuItemAdd release],[menuItemLinkedin release],[menuItemTwitter release];
//    menuController.arrowDirection = UIMenuControllerArrowLeft;
    [menuController setTargetRect:CGRectMake(320, 50, 0, 0) inView:self.navigationController.view];
    [menuController setMenuVisible:YES animated:YES];
}
#pragma mark - external reload methods

-(void) reloadLocalDataFromUserDataControllerForObject:(id)object;
{
    //    dispatch_async(dispatch_get_main_queue(), ^(void) {
    //        NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    //        [self.tableView reloadData];
    //        [self.tableView selectRowAtIndexPath:selected animated:YES scrollPosition:UITableViewScrollPositionNone];
    //                                   
    //        
    //    });
}
-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    NSString *status = [data objectAtIndex:0];
    //NSLog(@"DESTINATIONS LIST: updated UI: status is:%@",status);
    
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSNumber *isError = [data objectAtIndex:3];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        [alert removeAllSegments];
//        [alert insertSegmentWithTitle:status atIndex:0 animated:YES];
//        [self.navigationController setToolbarHidden:NO animated:YES];
    });
    //    if ([isError boolValue]) {
    //        dispatch_async(dispatch_get_main_queue(), ^(void) { 
    ////            UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:status]] autorelease];
    ////            alert.segmentedControlStyle = UISegmentedControlStyleBar;
    ////            alert.frame = CGRectMake(0, (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height)/2, self.navigationController.toolbar.bounds.size.width - (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height), alert.frame.size.height);
    ////            alert.userInteractionEnabled = NO;
    ////            //alert.selectedSegmentIndex = 0;
    ////            alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];;
    ////            
    ////            UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:alert] autorelease];
    ////            
    ////            
    ////            [self setToolbarItems:[NSArray arrayWithObject:item]];
    ////            self.navigationController.toolbar.translucent = YES;
    ////            self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
    ////            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    ////            
    ////            self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
    //            [alert removeAllSegments];
    //            [alert insertSegmentWithTitle:status atIndex:0 animated:NO];
    //
    //            [self.navigationController setToolbarHidden:NO animated:YES];
    //        });
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
    //            sleep(10);
    //            dispatch_async(dispatch_get_main_queue(), ^(void) { 
    //                [self.navigationController setToolbarHidden:YES animated:YES]; 
    //            });
    //        });
    //        
    //        // present modal
    //    }
    
    NSManagedObjectID *objectID = nil;
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    
    if ([isItLatestMessage boolValue] || [isError boolValue]) {    
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
//            isRoutesListUpdated = NO;
            //NSLog(@"isRoutesListUpdated = NO;");
            
//            [self.navigationController setToolbarHidden:YES animated:YES];
        });
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            if ([status isEqualToString:@"progress for update graph:DestinationsListWeBuy"]) {
                NSNumber *progress = [data objectAtIndex:1];
                
                operationProgress.progress = progress.floatValue;
                operationProgress.hidden = NO;
                operationTitle.text = @"we buy";
            }
            if ([status isEqualToString:@"progress for update graph:DestinationsListForSale"]) {
                NSNumber *progress = [data objectAtIndex:1];
                operationProgress.progress = progress.floatValue;
                operationProgress.hidden = NO;
                operationTitle.text = @"for sale";
            }
            if ([status isEqualToString:@"server download progress"]) {
                NSNumber *progress = [data objectAtIndex:1];
                operationProgress.progress = progress.floatValue;
                operationProgress.hidden = NO;            
            }
        });
        
    }
    if (objectID) {
        //if ([idsWithProgress containsObject:objectID] && ![isItLatestMessage boolValue]) return;
        //[idsWithProgress addObject:objectID];
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            DestinationsListPushList *updatedDestination = (DestinationsListPushList *)[self.managedObjectContext objectWithID:objectID];
            NSIndexPath *objectIndexPath = [self.fetchedResultsController indexPathForObject:updatedDestination];
            
            if ([[[updatedDestination entity] name] isEqualToString:@"DestinationsListPushList"]) {
                
                //if (updatedDestination.opened) [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:objectIndexPath.row]] withRowAnimation:UITableViewRowAnimationNone];
            }
            DestinationsPushListCell *cell = (DestinationsPushListCell *)[self.tableView cellForRowAtIndexPath:objectIndexPath];
            
            
            if (![isItLatestMessage boolValue]) {
                [cell.activity startAnimating];
                cell.activity.hidden = NO;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                //                [alert removeAllSegments];
                //                [alert insertSegmentWithTitle:status atIndex:0 animated:YES];
                //                [self.navigationController setToolbarHidden:NO animated:YES];
                
                
            } else {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//                isRoutesListUpdated = NO;
                //[self.navigationController setToolbarHidden:YES animated:YES];
                carriersProgress.hidden = YES;
                carriersProgressTitle.hidden = YES;
                operationTitle.hidden = YES;
                operationProgress.hidden = YES;
                routesChangeFilterWithOrWithoutTraffic.hidden = NO;
                //NSLog(@"routesChangeFilterWithOrWithoutTraffic.hidden = NO;");

                [cell.activity stopAnimating];
                cell.activity.hidden = YES;
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                    sleep(10);
//                    dispatch_async(dispatch_get_main_queue(), ^(void) { 
//                        [self.navigationController setToolbarHidden:YES animated:YES]; 
//                    });
//                });
                
                if ([status isEqualToString:@"remove object finish"] || [status isEqualToString:@"destination for removing not found"]) { 
                    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                    
                    [self.managedObjectContext deleteObject:updatedDestination];
                    //[[self fetchedResultsController] performFetch:nil];
                    [self safeSave];
                    
                    //sleep(1);
                    // dispatch_async(dispatch_get_main_queue(), ^(void) { 
                    
                    [self.tableView reloadData];
                    // });
                    //});
                    
                }
                
            }
            
        });
    }
    //    if ([status isEqualToString:@"get all objects finish "]) { 
    //        [self.tableView reloadData];
    //    }
    
    //withProgressEnabled:(BOOL)isProgressEnabled forObjectID:(NSManagedObjectID *)objectID andPercent:(NSNumber *)percent
    //NSLog(@"DESTINATIONS PUSH LIST:update UI:%@ latest message:%@",status,isItLatestMessage);
    
    
    
}

-(void)helpShowingDidFinish;
{
    self.tableView.alpha = 1.0;
}


#pragma mark - core data methods


-(void) safeSave;
{
    //NSLog(@"SAVED");
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) [self.managedObjectContext save:&error];
    if (error) NSLog(@"%@",[error localizedDescription]);
}

@end
