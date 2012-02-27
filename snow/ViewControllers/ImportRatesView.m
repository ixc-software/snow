//
//  ImportRatesViewClass.m
//  snow
//
//  Created by Oleksii Vynogradov on 1/21/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "ImportRatesView.h"

#import "desctopAppDelegate.h"
#import "AVResizedTableHeaderView.h"
#import "AVTableHeaderView.h"
#import "AVGradientBackgroundView.h"
#import "ParseCSV.h"
#import "ProjectArrays.h"
//#import "CarrierTableViewDelegate.h"

#import "Carrier.h"
#import "DestinationsListTargets.h"
#import "DestinationsListWeBuy.h"
#import "DestinationsListPushList.h"
#import "CountrySpecificCodeList.h"
#import "CodesList.h"

#import "MySQLIXC.h"
#import "UpdateDataController.h"

@implementation ImportRatesView

@synthesize delegate;
@synthesize moc;
@synthesize dragToCarrier;

// import rates or destinations view
@synthesize importRatesPanel;
@synthesize importRatesColumnSelectPanel;

//@synthesize importRatesView;
@synthesize importRatesViewController;
@synthesize importRatesColumnSelectViewController;
@synthesize importRatesImportedRoutes;
@synthesize importRatesParsedRows;

//@synthesize importRatesParsedCodes;
@synthesize importRatesCarrierList;
@synthesize importRatesCarriersRateSheet;
@synthesize importRatesEffectiveDate;
@synthesize importRatesSelectionList;
@synthesize importRatesRelationshipName;
@synthesize importRatesCarrierName;
@synthesize importRatesSelectedCountryForParsing;
@synthesize importRatesStartParsing;
@synthesize importRatesRatesheetList;
@synthesize importRatesProgress;
@synthesize importRatesPrefix;
@synthesize importRatesFirsParserResult;
@synthesize importRatesCodesTableView;
@synthesize importRatesSecondParserResult;
@synthesize importDestinationsLabel;
@synthesize chooseDestinationsType;
@synthesize removePreviousButton;
@synthesize importRatesDestinationChoice;
@synthesize importRatesApply;
@synthesize addDestinationCarriersList;
@synthesize chooseExcelSheetLabel;
@synthesize uncheckedLines;
@synthesize parsedFileURL;

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

#pragma mark -
#pragma mark CORE DATA methods


- (void)importerDidSave:(NSNotification *)saveNotification {
    //NSLog(@"MERGE in import rates/destinations view controller");
    //    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    if ([NSThread isMainThread]) {
        
        [[delegate managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
        
    } else {
        
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
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
#pragma mark - NSTableVIewDelegates

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    if ([aTableView tag] == 201) {
        NSMutableDictionary *row = [[importRatesSecondParserResult arrangedObjects ] objectAtIndex:rowIndex];
        //NSArray *codeList = [row valueForKey:@"codes"];
        NSString *countryFirstVersion = [row valueForKey:@"country"];
        NSString *specificFirstVersion = [row valueForKey:@"specific"];
        if (!specificFirstVersion) specificFirstVersion = @"";
        NSArray *userSpecificDictionaries = [[NSUserDefaults standardUserDefaults] valueForKey:@"userSpecificDictionaries"];
        __block NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(externalCountry == %@) and (externalSpecific == %@)",countryFirstVersion,specificFirstVersion];
        NSArray *filteredUserSpecificDictionaries = [userSpecificDictionaries filteredArrayUsingPredicate:predicate];
        
        if ([filteredUserSpecificDictionaries count] > 0) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList"
                                                      inManagedObjectContext:moc];
            [fetchRequest setEntity:entity];
            NSMutableArray *finalCodesList = [NSMutableArray arrayWithCapacity:0];
            [filteredUserSpecificDictionaries enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *userSpecificDictionary, NSUInteger idx, BOOL *stop) {
                NSString *localCountry = [userSpecificDictionary valueForKey:@"localCountry"];
                NSString *localSpecific = [userSpecificDictionary valueForKey:@"localSpecific"];
                predicate = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",localCountry,localSpecific];
                [fetchRequest setPredicate:predicate];
                
                NSError *error = nil;
                NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
                CountrySpecificCodeList *fetchedList = [fetchedObjects lastObject];
                NSSet *codes = fetchedList.codesList;
                
                [codes enumerateObjectsWithOptions:NSSortStable usingBlock:^(CodesList *codesList, BOOL *stop) {                    
                    NSDictionary *codeRow = [NSDictionary dictionaryWithObjectsAndKeys:[codesList.code stringValue],@"code", nil];
                    [finalCodesList addObject:codeRow];
                }];
                
            }];
            [row setValue:finalCodesList forKey:@"codes"];
            
            [fetchRequest release];
            
        }
        
        
        //NSLog(@"PARSING RESULT VIEW: add items");
        NSString *countryWithoutMinus = [countryFirstVersion stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        NSArray *countryAllWorlds = [countryWithoutMinus componentsSeparatedByString:@" "];
        NSString *countryName = [countryAllWorlds objectAtIndex:0];
        importRatesSelectedCountryForParsing.string = countryName;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList"
                                                  inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        predicate = [NSPredicate predicateWithFormat:@"country contains[cd] %@",importRatesSelectedCountryForParsing];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *result = [moc executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];

        [importRatesDestinationChoice removeAllItems];
        [importRatesDestinationChoice addItemWithTitle:@"PLEASE SELECT"];
        [importRatesDestinationChoice addItemWithTitle:@"SELECT ALL"];
        [importRatesDestinationChoice addItemWithTitle:@"DESELECT ALL"];
        
        for (CountrySpecificCodeList *countryDict in result)
        {
            NSString *localCountry = [countryDict valueForKey:@"country"];
            NSString *localSpecific = [countryDict valueForKey:@"specific"];
            
            NSArray *presentInSaved = [filteredUserSpecificDictionaries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@)",localCountry,localSpecific]];
            
            NSString *addOrRemove = nil;
            if ([presentInSaved count] == 0) addOrRemove = @"ADD";
            else addOrRemove = @"REMOVE";
            
            [importRatesDestinationChoice addItemWithTitle:[NSString stringWithFormat:@"%@: %@/%@",addOrRemove,localCountry,localSpecific]];
            
        }
        
    }
    return YES;
    
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectTableColumn:(NSTableColumn *)aTableColumn
{
    if ([aTableView tag] == 200) {
        if (!importRatesColumnSelectPanel) importRatesColumnSelectPanel = [[NSPopover alloc] init];
        
        if (importRatesColumnSelectPanel) {
            importRatesColumnSelectPanel.contentViewController = importRatesColumnSelectViewController;
            importRatesColumnSelectPanel.behavior = NSPopoverBehaviorTransient;
            id header = [aTableColumn headerCell];
            // NSView *controlView = [header controlView];
            NSRect cellFrame = [header currentFrame];
            cellFrame.origin.y -= 20;
            [importRatesColumnSelectPanel showRelativeToRect:cellFrame ofView:importRatesImportedRoutes preferredEdge:NSMinYEdge];
            NSArray *allColumns = [aTableView tableColumns];
            NSInteger number = [allColumns indexOfObject:aTableColumn];
            
            
            importRatesColumnSelectViewController.view.identifier = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:number]];
            
            //NSLog(@"current header frame is:%@, control view:%@ header:%@",NSStringFromRect(cellFrame),header);
        } else
        {
            importRatesColumnSelectViewController.view.frame = NSMakeRect([[aTableColumn headerCell] frame].origin.x, [[aTableColumn headerCell] frame].origin.y, importRatesColumnSelectViewController.view.frame.size.width, importRatesColumnSelectViewController.view.frame.size.height);
            [self.view addSubview:importRatesColumnSelectViewController.view];
            
        }
        
        return NO;
    } else return YES;
}


