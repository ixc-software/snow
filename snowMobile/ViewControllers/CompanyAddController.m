//
//  CompanyAddController.m
//  snow
//
//  Created by Oleksii Vynogradov on 04.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "CompanyAddController.h"
#import "CompanyInfoDetailCell.h"
#import "CurrentCompany.h"
#import "Carrier.h"
#import "CompanyStuff.h"
//#import "UniversalDataExchangeController.h"
#import "mobileAppDelegate.h"
#import "ClientController.h"


@interface CompanyAddController()
@property (nonatomic, retain) IBOutlet UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *bar;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchFetchedResultsController;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

@property (nonatomic) BOOL isUserChangeCompanyForThisSession;

@property (nonatomic) NSInteger savedScopeButtonIndex;
//@property (nonatomic, retain)  UISegmentedControl *segmented;
//@property (nonatomic, retain)  UISegmentedControl *segmented2;

//@property (nonatomic, retain) UniversalDataExchangeController *exchangeController;

@property (nonatomic) UIBackgroundTaskIdentifier identForCompanyUpdate;

@property (nonatomic, retain) NSIndexPath *editingRow;
@property (nonatomic, retain) NSMutableArray *canceledRegistrations;
@property (nonatomic, retain) NSMutableArray *registrationsInProcessNow;

@property (nonatomic, retain) NSMutableArray *idsWithProgress;


@property (nonatomic, retain) NSManagedObjectID *companyWhichWasSelectedWhenViewWasAppear;


- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;
- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController 
                   configureCell:(UITableViewCell *)theCell 
                     atIndexPath:(NSIndexPath *)theIndexPath 
                    forTableView:(UITableView *)tableView;

-(void) safeSave;
-(void) updateRelationship:(CurrentCompany *)company;
-(void) createNavigatorRightBlockWithMiddleTittle:(NSString *)startTitle startAction:(SEL)action isEdited:(BOOL)edited;
-(void) registerCompany;

@end;

@implementation CompanyAddController

@synthesize mySearchDisplayController,bar,fetchedResultsController,searchFetchedResultsController,managedObjectContext,savedSearchTerm,searchWasActive,savedScopeButtonIndex,cellInfo,stuffID,editingRow,identForCompanyUpdate,canceledRegistrations,registrationsInProcessNow,companyAndUserConfiguration,isUserChangeCompanyForThisSession,companyWhichWasSelectedWhenViewWasAppear,idsWithProgress;


- (void)dealloc
{
    [mySearchDisplayController release];
    [editingRow release];
    [bar release];
    [fetchedResultsController release];
    [searchFetchedResultsController release];
    [savedSearchTerm release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canceledRegistrations = [[[NSMutableArray alloc] init] autorelease]; 
    self.registrationsInProcessNow = [[[NSMutableArray alloc] init] autorelease];
    self.idsWithProgress = [[[NSMutableArray alloc] init] autorelease];
    
    
    bar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45)];
    self.bar.tintColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];

    
    for ( UIView * subview in self.bar.subviews) 
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] ) 
            [subview removeFromSuperview];
        
    }
    self.bar.tintColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
    self.tableView.tableHeaderView = bar;
    self.tableView.rowHeight = 92;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];


    
    self.mySearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:self.bar contentsController:self] autorelease];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;

    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    

    
//    if (!exchangeController) {
//        exchangeController = [[UniversalDataExchangeController alloc] init];
//        exchangeController.moc = self.managedObjectContext;
//    }
    


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:self.tableView];
    CompanyStuff *currentAdmin = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
    CurrentCompany *selected = currentAdmin.currentCompany;
    companyWhichWasSelectedWhenViewWasAppear = [selected objectID];
    
    NSIndexPath *currentPosition = [fetchController indexPathForObject:selected]; 
    [self.tableView selectRowAtIndexPath:currentPosition animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.tableView scrollToRowAtIndexPath:currentPosition atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];

    
    if ([selected.companyAdminGUID isEqualToString:currentAdmin.GUID]) {
        // admin can edit and register company
        //if ([selected.companyAdminGUID isEqualToString:stuff.GUID] && [[userController localStatusForObjectsWithRootGuid:selected.GUID] isEqualToString:@"finish"]) 
            [self createNavigatorRightBlockWithMiddleTittle:nil startAction:nil isEdited:YES];
        ///else [self createNavigatorRightBlockWithMiddleTittle:@"Register" startAction:@selector(registerCompany) isEdited:YES];
        // non admin can only join
    } else  [self createNavigatorRightBlockWithMiddleTittle:@"Join" startAction:@selector(registerCompany) isEdited:NO];
   
    
    isUserChangeCompanyForThisSession = NO;
 

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    self.searchWasActive = [self.mySearchDisplayController isActive];
//    self.savedSearchTerm = [self.mySearchDisplayController.searchBar text];
//    self.savedScopeButtonIndex = [self.mySearchDisplayController.searchBar selectedScopeButtonIndex];

    [super viewWillDisappear:animated];
