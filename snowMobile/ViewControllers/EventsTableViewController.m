//
//  EventsViewController.m
//  snow
//
//  Created by Alex Vinogradov on 20.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsTableViewController.h"
#import "EventsDetailViewController.h"
#import "DownloadExternalData.h"
#import "HelpForInfoView.h"

#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
//#define LIGHT_BACKGROUND [UIColor colorWithRed:180.0/255.0 green:190.0/255.0 blue:198.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:211.0/255.0 green:220.0/255.0 blue:223.0/255.0 alpha:1.0]


@implementation EventsTableViewController



@synthesize managedObjectContext, fetchedResultsController,eventCell;
@synthesize savedSearchTerm;
@synthesize savedScopeButtonIndex;
@synthesize searchWasActive;
@synthesize searchFetchedResultsController;
@synthesize mySearchDisplayController;
@synthesize search;
@synthesize segmented;
@synthesize downloadExternalDataWasUnsucceseful;
@synthesize updateResult;
@synthesize downloadAttempts;
@synthesize persistentStoreCoordinator;
@synthesize download;
@synthesize updateResultText;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    self.searchWasActive = [self.mySearchDisplayController isActive];
    self.savedSearchTerm = [self.mySearchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.mySearchDisplayController.searchBar selectedScopeButtonIndex];
    
    fetchedResultsController_.delegate = nil;
    [fetchedResultsController_ release];
    fetchedResultsController_ = nil;
    searchFetchedResultsController_.delegate = nil;
    [searchFetchedResultsController_ release];
    searchFetchedResultsController_ = nil;
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[mySearchDisplayController release];
	[fetchedResultsController release];
	//[fetchedResultsController release];

	//[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Events";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];

    //UIBarButtonItem *update = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateExternalData)];
    //self.navigationItem.rightBarButtonItem = update;
    //[update release];
    
    /*self.updateResult = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 105, 25)];
    updateResult.backgroundColor = [UIColor clearColor];
    updateResult.adjustsFontSizeToFitWidth = YES;
    updateResult.font = [UIFont systemFontOfSize:12];

    self.updateResultText = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 125, 30)];
    updateResultText.backgroundColor = [UIColor clearColor];
    //updateResultText.a = YES;
    updateResultText.font = [UIFont systemFontOfSize:12];*/

    
    //UIBarButtonItem *resultUpdate = [[UIBarButtonItem alloc] initWithCustomView:updateResultText];
    //self.navigationItem.leftBarButtonItem = resultUpdate;
    //[resultUpdate release];
    //[updateResult release];
    
    //[self performSelectorOnMainThread:@selector(updateExternalData) withObject:nil waitUntilDone:YES];
    
    
    self.tableView.rowHeight = 73.0;

    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.separatorColor = [UIColor colorWithRed:109.0/255.0 green:132.0/255.0 blue:162.0/255.0 alpha:1.0];
    //self.tableView.backgroundColor = DARK_BACKGROUND;

    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectZero] autorelease];

    searchBar.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    //searchBar.backgroundColor = DARK_BACKGROUND;
    searchBar.opaque = NO;
    [searchBar sizeToFit];
    searchBar.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];

    self.tableView.tableHeaderView.backgroundColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];;
    self.tableView.tableHeaderView = searchBar;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];
    self.tableView.separatorColor = [UIColor whiteColor];

    self.mySearchDisplayController = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    self.mySearchDisplayController.searchResultsTableView.rowHeight = 73.0;
    self.mySearchDisplayController.searchBar.backgroundColor = DARK_BACKGROUND;
    
    if (self.savedSearchTerm)
    {
        [self.mySearchDisplayController setActive:self.searchWasActive];
        [self.mySearchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.mySearchDisplayController.searchBar setText:savedSearchTerm_];
        
        self.savedSearchTerm = nil;
    }
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}		
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

#pragma mark TODO check around subviews and retain it
- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:animated];

    [super viewWillAppear:animated];
    /*for(UIView *view in self.tabBarController.tabBar.subviews) {  
        if([view isKindOfClass:[UIImageView class]]) {  
            [view removeFromSuperview];  
        }  
    }  
    UIImageView *newView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"150px-IPCU_icon.png"]] autorelease];
    newView.frame = CGRectMake(0, 0, 30, 30);
    
    [self.tabBarController.tabBar insertSubview:newView atIndex:0];
    UIBarItem *info = [self.tabBarController.tabBar.items objectAtIndex:1];
    info.title = @"Events";*/
    HelpForInfoView *helpView = [[HelpForInfoView alloc] init];
    
    helpView.isEventsSheet = YES;
    if ([helpView isHelpNecessary]) {
        self.navigationController.view.alpha = 0.8;
        helpView.delegate = self;
        [self.tabBarController.view addSubview:helpView.view];
    } else [helpView release];

}

- (void)viewDidAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.searchWasActive = [self.mySearchDisplayController isActive];
    self.savedSearchTerm = [self.mySearchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.mySearchDisplayController.searchBar selectedScopeButtonIndex];

    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Event support

