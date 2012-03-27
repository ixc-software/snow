//
//  TestingNumbersInputController.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/26/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "TestingNumbersInputController.h"

#import "DestinationsListWeBuyResults.h"
#import "CodesvsDestinationsList.h"

@interface TestingNumbersInputController ()

@end

@implementation TestingNumbersInputController
@synthesize countrySpecific;
@synthesize codes;
@synthesize addNumber;
@synthesize phoneNumber;

@synthesize tableView;
@synthesize destination;
@synthesize managedObjectContext,allNumbers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMoc:(NSManagedObjectContext *)moc withDestinationMain:(NSManagedObject *)destinationMain;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        managedObjectContext = moc;
        destination = destinationMain;
        allNumbers = [[NSMutableArray alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuyResults" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(destinationsListWeBuyTesting.destinationsListWeBuy.GUID == %@)",[self.destination valueForKey:@"GUID"]];
    [fetchRequest setPredicate:filterPredicate];
    NSArray *allNumbersAll = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSArray *distinct = [allNumbersAll valueForKeyPath:@"@distinctUnionOfObjects.numberB"];
    
    [allNumbers addObjectsFromArray:distinct];
    [fetchRequest release];
    
    NSSet *codesToCheck = [destination valueForKey:@"codesvsDestinationsList"];
    NSSet *distinctCodes = [codesToCheck valueForKeyPath:@"@distinctUnionOfObjects.code"];
    NSArray *distinctCodesArray = [distinctCodes allObjects];
    NSString *allCodesFinal = [distinctCodesArray componentsJoinedByString:@","];
    NSString *country = [destination valueForKey:@"country"];
    NSString *specific = [destination valueForKey:@"specific"];
    self.countrySpecific.text = [NSString stringWithFormat:@"%@/%@",country,specific];
    self.codes.text = allCodesFinal;
    [self.addNumber removeAllSegments];
    [self.addNumber insertSegmentWithTitle:@"Add" atIndex:0 animated:NO];
    [self.addNumber addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setCountrySpecific:nil];
    [self setCodes:nil];
    [self setAddNumber:nil];
    [self setPhoneNumber:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [countrySpecific release];
    [codes release];
    [addNumber release];
    [phoneNumber release];
    [allNumbers release];
    [super dealloc];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSArray *fetchedObjects = [[self fetchedResultsControllerForTableView:tableView] fetchedObjects];
    //NSLog(@"%@",[fetchedObjects lastObject]);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allNumbers.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"TestingResultsTableViewCell";
    
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSDictionary *row = [allNumbers objectAtIndex:indexPath.row];
        cell.textLabel.text = [row valueForKey:@"numberB"];
    }
    
    return cell;
}

#pragma mark - action method
- (IBAction)addNumber:(id)sender {
    
}


@end
