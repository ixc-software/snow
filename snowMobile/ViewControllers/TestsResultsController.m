//
//  TestsResultsController.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "TestsResultsController.h"
#import "mobileAppDelegate.h"
#import "DestinationsListWeBuyResults.h"
#import "DestinationsListWeBuyTesting.h"

@interface TestsResultsController () {
    NSFetchedResultsController *fetchedResultsController_;
}
@end

@implementation TestsResultsController
@synthesize tableView;
@synthesize destination,resultCell;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMoc:(NSManagedObjectContext *)moc withDestinationMain:(NSManagedObject *)destinationMain;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        managedObjectContext = moc;
        destination = destinationMain;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSArray *fetchedObjects = [[self fetchedResultsControllerForTableView:tableView] fetchedObjects];
    //NSLog(@"%@",[fetchedObjects lastObject]);
    NSInteger count = [[[self fetchedResultsController] sections] count];
    NSLog(@"Number of sections:%@",[NSNumber numberWithUnsignedInteger:count]);
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSInteger finalResult = 0;
//    if ([sections lastIndex] == section) finalResult = 1;
//    return finalResult;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];

    //return 10;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSArray *object = [sectionInfo objects];
    DestinationsListWeBuyResults *result = object.lastObject;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm"];

	// create the parent view that will hold header Label
	UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)] autorelease];
	
	// create the button object
	UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
	headerLabel.font = [UIFont boldSystemFontOfSize:20];
	headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    headerLabel.textAlignment = UITextAlignmentCenter;
        
	headerLabel.text = [NSString stringWithFormat:@"Test date:%@",[dateFormatter stringFromDate:result.destinationsListWeBuyTesting.date]];
    headerLabel.shadowOffset = CGSizeMake(1, 1);
    headerLabel.shadowColor = [UIColor blueColor];
    
	[customView addSubview:headerLabel];
    
	return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 44.0;
}