//    [self safeSave];
//    CurrentCompany *selected = self.stuff.currentCompany;
//
//    if (isUserChangeCompanyForThisSession && companyWhichWasSelectedWhenViewWasAppear == [selected objectID] && [selected.companyAdminGUID isEqualToString:stuff.GUID] && [[userController localStatusForObjectsWithRootGuid:stuff.GUID] isEqualToString:@"finish"]) {
//        
//        // if user was edit, change data for the company, registration will start when view will disappier, only for Register button and for delete company it will start immediately
//        
//        CurrentCompany *selected = self.stuff.currentCompany;
//        
//        NSArray *keys = [[[stuff entity] attributesByName] allKeys];
//        NSDictionary *clientStuffFullInfo = [stuff dictionaryWithValuesForKeys:keys];
//    
//        NSMutableDictionary *objectsForRegistration = [NSMutableDictionary dictionaryWithCapacity:0];
//    
//        NSString *statusForCompany = [userController localStatusForObjectsWithRootGuid:selected.GUID];
//        [objectsForRegistration setValue:selected.GUID forKey:@"rootObjectGUID"];
//        
//        NSMutableArray *new = [NSMutableArray arrayWithCapacity:0];
//        NSMutableArray *update = [NSMutableArray arrayWithCapacity:0];
//        NSMutableArray *delete = [NSMutableArray arrayWithCapacity:0];
//        if (statusForCompany && ![statusForCompany isEqualToString:@"unregistered"]) [update addObject:[selected objectID]]; 
//        else [new addObject:[selected objectID]];
//        [objectsForRegistration setValue:new forKey:@"new"];
//        [objectsForRegistration setValue:update forKey:@"updated"];
//        [objectsForRegistration setValue:delete forKey:@"deleted"];
//        
//        //NSLog(@"userController context = %@",userController.context);
//        [userController startRegistrationForObjects:objectsForRegistration 
//                                       forTableView:self.tableView 
//                                          forSender:self 
//                                clientStuffFullInfo:clientStuffFullInfo];
//
//    }
    
    //if (companyWhichWasSelectedWhenViewWasAppear != [selected objectID]) [self registerCompany];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) createNavigatorRightBlockWithMiddleTittle:(NSString *)startTitle startAction:(SEL)action isEdited:(BOOL)edited;
{
    UIToolbar *tools = [[UIToolbar alloc]
                        initWithFrame:CGRectZero];

    tools.clearsContextBeforeDrawing = NO;
    tools.clipsToBounds = NO;
    tools.tintColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.49 alpha:1.0];; // closest I could get by eye to black, translucent style.
    // anyone know how to get it perfect?
    tools.barStyle = -1; // clear background
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];
    
    CGFloat finalSize = 0;
    
    // Create a standard refresh button.
    // Add profile button.
    UIBarButtonItem *bi = nil;
    if (startTitle) {
        bi = [[UIBarButtonItem alloc] initWithTitle:startTitle style:UIBarButtonItemStylePlain target:self action:action];

        
        bi.style = UIBarButtonItemStyleBordered;
        CGSize size = [startTitle sizeWithFont:[UIFont systemFontOfSize:14]];
        finalSize = finalSize + size.width;
        [buttons addObject:bi];
        [bi release];
    }
    
    // Create a spacer.
    CGSize size;
    CompanyStuff *currentAdmin = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

    CurrentCompany *companyForCheck = currentAdmin.currentCompany;
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];

    NSString *localStatus =  [clientController localStatusForObjectsWithRootGuid:companyForCheck.GUID];
    [clientController release];
    
    if (edited) {
        
        bi = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editCompany:)];

        bi.style = UIBarButtonItemStyleBordered;
        size = [[NSString stringWithString:@"Edit"] sizeWithFont:[UIFont systemFontOfSize:14]];
        finalSize = finalSize + size.width;
        [buttons addObject:bi];
        [bi release];

        NSString *titleButtonForHiddenStatus = nil;
        if ([localStatus isEqualToString:@"registered"]) {
            if ([currentAdmin.currentCompany.isVisibleForCommunity boolValue] == YES) titleButtonForHiddenStatus = @"Hide";
            else titleButtonForHiddenStatus = @"Unhide";
            
            bi = [[UIBarButtonItem alloc] initWithTitle:titleButtonForHiddenStatus style:UIBarButtonItemStylePlain target:self action:@selector(switchHiddenStatusForCompany)];

            bi.style = UIBarButtonItemStyleBordered;
            size = [[NSString stringWithString:titleButtonForHiddenStatus] sizeWithFont:[UIFont systemFontOfSize:14]];
            finalSize = finalSize + size.width;
      
            [buttons addObject:bi];
            [bi release];

        }
    }
    
    bi = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addNewCompany)];
    bi.style = UIBarButtonItemStyleBordered;
    size = [[NSString stringWithString:@"Add"] sizeWithFont:[UIFont systemFontOfSize:14]];
    finalSize = finalSize + size.width;

    [buttons addObject:bi];
    [bi release];
    
    
    // Add buttons to toolbar and toolbar to nav bar.
    if ([startTitle isEqualToString:@"Register"]) tools.frame = CGRectMake(0.0, 0.0, finalSize + 98, 44.01);
    if ([startTitle isEqualToString:@"Join"]) tools.frame = CGRectMake(0.0, 0.0, finalSize + 51, 44.01);
    if (!startTitle) tools.frame = CGRectMake(0.0, 0.0, finalSize + 50, 44.01);
    if (!startTitle && [localStatus isEqualToString:@"registered"]) tools.frame = CGRectMake(0.0, 0.0, finalSize + 78, 44.01);

    [tools setItems:buttons animated:NO];
    [buttons release];
    UIBarButtonItem *twoButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
    [tools release];
    self.navigationItem.rightBarButtonItem = twoButtons;
    [twoButtons release];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    numberOfRows = [sectionInfo numberOfObjects];
    return numberOfRows;

}