#pragma mark - internal methods
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


- (void)awakeFromNib
{
//    delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [self updateTableView:importRatesCodesTableView];
    
    importRatesRelationshipName = [[NSMutableString alloc] init];
    importRatesCarrierName = [[NSMutableString alloc] init];
    importRatesSelectedCountryForParsing = [[NSMutableString alloc] init];;

    [self updateTableView:importRatesImportedRoutes];
    [self updateTableView:importRatesParsedRows];
    [self updateTableView:importRatesCarrierList];
    [self updateTableView:importRatesCarriersRateSheet];
    [self updateTableView:importRatesCodesTableView];
#if defined(SNOW_CLIENT_APPSTORE)
    [[importRatesCarriersRateSheet enclosingScrollView] setHidden:YES];
    [importRatesRelationshipName setString:@"destinationsListPushList"];
    [chooseDestinationsType setSelectedSegment:2];
    [chooseDestinationsType setEnabled:NO forSegment:0];
    [chooseDestinationsType setEnabled:NO forSegment:1];
    
#endif

}

- (IBAction)importChangeExcelSheet:(id)sender {
    [importRatesProgress setHidden:NO];
    [importRatesProgress startAnimation:self];
    [importRatesStartParsing setEnabled:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        NSInteger selectedIndex = [sender indexOfSelectedItem];
        NSMutableArray *parsed = [delegate.updateForMainThread parseToExcelwithSaveUrl:[parsedFileURL path] forSheetNumber:(int)selectedIndex];
        NSArray *content = [delegate.updateForMainThread parseCVSimported:parsed forCarrier:importRatesCarrierName withRelationshipName:importRatesRelationshipName];
        
        [delegate.updateForMainThread importCSVforArray:content 
                                        forChoiceTarget:nil 
                                        forChoiceColumn:nil
                                    forRelationshipName:importRatesRelationshipName];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //            [importRatesStartParsing setAction:@selector(applyRateSheet:)];
            //            [importRatesStartParsing setTitle:@"Apply"];
            [importRatesProgress setHidden:YES];
            [importRatesProgress stopAnimation:self];
            [importRatesStartParsing setEnabled:YES];
            
        });
        
    });


}

