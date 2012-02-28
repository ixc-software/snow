//
//  CarrierListConroller.m
//  snow
//
//  Created by Oleksii Vynogradov on 14.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import "CarrierListConroller.h"

#import "ClientController.h"
#import "mobileAppDelegate.h"
#import "DestinationsListViewController.h"
#import "HelpForInfoView.h"

#import "CompanyStuff.h"
#import "CurrentCompany.h"
#import "Carrier.h"

@interface CarrierListConroller()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectID *stuffID;
@property (nonatomic, retain) NSMutableString *previousSearchString;
@property (nonatomic, retain) NSMutableArray *updatedCarriersIDs;
@property (nonatomic, retain) NSArray* sectionsTitles;
@property (retain, nonatomic) UIBarButtonItem *editCarrierslistButton;

@property (readwrite) BOOL isCarriersEditing;
@property (readwrite) BOOL isCarriersUpdating;
-(void) safeSave;
- (NSFetchedResultsController *)fetchedResultsControllerWithSearchString:(NSString *)searchString;

@end

@implementation CarrierListConroller
@synthesize cell;
@synthesize searchBar;
@synthesize fetchedResultsController,stuffID,previousSearchString,isCarriersEditing,isCarriersUpdating;

@synthesize updatedCarriersIDs;
@synthesize sectionsTitles;
@synthesize editCarrierslistButton;

@synthesize carrierUpdateProgress;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
-(NSArray *) indexForSectionIndexTitlesForEntity:(NSString *)entityName;
{
    __block NSString *entityNameBlock = entityName;
    
    __block NSMutableArray *countForLetters = [NSMutableArray arrayWithCapacity:0];
    __block NSMutableArray *letters = [NSMutableArray arrayWithCapacity:0];
    [letters addObject:UITableViewIndexSearch];
    __block NSUInteger total = 0;
    __block mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    __block NSString *adminGUID = admin.GUID;
    
    [clientController release];
    __block NSArray *allLetters = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil]; 
    [allLetters enumerateObjectsUsingBlock:^(NSString *letter, NSUInteger idx, BOOL *stop) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityNameBlock
                                                  inManagedObjectContext:delegate.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyStuff.GUID == %@ and name BEGINSWITH [c] %@",adminGUID,letter];
        [fetchRequest setPredicate:predicate];
        //NSLog(@"check for predicate:%@",predicate);
        
        NSError *error = nil;
        NSInteger fetchedObjects = [delegate.managedObjectContext countForFetchRequest:fetchRequest error:&error];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Carriers";
    
    searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 5, 44)] autorelease];
    
    searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    //searchBar.backgroundColor = DARK_BACKGROUND;
    searchBar.opaque = NO;
    [searchBar sizeToFit];
    searchBar.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
    searchBar.delegate = self;
    
    //searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, searchBar.frame.size.width - 40 , searchBar.frame.size.height);

    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];

    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
    self.stuffID = [[clientController authorization] objectID];
    [clientController release];
    if (!self.previousSearchString) previousSearchString = [[NSMutableString alloc] initWithString:@""];
    self.tableView.rowHeight = 97.0;

    self.tableView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];
    self.tableView.separatorColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.tableHeaderView = searchBar;

    //    UIBarButtonItem *addCarrier = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCarrier:)];
