//
//  FinancialViewController.m
//  snow
//
//  Created by Oleksii Vynogradov on 30.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//
#import "desctopAppDelegate.h"

#import "FinancialView.h"
#import "Carrier.h"
#import "Financial.h"
#import "InvoicesAndPayments.h"
#import "CompanyStuff.h"
#import "CurrentCompany.h"
#import "Currency.h"
#import "CompanyAccounts.h"

#import "MySQLIXC.h"
#import "UpdateDataController.h"
#import "ProgressUpdateController.h"


#import "DestinationPerHourStat.h"
#import "DestinationsListForSale.h"
#import "AVGradientBackgroundView.h"
#import "AVTableHeaderView.h"

@implementation FinancialView
@synthesize newReceivedInvoiceCompanyAccountChanged;
@synthesize newReceivedInvoiceDatePickerChanged;
@synthesize isInvoicePreviewDone;
@synthesize moc,delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        [moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
        
    }
    
    return self;
}

#pragma mark - CoreData methods

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
            //success = NO;
        }
    }
    return;
    
}


- (void)importerDidSave:(NSNotification *)saveNotification {
    //NSLog(@"MERGE in financial view controller");
    if ([NSThread isMainThread]) {
//        AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
        NSManagedObjectContext *mainMoc = [delegate managedObjectContext];
        [mainMoc mergeChangesFromContextDidSaveNotification:saveNotification];
        //        [self performSelectorOnMainThread:@selector(finalSave:) withObject:self.moc waitUntilDone:YES];        
    } else {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}

#pragma mark - internal methods


-(NSString *) stringFromNumber:(NSNumber *)number;
{
    NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init];
    [rateFormatter setMaximumFractionDigits:2];
    [rateFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formatted = [rateFormatter stringFromNumber:number];
    [rateFormatter release];
    return formatted;
}



- (void) prepare
{
    if ([[delegate.carriersView.carrier selectedObjects] count] > 1) NSLog(@"FINANCIAL: selected more than 1 carrier"); 
    Carrier *selectedCarrier = [[delegate.carriersView.carrier selectedObjects] lastObject];
    selectedCarrierID = [selectedCarrier objectID];
    
    [financial setFilterPredicate:[NSPredicate predicateWithFormat:@"carrier.GUID == %@",selectedCarrier.GUID]];
    NSArray *selectedFinancials = [financial arrangedObjects];
    [carrierFinancialChoice removeAllItems];

    [carrierFinancialChoice addItemWithTitle:@"NONE"];

    [selectedFinancials enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Financial *financialObject = obj;

        [carrierFinancialChoice addItemWithTitle:financialObject.name];
        [carrierFinancialChoice selectItemAtIndex:1];
    }];
    //dispatch_async(dispatch_get_main_queue(), ^(void) {
    Carrier *selectedCarrierFromLocalMoc = (Carrier *)[moc objectWithID:selectedCarrierID];
    
    NSMutableArray *allInvoicesAndPaymentsForCarrier = [NSMutableArray array];
    
    NSSet *financials = selectedCarrierFromLocalMoc.financial;
    [financials enumerateObjectsUsingBlock:^(Financial *financialForCarrier, BOOL *stop) {
        //NSLog(@"NAME:%@",financialForCarrier.name);
        [allInvoicesAndPaymentsForCarrier addObjectsFromArray:financialForCarrier.invoicesAndPayments.allObjects];
    }];
    
    invoices.content = allInvoicesAndPaymentsForCarrier;
    payments.content = allInvoicesAndPaymentsForCarrier;
    
//    [invoices setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@)",selectedCarrier.GUID]];
//    [payments setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@)",selectedCarrier.GUID]];
    //});    
    //NSLog(@"%@",[invoices arrangedObjects]);

    NSArray *allInvoicesContent = [[invoices arrangedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isInvoice == YES"]];
    NSArray *allPaymentsContent = [[invoices arrangedObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isInvoice == NO"]];
    
    NSArray *allReceivedInvoicesContent = [allInvoicesContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isReceived == YES"]];
    NSArray *allSendedInvoicesContent = [allInvoicesContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isReceived == NO"]];
    
    NSArray *allReceivedPaymentsContent = [allPaymentsContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isReceived == YES"]];
    NSArray *allSendedPaymentsContent = [allPaymentsContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isReceived == NO"]];
    
    NSNumber *totalSumOfReceivedInvoices = [allReceivedInvoicesContent valueForKeyPath:@"@sum.amountConfirmed"];
    NSNumber *totalSumOfSendedInvoices = [allSendedInvoicesContent valueForKeyPath:@"@sum.amountConfirmed"];

    NSNumber *totalSumOfReceivedPayments = [allReceivedPaymentsContent valueForKeyPath:@"@sum.amountConfirmed"];
    NSNumber *totalSumOfSendedPayments = [allSendedPaymentsContent valueForKeyPath:@"@sum.amountConfirmed"];

    NSNumber *carrierBalanceTotal = [NSNumber numberWithDouble:[totalSumOfReceivedInvoices doubleValue] - [totalSumOfSendedInvoices doubleValue] + [totalSumOfReceivedPayments doubleValue] - [totalSumOfSendedPayments doubleValue]];
    [carrierBalance setTitle:[self stringFromNumber:carrierBalanceTotal]];
    
    NSNumber *totalOurSideSumOfInvoices = [allReceivedInvoicesContent valueForKeyPath:@"@sum.amountOurSide"];
    NSNumber *invoiceDifferenceTotal = [NSNumber numberWithDouble:[totalOurSideSumOfInvoices doubleValue] - [totalSumOfReceivedInvoices doubleValue]];
    
    [invoicesDifference setTitle:[self stringFromNumber:invoiceDifferenceTotal]];

    NSArray *disputedInvoices = [allInvoicesContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"amountConfirmed == 0"]];
    NSNumber *disputedInvoicesSum = [disputedInvoices valueForKeyPath:@"@sum.amountOurSide"];
    
    [disputedSum setTitle:[disputedInvoicesSum stringValue]];
    [pathToInvoice setURL:nil];
    
    [invoices setFilterPredicate:[NSPredicate predicateWithFormat:@"(isInvoice == YES) and (isReceived == NO)",selectedCarrier.GUID]];
    [payments setFilterPredicate:[NSPredicate predicateWithFormat:@" (isInvoice == NO) and (isReceived == YES)",selectedCarrier.GUID]];
    
    [pathToInvoice setPathStyle:NSPathStyleNavigationBar];
    [summTotalSelectedInvoices setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfSendedInvoices]]];
    [summTotalSelectedPayments setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfReceivedPayments]]];
}

- (IBAction)searchInvoiceOrPayment:(id)sender {

    NSPredicate *currentPredicate = [invoices filterPredicate];
    
    // Remove extraenous whitespace
    NSMutableString *searchText = [NSMutableString stringWithString:[search stringValue]];
  
    // Remove extraenous whitespace

    while ([searchText rangeOfString:@"Â  "].location != NSNotFound) {
        [searchText replaceOccurrencesOfString:@"Â  " withString:@" " options:0 range:NSMakeRange(0, [searchText length])];
    }
    //Remove leading space

    if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0,1)];
    
    //Remove trailing space
    if ([searchText length] != 0) [searchText replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange([searchText length]-1, 1)];
    if ([searchText length] == 0) {
        Carrier *selectedCarrier = [[delegate.carriersView.carrier selectedObjects] lastObject];

        [invoices setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == YES) and (isReceived == %@)",selectedCarrier.GUID,[NSNumber numberWithInteger:[invoicesReceivedSentChoice selectedSegment]]]];
        NSNumber *totalSumOfFindedInvoices = [[invoices arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedInvoices setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfFindedInvoices]]];

        return;
    }

    NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
    NSMutableArray *subPredicates = [[[NSMutableArray alloc] init] autorelease];

    if ([searchTerms count] == 1) {
        [subPredicates addObject:currentPredicate];
        for (NSString *term in searchTerms) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"(details contains[cd] %@)", searchText,searchText,searchText];
            [subPredicates addObject:p];
        }
        NSPredicate *cp = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        [invoices setFilterPredicate:cp];
        NSNumber *totalSumOfFindedInvoices = [[invoices arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedInvoices setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfFindedInvoices]]];

    }
    
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