- (void)configureCell:(CompanyInfoDetailCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;
{    
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    CurrentCompany *company = [fetchController objectAtIndexPath:indexPath];
    cell.name.text = company.name;
    //NSLog(@"companyName:%@",company.name);
    cell.name.textColor = [UIColor whiteColor];

    cell.url.text = company.url;
    cell.url.textColor = [UIColor whiteColor];
    
    NSSet *companyStuff = company.companyStuff;

    cell.members.text = [NSString stringWithFormat:@"Members: %@",company.stuffCount];
    cell.members.textColor = [UIColor whiteColor];

    NSSet *filteredStuff = [companyStuff filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"GUID == %@",company.companyAdminGUID]];
    CompanyStuff *admin = [filteredStuff anyObject];
    //NSLog(@"company admin:%@",admin);

    
    NSString *firstName =  admin.firstName;
    NSString *lastName = admin.lastName;
    if (!firstName && !lastName) { firstName = @"", lastName = @""; }
    
    CompanyStuff *localAdmin = (CompanyStuff *)[self.managedObjectContext objectWithID:stuffID];

    if ([company.companyAdminGUID isEqualToString:localAdmin.GUID]) { firstName = @"YOU", lastName = @""; }

    cell.adminFirstName.text = firstName;
    cell.adminFirstName.textColor = [UIColor whiteColor];

    cell.adminLastName.text = lastName;
    cell.adminLastName.textColor = [UIColor whiteColor];

    cell.destinations.text = [NSString stringWithFormat:@"Destinations: %@",company.destinationsPushListCount];

    cell.destinations.textColor = [UIColor whiteColor];
    cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.48 alpha:1.0];

    UIColor *statusColor = nil;
    statusColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1.0];
    NSString *companyGUID = company.GUID;
    NSDictionary *objectStatus =[[NSUserDefaults standardUserDefaults] objectForKey:companyGUID];
    //NSLog(@"company:%@ status:%@",company.name,objectStatus);

    NSString *status = nil;
    if (objectStatus) { 
        if ([objectStatus valueForKey:@"update"]) status = [objectStatus valueForKey:@"update"];
        if ([objectStatus valueForKey:@"new"]) status =  [objectStatus valueForKey:@"new"]; 
        if ([objectStatus valueForKey:@"delete"]) status =  [objectStatus valueForKey:@"delete"]; 
    }
    else { 
        //NSLog(@"company:%@ status:%@",company.name,company.isRegistrationDone);
        if ([company.isRegistrationDone boolValue]) status = @"registered";
            else status = @"unregistered";
    }
    
    if ([status isEqualToString:@"registered"]) { 
        statusColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
        status = @"registered";
    } else {
        if ([status isEqualToString:@"processing..."]) { 
            statusColor = [UIColor colorWithRed:0.92 green:0.85 blue:0.35 alpha:1.0];
            status = @"processing...";
        }
    }
    CGSize size;
    if (status) { 
        size = [status sizeWithFont:[UIFont systemFontOfSize:17]];
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([delegate isPad]) cell.notification.frame = CGRectMake(758.0 - size.width, 60.0, size.width, size.height);
        else cell.notification.frame = CGRectMake(310.0 - size.width, 60.0, size.width, size.height);
    }
    [cell.notification removeAllSegments];
    [cell.notification insertSegmentWithTitle:status atIndex:0 animated:NO];
    cell.notification.tintColor = statusColor;
    cell.delegate = self;
    if ([company.isVisibleForCommunity boolValue] != YES) cell.alpha = 0.6;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = nil;
    
    CompanyInfoDetailCell *cell = (CompanyInfoDetailCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UINib *quoteCellNib;
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([delegate isPad]) quoteCellNib = [UINib nibWithNibName:@"CompanyInfoDetailCelliPad" bundle:nil];
        else quoteCellNib = [UINib nibWithNibName:@"CompanyInfoDetailCell" bundle:nil];
            
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.cellInfo;
        self.cellInfo = nil;
    }
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath forTableView:tableView];
    
    return cell;
}
/*- (void)mergeChanges:(NSNotification *)notification;
{
	NSManagedObjectContext *mainContext = self.managedObjectContext;
	
	// Merge changes into the main context on the main thread
	[mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                                  withObject:notification
                               waitUntilDone:YES];
}*/


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //NSLog(@"DELETE start");
        
        // hide edit's
        CompanyInfoDetailCell *cell = (CompanyInfoDetailCell *)[tableView cellForRowAtIndexPath:editingRow];
        cell.name.hidden = NO;
        cell.url.hidden = NO;
        cell.members.hidden = NO;
        cell.destinations.hidden = NO;
        cell.adminFirstName.hidden = NO;
        cell.adminLastName.hidden = NO;
        cell.notification.hidden = NO;
        cell.isVisibleLabel.hidden = NO;
        
        cell.changeCompanyName.hidden = YES;
        cell.changeCompanyURL.hidden = YES;
        
        [tableView setEditing:NO animated:YES];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:editingRow] withRowAnimation:UITableViewRowAnimationFade];
        //[tableView selectRowAtIndexPath:editingRow animated:YES scrollPosition:UITableViewScrollPositionNone];
     
        NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
        //NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        
        NSInteger numberOfRows = [tableView numberOfRowsInSection:0];
        //if (newPath.row <= numberOfRows) {
        CurrentCompany *removedObject = [fetchController objectAtIndexPath:indexPath];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        if (newPath.row == numberOfRows) {
            // this was a lastone row, we must choice previous row
            newPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            
        }
        //[tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionNone];

        CurrentCompany *nextObject = [fetchController objectAtIndexPath:newPath];
        [self updateRelationship:nextObject];