//    self.navigationItem.rightBarButtonItem = addCarrier;

    editCarrierslistButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editCarriersList:)];
    self.navigationItem.rightBarButtonItem = editCarrierslistButton;
    [editCarrierslistButton release];
    
    carrierUpdateProgress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //carrierUpdateProgress.hidden = YES;
    UIBarButtonItem *progressCarrierUpdate = [[UIBarButtonItem alloc] initWithCustomView:carrierUpdateProgress];
    self.navigationItem.leftBarButtonItem = progressCarrierUpdate;
    [progressCarrierUpdate release];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];

    updatedCarriersIDs = [[NSMutableArray alloc] initWithCapacity:0];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    fetchedResultsController = [self fetchedResultsControllerWithSearchString:@""];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    HelpForInfoView *helpView = [[HelpForInfoView alloc] init];
    helpView.isCarriersList = YES;
    if ([helpView isHelpNecessary]) {
        self.tableView.alpha = 0.7;
        helpView.delegate = self;
        [self.navigationController.view addSubview:helpView.view];
    } else [helpView release];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        if (isCarriersUpdating == YES) return;
        else isCarriersUpdating = YES;
        NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastCarriersUpdatingTime"];
        if (lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] > 60 ) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastCarriersUpdatingTime"];
            
            mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];            
            CompanyStuff *admin = [clientController authorization];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                carrierUpdateProgress.hidden = NO;
                [carrierUpdateProgress startAnimating];

            });
            NSArray *allGUIDsCarrier = [clientController getAllObjectsListWithEntityForList:@"Carrier" withMainObjectGUID:admin.GUID withMainObjectEntity:@"CompanyStuff" withAdmin:admin withDateFrom:nil withDateTo:nil];
            NSArray *allObjectsForGUIDS = [clientController getAllObjectsListWithGUIDs:allGUIDsCarrier withEntity:@"Carrier" withAdmin:admin];
            if (allGUIDsCarrier && allObjectsForGUIDS) {
                
                NSArray *updatedCarrierIDs = [clientController updateGraphForObjects:allObjectsForGUIDS withEntity:@"Carrier" withAdmin:admin withRootObject:admin];
                [clientController finalSave:clientController.moc];
                // remove objects which was not on server
                NSSet *allCarriers = admin.carrier;
                [allCarriers enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",carrier.GUID];
                    NSArray *filteredCarrierIDs = [updatedCarrierIDs filteredArrayUsingPredicate:predicate];
                    if (filteredCarrierIDs.count == 0) {
                        [clientController.moc deleteObject:carrier];
                        NSLog(@"CLIENT CONTROLLER: object with entity %@ not on server and will removed",carrier.entity.name);
                    }
                }];
                [clientController finalSave:clientController.moc];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                carrierUpdateProgress.hidden = YES;
                [carrierUpdateProgress stopAnimating];
            });

            
            [clientController release];
            
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            isCarriersUpdating = NO;
        }
    });

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    sectionsTitles = [[NSArray alloc] initWithArray:[self indexForSectionIndexTitlesForEntity:@"Carrier"]];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self safeSave];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    NSInteger count = [sectionInfo numberOfObjects];
    if (isCarriersEditing) count = count + 1;
    NSLog(@"Rows:%@",[NSNumber numberWithInteger:count]);
    return count;

    // Return the number of rows in the section.
    //return 0;
}