-(void)awakeFromNib
{
    [self updateTableView:invoicesTableView];
    [self updateTableView:paymentsTableView];
    [self updateTableView:companyAccountDetailsTableView];
    [self updateTableView:invoiceGenerationFullDataTableView];
    [self updateTableView:invoiceGenerationPerDestinationsDataTableView];
    //isInvoicePreviewDone = NO;
    NSScrollView *sv = [invoiceGenerationPerDestinationsDataTableView enclosingScrollView];
    NSRect svFrame = [sv frame];
    initialInvoiceGenerationPerDestinationsDataTableView = svFrame;
    NSRect viewFrame = [invoiceBox frame];
    initialInvoiceBox = viewFrame;
    NSRect closeFrame = [closeButton frame];
    initialCloseButton = closeFrame;
    NSRect panelFrame = [invoiceFrame frame];
    initialInvoiceFrame = panelFrame;
    NSRect mainInvoiceFrame = [invoiceViewController.view frame];
    initialMainInvoiceFrame = mainInvoiceFrame;

}


#pragma mark - main view methods
- (IBAction)filterByDate:(id)sender {
    NSSegmentedControl *segmented = sender;
    Carrier *selectedCarrier = [[delegate.carriersView.carrier selectedObjects] lastObject];

    if ([segmented selectedSegment] == 0) {
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *month =
        [gregorian components:(NSMonthCalendarUnit |NSDayCalendarUnit|NSYearCalendarUnit) fromDate:today];
        NSInteger monthNumber = [month month];
        [month setMonth:monthNumber -1];
        NSDate *previousMonthBegin = [gregorian dateFromComponents:month];
        [month setMonth:monthNumber];
        NSDate *previousMonthEnd = [gregorian dateFromComponents:month];
        NSNumber *currentStatus = [NSNumber numberWithInteger:[invoicesReceivedSentChoice selectedSegment]];
        [invoices setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == YES) and (isReceived == %@) and (date > %@) and (date < %@)",selectedCarrier.GUID,currentStatus,previousMonthBegin,previousMonthEnd]];
        
        [payments setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == NO) and (isReceived == %@) and (date > %@) and (date < %@)",selectedCarrier.GUID,[NSNumber numberWithInteger:[paymentsReceiveSentChoice selectedSegment]],previousMonthBegin,previousMonthEnd]];
        NSNumber *totalSumOfFindedInvoices = [[invoices arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedInvoices setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfFindedInvoices]]];
        NSNumber *totalSumOfReceivedPayments = [[payments arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedPayments setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfReceivedPayments]]];

        [gregorian release];
    }
    
    if ([segmented selectedSegment] == 1) {
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *month =
        [gregorian components:(NSMonthCalendarUnit |NSDayCalendarUnit|NSYearCalendarUnit) fromDate:today];
        NSInteger monthNumber = [month month];
        [month setMonth:monthNumber -1];
        //NSDate *previousMonthBegin = [gregorian dateFromComponents:month];
        [month setMonth:monthNumber];
        NSDate *previousMonthEnd = [gregorian dateFromComponents:month];
        
        [invoices setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == YES) and (isReceived == %@) and (date > %@)",selectedCarrier.GUID,[NSNumber numberWithInteger:[invoicesReceivedSentChoice selectedSegment]],previousMonthEnd]];
        
        [payments setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == NO) and (isReceived == %@) and (date > %@)",selectedCarrier.GUID,[NSNumber numberWithInteger:[paymentsReceiveSentChoice selectedSegment]],previousMonthEnd]];
        NSNumber *totalSumOfFindedInvoices = [[invoices arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedInvoices setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfFindedInvoices]]];
        NSNumber *totalSumOfReceivedPayments = [[payments arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedPayments setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfReceivedPayments]]];

        [gregorian release];
    }
    if ([segmented selectedSegment] == 2) {
        [invoices setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == YES) and (isReceived == %@)",selectedCarrier.GUID,[NSNumber numberWithInteger:[invoicesReceivedSentChoice selectedSegment]]]];
        
        [payments setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == NO) and (isReceived == %@)",selectedCarrier.GUID,[NSNumber numberWithInteger:[paymentsReceiveSentChoice selectedSegment]]]];
        NSNumber *totalSumOfFindedInvoices = [[invoices arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedInvoices setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfFindedInvoices]]];
        NSNumber *totalSumOfReceivedPayments = [[payments arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedPayments setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfReceivedPayments]]];

    }
}

- (IBAction)changeFinancial:(id)sender {
}
- (IBAction)editFinancial:(id)sender {
}
- (IBAction)openInvoice:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:[[sender URL] path]];
}


- (IBAction)changeReceivedSentFilter:(id)sender {

    Carrier *selectedCarrier = [[delegate.carriersView.carrier selectedObjects] lastObject];
    NSSegmentedControl *segmented = sender;
    if ([sender tag] == 0)
    {
        // change invoice
        if ([segmented selectedSegment] == 0)  { 
            [invoices setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == YES) and (isReceived == NO)",selectedCarrier.GUID]];
            [newInvoice setTitle:@"Send invoice"];
        }
        if ([segmented selectedSegment] == 1) { 
            [invoices setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == YES) and (isReceived == YES)",selectedCarrier.GUID]];
            [newInvoice setTitle:@"Receive invoice"];

        }
        NSNumber *totalSumOfFindedInvoices = [[invoices arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedInvoices setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfFindedInvoices]]];
        NSNumber *totalSumOfReceivedPayments = [[payments arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedPayments setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfReceivedPayments]]];
        

    }
    if ([sender tag] == 1)
    {
        // payments area
        if ([segmented selectedSegment] == 0) {[payments setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == NO) and (isReceived == NO)",selectedCarrier.GUID]];
            [newPayment setTitle:@"Send payment"];
        }

        if ([segmented selectedSegment] == 1) { 
            [payments setFilterPredicate:[NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@) and (isInvoice == NO) and (isReceived == YES)",selectedCarrier.GUID]];
            [newInvoice setTitle:@"Receive payment"];
        }
        NSNumber *totalSumOfFindedInvoices = [[invoices arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedInvoices setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfFindedInvoices]]];
        NSNumber *totalSumOfReceivedPayments = [[payments arrangedObjects] valueForKeyPath:@"@sum.amountConfirmed"];
        [summTotalSelectedPayments setTitle:[NSString stringWithFormat:@"Total:%@",[self stringFromNumber:totalSumOfReceivedPayments]]];
    }
    
}