//        [userController deleteObjectAndChangeLocalStatusForAllSubEntitiesForObject:[removedObject objectID] parent:nil];
        
//        if ([[userController localStatusForObjectsWithRootGuid:removedObject.GUID] isEqualToString:@"finish"]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
                [clientController removeObjectWithID:[removedObject objectID]];
                [clientController release];
            });
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                //CurrentCompany *removedObject = [fetchController objectAtIndexPath:indexPath];
//                NSMutableDictionary *deleteStatus = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"object deleted",@"delete", nil];
//                [userController setUserDefaultsObject:deleteStatus forKey:removedObject.GUID];
//                
//                //NSLog(@"registrations:%@",userController.registrationsInProcessNow);
//                if ([userController.registrationsInProcessNow containsObject:removedObject]) {
//                    [userController.canceledRegistrations addObject:removedObject];
//                    while ([userController.registrationsInProcessNow containsObject:removedObject]) {
//                        sleep(1); 
//                    }
//                }
//                
//                //NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
//                //CurrentCompany *nextObject = [fetchController objectAtIndexPath:newPath];
//                
//                 dispatch_async(dispatch_get_main_queue(), ^(void) { 
//
//                    //[self updateRelationship:nextObject];
//                    [tableView setEditing:NO animated:YES];
//                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationFade];
//                    [tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//                 });
//                 NSArray *keys = [[[stuff entity] attributesByName] allKeys];
//                 NSDictionary *clientStuffFullInfo = [stuff dictionaryWithValuesForKeys:keys];
//                 
//                 NSDictionary *opjectsForRegistration = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:removedObject], @"deleted", removedObject.GUID,@"rootObjectGUID",  nil];
//                 
//                 [userController startRegistrationForObjects:opjectsForRegistration 
//                                                forTableView:self.tableView 
//                                                   forSender:self 
//                                         clientStuffFullInfo:clientStuffFullInfo];
//
//            });
//        } 
        //else {
            //[self.managedObjectContext deleteObject:removedObject];
            //[self safeSave];
        //}
            
        //} else {

        //}

        editingRow = nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == editingRow.row && indexPath.section == editingRow.section) return YES;
    else return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    CurrentCompany *selected = (CurrentCompany *)[fetchController objectAtIndexPath:indexPath];
    //NSLog(@"selected:%@",selected);
    NSSet *currentStuffs = selected.companyStuff;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",selected.companyAdminGUID];
    CompanyStuff *admin = [[currentStuffs filteredSetUsingPredicate:predicate] anyObject];
    [self performSelectorOnMainThread:@selector(updateRelationship:) withObject:selected waitUntilDone:YES];

    if (admin && ![admin isEqual:stuff]) {
        // here is different admin, can't be edited
        [self createNavigatorRightBlockWithMiddleTittle:@"Join"startAction:@selector(registerCompany) isEdited:NO];
        
    } else { 
        //NSLog(@"%@=%@, %@",selected.companyAdminGUID,stuff.GUID,[userController localStatusForObject:selected]);
        //if ([selected.companyAdminGUID isEqualToString:stuff.GUID] && [[userController localStatusForObjectsWithRootGuid:selected.GUID] isEqualToString:@"finish"]) 
        
            [self createNavigatorRightBlockWithMiddleTittle:nil startAction:nil isEdited:YES];
            //else [self createNavigatorRightBlockWithMiddleTittle:@"Register" startAction:@selector(registerCompany) isEdited:YES];
    }

    if (editingRow) { 
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
        [tableView selectRowAtIndexPath:editingRow animated:YES scrollPosition:UITableViewScrollPositionNone];
        return; 
    };
    
    
    return;
    if (editingRow) {
        return;
    }
    CompanyInfoDetailCell *cell = (CompanyInfoDetailCell *)[tableView cellForRowAtIndexPath:indexPath];

    cell.name.hidden = YES;
    cell.url.hidden = YES;
    cell.members.hidden = YES;
    cell.destinations.hidden = YES;
    cell.adminFirstName.hidden = YES;
    cell.adminLastName.hidden = YES;
    cell.notification.hidden = YES;
    cell.isVisibleLabel.hidden = YES;

    cell.changeCompanyName.hidden = NO;
    cell.changeCompanyURL.hidden = NO;
    cell.changeCompanyName.text = cell.name.text;
    cell.changeCompanyURL.text = cell.url.text;
    editingRow = indexPath;

}