-(void)configureCell:(CarrierListTableViewCell *)cellLocal atIndexPath:(NSIndexPath *)indexPath;
{
    cellLocal.delegate = self;
    cellLocal.currentIndexPath = indexPath;
    cellLocal.selectionStyle =  UITableViewCellSelectionStyleNone;

    cellLocal.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    //    if (indexPath.row ==  [[[self fetchedResultsController] fetchedObjects] count]) { 
    //        cellLocal.name.text = @"new carrier";
    //        
    //    }    else {
    Carrier *carrier = nil;
    if (isCarriersEditing && indexPath.row == 0) {
        // custom design for first editing row
        NSArray *allObjects = [[self fetchedResultsController] fetchedObjects];
        NSString *newCarrierName = [NSString stringWithFormat:@"new carrier%@",[NSNumber numberWithUnsignedInteger:[allObjects count]]];
        cellLocal.name.text = newCarrierName;
        CompanyStuff *stuff = (CompanyStuff *)[fetchedResultsController.managedObjectContext objectWithID:self.stuffID];
        cellLocal.responsibleFirstAndLastName.text = [NSString stringWithFormat:@"%@ %@",stuff.firstName,stuff.lastName];
        cellLocal.destinations.hidden = YES;
        //NSLog(@"display cell at index:%@ with carrier:NULL",indexPath);
        
    } else {
        if (isCarriersEditing) carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
        else carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        //NSLog(@"display cell at index:%@ with carrier:%@",indexPath,carrier.name);
        cellLocal.name.text = carrier.name;
        cellLocal.responsibleFirstAndLastName.text = [NSString stringWithFormat:@"%@ %@",carrier.companyStuff.firstName,carrier.companyStuff.lastName];
        cellLocal.destinations.text = [NSString stringWithFormat:@"Destinations: %@",[NSNumber numberWithUnsignedInteger:carrier.destinationsListPushList.count]];
        
        //NSString *objectGUID = [objects valueForKey:@"rootObjectGUID"];
        NSDictionary *objectStatus =[[NSUserDefaults standardUserDefaults] objectForKey:carrier.GUID];
        NSString *status = nil;
        if (objectStatus) { 
            if ([objectStatus valueForKey:@"update"]) status = [objectStatus valueForKey:@"update"];
            if ([objectStatus valueForKey:@"new"]) status =  [objectStatus valueForKey:@"new"]; 
            if ([objectStatus valueForKey:@"login"]) status =  [objectStatus valueForKey:@"login"]; 
        }
        
        //        NSLog(@"carrier company stuff guid:%@, local stuff guid:%@ for carrer:%@",carrier.companyStuff.GUID,stuff.GUID,carrier.name);
        //NSLog(@"status:%@ for carrier guid:%@",status,carrier.GUID);
        
        if (status) {
            
            cellLocal.status.text = status;
            if ([status isEqualToString:@"registered"]) cellLocal.textLabel.textColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
            else cellLocal.status.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
        } else { 
            //NSLog(@"company stuff email:%@, local user email:%@ for carrer:%@",carrier.companyStuff.email,[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],carrier.name);
            //            NSLog(@"carrier company stuff guid:%@, local stuff guid:%@ for carrer:%@",carrier.companyStuff.GUID,stuff.GUID,carrier.name);
            CompanyStuff *stuff = (CompanyStuff *)[fetchedResultsController.managedObjectContext objectWithID:self.stuffID];
            
            if (![carrier.companyStuff.GUID isEqualToString:stuff.GUID]) {
                
                cellLocal.status.text = @"registered by you colleague";
                cellLocal.status.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
                
            }
            else {
                cellLocal.status.text = @"new";
                cellLocal.status.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
            }
        }
    }
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Carrier";
    
    CarrierListTableViewCell *cellLocal = (CarrierListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cellLocal == nil) {
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        UINib *quoteCellNib; 

        if ([delegate isPad]) quoteCellNib = [UINib nibWithNibName:@"CarrierListTableViewIPad" bundle:nil];
        else quoteCellNib = [UINib nibWithNibName:@"CarrierListTableViewCell" bundle:nil];

        [quoteCellNib instantiateWithOwner:self options:nil];
        cellLocal = self.cell;
        self.cell = nil;
        [self configureCell:cellLocal atIndexPath:indexPath];
        
    }
//    cellLocal.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//
////    if (indexPath.row ==  [[[self fetchedResultsController] fetchedObjects] count]) { 
////        cellLocal.name.text = @"new carrier";
////        
////    }    else {
//        Carrier *carrier = nil;
//        if (isCarriersEditing && indexPath.row == 0) {
//            // custom design for first editing row
//            NSArray *allObjects = [[self fetchedResultsController] fetchedObjects];
//            NSString *newCarrierName = [NSString stringWithFormat:@"new carrier%@",[NSNumber numberWithUnsignedInteger:[allObjects count]]];
//            cellLocal.name.text = newCarrierName;
//            CompanyStuff *stuff = (CompanyStuff *)[fetchedResultsController.managedObjectContext objectWithID:self.stuffID];
//            cellLocal.responsibleFirstAndLastName.text = [NSString stringWithFormat:@"%@ %@",stuff.firstName,stuff.lastName];
//            cellLocal.destinations.hidden = YES;
//            //NSLog(@"display cell at index:%@ with carrier:NULL",indexPath);
//
//        } else {
//            if (isCarriersEditing) carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
//            else carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
//            //NSLog(@"display cell at index:%@ with carrier:%@",indexPath,carrier.name);
//            cellLocal.name.text = carrier.name;
//            cellLocal.responsibleFirstAndLastName.text = [NSString stringWithFormat:@"%@ %@",carrier.companyStuff.firstName,carrier.companyStuff.lastName];
//            cellLocal.destinations.text = [NSString stringWithFormat:@"Destinations: %@",[NSNumber numberWithUnsignedInteger:carrier.destinationsListPushList.count]];
//            
//            //NSString *objectGUID = [objects valueForKey:@"rootObjectGUID"];
//            NSDictionary *objectStatus =[[NSUserDefaults standardUserDefaults] objectForKey:carrier.GUID];
//            NSString *status = nil;
//            if (objectStatus) { 
//                if ([objectStatus valueForKey:@"update"]) status = [objectStatus valueForKey:@"update"];
//                if ([objectStatus valueForKey:@"new"]) status =  [objectStatus valueForKey:@"new"]; 
//                if ([objectStatus valueForKey:@"login"]) status =  [objectStatus valueForKey:@"login"]; 
//            }
//            
//            //        NSLog(@"carrier company stuff guid:%@, local stuff guid:%@ for carrer:%@",carrier.companyStuff.GUID,stuff.GUID,carrier.name);
//            //NSLog(@"status:%@ for carrier guid:%@",status,carrier.GUID);
//            
//            if (status) {
//                
//                cellLocal.status.text = status;
//                if ([status isEqualToString:@"registered"]) cellLocal.textLabel.textColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
//                else cellLocal.status.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
//            } else { 
//                //NSLog(@"company stuff email:%@, local user email:%@ for carrer:%@",carrier.companyStuff.email,[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],carrier.name);
//                //            NSLog(@"carrier company stuff guid:%@, local stuff guid:%@ for carrer:%@",carrier.companyStuff.GUID,stuff.GUID,carrier.name);
//                CompanyStuff *stuff = (CompanyStuff *)[fetchedResultsController.managedObjectContext objectWithID:self.stuffID];
//                
//                if (![carrier.companyStuff.GUID isEqualToString:stuff.GUID]) {
//                    
//                    cellLocal.status.text = @"registered by you colleague";
//                    cellLocal.status.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
//                    
//                }
//                else {
//                    cellLocal.status.text = @"new";
//                    cellLocal.status.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
//                }
//            }
//        }
//        
////    }
//    
    
    // Configure the cell...
    
    return cellLocal;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
//-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
//    return searchBar;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSFetchedResultsController *fetchController = [self fetchedResultsController];
        Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
        //NSLog(@"DELETE carrier:%@",carrier.name);
//        iphoneAppDelegate *delegate = (iphoneAppDelegate *)[[UIApplication sharedApplication] delegate];

//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//        if ([searchBar.text length] > 0) {
//            searchBar.text = @"";
//            [tableView reloadData]; 
//        }
//        });
        //[delegate.managedObjectContext deleteObject:carrier];
        [self safeSave];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
            [clientController removeObjectWithID:[carrier objectID]];
            [clientController release];
        });
        
    }   
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        Carrier *carrier = (Carrier *)[NSEntityDescription 
                                       insertNewObjectForEntityForName:@"Carrier" 
                                       inManagedObjectContext:delegate.managedObjectContext];
        
        NSFetchedResultsController *fetchController = [self fetchedResultsController];
        NSArray *allObjects = [fetchController fetchedObjects];
        NSString *newCarrierName = [NSString stringWithFormat:@"new carrier%@",[NSNumber numberWithUnsignedInteger:[allObjects count]]];
        carrier.name = newCarrierName;
        //carrier.name = newCarrier.data.text;
        CompanyStuff *updated = (CompanyStuff *)[delegate.managedObjectContext objectWithID:self.stuffID];
        
        carrier.companyStuff = updated;
        [self safeSave];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[carrier objectID]] mustBeApproved:NO];
            [clientController release];
        });

    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.tabBarController.selectedIndex = 2;