-(NSString *) pathToInvoiceForCarrier:(NSString *)carrierName forFileName:(NSString *)fileName;
{
//    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    NSString *supportDirectory = [delegate applicationFilesDirectory].path;
    
    NSString *pathToMove = [NSString stringWithFormat:@"%@/Invoices/%@/%@",supportDirectory,carrierName,fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if (![fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/Invoices/%@",supportDirectory,carrierName] isDirectory:NULL]) {
        if (![fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/Invoices/%@",supportDirectory,carrierName] withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", supportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",supportDirectory,error);
        }
    }
    return pathToMove;
}

- (NSString *) pathForPickUpFileAndSaveIntoWorkingDirectoryForCarrierName:(NSString *)carrierName;
{
    NSOpenPanel *savePanel = [NSOpenPanel openPanel]; 
    //[savePanel setFloatingPanel:YES];
    [savePanel setCanCreateDirectories:NO]; 
    [savePanel setCanChooseFiles:YES];
    //[savePanel setAllowedFileTypes:nil];
//    int i = [savePanel runModalForTypes:nil];
//    if (i != NSOKButton) return nil;
    __block BOOL isCompleted = NO;
    __block NSMutableString *pathToCopy = [NSMutableString stringWithCapacity:0];
    
    [financialWindow.contentView setFrame:NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    
    [savePanel beginSheetModalForWindow:financialWindow completionHandler:^(NSInteger result) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
         if (result == NSFileHandlingPanelOKButton) { 
            
            //[savePanel filename];
            //NSURL *url = [NSURL URLWithString:[savePanel filename]];
            NSString *fileNameFullPath = [[savePanel URL] path];
            NSString *fileName = [[fileNameFullPath componentsSeparatedByString:@"/"] lastObject];
             NSError *error = nil;
             NSString *pathToMove = [self pathToInvoiceForCarrier:carrierName forFileName:fileName];
             
             [[NSFileManager defaultManager] copyItemAtPath:fileNameFullPath toPath:pathToMove error:&error];
             if (error) NSLog(@"FINANCIAL: can't copy invoice with error:%@",[error localizedDescription]);
             else [pathToCopy appendString:pathToMove];
        }
        isCompleted = YES;

    }];
    while (!isCompleted) {
        sleep(2);
    }
    return [NSString stringWithString:pathToCopy];

}
- (IBAction)addFileToExsitsingInvoice:(id)sender {
    [progressUpdate startAnimation:self];
    [progressUpdate setHidden:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
        InvoicesAndPayments *selected = [[invoices selectedObjects] lastObject];
        selected.pathToFile = [self pathForPickUpFileAndSaveIntoWorkingDirectoryForCarrierName:selected.financial.carrier.name];
            [pathToInvoice setStringValue:selected.pathToFile];
            [progressUpdate stopAnimation:self];
            [progressUpdate setHidden:YES];
        });
    });
    
}
- (IBAction)closeMainView:(id)sender {
    if (delegate.carriersView.financialViewPopover) [delegate.carriersView.financialViewPopover close];
    
    if (delegate.carriersView.financialViewPanel) { 
        [delegate.carriersView.financialViewPanel orderOut:sender];
        [NSApp endSheet:delegate.carriersView.financialViewPanel];
    }

}
#pragma mark -
#pragma mark New received invoice block

-(void) updateCurrencyListAndCompanyAccounts;
{
    Carrier *selectedCarrier = (Carrier *)[self.moc objectWithID:selectedCarrierID];
    NSSet *currencies = selectedCarrier.companyStuff.currentCompany.currency;
    [newReceivedInvoiceCurrency removeAllItems];
    if ([currencies count] == 0) [newReceivedInvoiceCurrency addItemWithTitle:@"USD"];
    
    [currencies enumerateObjectsUsingBlock:^(Currency *currency, BOOL *stop) {
        [newReceivedInvoiceCurrency addItemWithTitle:currency.name];
    }];
    
    NSSet *accounts = selectedCarrier.companyStuff.currentCompany.companyAccounts;
    [newReceivedInvoiceCompanyAccounts removeAllItems];
    if ([accounts count] == 0) [newReceivedInvoiceCompanyAccounts addItemWithTitle:@"default account"];
    
    [accounts enumerateObjectsUsingBlock:^(CompanyAccounts *account, BOOL *stop) {
        [newReceivedInvoiceCompanyAccounts addItemWithTitle:account.name];
    }];
    
}

- (IBAction)newReceivedInvoice:(id)sender {
    if ([sender tag] == 0) {
        // do all stuff for invoice generation
        [newReceivedInvoice setTitle:@"invoice generation"];
        [addInvoiceFile setHidden:YES];
        [pathToInvoice setHidden:YES];
        [applyAndCreateDispute setAction:@selector(invoiceGeneration:)];
        [applyAndCreateDispute setTag:0];
        [applyAndCreateDispute setTitle:@"invoice preview"];
        [apply setTag:0];  
        [apply setTitle:@"Add invoice"];
        [newReceivedInvoiceFrom setTag:0];
        [newReceivedInvoiceTo setTag:0];
        //isInvoicePreviewDone = NO;

    }     
    if ([sender tag] == 1) {
        // do all stuff for new received invoice
        [newReceivedInvoice setTitle:@"new received invoice"];
        [addInvoiceFile setHidden:NO];
        [applyAndCreateDispute setTag:1];
        [applyAndCreateDispute setTitle:@"apply and create dispute"];
        [applyAndCreateDispute setAction:@selector(newReceivedInvoiceApplyAndCreateDispute:)];
        [apply setTag:1];
        [apply setTitle:@"Add invoice"];
        [newReceivedInvoiceFrom setTag:1];
        [newReceivedInvoiceTo setTag:1];

    }
    
    if ([sender tag] == 2) {
        // do all stuff for new received payment
        [newReceivedInvoice setTitle:@"new received payment"];
        [addInvoiceFile setHidden:YES];
        [pathToInvoice setHidden:YES];
        [newReceivedInvoiceInternalAmount setHidden:YES];
        [applyAndCreateDispute setHidden:YES];
        
        [apply setTag:2];
        [apply setTitle:@"Add payment"];
        [newReceivedInvoiceFrom setTag:1];
        [newReceivedInvoiceTo setTag:1];
        
    }

    if ([sender tag] == 3) {
        // do all stuff for new send payment
        [newReceivedInvoice setTitle:@"new send payment"];
        [addInvoiceFile setHidden:NO];
        [addInvoiceFile setHidden:YES];
        [pathToInvoice setHidden:YES];
        [newReceivedInvoiceInternalAmount setHidden:YES];

        [applyAndCreateDispute setHidden:YES];
        [apply setTag:3];
        [apply setTitle:@"Add payment"];
        [newReceivedInvoiceFrom setTag:1];
        [newReceivedInvoiceTo setTag:1];
        
    }

    
    self.newReceivedInvoiceCompanyAccountChanged = NO;
    self.newReceivedInvoiceDatePickerChanged = NO;

    //[newReceivedInvoice setBackgroundColor:[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1]];
    [newReceivedInvoiceFrom setDateValue:[NSDate date]];
    [newReceivedInvoiceTo setDateValue:[NSDate date]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];

    NSString *newInvoiceNumber = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    [newReceivedInvoiceNumber setTitleWithMnemonic:newInvoiceNumber];
    
    [self updateCurrencyListAndCompanyAccounts];
    
    if (!newReceivedInvoicePopover) newReceivedInvoicePopover = [[NSPopover alloc] init];

    if (newReceivedInvoicePopover) {
        newReceivedInvoicePopover.contentViewController = newReceivedInvoiceViewController;
        newReceivedInvoicePopover.behavior = NSPopoverBehaviorApplicationDefined;
        [newReceivedInvoicePopover showRelativeToRect:[sender frame] ofView:invoicesBox preferredEdge:NSMaxYEdge];
    } else
    {
        newReceivedInvoicePanel = [[[NSPanel alloc] initWithContentRect:newReceivedInvoiceViewController.view.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
        [newReceivedInvoicePanel.contentView addSubview:newReceivedInvoiceViewController.view];
        [NSApp beginSheet:newReceivedInvoicePanel 
           modalForWindow:delegate.window
            modalDelegate:nil 
           didEndSelector:nil
              contextInfo:nil];
    }

}
- (IBAction)addFileToNewReceivedInvoice:(id)sender {

    [progressUpdate startAnimation:self];
    [progressUpdate setHidden:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        Carrier *selectedCarrier = (Carrier *)[self.moc objectWithID:selectedCarrierID];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSString *relativePath = [self pathForPickUpFileAndSaveIntoWorkingDirectoryForCarrierName:selectedCarrier.name];
            [progressUpdate stopAnimation:self];
            [progressUpdate setHidden:YES];

            if ([relativePath length] > 0) { 
                [newReceivedInvoicePath setStringValue:relativePath];
                [newReceivedInvoicePath setHidden:NO];
            } else [newReceivedInvoicePath setHidden:YES];
        });
    });

}
- (IBAction)newReceivedInvoiceOrPaymentCancel:(id)sender {
    if (newReceivedInvoicePopover) [newReceivedInvoicePopover close];
    
    if (newReceivedInvoicePanel) { 
        [newReceivedInvoicePanel orderOut:sender];
        [NSApp endSheet:newReceivedInvoicePanel];
    }

}
- (IBAction)newReceivedInvoiceApplyAndCreateDispute:(id)sender {
    if (newReceivedInvoicePopover) [newReceivedInvoicePopover close];
    
    if (newReceivedInvoicePanel) { 
        [newReceivedInvoicePanel orderOut:sender];
        [NSApp endSheet:newReceivedInvoicePanel];
    }
}

