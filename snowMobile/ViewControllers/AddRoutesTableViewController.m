//
//  RoutesTableViewController.m
//  snow
//
//  Created by Oleksii Vynogradov on 14.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "AddRoutesTableViewController.h"
//#import "SectionHeaderView.h"
//#import "SearchSectionHeaderView.h"
#import "CountrySpecificCodeList.h"
#import "CodesList.h"
#import "AddRoutesCodesCellTextView.h"
#import "DestinationsListPushListTableViewController.h"
#import "DestinationsListPushList.h"
#import "CurrentCompany.h"
#import "CompanyStuff.h"
#import "Carrier.h"
//#import "UserDataController.h"
//#import "AVSearchDisplayController.h"
#import "ClientController.h"
#import "mobileAppDelegate.h"

#import "SpecificCodesCell.h"
#import <QuartzCore/QuartzCore.h>

#import "NormalizedCountryTransformer.h"
#import "NormalizedSpecificTransformer.h"
#import "NormalizedCodesTransformer.h"
#import "HelpForInfoView.h"

#pragma mark -
#pragma mark EmailMenuItem

@interface AddRouteMenuItem : UIMenuItem {
}
@property (nonatomic, retain) NSIndexPath* indexPath;
@end

@implementation AddRouteMenuItem
@synthesize indexPath;
- (void)dealloc {
    [indexPath release];
    [super dealloc];
}
@end


#pragma mark -
#pragma mark TableViewController


// Private RoutesTableViewController properties and methods.
@interface AddRoutesTableViewController ()

//@property (nonatomic, retain) NSMutableArray* sectionInfoArray;
@property (nonatomic, retain) NSIndexPath* pinchedIndexPath;
@property (nonatomic, assign) NSInteger openSectionIndex;
@property (nonatomic, assign) NSInteger closedSectionIndex;
@property (nonatomic, assign) CGFloat initialPinchHeight;
//@property (nonatomic) BOOL isLoading;
//@property (nonatomic,retain) UITableView *searchTableView;
@property (nonatomic, retain) NSMutableString *previousSearchString;

// Use the uniformRowHeight property if the pinch gesture should change all row heights simultaneously.
@property (nonatomic, assign) NSInteger uniformRowHeight;
@property (nonatomic, retain) NSArray* sectionsTitles;

-(void)updateForPinchScale:(CGFloat)scale atIndexPath:(NSIndexPath*)indexPath;

-(void)addRouteMenuButtonPressed:(UIMenuController*)menuController;
-(void)addRouteForEntryAtIndexPath:(NSIndexPath*)indexPath;
- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString;
-(void)safeSave;

@end

#define DEFAULT_ROW_HEIGHT 78
#define HEADER_HEIGHT 65

@implementation AddRoutesTableViewController

@synthesize quoteCell=newsCell_, pinchedIndexPath=pinchedIndexPath_, uniformRowHeight=rowHeight_, openSectionIndex=openSectionIndex_, initialPinchHeight=initialPinchHeight_, closedSectionIndex = closedSectionIndex_;
//@synthesize mySearchDisplayController;
@synthesize bar;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
//@synthesize fetchResultControllerSearch;
//@synthesize searchIsActive;
//@synthesize routeAddIsActive;
@synthesize destinationsPushListView;
//@synthesize home;
//@synthesize stuff;
//@synthesize userController;
//@synthesize isLoading;
//@synthesize searchTableView;
@synthesize previousSearchString;
@synthesize routesList;
@synthesize sectionsTitles;

#pragma mark Memory management

-(void)dealloc {
    
    //[countriesForSections release];
    //[sectionInfoArray_ release];
    [fetchedResultsController release];
    [previousSearchString release];   
    [super dealloc];
    
}
#pragma mark Initialization and configuration