#pragma mark - Delegate methods of NSFetchedResultsController


- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    //NSLog(@"fetch controller start:%@",[NSDate date]);
    CompanyStuff *admin = (CompanyStuff *)[self.managedObjectContext objectWithID:stuffID];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(isVisibleForCommunity == YES) or ((isVisibleForCommunity == NO) and (companyAdminGUID == %@))",admin.GUID];
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *predicateArray = [NSMutableArray array];
    
    if(searchString.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)",searchString];
        
        [predicateArray addObject:predicate];
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

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController != nil) 
    {
        return fetchedResultsController;
    }
    fetchedResultsController = [self newFetchedResultsControllerWithSearch:nil];
    return [[fetchedResultsController retain] autorelease];
}   

- (NSFetchedResultsController *)fetchResultControllerSearch 
{
    if (searchFetchedResultsController != nil) 
    {
        return searchFetchedResultsController;
    }
    searchFetchedResultsController = [self newFetchedResultsControllerWithSearch:self.bar.text];
    return [[searchFetchedResultsController retain] autorelease];
}   

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(CompanyInfoDetailCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath forTableView:(UITableView *)tableView;
{ 
    [self configureCell:theCell atIndexPath:theIndexPath forTableView:tableView];    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.mySearchDisplayController.searchResultsTableView;
    
	[tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.mySearchDisplayController.searchResultsTableView;
    
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
            //NSLog(@"COMPANY ADD: delete from fetchController");
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView setEditing:NO animated:YES];
            NSInteger numberOfRows = [tableView numberOfRowsInSection:0];
            //if (newPath.row <= numberOfRows) {

            NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            if (newPath.row == numberOfRows) {
                // this was a lastone row, we must choice previous row
                newPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
                
            }

            //NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            [tableView selectRowAtIndexPath:newPath animated:YES scrollPosition:UITableViewScrollPositionNone];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(CompanyInfoDetailCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath forTableView:tableView];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            
//            NSIndexPath *selectPath = [NSIndexPath indexPathForRow:newIndexPath.row + 1 inSection:newIndexPath.section];
//            if (selectPath.row == numberOfRows) {
//                // this was a lastone row, we must choice previous row
//                selectPath = [NSIndexPath indexPathForRow:newIndexPath.row - 1 inSection:newIndexPath.section];
//                
//            }
            //NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:self.tableView];
//            CurrentCompany *selected = [controller objectAtIndexPath:newIndexPath];
//
//            
//            //NSIndexPath *currentPosition = [controller indexPathForObject:selected]; 
//            [self.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//            [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
//            
//            if ([selected.companyAdminGUID isEqualToString:stuff.GUID]) {
//                // admin can edit and register company
//                //if ([selected.companyAdminGUID isEqualToString:stuff.GUID] && [[userController localStatusForObjectsWithRootGuid:selected.GUID] isEqualToString:@"finish"]) 
//                [self createNavigatorRightBlockWithMiddleTittle:nil startAction:nil isEdited:YES];
//                ///else [self createNavigatorRightBlockWithMiddleTittle:@"Register" startAction:@selector(registerCompany) isEdited:YES];
//                // non admin can only join
//            } else  [self createNavigatorRightBlockWithMiddleTittle:@"Join"startAction:@selector(registerCompany) isEdited:NO];

            //[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [tableView endUpdates];
            [tableView beginUpdates];
            [tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            //[tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionNone  animated:YES];
            [tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
            break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    UITableView *tableViewCurrent = controller == self.fetchedResultsController ? self.tableView : self.mySearchDisplayController.searchResultsTableView;
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableViewCurrent insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableViewCurrent deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    UITableView *tableView = controller == self.fetchedResultsController ? self.tableView : self.mySearchDisplayController.searchResultsTableView;

	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[tableView endUpdates];
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSInteger)scope
{
    // update the filter, in this case just blow away the FRC and let lazy evaluation create another with the relevant search info
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;
    searchFetchedResultsController = nil;
    
    self.searchFetchedResultsController = [self fetchResultControllerSearch];
    
    // if you care about the scope save off the index to be used by the serchFetchedResultsController
    //self.savedScopeButtonIndex = scope;
    
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView;
{
    // search is done so get rid of the search FRC and reclaim memory
    self.searchFetchedResultsController.delegate = nil;
    self.searchFetchedResultsController = nil;

    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:self.tableView];
    CurrentCompany *selected = stuff.currentCompany;
    NSIndexPath *currentPosition = [fetchController indexPathForObject:selected]; 
    
    [self.tableView selectRowAtIndexPath:currentPosition animated:YES scrollPosition:UITableViewScrollPositionNone];
    //editingRow = currentPosition;

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    for(UIView *subview in self.mySearchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:UILabel.class]) {
            subview.hidden = YES;
        }
    }

    [self filterContentForSearchText:searchString 
                               scope:[self.mySearchDisplayController.searchBar selectedScopeButtonIndex]];

    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    for(UIView *subview in self.mySearchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:UILabel.class]) {
            subview.hidden = YES;
        }
    }

    [self filterContentForSearchText:[self.mySearchDisplayController.searchBar text] 
                               scope:[self.mySearchDisplayController.searchBar selectedScopeButtonIndex]];

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView 
{
    for(UIView *subview in tableView.subviews) {
        if([subview isKindOfClass:UILabel.class]) {
            subview.hidden = YES;
        }
    }

    tableView.rowHeight = 92;
    tableView.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
}