-(BOOL) checkingAllChangedIssuesWasDoneForSender:(id)sender;
{
    if (!newReceivedInvoiceCompanyAccountChanged && [newReceivedInvoiceCompanyAccounts numberOfItems] > 1) {
        [changeAccountAlert setTitle:@"please change account"];
        [changeAccountAlert setHidden:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [changeAccountAlert setHidden:YES];
            });
        });
        return NO;
    }
    
    if ([[newReceivedInvoiceFrom dateValue] isEqualToDate:[newReceivedInvoiceTo dateValue]]) {
        [changeAccountAlert setTitle:@"date must be range"];
        [changeAccountAlert setHidden:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [changeAccountAlert setHidden:YES];
            });
        });
        return NO;
        
    }
    
    if ([[newReceivedInvoiceFrom dateValue] isEqualToDate:[newReceivedInvoiceTo dateValue]]) {
        [changeAccountAlert setTitle:@"date must be range"];
        [changeAccountAlert setHidden:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [changeAccountAlert setHidden:YES];
            });
        });
        return NO;
        
    }
//    NSString *amountCarrierSide = [newReceivedInvoiceInvoiceAmount stringValue];
//    if ([amountCarrierSide isEqualToString:@""]) {
//        [changeAccountAlert setTitle:@"amount must be present"];
//        [changeAccountAlert setHidden:NO];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//            sleep(2);
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                [changeAccountAlert setHidden:YES];
//            });
//        });
//        return NO;
//        
//    }
    
    if (!newReceivedInvoiceDatePickerChanged) {
        [changeAccountAlert setTitle:@"date must be choiced"];
        [changeAccountAlert setHidden:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [changeAccountAlert setHidden:YES];
            });
        });
        return NO;
        
    }
    
    if ([sender tag] == 0 && !isInvoicePreviewDone) 
    {
        [changeAccountAlert setTitle:@"please preview invoice first"];
        [changeAccountAlert setHidden:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(2);
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [changeAccountAlert setHidden:YES];
            });
        });
        return NO;
        
    }
    return YES;
}

-(BOOL) addNewInvoiceOrPaymentWasSuccessWithInvoicePath:(NSString *)path withSender:(id)sender
{
    // check necessary issues 
    // sender   tag = 0 - generated(sended) invoice
    //          tag = 1 received invoice
    //          tag = 2 received payment
    //          tag = 3 sended payment

    if (![self checkingAllChangedIssuesWasDoneForSender:sender]) return NO;
    
    // get financial selected
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];

    NSMenuItem *selected = [carrierFinancialChoice selectedItem];
    NSString *financialName = [selected title];
    Carrier *selectedCarrier = (Carrier *)[self.moc objectWithID:selectedCarrierID];
    NSSet *allFinancials = selectedCarrier.financial;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",financialName];
    NSSet *allFinancialsFiltered = [allFinancials filteredSetUsingPredicate:predicate];
    if ([allFinancialsFiltered count] == 0) {
        NSLog(@"FINANCIAL: warning, financial block not found to add new invoice");
    } else {
        
        NSString *accountSelected = [[newReceivedInvoiceCompanyAccounts selectedItem] title];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",accountSelected];
        NSSet *allAccounts = selectedCarrier.companyStuff.currentCompany.companyAccounts;
        NSSet *allAccountsFiltered = [allAccounts filteredSetUsingPredicate:predicate];
        if ([allAccountsFiltered count] == 0) {
            NSLog(@"FINANCIAL: warning, account not found to add new invoice");
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
//                NSManagedObjectContext *moc = [appDelegate managedObjectContext];
                
                InvoicesAndPayments *newInvoiceObject = (InvoicesAndPayments *)[NSEntityDescription insertNewObjectForEntityForName:@"InvoicesAndPayments" inManagedObjectContext:moc];
                Financial *findedFinancial = [allFinancialsFiltered anyObject];
                newInvoiceObject.financial = findedFinancial;

                if ([sender tag] == 0) {
                    newInvoiceObject.isReceived = [NSNumber numberWithBool:NO];
                    newInvoiceObject.isInvoice = [NSNumber numberWithBool:YES];
                }
                if ([sender tag] == 1) {
                    newInvoiceObject.isReceived = [NSNumber numberWithBool:YES];
                    newInvoiceObject.isInvoice = [NSNumber numberWithBool:YES];
                
                }
                if ([sender tag] == 2) {
                    newInvoiceObject.isReceived = [NSNumber numberWithBool:YES];
                    newInvoiceObject.isInvoice = [NSNumber numberWithBool:NO];
                    newInvoiceObject.paymentDate = [newReceivedInvoiceWhen dateValue];
                }
                if ([sender tag] == 3) {
                    newInvoiceObject.isReceived = [NSNumber numberWithBool:NO];
                    newInvoiceObject.isInvoice = [NSNumber numberWithBool:NO];
                    newInvoiceObject.paymentDate = [newReceivedInvoiceWhen dateValue];
                }

                newInvoiceObject.companyStuff = selectedCarrier.companyStuff;
                newInvoiceObject.date = [NSDate date];
                
                NSDate *from = [newReceivedInvoiceFrom dateValue];
                NSDate *to = [newReceivedInvoiceTo dateValue];
                newInvoiceObject.usagePeriodStart = from;
                newInvoiceObject.usagePeriodFinish = to;
                
                CompanyAccounts *necessaryAccount = [allAccountsFiltered anyObject];
                newInvoiceObject.companyAccounts = necessaryAccount;
                
                NSString *amountCarrierSide = [newReceivedInvoiceInvoiceAmount stringValue];
                NSString *amountOurSide = [newReceivedInvoiceInternalAmount title];
                if ([amountCarrierSide length] == 0) amountCarrierSide = amountOurSide;
               
                newInvoiceObject.amountOurSide = [numberFormatter numberFromString:amountOurSide];
                newInvoiceObject.amountCarrierSide = [numberFormatter numberFromString:amountCarrierSide];
                newInvoiceObject.amountConfirmed = [numberFormatter numberFromString:amountOurSide];
                //            
                newInvoiceObject.details = @"inserted by snow";
                newInvoiceObject.number = [newReceivedInvoiceNumber stringValue];
                
                MySQLIXC *databaseForInsertInvoice = [[MySQLIXC alloc] initWithDelegate:nil withProgress:nil];
                UpdateDataController *update = [[UpdateDataController alloc] initWithDatabase:databaseForInsertInvoice];
                
                
                databaseForInsertInvoice.connections = [update databaseConnections];
                [update release];
                     
                NSNumber *insertedInvoiceID = [databaseForInsertInvoice idForInsertedInvoiceOrPaymentForCarrier:selectedCarrier.name forAccountName:necessaryAccount.name forServiceDate:from forSumm:[numberFormatter numberFromString:amountOurSide] forInvoice:[newInvoiceObject.isInvoice boolValue] forReceived:[newInvoiceObject.isReceived boolValue]];
                [databaseForInsertInvoice release];
                
                newInvoiceObject.externalID = [insertedInvoiceID stringValue];

                if (path) newInvoiceObject.pathToFile =  path;
                
                NSLog(@"FINANCIAL: invoice or payment created:%@",newInvoiceObject);
                [self finalSaveForMoc:moc];
                

                NSManagedObjectContext *mocMain = [delegate managedObjectContext];
                NSManagedObject *createdObject = [mocMain objectWithID:[newInvoiceObject objectID]];
                NSLog(@"FINANCIAL:object from mainMoc:%@",createdObject);
                

            });
        }
        
     }
    [numberFormatter release];
    