- (IBAction)importRatesColumnChoice:(id)sender {
    
    NSString  *currentIdentifier = importRatesColumnSelectViewController.view.identifier;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]  init];
    NSNumber *tableColumnNumber = [formatter numberFromString:currentIdentifier];
    [formatter release];
    NSTableColumn *changedColumn = [[ importRatesImportedRoutes tableColumns] objectAtIndex:[tableColumnNumber unsignedIntegerValue]];
    NSString *finalColumnTitle = nil;
    
    switch ([sender tag]) {
        case 0:
            finalColumnTitle = @"NONE";
            break;
        case 1:
            finalColumnTitle = @"Price";
            break;
        case 2:
            finalColumnTitle = @"Code";
            break;
        case 3:
            finalColumnTitle = @"subcode";
            break;
        case 4:
            finalColumnTitle = @"ACD";
            break;
        case 5:
            finalColumnTitle = @"ASR";
            break;
        case 6:
            finalColumnTitle = @"Country";
            break;
        case 7:
            finalColumnTitle = @"Specific";
            break;
        case 8:
            finalColumnTitle = @"Minutes";
            break;
        case 9:
            finalColumnTitle = @"Attempts";
            break;
        case 10:
            finalColumnTitle = @"Date";
            break;
            
        default:
            break;
    }
    [[changedColumn headerCell] setStringValue:finalColumnTitle];
    [[importRatesImportedRoutes headerView] setNeedsDisplay:YES];
    
    if (importRatesColumnSelectPanel) [importRatesColumnSelectPanel close];

    //    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    // get current choices
    NSMutableDictionary *importRatesUserChoices = [NSMutableDictionary dictionary];
    [importRatesUserChoices addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationFilesDirectory]]]];
    // fill current titles
    NSMutableArray *allColumnsTitles = [NSMutableArray arrayWithCapacity:9];
    for (NSTableColumn *column in [importRatesImportedRoutes tableColumns]) { 
        NSString *title = [[column headerCell] stringValue];
        [allColumnsTitles addObject:title];
    }
    //NSLog(@"i will write:%@",allColumnsTitles);
    
    NSMutableDictionary *relationshipAndChoises = [NSMutableDictionary dictionary];
    [relationshipAndChoises setValue:allColumnsTitles forKey:importRatesRelationshipName];
    [importRatesUserChoices setValue:relationshipAndChoises forKey:importRatesCarrierName];
    
    [importRatesUserChoices writeToFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationFilesDirectory]] atomically:YES];
    
}
#pragma TODO - fix projects array!!!!!!!!!
- (IBAction)importDestinationsUserSelectDestination:(id)sender {
    NSArray *countrySpecific = [[sender title] componentsSeparatedByString:@"/"];
    NSString *countrySelected = [countrySpecific objectAtIndex:0];
    if ([countrySelected isEqualToString:@"PLEASE SELECT"] || [countrySelected isEqualToString:@"Destination choice"]) return;
    
    
    NSMutableDictionary *row = [[importRatesSecondParserResult selectedObjects] lastObject];
    NSString *countryFirstVersion = [row valueForKey:@"country"];
    NSString *specificFirstVersion = [row valueForKey:@"specific"];
    if (!specificFirstVersion) specificFirstVersion = @"";
    NSArray *userSpecificDictionariesForLocalChoice = [[NSUserDefaults standardUserDefaults] valueForKey:@"userSpecificDictionaries"];

    NSMutableArray *finalVersion = [NSMutableArray arrayWithArray:userSpecificDictionariesForLocalChoice];
    
    NSPredicate *predicate = nil;
    NSArray *result = nil;
    NSArray *codes = nil;
    NSMutableArray *codesCollection = [NSMutableArray array];
    if ([countrySelected isEqualToString:@"SELECT ALL"]) {
        predicate = [NSPredicate predicateWithFormat:@"(country contains[cd] %@)",importRatesSelectedCountryForParsing];
        result = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:predicate];
        //[codesCollection addObject:nil];
        //codes = [NSArray arrayWithArray:codesCollection];
        
        NSString *countryName = [[result lastObject] valueForKey:@"country"];
        
        for (NSDictionary *specifics in result) {
            [codesCollection addObjectsFromArray:[specifics valueForKey:@"code"]];
            NSString *specific = [specifics valueForKey:@"specific"];
            // add select to saved area
            NSDictionary *newObject = [NSDictionary dictionaryWithObjectsAndKeys:countryFirstVersion,@"externalCountry",specificFirstVersion,@"externalSpecific", countryName,@"localCountry",specific,@"localSpecific", nil];
            NSArray *filteredCurrentUserSpecificDictionaries = [userSpecificDictionariesForLocalChoice filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@) AND (externalCountry == %@) AND (externalSpecific == %@)",countryName,specific,countryFirstVersion,specificFirstVersion]];
            
            if ([filteredCurrentUserSpecificDictionaries count] == 0) [finalVersion addObject:newObject];
            
            
        }
        [row setValue:nil forKey:@"finded"];

        [[NSUserDefaults standardUserDefaults] setValue:finalVersion forKey:@"userSpecificDictionaries"];
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        NSString *applicationSupportDirectory = [delegate applicationFilesDirectory].path;
        [finalVersion writeToFile:[NSString stringWithFormat:@"%@/userSpecificDictionaries_IMPORT_DESTINATIONS.ary",applicationSupportDirectory] atomically:YES];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
//        NSArray *allItems = [importRatesDestinationChoice itemArray];
//        
//        [allItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
//            NSString *title = item.title;
//            
//            NSString *titleNew = [title stringByReplacingOccurrencesOfString:@"ADD" withString:@"REMOVE"]; 
//            item.title = titleNew;
//        }];
        NSInteger selectedRow = [importRatesParsedRows selectedRow];
        [self tableView:importRatesParsedRows shouldSelectRow:selectedRow];
        return;
        
    } 
    
    
    if ([countrySelected isEqualToString:@"DESELECT ALL"])
    {
        
        NSMutableDictionary *row = [[importRatesSecondParserResult selectedObjects ] lastObject];
        NSMutableArray *currentCodesList = [NSMutableArray arrayWithArray:[row valueForKey:@"codes"]];
        [currentCodesList removeAllObjects];
        [row setValue:currentCodesList forKey:@"codes"];
        
        [finalVersion removeAllObjects];
        
        [[NSUserDefaults standardUserDefaults] setValue:finalVersion forKey:@"userSpecificDictionaries"];
        NSString *applicationSupportDirectory = [delegate applicationFilesDirectory].path;
        [finalVersion writeToFile:[NSString stringWithFormat:@"%@/userSpecificDictionaries_IMPORT_DESTINATIONS.ary",applicationSupportDirectory] atomically:YES];

        [[NSUserDefaults standardUserDefaults] synchronize];
        [row setValue:@"not finded" forKey:@"finded"];
        NSInteger selectedRow = [importRatesParsedRows selectedRow];
        [self tableView:importRatesParsedRows shouldSelectRow:selectedRow];

        
        return;
    }
    NSString *specificSelected = [countrySpecific objectAtIndex:1];
    
    if ([codes count] == 0)
    {
        
        // just one country/specific pair selected
        NSString *countryFinal = nil;
        NSRange range = [countrySelected rangeOfString:@"ADD"];
        if (range.location != NSNotFound) {
            countryFinal = [countrySelected stringByReplacingOccurrencesOfString:@"ADD: " withString:@""];
            
            NSArray *filteredCurrentUserSpecificDictionaries = [userSpecificDictionariesForLocalChoice filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@) AND (externalCountry == %@) AND (externalSpecific == %@)",countryFinal,specificSelected,countryFirstVersion,specificFirstVersion]];
                        
            NSMutableDictionary *newObject = [NSMutableDictionary dictionaryWithCapacity:4];
            [newObject setValue:countryFirstVersion forKey:@"externalCountry"];
            if (specificFirstVersion) [newObject setValue:specificFirstVersion forKey:@"externalSpecific"];
            else [newObject setValue:@"" forKey:@"externalSpecific"];
            [newObject setValue:countryFinal forKey:@"localCountry"];
            [newObject setValue:specificSelected forKey:@"localSpecific"];
            
            if ([filteredCurrentUserSpecificDictionaries count] == 0)  [finalVersion addObject:newObject];
            
            // to prevent duplicate records we must check before add and delete appropriate object.
            
            [[NSUserDefaults standardUserDefaults] setValue:finalVersion forKey:@"userSpecificDictionaries"];
            //            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
            NSString *applicationSupportDirectory = [delegate applicationFilesDirectory].path;
            [finalVersion writeToFile:[NSString stringWithFormat:@"%@/userSpecificDictionaries_IMPORT_DESTINATIONS.ary",applicationSupportDirectory] atomically:YES];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            [row setValue:nil forKey:@"finded"];

            NSInteger selectedRow = [importRatesParsedRows selectedRow];
            [self tableView:importRatesParsedRows shouldSelectRow:selectedRow];
           
            
        }
        else { 
            
            countryFinal = [countrySelected stringByReplacingOccurrencesOfString:@"REMOVE: " withString:@""];
            
            NSArray *filteredCurrentUserSpecificDictionaries = [userSpecificDictionariesForLocalChoice filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(localCountry == %@) AND (localSpecific == %@) AND (externalCountry == %@) AND (externalSpecific == %@)",countryFinal,specificSelected,countryFirstVersion,specificFirstVersion]];
            
            
            
            if ([filteredCurrentUserSpecificDictionaries count] > 0)  [finalVersion removeObjectsInArray:filteredCurrentUserSpecificDictionaries];
            
            // to prevent duplicate records we must check before add and delete appropriate object.
            
            [[NSUserDefaults standardUserDefaults] setValue:finalVersion forKey:@"userSpecificDictionaries"];
            NSString *applicationSupportDirectory = [delegate applicationFilesDirectory].path;
            [finalVersion writeToFile:[NSString stringWithFormat:@"%@/userSpecificDictionaries_IMPORT_DESTINATIONS.ary",applicationSupportDirectory] atomically:YES];
            
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList"
                                                      inManagedObjectContext:moc];
            [fetchRequest setEntity:entity];
            predicate = [NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)",countryFinal,specificSelected];
            [fetchRequest setPredicate:predicate];
            
            NSError *error = nil;
            NSArray *result = [moc executeFetchRequest:fetchRequest error:&error];
            [fetchRequest release];
            CountrySpecificCodeList *list = [result lastObject];
            
            NSSet *codesToRemove = list.codesList;
            
            NSMutableArray *currentCodesList = [NSMutableArray arrayWithArray:[row valueForKey:@"codes"]];
            [codesToRemove enumerateObjectsUsingBlock:^(CodesList *codesObject, BOOL *stop) {
                NSArray *removedObject = [currentCodesList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@",codesObject.code.stringValue]];
                [currentCodesList removeObjectsInArray:removedObject];

            }];
            
//            [codes enumerateObjectsUsingBlock:^(NSString *code, NSUInteger idx, BOOL *stop) {
//                NSArray *removedObject = [currentCodesList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] %@",code]];
//                [currentCodesList removeObjectsInArray:removedObject];
//            }];
            
            [row setValue:currentCodesList forKey:@"codes"];
            if ([currentCodesList count] > 0) [row setValue:nil forKey:@"finded"];
            else [row setValue:@"not finded" forKey:@"finded"];
            NSInteger selectedRow = [importRatesParsedRows selectedRow];
            [self tableView:importRatesParsedRows shouldSelectRow:selectedRow];

        }
        
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


- (IBAction)importDestinationsParsing:(id)sender;
{
    //    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    [importRatesProgress setHidden:NO];
    [importRatesProgress startAnimation:self];
    [importRatesStartParsing setEnabled:NO];
    [importRatesApply setEnabled:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        [delegate.updateForMainThread importCSVstartWithRelationshipName:importRatesRelationshipName];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            //            [importRatesStartParsing setAction:@selector(applyRateSheet:)];
            //            [importRatesStartParsing setTitle:@"Apply"];
            [importRatesProgress setHidden:YES];
            [importRatesProgress stopAnimation:self];
            [importRatesStartParsing setEnabled:YES];
            [importRatesApply setEnabled:YES];

        });
        
    });
    
}
- (IBAction)importDestinationsApply:(id)sender {
    
    NSTabViewItem *selectedItem = [delegate.destinationsView.destinationsTab selectedTabViewItem];
    
    if ([[selectedItem label] isEqualToString:@"Targets"]){
        [delegate.destinationsView.targetsProgress setHidden:NO];
        [delegate.destinationsView.targetsProgress startAnimation:self];
        
    }
    if ([[selectedItem label] isEqualToString:@"Buy"]){
        [delegate.destinationsView.weBuyProgress setHidden:NO];
        [delegate.destinationsView.weBuyProgress startAnimation:self];
        
    }
    if ([[selectedItem label] isEqualToString:@"Pushlist"]){
        [delegate.destinationsView.pushListProgress setHidden:NO];
        [delegate.destinationsView.pushListProgress startAnimation:self];
    }
    if (delegate.destinationsView.importRatesPanel) [delegate.destinationsView.importRatesPanel close];

    if (delegate.destinationsView.importRatesMainPanel) { 
        [delegate.destinationsView.importRatesMainPanel orderOut:sender];
        [NSApp endSheet:delegate.destinationsView.importRatesMainPanel];
    }
    
    if (delegate.carriersView.importRatesPanel) [delegate.carriersView.importRatesPanel close];
    
    if (delegate.carriersView.importRatesMainPanel) { 
        [delegate.carriersView.importRatesMainPanel orderOut:sender];
        [NSApp endSheet:delegate.carriersView.importRatesMainPanel];
    }
    
    
//    delegate.carrierTableViewDelegate.importRatesPanel.animates = delegate.carrierTableViewDelegate.importRatesPanel.animates;
//
//    if (delegate.carrierTableViewDelegate.importRatesPanel) { 
//        delegate.carrierTableViewDelegate.importRatesPanel.animates = delegate.carrierTableViewDelegate.importRatesPanel.animates;
//        [delegate.carrierTableViewDelegate.importRatesPanel close];
//    }
//    [delegate.carrierTableViewDelegate.importRatesMainPanel setFloatingPanel:delegate.carrierTableViewDelegate.importRatesMainPanel.isFloatingPanel];
//
//    if (delegate.carrierTableViewDelegate.importRatesMainPanel) { 
//        [delegate.carrierTableViewDelegate.importRatesMainPanel orderOut:sender];
//        [NSApp endSheet:delegate.carrierTableViewDelegate.importRatesMainPanel];
//    }
//

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        [delegate.updateForMainThread importCSVfinishWithProgress:delegate.progressForMainThread withRelationship:importRatesRelationshipName];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([[selectedItem label] isEqualToString:@"Targets"]){
                [delegate.destinationsView.targetsProgress setHidden:YES];
                [delegate.destinationsView.targetsProgress stopAnimation:self];
                
            }
            if ([[selectedItem label] isEqualToString:@"Buy"]){
                [delegate.destinationsView.weBuyProgress setHidden:YES];
                [delegate.destinationsView.weBuyProgress stopAnimation:self];
                
            }
            if ([[selectedItem label] isEqualToString:@"Pushlist"]){
                [delegate.destinationsView.pushListProgress setHidden:YES];
                [delegate.destinationsView.pushListProgress stopAnimation:self];
            }
            
        });
        
        return;
    });
    
}