#pragma mark -
#pragma mark Content update Methods


-(void) registerCompany;
{
    [self safeSave];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:self.managedObjectContext];
        
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:self.stuffID] mustBeApproved:YES];
        
        [clientController release];
    });

    
    //NSLog(@"register");
//    UITableView *tableView = nil;
//    
//    if (searchFetchedResultsController) tableView = self.mySearchDisplayController.searchResultsTableView;
//    else tableView = self.tableView;
//    NSIndexPath *selectedRow = [tableView indexPathForSelectedRow];
//    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
//    
//    CurrentCompany *selected = (CurrentCompany *)[fetchController objectAtIndexPath:selectedRow];
//
//    NSArray *keys = [[[stuff entity] attributesByName] allKeys];
//    NSDictionary *clientStuffFullInfo = [stuff dictionaryWithValuesForKeys:keys];
//    
//    NSMutableDictionary *objectsForRegistration = [NSMutableDictionary dictionaryWithCapacity:0];
//    NSString *statusForCompany = [userController localStatusForObjectsWithRootGuid:selected.GUID];
//    NSString *statusForForStuff = [userController localStatusForObjectsWithRootGuid:stuff.GUID];
//    
//    [objectsForRegistration setValue:selected.GUID forKey:@"rootObjectGUID"];
//    
//    NSMutableArray *new = [NSMutableArray arrayWithCapacity:0];
//    NSMutableArray *update = [NSMutableArray arrayWithCapacity:0];
//    NSMutableArray *delete = [NSMutableArray arrayWithCapacity:0];
//  
//    if (statusForCompany && ![statusForCompany isEqualToString:@"unregistered"]) [update addObject:[selected objectID]]; 
//    else [new addObject:[selected objectID]];
//    if (statusForForStuff) [update addObject:[stuff objectID]];
//    else  [new addObject:[stuff objectID]];
//    
//    // update all carriers list for registration
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyAdminGUID == %@",stuff.GUID];
//    NSArray *allCompanies = [fetchController fetchedObjects];
//    NSArray *companiesWhereAdminIsLocalStuff = [allCompanies filteredArrayUsingPredicate:predicate];
//    [companiesWhereAdminIsLocalStuff enumerateObjectsWithOptions:NSSortStable usingBlock:^(CurrentCompany *company, NSUInteger idx, BOOL *stop) {
//        NSString *statusForCompany = [userController localStatusForObjectsWithRootGuid:company.GUID];
//        if (statusForCompany && [statusForCompany isEqualToString:@"finish"]) {
//            [delete addObject:[company objectID]];
//            [userController removeUserDefaultsObjectForKey:company.GUID];
//        }
//
//    }];
//
//    [objectsForRegistration setValue:new forKey:@"new"];
//    [objectsForRegistration setValue:update forKey:@"updated"];
//    [objectsForRegistration setValue:delete forKey:@"deleted"];
//
//    //NSLog(@"userController context = %@",userController.context);
//    [userController startRegistrationForObjects:objectsForRegistration 
//                                   forTableView:self.tableView 
//                                      forSender:self 
//                            clientStuffFullInfo:clientStuffFullInfo];
  
//    [new removeAllObjects];
//    [update removeAllObjects];
//    [delete removeAllObjects];
//    
//    NSSet *currentCarrier = stuff.carrier;
//    [currentCarrier enumerateObjectsWithOptions:NSSortStable usingBlock:^(Carrier *carrier, BOOL *stop) {
//        NSString *statusForCarrier = [userController localStatusForObjectsWithRootGuid:carrier.GUID];
//        if (statusForCarrier && ![statusForCarrier isEqualToString:@"unregistered"]) [update addObject:[carrier objectID]]; 
//        else [new addObject:[carrier objectID]];
//        
//        
//    }];
//    [objectsForRegistration setValue:new forKey:@"new"];
//    [objectsForRegistration setValue:update forKey:@"updated"];
//    [objectsForRegistration setValue:delete forKey:@"deleted"];
//    
//    //Carrier *anyCarrier = [currentCarrier anyObject];
//    
//    //[objectsForRegistration setValue:anyCarrier.GUID forKey:@"rootObjectGUID"];
//    //NSMutableDictionary *newStatus = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"new",@"new", nil];
//    //[userController setUserDefaultsObject:newStatus forKey:anyCarrier.GUID];
//
//    //NSLog(@"userController context = %@",userController.context);
//    [userController startRegistrationForObjects:objectsForRegistration 
//                                   forTableView:self.tableView 
//                                      forSender:self 
//                            clientStuffFullInfo:clientStuffFullInfo];
//
    
}
-(void)switchHiddenStatusForCompany
{
    CompanyStuff *currentAdmin = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
    
    CurrentCompany *selected = currentAdmin.currentCompany;
    if ([selected.companyAdminGUID isEqualToString:currentAdmin.GUID]) {
        selected.isVisibleForCommunity = [NSNumber numberWithBool:![selected.isVisibleForCommunity boolValue]];
        [self safeSave];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:self.managedObjectContext];
            
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:selected.objectID] mustBeApproved:NO];
            
            [clientController release];
        });
        