//    [appDelegate safeSave];
    
    return YES;
    
}
- (IBAction)newReceivedInvoiceOrPaymentApply:(id)sender {
    // sender   tag = 0 - generated(sended) invoice
    //          tag = 1 received invoice
    //          tag = 2 received payment
    //          tag = 3 sended payment

    NSString *path = nil;
    
    if (![newReceivedInvoicePath isHidden]) path =  [newReceivedInvoicePath stringValue];
    //if ([sender tag] == 0 || [sender tag] == 1 ) 
    if ([self addNewInvoiceOrPaymentWasSuccessWithInvoicePath:path withSender:sender]) {
        
        if (newReceivedInvoicePopover) [newReceivedInvoicePopover close];
        
        if (newReceivedInvoicePanel) { 
            [newReceivedInvoicePanel orderOut:sender];
            [NSApp endSheet:newReceivedInvoicePanel];
        }
    } else isInvoicePreviewDone = NO;

}
-(NSNumber *) totalAmountFrom:(NSDate *)from to:(NSDate *)to isDestinationsListBuy:(BOOL)isDestinationsListBuy;
{
    NSString *destinationRelationship = nil;
    
    if (isDestinationsListBuy) destinationRelationship = @"destinationsListWeBuy";
    else destinationRelationship = @"destinationsListForSale";
    
    Carrier *selectedCarrier = (Carrier *)[self.moc objectWithID:selectedCarrierID];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationPerHourStat" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date > %@) AND (date < %@) AND (%K.carrier.GUID == %@)",from,to,destinationRelationship,selectedCarrier.GUID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(destinationPerHourStat.date > %@) AND (destinationPerHourStat.date < %@)",from,to];
    //    NSSet *filteredDestinationsWeBuy = [destinationsWeBuy filteredSetUsingPredicate:predicate];
    NSNumber *totalProfitNumber = [fetchedObjects valueForKeyPath:@"@sum.cashflow"];
    return totalProfitNumber;
}

-(void)updateinternalInvoiceAmountForBuy:(BOOL)isDestinationsListBuy
{
    NSDate *from = [newReceivedInvoiceFrom dateValue];
    NSDate *to = [newReceivedInvoiceTo dateValue];
//    NSManagedObjectContext *moc = [carriers managedObjectContext];
//    
//    Carrier *selectedCarrier = (Carrier *)[[carriers managedObjectContext] objectWithID:selectedCarrierID];
//    //NSSet *destinationsWeBuy = selectedCarrier.destinationsListWeBuy;
//    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationPerHourStat" inManagedObjectContext:moc];
//    [fetchRequest setEntity:entity];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date > %@) AND (date < %@) AND (destinationsListWeBuy.carrier.GUID == %@)",from,to,selectedCarrier.GUID];
//    [fetchRequest setPredicate:predicate];
//    NSError *error = nil;
//    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
//    [fetchRequest release];
//
//    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(destinationPerHourStat.date > %@) AND (destinationPerHourStat.date < %@)",from,to];
////    NSSet *filteredDestinationsWeBuy = [destinationsWeBuy filteredSetUsingPredicate:predicate];
//    NSNumber *totalProfitNumber = [fetchedObjects valueForKeyPath:@"@sum.cashflow"];
    [newReceivedInvoiceInternalAmount setTitle:[self stringFromNumber:[self totalAmountFrom:from to:to isDestinationsListBuy:isDestinationsListBuy]]];
    
    
}
- (IBAction)newReceivedInvoiceFromDatePickerSelected:(id)sender {
    BOOL isDestinationsListBuy = NO;
    if ([sender tag] == 1) isDestinationsListBuy = YES;

    [self updateinternalInvoiceAmountForBuy:isDestinationsListBuy];
    self.newReceivedInvoiceDatePickerChanged = YES;

}
- (IBAction)newReceivedInvoiceToDatePickerSelected:(id)sender {
    BOOL isDestinationsListBuy = NO;
    if ([sender tag] == 1) isDestinationsListBuy = YES;
    [self updateinternalInvoiceAmountForBuy:isDestinationsListBuy];
    self.newReceivedInvoiceDatePickerChanged = YES;
}
- (IBAction)newReceivedInvoiceCurrencyChanged:(id)sender {
}
- (IBAction)companyAccountChanged:(id)sender {
    self.newReceivedInvoiceCompanyAccountChanged = YES;

}


- (IBAction)exportSelectedInvoicesToExcel:(id)sender {
}

- (IBAction)exportSelectedPaymentsToExcel:(id)sender {
}

#pragma mark -
#pragma mark invoice generation block

-(void) updateDatesInDictionary:(NSMutableDictionary *)rowForDestinationMutable withDate:(NSDate *)dateOfHourBlock;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MMM"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    [usLocale release];
    NSDate *from = [rowForDestinationMutable objectForKey:@"dateFrom"];
    NSDate *to = [rowForDestinationMutable objectForKey:@"dateTo"];
    //NSTimeInterval timeInterval = [dateOfHourBlock timeIntervalSinceDate:from];
    
    if ([dateOfHourBlock timeIntervalSinceDate:from] < 0) {
        //NSLog(@"date of hour block:%@ is early than date from:%@, date from will changed",dateOfHourBlock,from);
        [rowForDestinationMutable setValue:dateOfHourBlock forKey:@"dateFrom"];
        NSString *dateFromTo = [NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:[rowForDestinationMutable valueForKey:@"dateFrom"]],[formatter stringFromDate:[rowForDestinationMutable valueForKey:@"dateTo"]]];
        [rowForDestinationMutable setValue:dateFromTo forKey:@"dateFromTo"];
  
    } //else NSLog(@"date of hour block:%@ is later than date from:%@, do nothing",dateOfHourBlock,from);
    
    if ([dateOfHourBlock timeIntervalSinceDate:to] > 0) {
        //NSLog(@"date of hour block:%@ is early than date to:%@, date from will changed",[dateOfHourBlock description],[to description]);
        [rowForDestinationMutable setValue:dateOfHourBlock forKey:@"dateTo"];
        NSString *dateFromTo = [NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:[rowForDestinationMutable valueForKey:@"dateFrom"]],[formatter stringFromDate:[rowForDestinationMutable valueForKey:@"dateTo"]]];
        [rowForDestinationMutable setValue:dateFromTo forKey:@"dateFromTo"];

    } //else NSLog(@"date of hour block:%@ is later than date to:%@, do nothing",dateOfHourBlock,from);
    
    [formatter release];

}

-(void) updateDestinationWithDictionary:(NSMutableDictionary *)rowForDestinationMutable withCalls:(NSNumber *)calls withMinutes:(NSNumber *)minutes withAmount:(NSNumber *)amount;
{
    NSNumber *previousCalls = [rowForDestinationMutable valueForKey:@"calls"];
    NSNumber *newCalls = [NSNumber numberWithDouble:[calls doubleValue] + [previousCalls doubleValue]];
    [rowForDestinationMutable setValue:newCalls forKey:@"calls"];
    
    NSNumber *previousMinutes = [rowForDestinationMutable valueForKey:@"minutes"];
    NSNumber *newMinutes = [NSNumber numberWithDouble:[minutes doubleValue] + [previousMinutes doubleValue]];
    [rowForDestinationMutable setValue:newMinutes forKey:@"minutes"];
    
    NSNumber *previousAmount = [rowForDestinationMutable valueForKey:@"amount"];
    NSNumber *newAmount = [NSNumber numberWithDouble:[amount doubleValue] + [previousAmount doubleValue]];
    [rowForDestinationMutable setValue:newAmount forKey:@"amount"];

}