- (IBAction)importDestinationsClose:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (delegate.destinationsView.importRatesPanel) [delegate.destinationsView.importRatesPanel close];
        
        if (delegate.destinationsView.importRatesMainPanel) { 
            [delegate.destinationsView.importRatesMainPanel orderOut:sender];
            [NSApp endSheet:delegate.destinationsView.importRatesMainPanel];
        }
        if (delegate.carriersView.importRatesPanel) [delegate.carriersView.importRatesPanel close];
        
        if (delegate.carriersView.importRatesMainPanel) { 
            [delegate.carriersView.importRatesMainPanel orderOut:sender];
            [NSApp endSheet:delegate.carriersView.importRatesMainPanel];
        }
        //    NSLog(@"IMPORT RATES VIEW: %@",delegate.carrierTableViewDelegate.importRatesPanel);
        //delegate.carrierTableViewDelegate.importRatesPanel.animates = delegate.carrierTableViewDelegate.importRatesPanel.animates;
        
//        if (delegate.carrierTableViewDelegate.importRatesPanel) { 
//            //delegate.carrierTableViewDelegate.importRatesPanel.animates = delegate.carrierTableViewDelegate.importRatesPanel.animates;
//            
//            [delegate.carrierTableViewDelegate.importRatesPanel close];
//        } 
        
        //[delegate.carrierTableViewDelegate.importRatesMainPanel setFloatingPanel:delegate.carrierTableViewDelegate.importRatesMainPanel.isFloatingPanel];
        