//    //[self.view dis
//    NSArray *viewControllers = delegate.tabBarController.viewControllers;
//    UINavigationController *destinations = [viewControllers objectAtIndex:2];
//    NSArray *viewControllersForNavigation = destinations.viewControllers;
    DestinationsListViewController *routesTableViewController = [[[DestinationsListViewController alloc] initWithNibName:@"DestinationsListViewController" bundle:nil] autorelease];
    routesTableViewController.isControllerStartedFromOutsideTabbar = YES;
    routesTableViewController.managedObjectContext = [delegate managedObjectContext];
    Carrier *carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];

    routesTableViewController.selectedCarrierID = carrier.objectID;
    
    [self.navigationController pushViewController:routesTableViewController animated:YES];

}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return UITableViewCellEditingStyleInsert;
    } 
    return UITableViewCellEditingStyleDelete;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSIndexPath *updatedIndexPath = nil;
//    
//    if (isCarriersEditing) updatedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
//     else updatedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
//
//    Carrier *carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
//    if (!carrier) return YES;
//    if ([carrier.companyStuff.objectID isEqual:self.stuffID]) return YES;
//    else return NO;
//    //NSIndexPath *selected = [tableView indexPathForSelectedRow];
    //    if (indexPath.section == 2) return YES;
    //    else 
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"for indexPath:%@ isCarrierEditing:%@",indexPath,[NSNumber numberWithBool:isCarriersEditing]);
    
    if (!isCarriersEditing)  {
//        NSArray *viewControllers = self.tabBarController.viewControllers;
//        UINavigationController *destinations = [viewControllers objectAtIndex:2];
//        
//        DestinationsListPushListTableViewController *destinationsController = [destinations.viewControllers objectAtIndex:0];
//        [self.navigationController pushViewController:destinationsController animated:YES];
        return nil;
        
    } else { 
        if (indexPath.row == 0) return nil;
        else { 
            if (!self.searchBar.text.length) {
                NSFetchedResultsController *fetchController = [self fetchedResultsController];
                Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0]];
                
                CarrierListTableViewCell *cellForUpdate = (CarrierListTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                cellForUpdate.carrierNameForEdit.text = carrier.name;
                [self.searchBar resignFirstResponder];
                return indexPath;
            } else return nil;
        }
    }
    
    //[self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (!isCarriersEditing) {