- (IBAction)invoiceGeneration:(id)sender {
    
    
    Carrier *selectedCarrier = (Carrier *)[self.moc objectWithID:selectedCarrierID];
//    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    NSString *logosDirectory = [NSString stringWithFormat:@"%@/CompaniesLogos/",[delegate applicationFilesDirectory]];
    NSString *companyName = selectedCarrier.companyStuff.currentCompany.name;
    NSString *finalURL = [logosDirectory stringByAppendingFormat:@"%@.png",companyName];
    NSImage *logoImage = [[NSImage alloc] initByReferencingFile:finalURL];
    [logo setImage:logoImage];
    [logoImage release];
    
    NSString *companyAddress = selectedCarrier.companyStuff.currentCompany.address;
    NSString *companyPhone = selectedCarrier.companyStuff.currentCompany.localPhoneList;
    if (!companyAddress) companyAddress = @"";
    if (!companyPhone) companyPhone = @"";
        
    NSString *finalCompanyInfo = [NSString stringWithFormat:@"%@\n%@\n%@\n",companyName,companyAddress,companyPhone];
    [companyNameAddressPhone setTitleWithMnemonic:finalCompanyInfo];
    
    NSString *accountSelected = [[newReceivedInvoiceCompanyAccounts selectedItem] title];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",accountSelected];
    NSSet *allAccounts = selectedCarrier.companyStuff.currentCompany.companyAccounts;
    NSSet *allAccountsFiltered = [allAccounts filteredSetUsingPredicate:predicate];
    if ([allAccountsFiltered count] == 0) {
        NSLog(@"FINANCIAL: warning, account not found to preview new invoice");
    } else {
        CompanyAccounts *necessaryAccount = [allAccountsFiltered anyObject];
        NSString *bankName = necessaryAccount.bankName;
        NSString *bankSwift = necessaryAccount.bankSwift;
        NSString *bankABA = necessaryAccount.bankABA;
        NSString *bankIBAN = necessaryAccount.bankIBAN;
        NSString *bankAccountNumber = necessaryAccount.bankAccountNumber;
        NSString *bankAddress = necessaryAccount.bankAddress;
        if (!bankName) bankName = @"";
        if (!bankSwift) bankSwift = @"";
        if (!bankABA) bankABA = @"";
        if (!bankIBAN) bankIBAN = @"";
        if (!bankAccountNumber) bankAccountNumber = @"";
        if (!bankAddress) bankAddress = @"";
        
        NSString *finalCompanyBankingInfo = [NSString stringWithFormat:@"Bank name:%@\nBank SWIFT:%@\nBank ABA:%@\nIBAN:%@\nAccount number:%@\n Bank address:%@",bankName,bankSwift,bankABA,bankIBAN,bankAccountNumber,bankAddress];
        [companyBankingDetails setTitleWithMnemonic:finalCompanyBankingInfo];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    
    NSString *newInvoiceNumber = [formatter stringFromDate:[NSDate date]];
    
    [invoiceNumber setTitleWithMnemonic:[NSString stringWithFormat:@"INVOICE N%@",newInvoiceNumber]];
    
    NSString *finalCompanyBankingInfo = [NSString stringWithFormat:@"to Carrier::%@\nATTN:%@",selectedCarrier.name,selectedCarrier.address];
    
    [carrierNameAndAddress setTitleWithMnemonic:finalCompanyBankingInfo];

    NSDate *from = [newReceivedInvoiceFrom dateValue];
    NSDate *to = [newReceivedInvoiceTo dateValue];

    [formatter setDateFormat:@"yyyy/MM/dd"];

    NSString *fromString = [formatter stringFromDate:from];
    NSString *toString = [formatter stringFromDate:to];
    

    NSMutableDictionary *fullData = [NSMutableDictionary dictionaryWithCapacity:0];
    [fullData setValue:[NSString stringWithFormat:@"%@ - %@",fromString,toString] forKey:@"accountPeriod"];
    [fullData setValue:[NSString stringWithFormat:@"%@",[formatter stringFromDate:[NSDate date]]] forKey:@"billingDate"];

    NSMenuItem *selected = [carrierFinancialChoice selectedItem];
    NSString *financialName = [selected title];

    NSSet *allFinancials = selectedCarrier.financial;
    predicate = [NSPredicate predicateWithFormat:@"name == %@",financialName];
    NSSet *allFinancialsFiltered = [allFinancials filteredSetUsingPredicate:predicate];
    if ([allFinancialsFiltered count] == 0) {
        NSLog(@"FINANCIAL: warning, financial block not found to preview  invoice");
    } else {
        Financial *findedFinancial = [allFinancialsFiltered anyObject];
        int timeIntervalForPayment = [findedFinancial.paymentTermsPaidPeriod intValue] * 24 * 60 * 60;
        NSDate *datePayment = [NSDate dateWithTimeInterval:timeIntervalForPayment sinceDate:[NSDate date]];
        [fullData setValue:[NSString stringWithFormat:@"%@",[formatter stringFromDate:datePayment]] forKey:@"dueDate"];

        // little fix, i need connect currency entity under company account first (one way relationships)
        [fullData setValue:@"USD" forKey:@"currency"];

    }    
    BOOL isDestinationsListBuy = NO;
    if ([sender tag] == 1) isDestinationsListBuy = YES;

    NSNumber *totalAmount = [self totalAmountFrom:from to:to isDestinationsListBuy:isDestinationsListBuy];
    [fullData setValue:totalAmount forKey:@"amountDue"];
    
    [invoiceGenerationFullData setContent:[NSArray arrayWithObject:[NSDictionary dictionaryWithDictionary:fullData]]];
    
    
    NSString *destinationRelationship = nil;
    if (isDestinationsListBuy) destinationRelationship = @"destinationsListWeBuy";
    else destinationRelationship = @"destinationsListForSale";
    
//    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationPerHourStat" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    predicate = [NSPredicate predicateWithFormat:@"(date > %@) AND (date < %@) AND (%K.carrier.GUID == %@)",from,to,destinationRelationship,selectedCarrier.GUID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    __block NSMutableArray *perDestinationsData = [NSMutableArray arrayWithCapacity:0];
    [fetchedObjects enumerateObjectsUsingBlock:^(DestinationPerHourStat *statPerHour, NSUInteger idx, BOOL *stop) {
        if ([statPerHour.minutesLenght doubleValue] > 0 || [statPerHour.cashflow doubleValue] > 0 ) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectID = %@",[statPerHour.destinationsListForSale objectID]];
            NSArray *filteredPerDestinationData = [perDestinationsData filteredArrayUsingPredicate:predicate];
            NSNumber *rate = [NSNumber numberWithDouble:[statPerHour.cashflow doubleValue] / [statPerHour.minutesLenght doubleValue]];
            
            if ([filteredPerDestinationData count] == 0) {
                // this is new destination, just add stat
                // bcs rate can be changed, we must using a current rate for that hour
                [formatter setDateFormat:@"dd/MMM"];
                NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [formatter setLocale:usLocale];
                [usLocale release];
                
                NSString *dateFromTo = [NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:statPerHour.date],[formatter stringFromDate:statPerHour.date]];
                
                
                NSDictionary *rowForDestination = [NSDictionary dictionaryWithObjectsAndKeys:[statPerHour.destinationsListForSale objectID],@"objectID", statPerHour.date, @"dateFrom", statPerHour.date, @"dateTo", dateFromTo, @"dateFromTo",[NSString stringWithFormat:@"%@/%@",statPerHour.destinationsListForSale.country,statPerHour.destinationsListForSale.specific], @"destination", statPerHour.callAttempts, @"calls", statPerHour.minutesLenght, @"minutes", rate, @"rate",@"USD", @"currency",statPerHour.cashflow, @"amount",nil];
                [perDestinationsData addObject:rowForDestination];
            } else {
                // ok we already add destination, and we must fix first, if we have more than 1 destination in list with same id (it happened, when rates changed in continue working)
                if ([filteredPerDestinationData count] == 1) {
                    // here is just one destination
                    NSDictionary *rowForDestination = [filteredPerDestinationData lastObject];
                    NSMutableDictionary *rowForDestinationMutable = [NSMutableDictionary dictionaryWithDictionary:rowForDestination];
                    [perDestinationsData removeObject:rowForDestination];
                    //NSDate *dateOfHourBlock = statPerHour.date;
                    [self updateDatesInDictionary:rowForDestinationMutable withDate:statPerHour.date];
                    
                    [self updateDestinationWithDictionary:rowForDestinationMutable 
                                                withCalls:statPerHour.callAttempts 
                                              withMinutes:statPerHour.minutesLenght 
                                               withAmount:statPerHour.cashflow];
                    [perDestinationsData addObject:rowForDestinationMutable];

                } else {
                    // here is couple destinations
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rate == %@",rate];
                    NSArray *filteredNextStage = [filteredPerDestinationData filteredArrayUsingPredicate:predicate];
                    if ([filteredNextStage count] == 0) {
                        // looks like we have new rate?
                        [formatter setDateFormat:@"dd/MMM"];
                        NSString *dateFromTo = [NSString stringWithFormat:@"%@ - %@",[formatter stringFromDate:statPerHour.date],[formatter stringFromDate:statPerHour.date]];
                        
                        NSDictionary *rowForDestination = [NSDictionary dictionaryWithObjectsAndKeys:[statPerHour.destinationsListForSale objectID],@"objectID", statPerHour.date, @"dateFrom", statPerHour.date, @"dateTo", dateFromTo, @"dateFromTo",[NSString stringWithFormat:@"%@/%@",statPerHour.destinationsListForSale.country,statPerHour.destinationsListForSale.specific], @"destination", statPerHour.callAttempts, @"calls", statPerHour.minutesLenght, @"minutes", rate, @"rate",@"USD", @"currency",statPerHour.cashflow, @"amount",nil];
                        [perDestinationsData addObject:rowForDestination];
                        
                    } 
                    
                    if ([filteredNextStage count] == 1) {
                        // perfect, this is what we want and row must be updated
                        NSDictionary *rowForDestination = [filteredNextStage lastObject];
                        NSMutableDictionary *rowForDestinationMutable = [NSMutableDictionary dictionaryWithDictionary:rowForDestination];
                        [perDestinationsData removeObject:rowForDestination];
                        NSDate *dateOfHourBlock = statPerHour.date;
                        [self updateDatesInDictionary:rowForDestinationMutable withDate:dateOfHourBlock];
                        
                        [self updateDestinationWithDictionary:rowForDestinationMutable 
                                                    withCalls:statPerHour.callAttempts 
                                                  withMinutes:statPerHour.minutesLenght 
                                                   withAmount:statPerHour.cashflow];
                        [perDestinationsData addObject:rowForDestinationMutable];


                    } 
                    
                    if ([filteredNextStage count] > 1) {
                        NSLog(@"FINANCIAL: warning,%@ has more than 2 finded rates with same rate:%@",filteredPerDestinationData,rate);
                    } 
                    
                    
                }
                
            }
        }
        
        
    }];

    
    NSNumber *totalCalls = [perDestinationsData valueForKeyPath:@"@sum.calls"];
    NSNumber *totalMinutes = [perDestinationsData valueForKeyPath:@"@sum.minutes"];
    NSDictionary *rowForDestination = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"objectID",@"",@"dateFrom",@"",@"dateTo",@"", @"dateFromTo",[NSString stringWithFormat:@"Grand total:"], @"destination", totalCalls, @"calls", totalMinutes, @"minutes", @"USD", @"currency",totalAmount, @"amount",nil];
    [perDestinationsData addObject:rowForDestination];
    
    NSUInteger previousCount = [invoiceGenerationPerDestinationsData.arrangedObjects count];
    
    [invoiceGenerationPerDestinationsData setContent:[NSArray arrayWithArray:perDestinationsData]];
    NSUInteger newCount = [invoiceGenerationPerDestinationsData.arrangedObjects count];
    
    //NSLog(@"%@",perDestinationsData);
