//
//  TestsResultsController.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "TestsResultsController.h"
#import "mobileAppDelegate.h"

@interface TestsResultsController ()

@end

@implementation TestsResultsController
@synthesize tableView;
@synthesize destination,resultCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
//    NSInteger count = [[[self fetchedResultsController] fetchedObjects] count];
//    NSLog(@"Number of sections:%@",[NSNumber numberWithUnsignedInteger:count]);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSInteger finalResult = 0;
//    if ([sections lastIndex] == section) finalResult = 1;
//    return finalResult;
    return 10;
    
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
        self.resultCell = nil;
        
        //[self configureCell:cell atIndexPath:indexPath forTableView:self.tableView];
        
//        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//        [cell addGestureRecognizer:longPressRecognizer];      
//        [longPressRecognizer release];
        
    }
    
    return cell;
}



- (void)dealloc {
    [tableView release];
    [super dealloc];
}
@end