//    NSArray *keys = [[[stuff entity] attributesByName] allKeys];
//    NSDictionary *clientStuffFullInfo = [stuff dictionaryWithValuesForKeys:keys];
//
//    NSMutableDictionary *objectsForRegistration = [NSMutableDictionary dictionaryWithCapacity:0];
//
//    NSString *statusForCompany = [userController localStatusForObjectsWithRootGuid:selected.GUID];
//    [objectsForRegistration setValue:selected.GUID forKey:@"rootObjectGUID"];
//    
//    NSMutableArray *new = [NSMutableArray arrayWithCapacity:0];
//    NSMutableArray *update = [NSMutableArray arrayWithCapacity:0];
//    NSMutableArray *delete = [NSMutableArray arrayWithCapacity:0];
//    if (statusForCompany && ![statusForCompany isEqualToString:@"unregistered"]) [update addObject:[selected objectID]]; 
//    else [new addObject:[selected objectID]];
//    [objectsForRegistration setValue:new forKey:@"new"];
//    [objectsForRegistration setValue:update forKey:@"updated"];
//    [objectsForRegistration setValue:delete forKey:@"deleted"];
//    
//    //NSLog(@"userController context = %@",userController.context);
//    [userController startRegistrationForObjects:objectsForRegistration 
//                                   forTableView:self.tableView 
//                                      forSender:self 
//                            clientStuffFullInfo:clientStuffFullInfo];
        isUserChangeCompanyForThisSession = YES;
    }
}
-(void) addNewCompany
{

    CurrentCompany *newCompany = (CurrentCompany *)[NSEntityDescription 
                                 insertNewObjectForEntityForName:@"CurrentCompany" 
                                 inManagedObjectContext:self.managedObjectContext];
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    newCompany.name = [NSString stringWithFormat:@"new company%@",[NSNumber numberWithInteger:numberOfRows]];
    CompanyStuff *currentAdmin = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
    newCompany.companyAdminGUID = currentAdmin.GUID;
    currentAdmin.currentCompany = newCompany;
    
    [self safeSave];
    
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:self.tableView];
    //CurrentCompany *selected = stuff.currentCompany;
    NSIndexPath *currentPosition = [fetchController indexPathForObject:newCompany]; 
    [self.tableView selectRowAtIndexPath:currentPosition animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.tableView scrollToRowAtIndexPath:currentPosition atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
}



-(void) editCompany:(id)sender;
{
    UITableView *tableView = nil;

    if (searchFetchedResultsController) tableView = self.mySearchDisplayController.searchResultsTableView;
    else tableView = self.tableView;
    self.editingRow = [tableView indexPathForSelectedRow];

    CompanyInfoDetailCell *cell = (CompanyInfoDetailCell *)[tableView cellForRowAtIndexPath:editingRow];
    
    cell.admin.hidden = YES;
    cell.name.hidden = YES;
    cell.url.hidden = YES;
    cell.members.hidden = YES;
    cell.destinations.hidden = YES;
    cell.adminFirstName.hidden = YES;
    cell.adminLastName.hidden = YES;
    cell.notification.hidden = YES;
    cell.isVisibleLabel.hidden = YES;
    
    
    cell.changeCompanyName.hidden = NO;
    cell.changeCompanyURL.hidden = NO;
    cell.changeCompanyName.text = cell.name.text;
    cell.changeCompanyURL.text = cell.url.text;
    [tableView setEditing:YES animated:YES];

}