//        if (delegate.carrierTableViewDelegate.importRatesMainPanel) { 
//            //[delegate.carrierTableViewDelegate.importRatesMainPanel setFloatingPanel:delegate.carrierTableViewDelegate.importRatesMainPanel.isFloatingPanel];
//            
//            [delegate.carrierTableViewDelegate.importRatesMainPanel orderOut:sender];
//            [NSApp endSheet:delegate.carrierTableViewDelegate.importRatesMainPanel];
//        }
    });
}

- (IBAction)importDestinations:(id)sender {
    //    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//    
//#if defined(SNOW_CLIENT_APPSTORE)
//    [importRatesEffectiveDate setHidden:YES];
//    [importRatesRatesheetList setHidden:YES];
//    [importRatesPrefix setHidden:YES];
//#endif
//    
//    
//    importRatesEffectiveDate.dateValue = [NSDate dateWithTimeIntervalSinceNow:-86400];
//    NSMutableArray *carriers = [NSMutableArray arrayWithCapacity:0];
//    NSTabViewItem *selectedItem = [delegate.destinationsView.destinationsTab selectedTabViewItem];
//    NSString *relationShipName = nil;
//    NSArray *selectedDestinations = nil;
//    if ([[selectedItem label] isEqualToString:@"Targets"]){
//        relationShipName = @"destinationsListTargets";
//        selectedDestinations = [delegate.destinationsView.destinationsListTargets selectedObjects];
//        [delegate.destinationsView.destinationsListTargets setSelectedObjects:nil];
//        for (DestinationsListTargets *target in selectedDestinations) if (![carriers containsObject:target.carrier]) [carriers addObject:target.carrier];
//        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"selectionChoices", nil];
//        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
//        [importRatesViewController setTitle:@"import targets"];
//    }
//    if ([[selectedItem label] isEqualToString:@"Buy"]){
//        relationShipName = @"destinationsListWeBuy";
//        
//        selectedDestinations = [delegate.destinationsView.destinationsListWeBuy selectedObjects];
//        [delegate.destinationsView.destinationsListWeBuy setSelectedObjects:nil];
//        for (DestinationsListWeBuy *destinationWeBuy in selectedDestinations) if (![carriers containsObject:destinationWeBuy.carrier]) [carriers addObject:destinationWeBuy.carrier];
//        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"selectionChoices", nil];
//        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
//        [importRatesViewController setTitle:@"import rates to destination we buy"];
//        
//    }
//    if ([[selectedItem label] isEqualToString:@"Pushlist"]){
//        relationShipName = @"destinationsListPushList";
//        selectedDestinations = [delegate.destinationsView.destinationsListPushList selectedObjects];
//        [delegate.destinationsView.destinationsListPushList setSelectedObjects:nil];
//        for (DestinationsListPushList *destinationsPushList in selectedDestinations) if (![carriers containsObject:destinationsPushList.carrier]) [carriers addObject:destinationsPushList.carrier];
//        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"selectionChoices", nil];
//        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
//        [importRatesViewController setTitle:@"import push list"];
//        
//        
//    }
//    
//    for (Carrier *carrier in [delegate.carrierArrayController selectedObjects]) if (![carriers containsObject:carrier]) [carriers addObject:carrier];
//    if (carriers.count == 0) [carriers addObject:[delegate.carrierArrayController.arrangedObjects lastObject]];
//    
//    [importRatesRelationshipName setString:relationShipName];
//    
//    [importRatesStartParsing setAction:@selector(importDestinationsParsing:)];
//    [importRatesStartParsing setTitle:@"Start parsing"];
//    
//    NSOpenPanel *savePanel = [NSOpenPanel openPanel]; 
//    NSArray *fileTypes = [NSArray arrayWithObjects:@"csv",@"xls",nil];
//    //[savePanel setFloatingPanel:YES];
//    [savePanel setCanCreateDirectories:NO]; 
//    [savePanel setCanChooseFiles:YES];
//    [savePanel setAllowedFileTypes:fileTypes];
//    
//    [savePanel beginSheetModalForWindow:delegate.window completionHandler:^(NSInteger result) {
//        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        
//        //        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        if ([delegate.loggingLevel intValue] == 1) NSLog(@"RATES IMPORT:result is:%@",[NSNumber numberWithInteger:result]);
//        
//        if (result == NSFileHandlingPanelOKButton) { 
//            //            if ([carriers count] == 1)
//            //            {
//            //                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//            //                NSString *warning = [NSString stringWithFormat:@"HMMM... you like to add for more than two carriers once? i didn't hear about is it nessesary"];
//            //                [dict setValue:warning forKey:NSLocalizedDescriptionKey];
//            //                [dict setValue:@"There was an error for insert new destination." forKey:NSLocalizedFailureReasonErrorKey];
//            //                NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
//            //                [[NSApplication sharedApplication] presentError:error];
//            //                return ;
//            //                
//            //            }
//            //[self createAndConnectMainThreadControllers];
//            [delegate.progressForMainThread startProgressIndicatorCountSeeWebRouting];
//            
//            //[queneForMainThreadBackground addOperationWithBlock:^{
//            NSURL *choicedFile = [savePanel URL];
//            NSString *extension = [choicedFile pathExtension];
//            NSMutableArray *parsedFinal = [NSMutableArray arrayWithCapacity:0];
//            
//            //            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//            if ([delegate.loggingLevel intValue] == 1) NSLog(@"RATES IMPORT:%@",extension);
//            if ([extension isEqualToString:@"xls"] || [extension isEqualToString:@"XLS"] || [extension isEqualToString:@"xlsx"]) {
//                NSArray *allSheets = [delegate.updateForMainThread allExcelBookSheetsForUSR:[choicedFile path]];
//                
//                NSMutableArray *parsed = [NSMutableArray array];
//                if ([allSheets count] == 1) {
//                    [parsed addObjectsFromArray:[delegate.updateForMainThread parseToExcelwithSaveUrl:[choicedFile path] forSheetNumber:0]];
//                    [importRatesRatesheetList setHidden:YES];
//                    //[importCSVprefix setHidden:NO];
//                    
//                    [importRatesRatesheetList removeAllItems];
//                    
//                } else {
//                    delegate.importCSVselectedURL = choicedFile;
//                    Carrier *updated = [carriers lastObject];
//                    [delegate.importCSVselectedCarrierName setString:updated.name];
//                    
//                    [importRatesRatesheetList setHidden:NO];
//                    //[importCSVprefix setHidden:NO];
//                    
//                    [importRatesRatesheetList removeAllItems];
//                    for (NSString *sheetName in allSheets)
//                    {
//                        [importRatesRatesheetList addItemWithTitle:sheetName];
//                    }
//                    [parsed addObjectsFromArray:[delegate.updateForMainThread parseToExcelwithSaveUrl:[choicedFile path] forSheetNumber:0]];
//                    
//                }
//                [parsedFinal addObjectsFromArray:parsed];
//            }
//            if ([extension isEqualToString:@"csv"]) {
//                // start parsing cvs file 
//                ParseCSV *parser = [[ParseCSV alloc] init];
//                [parser openFile:[choicedFile path]];
//                NSMutableArray *parsed = [parser parseFile];
//                [parser release];
//                [parsedFinal addObjectsFromArray:parsed];
//                
//            }
//            
//            
//            //[parsed writeToFile:@"/Users/alex/Documents/rulesParsed.ary" atomically:YES];
//            Carrier *carrierToImport = [carriers lastObject];
//            NSString *carrierToImportName = carrierToImport.name;
//            [importRatesCarrierName setString:carrierToImportName];
//            // read current choices and update tableview
//            NSMutableDictionary *importRatesUserChoices = [NSMutableDictionary dictionary];
//            [importRatesUserChoices addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationSupportDirectory]]]];
//            NSMutableDictionary *carrierChoisesList = [importRatesUserChoices valueForKey:importRatesCarrierName];
//            NSArray *allColumns = [carrierChoisesList valueForKey:importRatesRelationshipName];
//            NSArray *allTableColumns = [importRatesImportedRoutes tableColumns];
//            
//            if (allColumns) {
//                [allTableColumns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
//                    [[column headerCell] setStringValue:[allColumns objectAtIndex:idx]];
//                }];
//            } else {
//                [allTableColumns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
//                    [[column headerCell] setStringValue:@"click to select"];
//                }];
//                
//            }
//            //            dispatch_async(dispatch_get_main_queue(), ^(void) {
//            //                
//            //                [[importRatesImportedRoutes headerView] setNeedsDisplay:YES];
//            //            });
//            //for (NSTableColumn *column in [importRatesImportedRoutes tableColumns]) [allColumnsTitles addObject:[[changedColumn headerCell] stringValue]];
//            
//            
//            
//            
//            
//            [delegate.updateForMainThread parseCVSimported:parsedFinal forCarrier:carrierToImportName withRelationshipName:relationShipName];
//            [addDestinationCarriersList setContent:[delegate.updateForMainThread fillCarriersForAddArrayForCarriers:carriers withRelationShipName:relationShipName forCurrentContent:[addDestinationCarriersList arrangedObjects]]];
//            
//            [delegate.progressForMainThread stopProgressIndicatorCountSeeWebRouting];
//            //[importCSV setBackgroundColor:[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1]];
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                
//                importRatesPanel = [[[NSPopover alloc] init] autorelease];
//                //                NSRect frameOfTestingCell = [sender frame]; 
//                NSRect frameOfSender = [sender frame]; 
//                
//                if (importRatesPanel) {
//                    importRatesPanel.contentViewController = self;
//                    importRatesPanel.behavior = NSPopoverBehaviorApplicationDefined;
//                    [importRatesPanel showRelativeToRect:frameOfSender ofView:delegate.destinationsView.view preferredEdge:NSMaxYEdge];
//                } else
//                {
//                    importRatesViewController.view.frame = NSMakeRect(frameOfSender.origin.x, frameOfSender.origin.y, importRatesViewController.view.frame.size.width, importRatesViewController.view.frame.size.height);
//                    [self.view addSubview:importRatesViewController.view];
//                }
//                
//                //            [NSApp beginSheet:addDestinationsMainPanel 
//                //               modalForWindow:delegate.window
//                //                modalDelegate:nil 
//                //               didEndSelector:nil
//                //                  contextInfo:nil];
//            });
//            
//            //return;
//        }
//        //});
//    }];
//    //[savePanel runModal];
//    
//    //NSArray *carriers = [NSArray arrayWithArray:[carrierArrayController selectedObjects]];
//    //[carrierArrayController setSelectedObjects:nil];
//    //DestinationsListTargets *selectedTarget = [[destinationsListTargets selectedObjects] lastObject];
//    //NSArray *newCarriers = nil;
    
    
}