-(BOOL)canBecomeFirstResponder {
    return YES;
}
#pragma mark TODO - first load bug - not updated fetch controller
-(NSArray *) indexForSectionIndexTitlesForEntity:(NSString *)entityName;
{
    __block NSString *entityNameBlock = entityName;
    
    __block NSMutableArray *countForLetters = [NSMutableArray arrayWithCapacity:0];
    __block NSMutableArray *letters = [NSMutableArray arrayWithCapacity:0];
    [letters addObject:UITableViewIndexSearch];

    __block NSUInteger total = 0;
//    iphoneAppDelegate *delegate = (iphoneAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
//    CompanyStuff *admin = [clientController authorization];
//    __block NSString *adminGUID = admin.GUID;
//    
//    [clientController release];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityNameBlock
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"country"]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchedObjects enumerateObjectsUsingBlock:^(NSDictionary *country, NSUInteger idx, BOOL *stop) {
        NSString *countryName = [country valueForKey:@"country"];
        NSString *letter = [countryName substringWithRange:NSMakeRange(0, 1)];
        [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letter,@"letter",[NSNumber numberWithInteger:total],@"index", nil]];
        [letters addObject:letter];

        total += 1;

    }];
    [fetchRequest release];
    
//    __block NSArray *allLetters = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil]; 
//    [allLetters enumerateObjectsUsingBlock:^(NSString *letter, NSUInteger idx, BOOL *stop) {
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:entityNameBlock
//                                                  inManagedObjectContext:self.managedObjectContext];
//        [fetchRequest setEntity:entity];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country BEGINSWITH [c] %@",letter];
//        [fetchRequest setPredicate:predicate];
//        NSLog(@"check for predicate:%@",predicate);
//        
//        NSError *error = nil;
//        NSInteger fetchedObjects = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects > 0) { 
//            [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letter,@"letter",[NSNumber numberWithInteger:total],@"index", nil]];
//            [letters addObject:letter];
//        }
//        total += fetchedObjects;
//        [fetchRequest release];
//        
//    }];
    
    [countForLetters addObject:[NSDictionary dictionaryWithObjectsAndKeys:letters,@"letters", nil]];
    
    
    return [NSArray arrayWithArray:countForLetters];
}

- (void)viewDidLoad {

    
    [super viewDidLoad];
    // Add a pinch gesture recognizer to the table view.
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self.tableView addGestureRecognizer:pinchRecognizer];
	[pinchRecognizer release]; 
    
    
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];

    // Set up default values.
    self.tableView.sectionHeaderHeight = HEADER_HEIGHT;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];


    self.tableView.separatorColor = [UIColor whiteColor];
    rowHeight_ = DEFAULT_ROW_HEIGHT;
    openSectionIndex_ = NSNotFound;

    UIView *segmentedBlock = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 44)];
    routesList =  [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Routes list", nil]];
    routesList.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
    routesList.segmentedControlStyle = UISegmentedControlStyleBar;
    routesList.frame = CGRectMake(routesList.frame.origin.x + 230, routesList.frame.origin.y + 7, routesList.frame.size.width, routesList.frame.size.height);
    [routesList addTarget:self action:@selector(returnToDestinationsList:) forControlEvents:UIControlEventAllEvents];
    [segmentedBlock addSubview:routesList];
    
    bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0,  220.0, 45)];
    for ( UIView *subview in self.bar.subviews) 
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] ) [subview removeFromSuperview];
    }
    //[newBar setContentInset:UIEdgeInsetsMake(5, 0, 5, 35)];
    
    [segmentedBlock addSubview:self.bar];
    self.navigationItem.titleView = segmentedBlock;
    [segmentedBlock release];
    [routesList release];
    
    self.bar.delegate = self;
    self.bar.showsCancelButton = NO;
    self.bar.autocorrectionType = UITextAutocorrectionTypeNo;
    
//    self.bar.placeholder = @"long press to add";
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        sleep(5);
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            self.bar.placeholder = @"country,code,specific";});
//        
//    });
    if (!self.previousSearchString) previousSearchString = [[NSMutableString alloc] initWithString:@""];
    sectionsTitles = [[NSArray alloc] initWithArray:[self indexForSectionIndexTitlesForEntity:@"CountrySpecificCodeList"]];

}

