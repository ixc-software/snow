//
//  RegistrationsAvaitingApproveDetailViewController.m
//  snow
//
//  Created by Oleksii Vynogradov on 28.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "RegistrationsAvaitingApproveDetailViewController.h"
#import "CompanyStuff.h"
#import "OperationNecessaryToApprove.h"
#import "ClientController.h"

@implementation RegistrationsAvaitingApproveDetailViewController

@synthesize stackRecord,cellInfo,stuff,companyAndUsedConfiguration,operationObjectID;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}
-(void) safeSave;
{
    //NSLog(@"SAVED");
    NSError *error = nil;
    if ([self.companyAndUsedConfiguration.managedObjectContext hasChanges]) [self.companyAndUsedConfiguration.managedObjectContext save:&error];
    if (error) NSLog(@"%@",[error localizedDescription]);
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
    self.navigationItem.title = @"User for approve";
    self.tableView.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
    //[[[self.stackRecord valueForKey:@"clientStuffFullInfo"] allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    RegistrationsDetailTableViewCell *cell = (RegistrationsDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UINib *quoteCellNib = [UINib nibWithNibName:@"RegistrationsDetailTableViewCell" bundle:nil];
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.cellInfo;
        self.cellInfo = nil;
    }
    
//    NSString *key = nil;
    //[[[self.stackRecord valueForKey:@"clientStuffFullInfo"] allKeys] objectAtIndex:indexPath.row];
    OperationNecessaryToApprove *updated = (OperationNecessaryToApprove *)[self.companyAndUsedConfiguration.managedObjectContext objectWithID:operationObjectID];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:updated.forEntity inManagedObjectContext:self.companyAndUsedConfiguration.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",updated.forGUID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.companyAndUsedConfiguration.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    [fetchRequest release];
    CompanyStuff *findedStuff = [fetchedObjects lastObject];

    if (!findedStuff) NSLog(@"REGISTRATIONS: warning, stuff for approve not found in local database");

    if (indexPath.row == 0) { 
        cell.key.text = @"firstName";
        cell.attribute.text = findedStuff.firstName;
        
    }
    if (indexPath.row == 1) { 
        cell.key.text = @"lastName";
        cell.attribute.text = findedStuff.lastName;

    }
    if (indexPath.row == 2) { 
        cell.key.text = @"email";
        cell.attribute.text = findedStuff.email;
    }
//    NSArray *updated = [self.stackRecord valueForKey:@"updated"];
//    if ([updated count] != 0) { 
//        NSDictionary *stuffObject = nil;
//        // hz why but position in array can changed, so we cover all
//        if (![[stuffObject valueForKey:@"entity"] isEqualToString:@"CompanyStuff"]) stuffObject = [updated objectAtIndex:0];
//        else [updated objectAtIndex:1];
//        
//        NSDictionary *clientStuff = [stuffObject valueForKey:@"clientStuffFullInfo"];
//        
//        
//        NSString *attribute = [clientStuff valueForKey:key];
//        NSLog(@"key:%@ attribute:%@",key,attribute);
//        cell.key.text = key;
//        if ([[attribute class] isSubclassOfClass:[NSString class]]) cell.attribute.text = attribute;
//        //else cell.attribute.titleLabel.text = [attribute stringValue];
//    }
    // Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 45;
}       

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(100, 20, 30, 30)] autorelease];

    UISegmentedControl *reject = nil;
    UISegmentedControl *approve = nil;

    approve = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Approve", nil]] autorelease];
    approve.segmentedControlStyle = UISegmentedControlStyleBar;
    approve.tintColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
    approve.frame = CGRectMake(190.0, 10.0, 100.0, 35.0);
    [approve addTarget:self action:@selector(approve) forControlEvents:UIControlEventValueChanged];
    [approve setSelectedSegmentIndex:UISegmentedControlNoSegment];
    approve.opaque = NO;
    approve.enabled = YES;



    reject = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Reject", nil]] autorelease];
    reject.segmentedControlStyle = UISegmentedControlStyleBar;
    reject.tintColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
    reject.frame = CGRectMake(40.0, 10.0, 100.0, 35.0);
    [reject addTarget:self action:@selector(reject) forControlEvents:UIControlEventValueChanged];
    [reject setSelectedSegmentIndex:UISegmentedControlNoSegment];
    reject.opaque = NO;

    [customView addSubview:approve];
    [customView addSubview:reject];
    return customView;
    

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Data methods