- (void)viewDidLoad {
    //NSLog(@"viewWillLoad");
    NSTabViewItem *selectedItem = [delegate.destinationsView.destinationsTab selectedTabViewItem];
    NSString *selectedLabel = [selectedItem label];

#if defined(SNOW_CLIENT_APPSTORE)
    [importRatesEffectiveDate setHidden:YES];
    [importRatesRatesheetList setHidden:YES];
    [importRatesPrefix setHidden:YES];
    selectedLabel = @"Pushlist";
#endif
    
    importRatesEffectiveDate.dateValue = [NSDate dateWithTimeIntervalSinceNow:-86400];
    NSMutableArray *carriers = [NSMutableArray arrayWithCapacity:0];
    
    NSString *relationShipName = nil;
    NSArray *selectedDestinations = nil;
    
    if ([selectedLabel isEqualToString:@"Targets"]){
        relationShipName = @"destinationsListTargets";
        selectedDestinations = [delegate.destinationsView.destinationsListTargets selectedObjects];
        [delegate.destinationsView.destinationsListTargets setSelectedObjects:nil];
        for (DestinationsListTargets *target in selectedDestinations) if (![carriers containsObject:target.carrier]) [carriers addObject:target.carrier];
        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"selectionChoices", nil];
        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
        [importRatesViewController setTitle:@"import targets"];
        chooseDestinationsType.selectedSegment = 1;
        
    }
    if ([selectedLabel isEqualToString:@"Buy"]){
        relationShipName = @"destinationsListWeBuy";
        
        selectedDestinations = [delegate.destinationsView.destinationsListWeBuy selectedObjects];
        [delegate.destinationsView.destinationsListWeBuy setSelectedObjects:nil];
        for (DestinationsListWeBuy *destinationWeBuy in selectedDestinations) if (![carriers containsObject:destinationWeBuy.carrier]) [carriers addObject:destinationWeBuy.carrier];
        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"selectionChoices", nil];
        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
        [importRatesViewController setTitle:@"import rates to destination we buy"];
        chooseDestinationsType.selectedSegment = 0;

    }
    if ([selectedLabel  isEqualToString:@"Pushlist"]){
        relationShipName = @"destinationsListPushList";
        selectedDestinations = [delegate.destinationsView.destinationsListPushList selectedObjects];
        [delegate.destinationsView.destinationsListPushList setSelectedObjects:nil];
        for (DestinationsListPushList *destinationsPushList in selectedDestinations) if (![carriers containsObject:destinationsPushList.carrier]) [carriers addObject:destinationsPushList.carrier];
        NSDictionary *selectionChoices = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"selectionChoices", nil];
        [importRatesSelectionList setContent:[NSArray arrayWithObject:selectionChoices]];
        [importRatesViewController setTitle:@"import push list"];
        chooseDestinationsType.selectedSegment = 2;

        
    }
    
    for (Carrier *carrier in [delegate.carriersView.carrier selectedObjects]) if (![carriers containsObject:carrier]) [carriers addObject:carrier];
    
    if (relationShipName) [importRatesRelationshipName setString:relationShipName];
    else { 
        relationShipName = @"destinationsListTargets";
        [importRatesRelationshipName setString:@"destinationsListTargets"];
        [carriers addObject:[moc objectWithID:dragToCarrier]];
    }