//    if (!isInvoicePreviewDone) {
    
    
    
        
    NSScrollView *sv = [invoiceGenerationPerDestinationsDataTableView enclosingScrollView];
    NSTableHeaderView *aHeaderView = [invoiceGenerationPerDestinationsDataTableView headerView];
    // return to start position all views:
//    sv.frame = initialInvoiceGenerationPerDestinationsDataTableView;
//    invoiceBox.frame = initialInvoiceBox;
//    closeButton.frame = initialCloseButton;
//    invoiceFrame.frame = initialInvoiceFrame;
    //    invoiceViewController.view.frame = initialMainInvoiceFrame;
    int height = ([invoiceGenerationPerDestinationsDataTableView rowHeight] + [invoiceGenerationPerDestinationsDataTableView intercellSpacing].height) * (newCount - previousCount);
    
    NSRect svFrame = [sv frame];
    if (height > 0) {
        svFrame.size.height = height + aHeaderView.frame.size.height;
        svFrame.origin.y = svFrame.origin.y - height - aHeaderView.frame.size.height;
        [sv setFrame:svFrame];
    }
    
    NSRect viewFrame = [invoiceBox frame];
    if (height > 0) {
        viewFrame.size.height = viewFrame.size.height + height + aHeaderView.frame.size.height;
        viewFrame.origin.y = viewFrame.origin.y - height - aHeaderView.frame.size.height;
        [invoiceBox setFrame:viewFrame];
    }
    
    NSRect closeFrame = [closeButton frame];
    if (height > 0) {
        closeFrame.origin.y = closeFrame.origin.y - height  - aHeaderView.frame.size.height;
        [closeButton setFrame:closeFrame];
    }    

    NSRect panelFrame = [invoiceFrame frame];
    if (height > 0) {
        panelFrame.size.height = panelFrame.size.height + height  + aHeaderView.frame.size.height;
        panelFrame.origin.y = panelFrame.origin.y - height - aHeaderView.frame.size.height;
        [invoiceFrame setFrame:panelFrame];
    }

    NSRect mainInvoiceFrame = [invoiceViewController.view frame];
    if (height > 0) {
        mainInvoiceFrame.size.height = mainInvoiceFrame.size.height + height  + aHeaderView.frame.size.height;
        mainInvoiceFrame.origin.y = mainInvoiceFrame.origin.y - height - aHeaderView.frame.size.height;
        [invoiceViewController.view setFrame:panelFrame];
    }
        
//    }
    
    [formatter release];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        sleep (1);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
                [invoiceGenerationPerDestinationsDataTableView deselectAll:self];
                [invoiceGenerationFullDataTableView deselectAll:self];

//            [invoiceGenerationPerDestinationsData setSelectionIndex:-1];
//            [invoiceGenerationFullData setSelectionIndex:-1];
        });
    });
//    [invoiceGenerationPerDestinationsDataTableView setRefusesFirstResponder:YES];
//    [invoiceGenerationPerDestinationsDataTableView deselectAll:self];
//    [invoiceGenerationFullDataTableView setRefusesFirstResponder:YES];
//    [invoiceGenerationFullDataTableView deselectAll:self];
    
    if (!invoicePopover) invoicePopover = [[NSPopover alloc] init];
    
    if (invoicePopover) {
        invoicePopover.contentViewController = invoiceViewController;
        invoicePopover.behavior = NSPopoverBehaviorApplicationDefined;
        [invoicePopover showRelativeToRect:[sender frame] ofView:newReceivedInvoice preferredEdge:NSMaxYEdge];
    } else
    {
        invoicePanel = [[[NSPanel alloc] initWithContentRect:invoiceViewController.view.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES] autorelease];
        [invoicePanel.contentView addSubview:invoiceViewController.view];
        [NSApp beginSheet:invoicePanel 
           modalForWindow:delegate.window
            modalDelegate:nil 
           didEndSelector:nil
              contextInfo:nil];
    }
 
    
}
- (IBAction)invoiceGeterationEnd:(id)sender {
    Carrier *selectedCarrier = (Carrier *)[self.moc objectWithID:selectedCarrierID];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    NSString *newInvoiceNumber = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    NSString *pathToInvoiceFile = [self pathToInvoiceForCarrier:selectedCarrier.name forFileName:[newInvoiceNumber stringByAppendingString:@".pdf"]];
    
    NSPrintInfo *printInfo;
    NSPrintInfo *sharedInfo;
    NSPrintOperation *printOp;
    NSMutableDictionary *printInfoDict;
    NSMutableDictionary *sharedDict;
    
    sharedInfo = [NSPrintInfo sharedPrintInfo];
    sharedDict = [sharedInfo dictionary];
    printInfoDict = [NSMutableDictionary dictionaryWithDictionary:
                     sharedDict];
    [printInfoDict setObject:NSPrintSaveJob 
                      forKey:NSPrintJobDisposition];
    [printInfoDict setObject:pathToInvoiceFile forKey:NSPrintSavePath];
    printInfo = [[NSPrintInfo alloc] initWithDictionary: printInfoDict];
    [printInfo setHorizontalPagination: NSFitPagination];
    [printInfo setVerticalPagination: NSAutoPagination];
    [printInfo setVerticallyCentered:NO];
    printOp = [NSPrintOperation printOperationWithView:invoiceBox 
                                             printInfo:printInfo];
    [printInfo release];
    [printOp setShowsPrintPanel:NO];
    [printOp setShowsProgressPanel:NO];
    
    [printOp runOperation];
    isInvoicePreviewDone = YES;
    if (invoicePopover) [invoicePopover close];
    
    if (invoicePanel) { 
        [invoicePanel orderOut:sender];
        [NSApp endSheet:invoicePanel];
    }

}