- (void)viewWillAppear:(BOOL)animated {


	[super viewWillAppear:animated]; 
    routesList.selectedSegmentIndex = -1;
    self.bar.placeholder = @"long press to add";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        sleep(5);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.bar.placeholder = @"country,code,specific";});
    });
    HelpForInfoView *helpView = [[HelpForInfoView alloc] init];
    helpView.isAddRoutesSheet = YES;
    if ([helpView isHelpNecessary]) {
        self.tableView.alpha = 0.7;
        helpView.delegate = self;
        [self.navigationController.view addSubview:helpView.view];
    } else [helpView release];

}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    // To reduce memory pressure, reset the section info array if the view is unloaded.
	//self.sectionInfoArray = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
#pragma mark Table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    NSInteger count = [[[self fetchedResultsController] sections] count];
    //NSLog(@"Sections:%@",[NSNumber numberWithUnsignedInteger:count]);
    return count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    
    // search string section
    id <NSFetchedResultsSectionInfo> sectionInfoCoreData = nil;
    sectionInfoCoreData = [[[self fetchedResultsController] sections] objectAtIndex:section];
	NSInteger numSpecificsInSection = [sectionInfoCoreData numberOfObjects];
    NSArray *objectsOfSection = [sectionInfoCoreData objects];
    CountrySpecificCodeList *object = [objectsOfSection objectAtIndex:0];

    
    NSInteger finalResult = [object.opened boolValue] ? numSpecificsInSection : 0;
    //if (finalResult != 0) self.tableView.separatorColor = [UIColor whiteColor];
    //else self.tableView.separatorColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
    //else self.tableView.separatorColor = [UIColor whiteColor];

    //if (self.closedSectionIndex == section) finalResult = 0;
    //NSLog(@"Number of rows in section:%@ for country:%@ = %@ with current state:%@ with closedSectionIndex:%@",[NSNumber numberWithUnsignedInteger:section],object.country,[NSNumber numberWithUnsignedInteger:finalResult],[object.opened boolValue] ? @"YES" : @"NO",[NSNumber numberWithInteger:self.closedSectionIndex]);

    /*if (section == 240) {
        NSLog(@"Number of rows in section:%@ for country:%@ = %@ with current state:%@ with closedSectionIndex:%@",[NSNumber numberWithUnsignedInteger:section],object.country,[NSNumber numberWithUnsignedInteger:finalResult],[object.opened boolValue] ? @"YES" : @"NO",[NSNumber numberWithInteger:self.closedSectionIndex]);
    }*/

    return finalResult;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return HEADER_HEIGHT;
}