//    if (carriers.count == 0) [carriers addObject:[delegate.carrierArrayController.arrangedObjects lastObject]];
    
    
    [importRatesStartParsing setAction:@selector(importDestinationsParsing:)];
    [importRatesStartParsing setTitle:@"Start parsing"];
    
    NSString *extension = [parsedFileURL pathExtension];
    NSMutableArray *parsedFinal = [NSMutableArray arrayWithCapacity:0];
    
    if ([delegate.loggingLevel intValue] == 1) NSLog(@"RATES IMPORT:%@",extension);
    if ([extension isEqualToString:@"xls"] || [extension isEqualToString:@"XLS"] || [extension isEqualToString:@"xlsx"]) {
        NSArray *allSheets = [delegate.updateForMainThread allExcelBookSheetsForUSR:[parsedFileURL path]];
        
        NSMutableArray *parsed = [NSMutableArray array];
        if ([allSheets count] == 1) {
            [parsed addObjectsFromArray:[delegate.updateForMainThread parseToExcelwithSaveUrl:[parsedFileURL path] forSheetNumber:0]];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                [importRatesRatesheetList setHidden:YES];
                [chooseExcelSheetLabel setHidden:YES];
                [importRatesRatesheetList removeAllItems];            
            });
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                
                Carrier *updated = [carriers lastObject];
                NSString *carrierName = updated.name;
                if (carrierName) self.importRatesCarrierName.string = carrierName;
                [importRatesRatesheetList setHidden:NO];
                [chooseExcelSheetLabel setHidden:NO];
            });
            [importRatesRatesheetList removeAllItems];
            for (NSString *sheetName in allSheets)
            {
                [importRatesRatesheetList addItemWithTitle:sheetName];
            }
            [parsed addObjectsFromArray:[delegate.updateForMainThread parseToExcelwithSaveUrl:[parsedFileURL path] forSheetNumber:0]];
        }
        [parsedFinal addObjectsFromArray:parsed];
    }
    if ([extension isEqualToString:@"csv"]) {
        // start parsing cvs file 
        ParseCSV *parser = [[ParseCSV alloc] init];
        [parser openFile:[parsedFileURL path]];
        NSMutableArray *parsed = [parser parseFile];
        [parser release];
        [parsedFinal addObjectsFromArray:parsed];
    }
    
    Carrier *carrierToImport = [carriers lastObject];
    NSString *carrierToImportName = carrierToImport.name;
    [importRatesCarrierName setString:carrierToImportName];
    // read current choices and update tableview
    NSMutableDictionary *importRatesUserChoices = [NSMutableDictionary dictionary];
    [importRatesUserChoices addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationFilesDirectory]]]];
    NSMutableDictionary *carrierChoisesList = [importRatesUserChoices valueForKey:importRatesCarrierName];
    NSArray *allColumns = [carrierChoisesList valueForKey:importRatesRelationshipName];
    NSArray *allTableColumns = [importRatesImportedRoutes tableColumns];
    
    if (allColumns) {
        [allTableColumns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
            NSString *columnName = [allColumns objectAtIndex:idx];
            if ([columnName isEqualToString:@"NONE"] || [columnName isEqualToString:@"Price"] || [columnName isEqualToString:@"Code"] || [columnName isEqualToString:@"subcode"] || [columnName isEqualToString:@"ACD"] || [columnName isEqualToString:@"ASR"] || [columnName isEqualToString:@"Country"] || [columnName isEqualToString:@"Specific"] || [columnName isEqualToString:@"Minutes"] || [columnName isEqualToString:@"Attempts"] || [columnName isEqualToString:@"Date"]) [[column headerCell] setStringValue:columnName];
            else [[column headerCell] setStringValue:@"click to select"];

        }];
    } else {
        [allTableColumns enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
            [[column headerCell] setStringValue:@"click to select"];
        }];
    }
    
    MySQLIXC *database = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:nil];
    database.connections = [delegate.updateForMainThread databaseConnections];
    
    UpdateDataController *update = [[UpdateDataController alloc] initWithDatabase:database];

    NSArray *contentFirstParsed = [update parseCVSimported:parsedFinal forCarrier:carrierToImportName withRelationshipName:relationShipName];;
    importRatesFirsParserResult.content = contentFirstParsed;
    
    [update release],[database release];
    
    //NSLog(@"content parsed:%@",importRatesFirsParserResult.arrangedObjects);
    
    [addDestinationCarriersList setContent:[delegate.updateForMainThread fillCarriersForAddArrayForCarriers:carriers withRelationShipName:relationShipName forCurrentContent:[addDestinationCarriersList arrangedObjects]]];

}