#pragma mark -
#pragma mark UI entrance block for invoice and payments
// sender   tag = 0 - generated(sended) invoice
//          tag = 1 received invoice
//          tag = 2 received payment
//          tag = 3 sended payment
- (IBAction)newInvoice:(id)sender {
    if ([invoicesReceivedSentChoice selectedSegment] == 0) {
        // send invoice
        [sender setTag:0];
        [self newReceivedInvoice:sender];
    } else {
        // receive invoice
        [sender setTag:1];
        [self newReceivedInvoice:sender];
    }
    
        
}
- (IBAction)newPayment:(id)sender {
    if ([invoicesReceivedSentChoice selectedSegment] == 0) {
        // sent payment
        [sender setTag:3];
        [self newReceivedInvoice:sender];

    } else {
        // received payment
        [sender setTag:2];
        [self newReceivedInvoice:sender];

    }
    

}

#pragma mark -
#pragma mark tableViewDelegates
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    // this is delegate for main financial sheet only
    if ([aTableView tag] == 0 ) {
        
        InvoicesAndPayments *selected = [[invoices arrangedObjects] objectAtIndex:rowIndex];
        if (selected.pathToFile) {
            if (![selected.pathToFile isEqualToString:@"file://localhost/Applications/"]) [pathToInvoice setStringValue:selected.pathToFile];
        } else [pathToInvoice setURL:nil];
    }
    return YES;
}

-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    // this is delegate for invoice generation only
    if ([tableView tag] == 0 ) {
        //     if ([[invoiceGenerationPerDestinationsData arrangedObjects] count] != 0)  NSLog(@"displayed row:%@ array count:%@",[NSNumber numberWithInteger:row],[NSNumber numberWithInteger:[[invoiceGenerationPerDestinationsData arrangedObjects] count]]);
        NSString *finalValue = nil;
        NSString *cellValue = [cell stringValue];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *numberFromCell = [formatter numberFromString:cellValue];
        if (numberFromCell) finalValue = [self stringFromNumber:numberFromCell];
        else {
            [formatter setDecimalSeparator:@"."];
            numberFromCell = [formatter numberFromString:cellValue];
            if (numberFromCell) finalValue = [self stringFromNumber:numberFromCell];
            else finalValue = cellValue;
        }
        [formatter release];
        [cell setFormatter:nil];
        
        if (([[invoiceGenerationPerDestinationsData arrangedObjects] count] != 0) && (row == ([[invoiceGenerationPerDestinationsData arrangedObjects] count] - 1))) {
            
            NSFont *txtFont = [NSFont boldSystemFontOfSize:13];
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            [paragraph setAlignment:NSRightTextAlignment];
            
            NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     txtFont, NSFontAttributeName,paragraph,NSParagraphStyleAttributeName, nil];
            NSAttributedString *attrStr = [[[NSAttributedString alloc]
                                            initWithString:finalValue attributes:txtDict] autorelease];
            [cell setAttributedStringValue:attrStr];
            [paragraph release];
            
        } else [cell setStringValue:finalValue];
        
        //if ([[invoiceGenerationPerDestinationsData arrangedObjects] count] != 0)  NSLog(@"finally displayed row:%@ array count:%@ tableColumn:%@ %lu",[NSNumber numberWithInteger:row],[NSNumber numberWithInteger:[[invoiceGenerationPerDestinationsData arrangedObjects] count]],tableColumnTitle,[cell alignment]);
    }

}

#pragma mark -
#pragma mark edit company account details 
- (NSArray *) transformContentFromHorizontalToVerticalDataForBinding:(NSManagedObject *)content;
{
    
    NSMutableArray *columns = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMM"];
    
    for (NSString *attribute in [[content entity] attributeKeys])
    {
        //if (![attribute isEqualToString:@"GUID"]) {
        NSMutableDictionary *row = [NSMutableDictionary dictionary];
        [row setValue:attribute forKey:@"attribute"];
        
        if ([content valueForKey:attribute]){ 
            id object = [content valueForKey:attribute];
            if ([[object class] isSubclassOfClass:[NSDate class]]) {
                [row setValue:[formatter stringFromDate:object] forKey:@"data"]; 
            } else [row setValue:[content valueForKey:attribute] forKey:@"data"]; 
            
        }
        else [row setValue:@"" forKey:@"data"];
        [columns addObject:row];
        //}
    }
    [formatter release];
    return [NSArray arrayWithArray:columns];
}



- (IBAction)didFinishEditing:(id)sender {
//    [companyAccountDetails orderOut:sender];
//    [NSApp endSheet:companyAccountDetails];
    [self finalSaveForMoc:moc];

}
- (IBAction)shouldStartEditing:(id)sender {
    [self updateTableView:companyAccountDetailsTableView];
    
    Carrier *selectedCarrier = (Carrier *)[self.moc objectWithID:selectedCarrierID];

    NSString *accountSelected = [[newReceivedInvoiceCompanyAccounts selectedItem] title];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",accountSelected];
    NSSet *allAccounts = selectedCarrier.companyStuff.currentCompany.companyAccounts;
    NSSet *allAccountsFiltered = [allAccounts filteredSetUsingPredicate:predicate];
    if ([allAccountsFiltered count] == 0) {
        NSLog(@"FINANCIAL: warning, account not found to preview new invoice");
    } else {
        NSManagedObject *necessaryAccount = [allAccountsFiltered anyObject];
        [companyAccountsVerticalView setContent:[self transformContentFromHorizontalToVerticalDataForBinding:necessaryAccount]];
        for (id verticalViewObject in [companyAccountsVerticalView arrangedObjects]) [verticalViewObject addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:[necessaryAccount objectID]]; 

    }
//    [companyAccountDetails setBackgroundColor:[NSColor colorWithDeviceRed:0.52 green:0.54 blue:0.70 alpha:1]];
//
//    [NSApp beginSheet:companyAccountDetails 
//       modalForWindow:newReceivedInvoice
//        modalDelegate:nil 
//       didEndSelector:nil
//          contextInfo:nil];

    
}


- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    if ([delegate.loggingLevel intValue] == 1) NSLog( @">>>>  FINANCIAL:Detected Change in keyPath: %@, change:%@", keyPath,change );
    id new = [change valueForKey:@"new"];
    id old = [change valueForKey:@"old"];
    if ([new isEqualTo:old]) { 
        NSLog(@"nothing to change, return");
        return;
    }
    
    NSManagedObject *changedObject = [[delegate managedObjectContext] objectWithID:context];
    if (!changedObject) NSLog(@"FINANCIAL:warning, object not found");
    else {
        [changedObject setValue:[object valueForKey:@"data"] forKeyPath:[object valueForKey:@"attribute"]];
    }
}
@end