- (void)add:(id)sender {
    // To add a new recipe, create a RecipeAddViewController.  Present it as a modal view so that the user's focus is on the task of adding the recipe; wrap the controller in a navigation controller to provide a navigation bar for the Done and Save buttons (added by the RecipeAddViewController in its viewDidLoad method).
    /*EventAddTableViewController *addController = [[EventAddTableViewController alloc] initWithNibName:@"EventAddTableViewController" bundle:nil];
    addController.delegate = self;
	
	NSManagedObject *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:self.managedObjectContext];
	addController.event = newEvent;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addController];
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
    [addController release];*/
}

- (void)eventAddViewController:(UITableViewController *)eventAddViewController didAddEvent:(NSManagedObject *)event {
    if (event) {        
        // Show the recipe in a new view controller
        [self showEvent:event animated:NO];
    }
    
    // Dismiss the modal add recipe view controller
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showEvent:(NSManagedObject *)event animated:(BOOL)animated {
    // Create a detail view controller, set the recipe, then push it.
    EventsDetailViewController *detailViewController = [[EventsDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailViewController.event = event;
    
    [self.navigationController pushViewController:detailViewController animated:animated];
    [detailViewController release];
}




#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[[self fetchedResultsControllerForTableView:tableView] sections] count];

	if (count == 0) {
		count = 1;
	}
	
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
    NSArray *sections = fetchController.sections;
    if(sections.count > 0) 
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCellIdentifier";
        
    //UILabel *name, *date,*country;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        //[[NSBundle mainBundle] loadNibNamed:@"EventsTableCell" owner:self options:nil];
        //cell = eventCell;
        //self.eventCell = nil;
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
        for (UIView *subview in subviews) {
            [subview removeFromSuperview];
        }
        [subviews release];
        
        UILabel *country = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 244, 22)];
        country.font = [UIFont boldSystemFontOfSize:24];
        country.textColor = [UIColor whiteColor];
        country.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
        country.tag = 1;
        country.shadowColor = [UIColor blackColor];
        country.shadowOffset = CGSizeMake(1, 1);

        //UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(230, 0, 79, 21)];
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(12, 28, 145, 21)];

        date.font = [UIFont boldSystemFontOfSize:11];
        date.textColor = [UIColor whiteColor];
        date.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
        date.tag = 3;
        date.shadowColor = [UIColor blackColor];
        date.shadowOffset = CGSizeMake(1, 1);

        //UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(12, 20, 308, 21)];
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(12, 44, 308, 21)];

        name.font = [UIFont systemFontOfSize:13];
        name.textColor = [UIColor whiteColor];

        name.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
        name.tag = 2;
        name.shadowColor = [UIColor blackColor];
        name.shadowOffset = CGSizeMake(1, 1);


        [cell.contentView addSubview:country];
        [cell.contentView addSubview:date];
        [cell.contentView addSubview:name];
        [country release];
        [date release];
        [name release];
 
    }
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    //cell.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
    
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath forTableView:tableView];

    return cell;
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;

{
    UILabel *name, *date,*country;

    country = (UILabel *)[cell.contentView viewWithTag:1];
    name = (UILabel *)[cell.contentView viewWithTag:2];
    date = (UILabel *)[cell.contentView viewWithTag:3];
    
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];

    NSManagedObject *managedObject = [fetchController objectAtIndexPath:indexPath];
    NSString *countryWithIdent =  [managedObject valueForKey:@"name"];
    //NSString *countryName = [countryWithIdent stringByReplacingOccurrencesOfString:@"countriesEvent_" withString:@""];
    if (countryWithIdent) country.text = countryWithIdent;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *currentDate = [managedObject valueForKey:@"date"];
    //NSString *dateString = [currentDate description];
    NSString *dateString = [formatter stringFromDate:currentDate];
    [formatter release],formatter = nil;
    currentDate = nil;
    NSString *necessaryData = [managedObject valueForKey:@"necessaryData"];
    NSString *necessaryDataParsing = [necessaryData stringByReplacingOccurrencesOfString:@"countriesEvent_" withString:@"in country "];
    date.text = dateString;
    name.text = necessaryDataParsing;
    
    dateString = nil;necessaryData = nil;
    name = nil, date = nil, country = nil;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
	NSManagedObject *event = (NSManagedObject *)[fetchController objectAtIndexPath:indexPath];
    
    [self showEvent:event animated:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];
	NSManagedObject *event = (NSManagedObject *)[fetchController objectAtIndexPath:indexPath];
    
    [self showEvent:event animated:YES];

}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSFetchedResultsController *fetchController = [self fetchedResultsControllerForTableView:tableView];

		NSManagedObjectContext *context = [fetchController managedObjectContext];
        NSManagedObject *object = [fetchController objectAtIndexPath:indexPath];
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        NSString *eventIdentifier = [object valueForKey:@"eventIdentifier"];
        if (eventIdentifier) {
            EKEvent *eventExist = [eventStore eventWithIdentifier:eventIdentifier];
            NSError *error;
            
            BOOL removed = [eventStore removeEvent:eventExist span:EKSpanThisEvent error:&error];
            if (!removed && error) {
                NSLog(@"%@",[error localizedDescription]);
            } 
            
            [eventStore release];
            return;        
        }
      
        [eventStore release];
		[context deleteObject:object];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}   
}

- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    NSPredicate *filterPredicate = nil;
    filterPredicate = [NSPredicate predicateWithFormat:@"(date > %@)",[NSDate date]];
   //if ([segmented selectedSegmentIndex] == 0) filterPredicate = [NSPredicate predicateWithFormat:@"(date > %@) and (resolved == %@)",[NSDate date],[NSNumber numberWithBool:YES]];// your predicate here
    //if ([segmented selectedSegmentIndex] == 1) filterPredicate = [NSPredicate predicateWithFormat:@"(date > %@) and ((resolved == %@) or (resolved == nil))",[NSDate date],[NSNumber numberWithBool:NO]];// your predicate here
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSMutableArray *predicateArray = [NSMutableArray array];

    if(searchString.length) {
        [predicateArray addObject:[NSPredicate predicateWithFormat:@"necessaryData CONTAINS[cd] %@", searchString]];
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
    //[fetchRequest setFetchBatchSize:20];
    //[fetchRequest setFetchLimit:20];
    
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
    if (fetchedResultsController_ != nil) 
    {
        return fetchedResultsController_;
    }
    fetchedResultsController_ = [self newFetchedResultsControllerWithSearch:nil];
    return [[fetchedResultsController_ retain] autorelease];
}   

- (NSFetchedResultsController *)searchFetchedResultsController 
{
    if (searchFetchedResultsController_ != nil) 
    {
        return searchFetchedResultsController_;
    }
    searchFetchedResultsController_ = [self newFetchedResultsControllerWithSearch:self.mySearchDisplayController.searchBar.text];
    return [[searchFetchedResultsController_ retain] autorelease];
}   



/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.fetchedResultsController : self.searchFetchedResultsController;
}

- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath forTableView:(UITableView *)tableView;
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
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath forTableView:tableView];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    searchFetchedResultsController_ = nil;
    
    self.searchFetchedResultsController = [self searchFetchedResultsController];
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
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString 
                               scope:[self.mySearchDisplayController.searchBar selectedScopeButtonIndex]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.mySearchDisplayController.searchBar text] 
                               scope:[self.mySearchDisplayController.searchBar selectedScopeButtonIndex]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView 
{
    tableView.rowHeight = 73.0;
    tableView.separatorColor = [UIColor colorWithRed:109.0/255.0 green:132.0/255.0 blue:162.0/255.0 alpha:1.0];

}

#pragma mark -
#pragma mark UISegmentedControl Methods

-(void) resolvedSelected:(id)sender
{
    //[self.fetchedResultsController fetchRequest];
}

#pragma mark -
#pragma mark Update external data Methods

- (void) updateExternalData;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:kCFDateFormatterShortStyle];
    [formatter setDateStyle: NSDateFormatterNoStyle];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    [formatter release];

    self.navigationItem.rightBarButtonItem.enabled = NO;
    updateResultText.text = [NSString stringWithFormat:@"%@ Update\n is started.",time];
    NSManagedObjectContext *context = self.managedObjectContext;
    self.download = [[[DownloadExternalData alloc] init] autorelease];
    download.managedObjectContext = context;
    NSPersistentStoreCoordinator *psc = self.persistentStoreCoordinator;
    download.persistentStoreCoordinator = psc;
    download.delegateData = self;
    //[download downloadAndPutInLocalDatabaseEventsArray];
    
}

#pragma mark <DownloadExternalDataDelegate> Implementation

- (void)updateUIForThread:(NSNumber *) result
{
//    NSError *saveError = nil;
//    NSAssert1([self.managedObjectContext save:&saveError], @"Unhandled error saving managed object context in import thread: %@", [saveError localizedDescription]);
//    #pragma unused (saveError)

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:kCFDateFormatterShortStyle];
    [formatter setDateStyle: NSDateFormatterNoStyle];
    NSString *time = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    if ([result boolValue]) updateResultText.text = [NSString stringWithFormat:@"%@ Update\nwas successeful.",time];
    else  updateResultText.text = [NSString stringWithFormat:@"%@ Update\nwas unsucceseful.",time];;
    int attempts = self.downloadAttempts;
    attempts++;
    self.downloadAttempts = attempts;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.download = nil;
    [result release];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastStoreUpdate"];
}

- (void)dataWasUpdateWithResult:(DownloadOperation *)importer;
{
    NSNumber *result = [[NSNumber alloc] initWithBool:!importer.downloadExternalDataWasUnsucceseful];
    [self performSelectorOnMainThread:@selector(updateUIForThread:) withObject:result waitUntilDone:YES];
    [result release]; 
}

-(void)helpShowingDidFinish;
{
    self.navigationController.view.alpha = 1.0;
}

@end