//- (void)viewDidLoad {
//    NSLog(@"viewDidLoad");
//
//}

- (void)loadView {
    //[self viewWillLoad];
    [super loadView];
    [self viewDidLoad];
}

- (IBAction)changeRelationship:(id)sender {
    NSString *relationShipName = nil;
#if defined(SNOW_CLIENT_APPSTORE)
    relationShipName = @"destinationsListPushList";
    [importRatesRelationshipName setString:relationShipName];
#else
    switch (chooseDestinationsType.selectedSegment) {
        case 0:
            relationShipName = @"destinationsListWeBuy";

            break;
        case 1:
            relationShipName = @"destinationsListTargets";
            break;
        case 2:
            relationShipName = @"destinationsListPushList";
            break;
            
        default:
            break;
    }
    [importRatesRelationshipName setString:relationShipName];
#endif
    //NSLog(@"selected relationshi:%@",[NSNumber numberWithInteger:chooseDestinationsType.selectedSegment]);
}



//- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
//{
//    if ([aTableView tag] == 201) {
//        if ([[aTableColumn identifier] isEqualToString:@"finded"]) {
//            NSDictionary *row = [[importRatesSecondParserResult arrangedObjects] objectAtIndex:rowIndex];  
//            NSString *finded = [row valueForKey:@"finded"];
//            NSLog(@"finded:%@ for row:%@",finded,[NSNumber numberWithInteger:rowIndex]);
//            if (!finded || finded.length < 1) { 
//                [aCell setBordered:NO];
//                [aCell setBezeled:NO];
//            } else {
//                [aCell setBordered:YES];
//                [aCell setBezeled:YES];
//            }
//        }
//    }
//}
//

@end