- (void)configureCell:(TestingResultsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;

{
    NSFetchedResultsController *fetchController = [self fetchedResultsController];
    DestinationsListWeBuyResults *result = [fetchController objectAtIndexPath:indexPath];
    
    cell.number.text = [NSString stringWithFormat:@"+%@",result.numberB];
    cell.numberA.text = [NSString stringWithFormat:@"from +%@",result.numberA];

    NSDate *timeInvite = result.timeInvite;
    NSDate *timeRinging = result.timeRinging;

    NSTimeInterval inviteRingingInterval = [timeRinging timeIntervalSinceDate:timeInvite];
    [cell.setupConnectTime removeAllSegments];
    [cell.setupConnectTime insertSegmentWithTitle:[NSString stringWithFormat:@"%@ sec",[NSNumber numberWithInt:inviteRingingInterval]] atIndex:0 animated:NO];
    
    NSDate *timeSetup = result.timeSetup;
    NSDate *timeOk = result.timeOk;
    
    NSTimeInterval ringingOkInterval = [timeOk timeIntervalSinceDate:timeSetup];
    [cell.pddTime removeAllSegments];
    [cell.pddTime insertSegmentWithTitle:[NSString stringWithFormat:@"%@ sec",[NSNumber numberWithInt:ringingOkInterval]] atIndex:0 animated:NO];
    
    
    NSDate *timeRelease = result.timeRelease;
    
    NSTimeInterval okReleaseInterval = [timeRelease timeIntervalSinceDate:timeOk];
    [cell.callTime removeAllSegments];
    [cell.callTime insertSegmentWithTitle:[NSString stringWithFormat:@"%@ sec",[NSNumber numberWithInt:okReleaseInterval]] atIndex:0 animated:NO];
    
    cell.inputPackets.text = [NSString stringWithFormat:@"Input:%@k",result.inputPackets];
    cell.outputPackets.text = [NSString stringWithFormat:@"Output:%@k",result.outputPackets];
    if (okReleaseInterval > 0) {
        cell.markFasButton.hidden = NO;

        if (result.isFAS.boolValue) {
            cell.number.textColor = [UIColor redColor];
            cell.fasReason.hidden = NO;
            cell.isFas = YES;
            cell.fasReason.text = result.fasReason;
            [cell.markFasButton setImage:[UIImage imageNamed:@"unmarkAsFas.png"] forState:UIControlStateNormal];
            [cell.markFasButton addTarget:cell action:@selector(unmarkAsFas:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            cell.number.textColor = [UIColor greenColor];
            cell.fasReason.hidden = YES;
            cell.isFas = NO;
            [cell.markFasButton setImage:[UIImage imageNamed:@"markAsFas.png"] forState:UIControlStateNormal];
            [cell.markFasButton addTarget:cell action:@selector(markAsFas:) forControlEvents:UIControlEventTouchUpInside];
        }
    }  else {
        cell.fasReason.hidden = YES;
        cell.markFasButton.hidden = YES;
    }
    cell.playButton.enabled = NO;

    if (result.ringMP3 && result.ringMP3.length > 0) {
        cell.playButton.enabled = YES;
        [cell.markFasButton addTarget:cell action:@selector(playRing:) forControlEvents:UIControlEventTouchUpInside];

    }

    //if (result.ringMP3 && result.ringMP3.length > 0) {
//    if (cell.isPlayingCall) {
//        cell.playButton.enabled = YES;
//        [cell.playButton addTarget:cell action:@selector(stopPlayCall:) forControlEvents:UIControlEventTouchUpInside];
//        NSLog(@">>>>>>>>>>>stopPlayCall:");
//
//    } else {
        
        cell.playButton.enabled = YES;
        [cell.playButton addTarget:cell action:@selector(playCall:) forControlEvents:UIControlEventTouchUpInside];
        //NSLog(@">>>>>>>>>>>playCall:");

//    }
    //}

    /*@dynamic numberB;
    @dynamic inputPackets;
    @dynamic outputPackets;
    @dynamic timeSetup;
    @dynamic timeInvite;
    @dynamic timeOk;
    @dynamic timeRelease;
    @dynamic timeRinging;
    @dynamic timeTrying;
    @dynamic numberA;
    @dynamic ringMP3;
    @dynamic callMP3;
     @dynamic isFAS;
     @dynamic log;
    @dynamic fasReason;
     */
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"TestingResultsTableViewCell";
    
    TestingResultsTableViewCell *cell = (TestingResultsTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        UINib *quoteCellNib;
        mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([delegate isPad]) quoteCellNib = [UINib nibWithNibName:@"TestingResultsTableViewCellIPad" bundle:nil];
        else quoteCellNib = [UINib nibWithNibName:@"TestingResultsTableViewCell" bundle:nil];
        
        //        UINib *quoteCellNib = [UINib nibWithNibName:@"DestinationsPushListCell" bundle:nil];
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.resultCell;
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        self.resultCell = nil;
        
        [self configureCell:cell atIndexPath:indexPath forTableView:self.tableView];
        
//        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//        [cell addGestureRecognizer:longPressRecognizer];      
//        [longPressRecognizer release];
        
    }
    
    return cell;
}

#pragma mark - action methods
- (IBAction)playRingForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"playRingForIndexPath:%@",indexPath);
}

- (IBAction)stopPlayRingForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"stopPlayRingForIndexPath:%@",indexPath);
}


- (IBAction)playCallForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"playCallForIndexPath:%@",indexPath);

}
- (IBAction)stopPlayCallForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"stopPlayCallForIndexPath:%@",indexPath);
}

- (IBAction)unmarkAsFasForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"unmarkAsFasForIndexPath:%@",indexPath);

}
- (IBAction)markAsFasForIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"markAsFasForIndexPath:%@",indexPath);

}

- (void)dealloc {
    [tableView release];
    [super dealloc];
}

#pragma mark - NSFetchedResultsController methods
- (NSFetchedResultsController *)newFetchedResultsControllerWithSearch:(NSString *)searchString
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"destinationsListWeBuyTesting.date" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(destinationsListWeBuyTesting.destinationsListWeBuy.GUID == %@)",[self.destination valueForKey:@"GUID"]];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuyResults" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:filterPredicate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:@"destinationsListWeBuyTesting.objectID" 
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    
	[tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(TestingResultsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath forTableView:tableView];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	[tableView endUpdates];
}


@end