-(void) approve
{
    OperationNecessaryToApprove *updated = (OperationNecessaryToApprove *)[self.companyAndUsedConfiguration.managedObjectContext objectWithID:operationObjectID];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:updated.forEntity inManagedObjectContext:self.companyAndUsedConfiguration.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",updated.forGUID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.companyAndUsedConfiguration.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    [fetchRequest release];
    CompanyStuff *findedStuff = [fetchedObjects lastObject];
    findedStuff.isRegistrationDone = [NSNumber numberWithBool:YES];
    findedStuff.isRegistrationProcessed = [NSNumber numberWithBool:NO];
    [self safeSave];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.companyAndUsedConfiguration.managedObjectContext persistentStoreCoordinator] withSender:self.companyAndUsedConfiguration withMainMoc:self.companyAndUsedConfiguration.managedObjectContext];
        
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[findedStuff objectID]] mustBeApproved:NO];
        [clientController release];
    });

    
//    [self.userController startProcessingtFor:self.stackRecord toStatus:self.userController.controller.objectStatusFinish sender:self]; 
//                                //forTableView:self.companyAndUsedConfiguration.tableView 
//                                   // toStatus:self.userController.controller.objectStatusFinish] ;
//    
//    NSData *stackData = [[userController userDefaultsObjectForKey:stuff.GUID] valueForKey:@"recordsStack"];
//    NSArray *stack = [NSKeyedUnarchiver unarchiveObjectWithData:stackData];
//
//    NSMutableArray *stackMutable = [NSMutableArray arrayWithArray:stack];
//    [stackMutable removeObject:self.stackRecord];
//    NSData *finalStackData = [NSKeyedArchiver archivedDataWithRootObject:stackMutable];
//    
//    NSDictionary *stuffInfo = [userController userDefaultsObjectForKey:stuff.GUID];
//    NSMutableDictionary *stuffInfoMutable = [NSMutableDictionary dictionaryWithDictionary:stuffInfo];
//    [stuffInfoMutable setValue:finalStackData forKey:@"recordsStack"];
//    [userController setUserDefaultsObject:[NSDictionary dictionaryWithDictionary:stuffInfoMutable] forKey:stuff.GUID];

    
    //NSLog(@"approve");
    [self.navigationController popToRootViewControllerAnimated:YES];

}

-(void)reject
{
    OperationNecessaryToApprove *updated = (OperationNecessaryToApprove *)[self.companyAndUsedConfiguration.managedObjectContext objectWithID:operationObjectID];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:updated.forEntity inManagedObjectContext:self.companyAndUsedConfiguration.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",updated.forGUID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.companyAndUsedConfiguration.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    [fetchRequest release];
    CompanyStuff *findedStuff = [fetchedObjects lastObject];
    findedStuff.isRegistrationDone = [NSNumber numberWithBool:NO];
    findedStuff.isRegistrationProcessed = [NSNumber numberWithBool:NO];
    [self safeSave];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.companyAndUsedConfiguration.managedObjectContext persistentStoreCoordinator] withSender:self.companyAndUsedConfiguration withMainMoc:companyAndUsedConfiguration.managedObjectContext];
        
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[findedStuff objectID]] mustBeApproved:NO];
        [clientController release];
    });

//    [self.userController startProcessingtFor:self.stackRecord toStatus:self.userController.controller.objectStatusFailed sender:self]; 
//    //forTableView:self.companyAndUsedConfiguration.tableView 
//    // toStatus:self.userController.controller.objectStatusFinish] ;
//    
//    NSData *stackData = [[userController userDefaultsObjectForKey:stuff.GUID] valueForKey:@"recordsStack"];
//    NSArray *stack = [NSKeyedUnarchiver unarchiveObjectWithData:stackData];
//    
//    NSMutableArray *stackMutable = [NSMutableArray arrayWithArray:stack];
//    [stackMutable removeObject:self.stackRecord];
//    NSData *finalStackData = [NSKeyedArchiver archivedDataWithRootObject:stackMutable];
//    
//    NSDictionary *stuffInfo = [userController userDefaultsObjectForKey:stuff.GUID];
//    NSMutableDictionary *stuffInfoMutable = [NSMutableDictionary dictionaryWithDictionary:stuffInfo];
//    [stuffInfoMutable setValue:finalStackData forKey:@"recordsStack"];
//    [userController setUserDefaultsObject:[NSDictionary dictionaryWithDictionary:stuffInfoMutable] forKey:stuff.GUID];
//    
//    
    //NSLog(@"approve");
    [self.navigationController popToRootViewControllerAnimated:YES];
 
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

@end