//        
//        iphoneAppDelegate *delegate = (iphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
//        //    delegate.tabBarController.selectedIndex = 2;
//        //    //[self.view dis
//        //    NSArray *viewControllers = delegate.tabBarController.viewControllers;
//        //    UINavigationController *destinations = [viewControllers objectAtIndex:2];
//        //    NSArray *viewControllersForNavigation = destinations.viewControllers;
//        DestinationsListPushListTableViewController *routesTableViewController = [[[DestinationsListPushListTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
//        routesTableViewController.isControllerStartedFromOutsideTabbar = YES;
//        routesTableViewController.managedObjectContext = [delegate managedObjectContext];
//        Carrier *carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
//        
//        routesTableViewController.selectedCarrierID = carrier.objectID;
//        
//        [self.navigationController pushViewController:routesTableViewController animated:YES];
//    }
//    NSLog(@"for indexPath:%@ isCarrierEditing:%@",indexPath,[NSNumber numberWithBool:isCarriersEditing]);
//    if (!isCarriersEditing) {
//        NSArray *viewControllers = self.tabBarController.viewControllers;
//        UINavigationController *destinations = [viewControllers objectAtIndex:2];
//        
//        DestinationsListPushListTableViewController *destinationsController = [destinations.viewControllers objectAtIndex:0];
//        [self.navigationController pushViewController:destinationsController animated:YES];
//    }

}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([searchBar.text length] == 0) return [[sectionsTitles lastObject] valueForKey:@"letters"];
    else return nil; 
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //NSNumber *total = [[sectionsTitles objectAtIndex:[sectionsTitles count] - 1] valueForKey:@"total"];
    if ([title isEqualToString:UITableViewIndexSearch]) { 
//        dispatch_async(dispatch_get_main_queue(), ^(void) { 
//            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
//        });

        return 0;
    }
    NSUInteger indexToScroll = 0;
    NSPredicate *letterPredicate = [NSPredicate predicateWithFormat:@"letter == %@",title];
    NSArray *sectionTitlesFiltered = [sectionsTitles filteredArrayUsingPredicate:letterPredicate];
    if ([sectionTitlesFiltered count] == 0) NSLog(@"CARRIERS LIST: >>>> warning, for title %@ index not found",title);
    else indexToScroll = [[[sectionTitlesFiltered lastObject] valueForKey:@"index"] unsignedIntegerValue];
    //NSLog(@"scroll to %@",[[sectionTitlesFiltered lastObject] valueForKey:@"index"]);
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexToScroll inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    });
    //NSLog(@"sectionForSectionIndexTitle:%@ and index:%@ return value is:%@",title,[NSNumber numberWithUnsignedInteger:index],[NSNumber numberWithUnsignedInteger:index * 12]);
    //return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index - 1];
    return 0;
}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
////    NSLog(@"sectionForSectionIndexTitle:%@ and index:%@ return value is:%@",title,[NSNumber numberWithUnsignedInteger:index],[NSNumber numberWithUnsignedInteger:index * 6]);
////    //return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index - 1];
//    NSUInteger numberOfRows = [tableView numberOfRowsInSection:0];
//    NSUInteger scrolllTo = numberOfRows * 6;
//    if (scrolllTo > numberOfRows) scrolllTo = numberOfRows - 1;
//    
//        
//    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:scrolllTo inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
//    return 0;
//}