-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    static NSString *SpecificCodesCellIdentifier = @"QuoteCellIdentifier";

    SpecificCodesCell *cell = (SpecificCodesCell*)[tableView dequeueReusableCellWithIdentifier:SpecificCodesCellIdentifier];
    
    if (!cell) {
        
        UINib *quoteCellNib = [UINib nibWithNibName:@"QuoteCell" bundle:nil];
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.quoteCell;
        self.quoteCell = nil;

        //NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
        NSIndexPath *new = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        CountrySpecificCodeList *managedObject = [[self fetchedResultsController] objectAtIndexPath:new];
        cell.specific.text = managedObject.specific;
        cell.codes.text = managedObject.codes;
        cell.codes.backgroundColor = [UIColor clearColor];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [cell addGestureRecognizer:longPressRecognizer];      
        [longPressRecognizer release];
        //if (!managedObject.opened) cell.frame.size.height = 8000;

    }
    return cell;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    

    self.tableView.sectionHeaderHeight = HEADER_HEIGHT;

    NSIndexPath *new = [NSIndexPath indexPathForRow:0 inSection:section];
    NSManagedObjectID *managedObjectID = [[[self fetchedResultsController] objectAtIndexPath:new] objectID];
    
    id <NSFetchedResultsSectionInfo> sectionInfoCoreData = [[[self fetchedResultsController] sections] objectAtIndex:section];
    NSManagedObject *object = [[sectionInfoCoreData objects] objectAtIndex:0];


    UIView *viewSection = [[[AddRoutesHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, HEADER_HEIGHT) 
                                                           objectID:managedObjectID 
                                                            section:section
                                                        sectionName:[sectionInfoCoreData name]
                                                             opened:[[object valueForKey:@"opened"] boolValue]
                                                           delegate:self
                                                   ] autorelease];
    return viewSection;
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    CGFloat returnResult = 0;
    
    NSIndexPath *new = nil;
    new = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    CountrySpecificCodeList *managedObject = [[self fetchedResultsController] objectAtIndexPath:new];
    returnResult = [managedObject.rowHeight floatValue];
    //NSLog(@"For section:%@ height is %@ object is:%@",indexPath, [NSNumber numberWithFloat:returnResult],managedObject);
    return returnResult;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //NSLog(@"%@",sectionsTitles);

    return [[sectionsTitles lastObject] valueForKey:@"letters"]; 
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title isEqualToString:UITableViewIndexSearch]) return 0;

    NSPredicate *letterPredicate = [NSPredicate predicateWithFormat:@"letter == %@",title];
    NSArray *sectionTitlesFiltered = [sectionsTitles filteredArrayUsingPredicate:letterPredicate];
    if ([sectionTitlesFiltered count] == 0) NSLog(@"COUNTRIES LIST: >>>> warning, for title %@ index not found",title);
    else return [[[sectionTitlesFiltered lastObject] valueForKey:@"index"] unsignedIntegerValue];
    //NSLog(@"sectionForSectionIndexTitle:%@ and index:%@ return value is:%@",title,[NSNumber numberWithUnsignedInteger:index],[NSNumber numberWithUnsignedInteger:index * 12]);
    //return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index - 1];
    return 0;
}

#pragma mark Section header delegate

-(void)sectionHeaderView:(AddRoutesHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    //self.tableView.separatorColor = [UIColor whiteColor];
    [self.bar resignFirstResponder];

    //NSLog(@"tap:%@",[NSDate date]);
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    //UITableView *currentTableView = nil;
    //if (self.fetchedResultsController) currentTableView = self.tableView;
    //if (self.fetchResultControllerSearch) currentTableView = self.mySearchDisplayController.searchResultsTableView;

    id <NSFetchedResultsSectionInfo> sectionInfoCoreData = nil;
    CountrySpecificCodeList *object = nil;
    sectionInfoCoreData = [[[self fetchedResultsController] sections] objectAtIndex:sectionOpened];
    object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionOpened]];

    NSInteger countOfRowsToInsert = [sectionInfoCoreData numberOfObjects];
    
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    object.opened = [NSNumber numberWithBool:YES];
    
     NSInteger previousOpenSectionIndex = self.openSectionIndex;

    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    //UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        //deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        //deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // Apply the updates.
    //if (!searchIsActive) {
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    //self.tableView.separatorColor = [UIColor whiteColor];

    //}
    /*if (searchIsActive) {   
        [self.mySearchDisplayController.searchResultsTableView beginUpdates];
        [self.mySearchDisplayController.searchResultsTableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
        [self.mySearchDisplayController.searchResultsTableView endUpdates];
    }*/
    
    self.openSectionIndex = sectionOpened;
    
    //NSLog(@"openSectionIndex = %d for event = %@",self.openSectionIndex,[sectionInfo.event valueForKey:@"country"]);

    [indexPathsToInsert release];
    //NSLog(@"opened:%@",[NSDate date]);


}