-(void)companyDidChangesFor:(NSString *)placeholder;
{
    UITableView *tableView = nil;
    if (searchFetchedResultsController) tableView = self.mySearchDisplayController.searchResultsTableView;
    else tableView = self.tableView;
    
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    
    CurrentCompany *selected = nil;
    if (editingRow)
    {
        selected = (CurrentCompany *)[fetchController objectAtIndexPath:editingRow];
        
        //NSLog(@"registrations:%@/nselected:%@",userController.registrationsInProcessNow,selected);

//        if ([userController.registrationsInProcessNow containsObject:selected]) [userController.canceledRegistrations addObject:selected];
//
        //NSLog(@"cancelled:%@",userController.canceledRegistrations);

        CompanyInfoDetailCell *cell = (CompanyInfoDetailCell *)[tableView cellForRowAtIndexPath:editingRow];

        cell.admin.hidden = NO;
        cell.name.hidden = NO;
        cell.url.hidden = NO;
        cell.members.hidden = NO;
        cell.destinations.hidden = NO;
        cell.adminFirstName.hidden = NO;
        cell.adminLastName.hidden = NO;
        cell.notification.hidden = NO;
        cell.isVisibleLabel.hidden = NO;
        
        cell.changeCompanyName.hidden = YES;
        cell.changeCompanyURL.hidden = YES;
        selected.name = cell.changeCompanyName.text;
        selected.url = cell.changeCompanyURL.text;
        
//        NSDictionary *clientInfoFromDisk =[userController userDefaultsObjectForKey:selected.GUID];
//        NSMutableDictionary *clientInfo = [NSMutableDictionary dictionaryWithDictionary:clientInfoFromDisk];
//        
//        if ([clientInfo valueForKey:@"update"]) [clientInfo setValue:@"changed" forKey:@"update"];
//        else [clientInfo setValue:@"unregistered" forKey:@"new"];
//        [userController setUserDefaultsObject:clientInfo forKey:selected.GUID];
//        
//        selected.isRegistrationDone = [NSNumber numberWithBool:NO];
//        selected.isRegistrationProcessed = [NSNumber numberWithBool:NO];
        
        /*for (UIView *subview in cell.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISegmentedControl") ] ) 
                [subview setHidden:NO];
        }*/
 
    }
    //[segmented setSelectedSegmentIndex:1];
    NSIndexPath *currentPosition = [fetchController indexPathForObject:selected]; 

    [tableView beginUpdates];
    [tableView setEditing:NO animated:YES];
    [self.tableView selectRowAtIndexPath:currentPosition animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.tableView scrollToRowAtIndexPath:currentPosition atScrollPosition:UITableViewScrollPositionMiddle  animated:YES];
    [tableView endUpdates];
    
    [self safeSave];
    
    self.editingRow = nil;
    isUserChangeCompanyForThisSession = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:self.managedObjectContext];
        
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[selected objectID]] mustBeApproved:NO];
        [clientController release];
    });
    
}

-(void) updateRelationship:(CurrentCompany *)company
{
//    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastGraphUpdatingTime"];
//    if (lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] > 60) {
        CompanyStuff *currentAdmin = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
        currentAdmin.currentCompany = company;
        [self safeSave];
        //isUserChangeCompanyForThisSession = YES;
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


-(void) safeSave;
{
    //NSLog(@"SAVED");
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
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

#pragma mark - external reload methods

-(void) reloadLocalDataFromUserDataControllerForObject:(id)object;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:selected animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.companyAndUserConfiguration.tableView reloadData];
    });
}

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
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
            sleep(10);
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [self.navigationController setToolbarHidden:YES animated:YES]; 
            });
        });

        // present modal
    }
    
     NSManagedObjectID *objectID = nil;
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    
    if (objectID) {
        //if ([idsWithProgress containsObject:objectID] && ![isItLatestMessage boolValue]) return;
        //[idsWithProgress addObject:objectID];

            if ([[[[self.managedObjectContext objectWithID:objectID] entity] name] isEqualToString:@"CurrentCompany"]) {
                
                CurrentCompany *updatedCompany = (CurrentCompany *)[self.managedObjectContext objectWithID:objectID];
                //NSLog(@"Updated company:%@",updatedCompany);
                NSArray *allObjects = [self.fetchedResultsController fetchedObjects];
                //NSLog(@"All objects:%@",allObjects);
                NSArray *filteredObjects = [allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"GUID == %@",updatedCompany.GUID]];
                
                NSIndexPath *objectIndexPath = [self.fetchedResultsController indexPathForObject:[filteredObjects lastObject]];
                
                if (objectIndexPath) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:objectIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [self.tableView selectRowAtIndexPath:objectIndexPath animated:NO scrollPosition: UITableViewScrollPositionNone];
                    });
                    
                    CompanyInfoDetailCell *cell = (CompanyInfoDetailCell *)[self.tableView cellForRowAtIndexPath:objectIndexPath];
                    
                    if (![isItLatestMessage boolValue]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                            [cell.activity startAnimating];
                            cell.activity.hidden = NO;
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                        });
                        
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            
                            [cell.activity stopAnimating];
                            cell.activity.hidden = YES;
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                        });
                        
                        if ([status isEqualToString:@"remove object finish"] || [status isEqualToString:@"company for removing not found"]) { 
                            [self.managedObjectContext deleteObject:updatedCompany];
                            [self safeSave];
                        }
                        
                    }
                } else NSLog(@"COMPANY ADD:warning, indexPath for %@ not found",updatedCompany.name);
            }
        if ([[[[self.managedObjectContext objectWithID:objectID] entity] name] isEqualToString:@"CompanyStuff"]) {
            if (![isItLatestMessage boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                });
                
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                });
                
                if ([status isEqualToString:@"put object finish"] && ![isError boolValue]) { 
                    dispatch_async(dispatch_get_main_queue(), ^(void) { 
                        
                        UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"you request was sent to admin"]] autorelease];
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
                        sleep(10);
                        dispatch_async(dispatch_get_main_queue(), ^(void) { 
                            [self.navigationController setToolbarHidden:YES animated:YES]; 
                        });
                    });

                }
                
            }

            }
        
    }
    
    //withProgressEnabled:(BOOL)isProgressEnabled forObjectID:(NSManagedObjectID *)objectID andPercent:(NSNumber *)percent
    //NSLog(@"COMPANY ADD:update UI:%@ latest message:%@",status,isItLatestMessage);

    
    
}


@end