#pragma mark - searchBar delegate

- (void)searchBar:(UISearchBar *)searchBarr textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) { 
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBarr afterDelay:0];
        
    } else {
        
        if (![searchText isEqualToString:previousSearchString]) {
            NSFetchedResultsController *fetchController = [self fetchedResultsController];
            NSArray *allObjects = [fetchController fetchedObjects];
            if ([allObjects count] > 0) {
                NSManagedObject *firstObject = [allObjects objectAtIndex:0];
                //NSLog(@"scroll to company:%@",[firstObject valueForKey:@"name"]);
                [updatedCarriersIDs removeAllObjects];
                [updatedCarriersIDs addObject:firstObject.objectID];
            }
            
        }
    }
    [fetchedResultsController release],fetchedResultsController = nil;
    fetchedResultsController = [self fetchedResultsControllerWithSearchString:searchText];

    [self.tableView reloadData];
}
- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{   
    
    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    NSManagedObjectID *lastSelectedIDs = [updatedCarriersIDs lastObject];
    if (lastSelectedIDs) {
        NSManagedObject *obj = [fetchController.managedObjectContext objectWithID:lastSelectedIDs];
        NSIndexPath *pathToScroll = [fetchController indexPathForObject:obj];
        //NSLog(@"path to scroll:%@",pathToScroll);
        [self.tableView scrollToRowAtIndexPath:pathToScroll atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
                           
    [self.searchBar resignFirstResponder];   
}


#pragma mark - FetchedResultsController methods


- (NSFetchedResultsController *)fetchedResultsControllerWithSearchString:(NSString *)searchString;
{
    NSString *currentSearchString = searchString;
    
    if (!currentSearchString) currentSearchString = @"";

    if (fetchedResultsController != nil && [currentSearchString isEqualToString:self.previousSearchString]) 
    {
        //NSLog(@"FETCH is same");

        return fetchedResultsController;
    }
    
    //NSLog(@"FETCH is updated");
    
    [self.previousSearchString setString:currentSearchString];

    //isEdited = NO;
    NSMutableArray *predicateArray = [NSMutableArray array];

    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];

    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:delegate.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    [clientController release];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(companyStuff.currentCompany.GUID == %@)",admin.currentCompany.GUID];;
    
    if(currentSearchString.length) {
        NSPredicate *predicateName = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)",currentSearchString];
        [predicateArray addObject:predicateName];

        if(filterPredicate)
        {
            filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:filterPredicate, [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray], nil]];
        }
        else
        {
            filterPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicateArray];
        }

    }
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [sortDescriptor release];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:delegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:sortDescriptors];

    [sortDescriptors release];
    
    //}
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:delegate.managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    [fetchRequest release];
    
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
    
    fetchedResultsController =  aFetchedResultsController;
    return [[fetchedResultsController retain] autorelease];
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    //if (indexPath.section == 0) {
    
    UITableView *tableView = self.tableView;