-(void)sectionHeaderView:(AddRoutesHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    [self.bar resignFirstResponder];

    NSInteger countOfRowsToDelete;
    //self.tableView.separatorColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];

    //UITableView *currentTableView = nil;

    //if (!searchIsActive) currentTableView = self.tableView;
    //if (searchIsActive) currentTableView = self.mySearchDisplayController.searchResultsTableView;

    
    id <NSFetchedResultsSectionInfo> sectionInfoCoreData = nil;
    sectionInfoCoreData = [[[self fetchedResultsController] sections] objectAtIndex:sectionClosed];
    
    countOfRowsToDelete  = [sectionInfoCoreData numberOfObjects];
    NSArray *objectsInSection = [sectionInfoCoreData objects];
    CountrySpecificCodeList *object = [objectsInSection objectAtIndex:0];
    
    //NSLog(@"Previous opened = %d for event = %@",previousOpenSectionIndex,previousOpenSection.event);
    
    object.opened = [NSNumber numberWithBool:NO];

    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        //if (!searchIsActive) { 
            [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
            //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        //}
        //if (searchIsActive) {
        //    [self.mySearchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
        //}
        [indexPathsToDelete release];
    }
    self.openSectionIndex = NSNotFound;
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
		self.pinchedIndexPath = newPinchedIndexPath;
        
        CountrySpecificCodeList *object = nil;
        object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:newPinchedIndexPath.row inSection:newPinchedIndexPath.section]];

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
        
        CountrySpecificCodeList *object = nil;
        //if (!searchIsActive) 
            object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
        //if (searchIsActive)  object = [[self fetchedResultsControllerForTableView:self.searchDisplayController.searchResultsTableView] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section -1]];

        object.rowHeight = [NSNumber numberWithFloat:newHeight];
        //NSLog(@"Object updated is:%@",object);

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
        //self.tableView.separatorColor = [UIColor whiteColor];

        //}
        //if (searchIsActive){
        //    
        //    [self.mySearchDisplayController.searchResultsTableView beginUpdates];
        //    [self.mySearchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //    [self.mySearchDisplayController.searchResultsTableView endUpdates];
        //}
   
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
        
        if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
            [self becomeFirstResponder];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            AddRouteMenuItem *menuItem = [[AddRouteMenuItem alloc] initWithTitle:@"Add to push list" action:@selector(addRouteMenuButtonPressed:)];
            menuItem.indexPath = pressedIndexPath;
            menuController.menuItems = [NSArray arrayWithObject:menuItem];
            [menuItem release];
            [menuController setTargetRect:[self.tableView rectForRowAtIndexPath:pressedIndexPath] inView:self.tableView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}


-(void)addRouteMenuButtonPressed:(UIMenuController*)menuController {
    
    AddRouteMenuItem *menuItem = [[[UIMenuController sharedMenuController] menuItems] objectAtIndex:0];
    if (menuItem.indexPath) {
        [self resignFirstResponder];
        [self addRouteForEntryAtIndexPath:menuItem.indexPath];
    }
}


-(void)addRouteForEntryAtIndexPath:(NSIndexPath*)indexPath {
    //NSError *error = nil;
    CountrySpecificCodeList *object = nil;
   //if (!searchIsActive)  
       object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    //else object = [[self fetchedResultsControllerForTableView:self.searchDisplayController.searchResultsTableView] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    
//    UserDataController *data = [[UserDataController alloc] init];
//    data.context = self.managedObjectContext;
//    CompanyStuff *currentStuff = [data authorization];
//    if (!currentStuff) currentStuff = [data defaultUser];
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:self.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    
    Carrier *carrier = nil;
    
    if (destinationsPushListView.isControllerStartedFromOutsideTabbar && destinationsPushListView.selectedCarrierID) {
        carrier = (Carrier *)[clientController.moc objectWithID:destinationsPushListView.selectedCarrierID];
        if (![carrier.companyStuff.objectID isEqual:admin.objectID]) carrier = [admin.carrier anyObject];
    } else carrier = [admin.carrier anyObject];
    
    
    if (!carrier) { 
        carrier = (Carrier *)[NSEntityDescription insertNewObjectForEntityForName:@"Carrier" inManagedObjectContext:clientController.moc];
        carrier.companyStuff = admin;
        carrier.name = @"new carrier";
        NSError *error = nil;
        [clientController.moc save:&error];
        if (error) NSLog(@"ADD ROUTES: error to save client moc to add new carrier");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[carrier objectID]] mustBeApproved:NO];
            [clientController release];
        });
    }
    
    DestinationsListPushList *newDestination = (DestinationsListPushList *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListPushList" inManagedObjectContext:clientController.moc];
    newDestination.carrier = carrier;
    newDestination.country = object.country;
    newDestination.specific = object.specific;
    NSError *error = nil;
    [clientController.moc save:&error];
    if (error) NSLog(@"ADD ROUTES: error to save client moc to add new carrier");
    [clientController release];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[newDestination objectID]] mustBeApproved:NO];
        [clientController release];
    });
    
    [destinationsPushListView.tableView reloadData];