//    [tableView beginUpdates];
    NSIndexPath *updatedIndexPath = nil;
    NSIndexPath *updatedNewIndexPath = nil;
    
    if (isCarriersEditing) {
        // all rows moved down
        if (indexPath) updatedIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        if (newIndexPath) updatedNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
    } else {
        if (indexPath) updatedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        if (newIndexPath) updatedNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section];
    }
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
        {
            //NSLog(@"COMPANY AND USER:fetchControllerDidChanges INSERT");
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:updatedNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            //NSLog(@"COMPANY AND USER:fetchControllerDidChanges DELETE :%@",updatedIndexPath);
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:updatedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            //NSLog(@"COMPANY AND USER:fetchControllerDidChanges UPDATE:%@",updatedIndexPath);
            //[self configureCell:(CarrierListTableView *)[tableView cellForRowAtIndexPath:updatedIndexPath] atIndexPath:updatedIndexPath];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:updatedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            //NSLog(@"COMPANY AND USER:fetchControllerDidChanges MOVE from:%@ to:%@",updatedIndexPath,updatedNewIndexPath);
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:updatedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:updatedNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
    
    //[tableView endUpdates];
    
    
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
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


-(void) safeSave;
{
    //NSLog(@"SAVED");
    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSError *error = nil;
    if ([delegate.managedObjectContext hasChanges]) {
        if (![delegate.managedObjectContext save:&error]) {
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
        }
    }
}
#pragma mark - Data methods


-(void)addCarrier:(id)sender
{
    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];

    Carrier *carrier = (Carrier *)[NSEntityDescription 
                                   insertNewObjectForEntityForName:@"Carrier" 
                                   inManagedObjectContext:delegate.managedObjectContext];
    
    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    NSArray *allObjects = [fetchController fetchedObjects];
    NSString *newCarrierName = [NSString stringWithFormat:@"new carrier%@",[NSNumber numberWithUnsignedInteger:[allObjects count]]];
    carrier.name = newCarrierName;
    CompanyStuff *updated = (CompanyStuff *)[delegate.managedObjectContext objectWithID:self.stuffID];
    
    carrier.companyStuff = updated;
    [self safeSave];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
//        iphoneAppDelegate *delegate = (iphoneAppDelegate *)[[UIApplication sharedApplication] delegate];

        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:carrier.objectID] mustBeApproved:NO];
        [clientController release];
        //    if (isSomethingAdded) [userController startRegistrationForAllObjectsInFutureArrayForTableView:self.tableView sender:self clientStuffGUID:self.stuff.GUID];
        
    });


}
- (IBAction)finishEditing:(id)sender {
    NSArray *selected = [self.tableView indexPathsForSelectedRows];
    NSIndexPath *selectedLast = [selected lastObject];
    
    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:selectedLast.row - 1 inSection:0]];
    carrier.name = [sender text];
    //CarrierListTableView *cellForUpdate = (CarrierListTableView *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLast.row  inSection:0]];
//    cellForUpdate.name.text = [sender text];

    //NSLog(@"carrier to update:%@ indexpath:%@",carrier.name,selectedLast);
    [sender resignFirstResponder];
    [sender setHidden:YES];
    [updatedCarriersIDs addObject:carrier.objectID];
    //[self safeSave];
//    dispatch_async(dispatch_get_main_queue(), ^(void) { 
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedLast] withRowAnimation:UITableViewRowAnimationFade];
//    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:carrier.objectID] mustBeApproved:NO];
        [clientController release];
        //    if (isSomethingAdded) [userController startRegistrationForAllObjectsInFutureArrayForTableView:self.tableView sender:self clientStuffGUID:self.stuff.GUID];
        
    });

}

-(void) updateData:(NSString *)dataText forCellAtIndexPath:(NSIndexPath *)indexPath;
{
//    NSFetchedResultsController *fetchController = [self fetchedResultsController];
////    Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
//    CarrierListTableView *cellForUpdate = (CarrierListTableView *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1  inSection:0]];
//
//    cellForUpdate.name.text = dataText;
//    Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
//    [[fetchController managedObjectContext] save:nil];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
//        sleep(2);
//        NSFetchedResultsController *fetchController = [self fetchedResultsController];
//        NSArray *allObjects = [fetchedResultsController fetchedObjects];
//        Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
//        NSLog(@"carrier to update:%@",carrier.name);
//        carrier.name = dataText;
//        [self performSelectorOnMainThread:@selector(safeSave) withObject:nil waitUntilDone:YES];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
//            iphoneAppDelegate *delegate = (iphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
//            
//            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
//            
//            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:carrier.objectID] mustBeApproved:NO];
//            [clientController release];
//            //    if (isSomethingAdded) [userController startRegistrationForAllObjectsInFutureArrayForTableView:self.tableView sender:self clientStuffGUID:self.stuff.GUID];
//            
//        });
//    });
    
}

-(void)editCarriersList:(id)sender;
{
    
    if (!isCarriersEditing) {
        isCarriersEditing = YES;
        //            NSInteger count = [[[self fetchedResultsController] fetchedObjects] count];
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            [updatedCarriersIDs removeAllObjects];
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView setEditing:YES animated:YES];
            [self.tableView endUpdates];
            [self.searchBar resignFirstResponder];
        });
        
    } else {
        //            NSInteger count = [[[self fetchedResultsController] fetchedObjects] count];
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            isCarriersEditing = NO;
            
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView setEditing:NO animated:YES];
            [self.tableView endUpdates];
        });
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//            isCarriersUpdating = YES;
//            sleep(5);
//            [updatedCarriersIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
//                NSFetchedResultsController *fetchController = [self fetchedResultsController];
//                Carrier *updatedCarrier = (Carrier *)[fetchController.managedObjectContext objectWithID:objectID];
//                
//                NSIndexPath *indexPath = [fetchController indexPathForObject:updatedCarrier];
//                CarrierListTableView *cellForUpdate = (CarrierListTableView *)[self.tableView cellForRowAtIndexPath:indexPath];
//                updatedCarrier.name = cellForUpdate.carrierNameForEdit.text;
//                
//            }];
//            dispatch_async(dispatch_get_main_queue(), ^(void) { 
//
//            [self safeSave];
//                isCarriersUpdating = NO;
//
//            });
//
//        });

    }
}

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        editCarrierslistButton.enabled = NO;
    });
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSManagedObjectID *objectID = nil;
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:status]] autorelease];
            alert.segmentedControlStyle = UISegmentedControlStyleBar;
            alert.frame = CGRectMake(0, (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height)/2, self.navigationController.toolbar.bounds.size.width - (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height), alert.frame.size.height);
            alert.userInteractionEnabled = NO;
            //alert.selectedSegmentIndex = 0;
            alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];;
            
            UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:alert] autorelease];
            
            [self setToolbarItems:[NSArray arrayWithObject:item]];
            self.navigationController.toolbar.translucent = YES;
            self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
            
            self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
            [self.navigationController setToolbarHidden:NO animated:YES];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(4);
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [self.navigationController setToolbarHidden:YES animated:YES]; 
            });
        });
        
        // present modal
    }
    
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    
    if (objectID) {
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];

        NSManagedObject *updatedObject = [delegate.managedObjectContext objectWithID:objectID];
       
        if ([[[updatedObject entity] name] isEqualToString:@"Carrier"]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSUInteger deltaLines = 0;
                if (isCarriersEditing) deltaLines = 1;

                if (![isItLatestMessage boolValue])
                {
                    NSIndexPath *objectPath = [fetchedResultsController indexPathForObject:updatedObject];
                    
                    CarrierListTableViewCell *cellForUpdate = (CarrierListTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:objectPath.row + deltaLines inSection:0]];
                    cellForUpdate.activity.hidden = NO;
                    [cellForUpdate.activity startAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                    
                } else { 
                    NSIndexPath *objectPath = [fetchedResultsController indexPathForObject:updatedObject];
                    CarrierListTableViewCell *cellForUpdate = (CarrierListTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:objectPath.row + deltaLines inSection:0]];
                    cellForUpdate.activity.hidden = YES;
                    [cellForUpdate.activity stopAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    editCarrierslistButton.enabled = YES;

                    
                    //                    NSString *status = [[[NSUserDefaults standardUserDefaults] objectForKey:[updatedObject valueForKey:@"GUID"]] valueForKey:@"update"];
                    //                    cell.state.text = status;
                    
                    if ([status isEqualToString:@"remove object finish"] || [status isEqualToString:@"carrier for removing not found"]  || [status isEqualToString:@"carrier have more than 2 records"]) { 
                        //if ([searchBar.text length] > 0) searchBar.text = @"";
                        [delegate.managedObjectContext deleteObject:updatedObject];
                        [self safeSave];
                    }
                    
                    //NSLog(@"COMPANY AND USER:updated object:%@ for guid:%@ with object:%@",[[NSUserDefaults standardUserDefaults] objectForKey:[updatedObject valueForKey:@"GUID"]],[updatedObject valueForKey:@"GUID"],updatedObject);
                    //[self.tableView reloadData];
                    
                }
            });
            
        }
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        self.stuffID = [[clientController authorization] objectID];
        [clientController release];
    }
    
    
}
-(void)helpShowingDidFinish;
{
    self.tableView.alpha = 1.0;
}



- (void)dealloc {
    [updatedCarriersIDs release];
    [previousSearchString release];
    [searchBar release];
    [super dealloc];
}
@end