//    NSArray *keys = [[[stuff entity] attributesByName] allKeys];
//    NSDictionary *dict = [stuff dictionaryWithValuesForKeys:keys];
//    
//    NSString *statusForCarrier = [userController localStatusForObjectsWithRootGuid:carrier.GUID];
//    NSString *statusForCompany = [userController localStatusForObjectsWithRootGuid:carrier.companyStuff.currentCompany.GUID];
//    NSString *statusForStuff = [userController localStatusForObjectsWithRootGuid:carrier.companyStuff.GUID];
//
//    if (!statusForCarrier || !statusForCompany || !statusForStuff) {
//        NSLog(@"u can't add routes while not register other");
//        [data release];
//        return; 
//    }
//    [self.managedObjectContext save:&error];
//    if (error) NSLog(@"%@",[error localizedDescription]);
//
//    NSDictionary *opjectsForRegistration = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:[newDestination objectID]], @"new", newDestination.GUID, @"rootObjectGUID", nil];
//
//    [userController startRegistrationForObjects:opjectsForRegistration 
//                                   forTableView:nil
//                                      forSender:self 
//                            clientStuffFullInfo:dict];
//    
     //startRegistrationForObject:newDestination forTableView:destinationsPushListView.tableView forSender:self clientStuffFullInfo:dict];

    //NSLog(@"Add route:%@",newDestination);

    //[data release];
    //[self.destinationsPushListView.tableView reloadData];
}


#pragma mark -
#pragma mark Content Filtering

//- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
//{
//    if ([searchText length] < 2) return;
//
//    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
//    //self.fetchResultControllerSearch.delegate = nil;
//    //self.fetchResultControllerSearch = nil;
//    
//    //self.fetchResultControllerSearch = [self fetchResultControllerSearch];
//    // if you care about the scope save off the index to be used by the serchFetchedResultsController
//    //self.savedScopeButtonIndex = scope;
//    
//    
//}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods
//
//- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
//{
//    NSLog(@"willUnloadSearchResultsTableView");
//    //self.fetchResultControllerSearch.delegate = nil;
//    //self.fetchResultControllerSearch = nil;
//    //self.searchIsActive = NO;
//
//    //[self sectionInfoReload];
//
//}
//
//
//- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
//{
//   NSLog(@"searchDisplayControllerWillBeginSearch");
//    [controller.searchResultsTableView setRowHeight:80000];
//
//   // self.searchIsActive = YES;
//
//}
//
//- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
//{
//    NSLog(@"searchDisplayControllerDidBeginSearch");
//    UIButton *cancelButtonInSearch = nil;
//    self.bar.showsCancelButton = YES;
//    
//    for ( UIView * subview in self.bar.subviews) 
//    {
//        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] ) 
//            [subview removeFromSuperview];
//        if ([subview isKindOfClass:[UIButton class]]) cancelButtonInSearch = (UIButton*)subview;
//        
//    }
//    if (cancelButtonInSearch) {
//        cancelButtonInSearch.titleLabel.text = @"Routes list";
//        /*[cancelButtonInSearch setTitle:@"Routes list" forState:UIControlStateNormal];
//        [cancelButtonInSearch setTitle:@"Routes list" forState:UIControlStateHighlighted];
//        [cancelButtonInSearch setTitle:@"Routes list" forState:UIControlStateDisabled];
//        [cancelButtonInSearch setTitle:@"Routes list" forState:UIControlStateSelected];
//        [cancelButtonInSearch setTitle:@"Routes list" forState:UIControlStateApplication];
//        [cancelButtonInSearch setTitle:@"Routes list" forState:UIControlStateReserved];*/
//        NSLog(@"cancelButtonInSearch state is:%@",[cancelButtonInSearch titleLabel]);
//        //[cancelButtonInSearch setEnabled:YES];
//        [cancelButtonInSearch addTarget:self action:@selector(returnToDestinationsList:) forControlEvents:UIControlEventTouchDown];
//    } else NSLog(@"ADD ROUTES:cancelButtonInSearch is nil");
//
//    //self.tableView.hidden = YES;
//
//}
//
//- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
//{
//   //NSLog(@"bla2");
//    //self.searchIsActive = NO;
//   // self.tableView.hidden = NO;
//
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    NSLog(@"shouldReloadTableForSearchString");
//    //isLoading = YES;
//    
//    //self.searchIsActive = YES;
//
//    //[self filterContentForSearchText:searchString 
//      //                             scope:[self.mySearchDisplayController.searchBar selectedScopeButtonIndex]];
//    NSLog(@"shouldReloadTableForSearchString predicate start");
//
//    //[self.countriesForSections filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchString]];
//    NSLog(@"shouldReloadTableForSearchString predicate stop");
//
//    [controller.searchResultsTableView setRowHeight:80000];
//    
//
//    /*for(UIView *subview in self.mySearchDisplayController.searchResultsTableView.subviews) {
//        if([subview isKindOfClass:UILabel.class]) {
//            subview.hidden = YES;
//        }
//    }*/
//    
//    //[self sectionInfoReload];
//    return YES;
//}
//
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
//{
//    NSLog(@"shouldReloadTableForSearchScope");
//
//    //if ([[self.mySearchDisplayController.searchBar text] length] < 2) return NO;
//    //[self filterContentForSearchText:[self.mySearchDisplayController.searchBar text] 
//    //                           scope:[self.mySearchDisplayController.searchBar selectedScopeButtonIndex]];
//    return YES;
//}
//-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView 
//{
//    NSLog(@"didLoadSearchResultsTableView");
//    //searchTableView = tableView;
//    tableView.sectionHeaderHeight = HEADER_HEIGHT;
//    tableView.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
//    tableView.separatorColor = [UIColor whiteColor];
//
//}
//
//
//- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
//{
//    NSLog(@"searchDisplayControllerDidEndSearch");
//    self.tableView.hidden = NO;
//
//    self.bar.showsCancelButton = YES;
//    UIButton *cancelButtonInSearch = nil;
//    
//    for ( UIView * subview in self.bar.subviews) 
//    {
//        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] ) 
//            [subview removeFromSuperview];
//        if ([subview isKindOfClass:[UIButton class]]) cancelButtonInSearch = (UIButton*)subview;
//        
//    }
//    if (cancelButtonInSearch) {
//        [cancelButtonInSearch setTitle:@"Routes list" forState:UIControlStateNormal];
//        [cancelButtonInSearch setEnabled:YES];
//        [cancelButtonInSearch addTarget:self action:@selector(returnToDestinationsList:) forControlEvents:UIControlEventTouchDown];
//    }
//
//    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //NSLog(@"textDidChange");
    //NSLog(@"textDidChange predicate start for:%@",searchText);
    //[fetchResultController release];
    //NSString *finalSearchText = searchText;
    //if ([searchText length] == 0) searchText = nil;
    //fetchedResultsController = [self newFetchedResultsControllerWithSearch:searchText];
    //[self.countriesForSections filterUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText]];
    if ([searchText isEqualToString:@""]) { 
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
        
    }

    [self.tableView reloadData];
    //NSLog(@"textDidChange predicate stop");

}
- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{   
    [self.bar resignFirstResponder];   
}

#pragma mark Delegate methods of NSFetchedResultsController


- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    //NSLog(@"fetchedResultsControllerForTableView");
    return nil;
    //return tableView == self.tableView ? self.fetchedResultsController : self.fetchResultControllerSearch;
}

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    /*if ([searchString length] < 2 && fetchedResultsController != nil) {
        NSLog(@"fetch controller return standart controller:%@",[NSDate date]);

        return self.fetchedResultsController;
    }*/
    //NSLog(@"fetch controller start:%@",[NSDate date]);

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"country" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSPredicate *filterPredicate = nil;

    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    if(searchString.length) {
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(country CONTAINS[cd] %@) OR (specific CONTAINS[cd] %@) OR (codes CONTAINS[cd] %@)", searchString,searchString,searchString];
        NormalizedCountryTransformer *transformerCountry = [[NormalizedCountryTransformer alloc] init];
        NSPredicate *predicateCountryUnModified = [NSPredicate predicateWithFormat:@"(country CONTAINS[cd] %@)",searchString];
        NSPredicate *predicateCountry = [transformerCountry reverseTransformedValue:predicateCountryUnModified];
        [transformerCountry release];
        
        NormalizedSpecificTransformer *transformerSpecific = [[NormalizedSpecificTransformer alloc] init];
        NSPredicate *predicateSpecificUnModified = [NSPredicate predicateWithFormat:@"(specific CONTAINS[cd] %@)",searchString];
        NSPredicate *predicateSpecific = [transformerSpecific reverseTransformedValue:predicateSpecificUnModified];
        [transformerSpecific release];

        NormalizedCodesTransformer *transformerCodes = [[NormalizedCodesTransformer alloc] init];
        NSPredicate *predicateCodesUnModified = [NSPredicate predicateWithFormat:@"(codes CONTAINS[cd] %@)",searchString];
        NSPredicate *predicateCodes = [transformerCodes reverseTransformedValue:predicateCodesUnModified];
        [transformerCodes release];

        [predicateArray addObject:predicateCountry];
        [predicateArray addObject:predicateSpecific];
        [predicateArray addObject:predicateCodes];

        
        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }
    }
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    //[fetchRequest setFetchLimit:120];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:@"country" 
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) 
    {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}    


- (NSFetchedResultsController *)fetchedResultsController 
{
    //NSLog(@"fetchedResultsController");
    NSString *currentSearchString = self.bar.text;
    
    if (!currentSearchString) currentSearchString = @"";
    
    if (fetchedResultsController != nil && [currentSearchString isEqualToString:self.previousSearchString]) 
    {
        return fetchedResultsController;
    }
    //NSLog(@"fetchedResultsController from nil");
    [self.previousSearchString setString:currentSearchString];
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:currentSearchString];
    return [[fetchedResultsController retain] autorelease];
}   

- (NSFetchedResultsController *)fetchResultControllerSearch 
{
    //NSLog(@"fetchResultControllerSearch");
    if (fetchResultControllerSearch != nil) 
    {
        return fetchResultControllerSearch;
    }
    //NSLog(@"fetchResultControllerSearch from nil");

    //if ([self.bar.text length]> 2) {
    NSString *currentSearchString = self.bar.text;
    if ([currentSearchString length] < 2) currentSearchString = nil;
    
    fetchResultControllerSearch = [self newFetchedResultsControllerWithSearch:currentSearchString];
    //} else return fetchedResultsController;
    
    return [[fetchResultControllerSearch retain] autorelease];
}   
#pragma mark Add new route

- (void) returnToDestinationsList:(id) sender
{
    [self.bar resignFirstResponder];

    self.destinationsPushListView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self dismissModalViewControllerAnimated:YES];
//    [self presentModalViewController:self.destinationsPushListView animated:YES];
}




#pragma mark - external reload methods

-(void) reloadLocalDataFromUserDataControllerForObject:(id)object;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:selected animated:YES scrollPosition:UITableViewScrollPositionNone];
    });
}

-(void) safeSave;
{
    //NSLog(@"SAVED");
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) [self.managedObjectContext save:&error];
    if (error) NSLog(@"%@",[error localizedDescription]);
}

-(void)helpShowingDidFinish;
{
    self.tableView.alpha = 1.0;
}


@end
