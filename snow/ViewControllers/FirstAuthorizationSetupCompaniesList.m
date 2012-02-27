//
//  FirstAuthorizationSetupCompaniesList.m
//  snow
//
//  Created by Oleksii Vynogradov on 28.11.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import "FirstAuthorizationSetupCompaniesList.h"
#import "FirstAuthorizationSetup.h"
#import "AVGradientBackgroundView.h"
#import "AVTableHeaderView.h"

#import "desctopAppDelegate.h"
#import "CurrentCompany.h"

@implementation FirstAuthorizationSetupCompaniesList
@synthesize firstAuthorizationSetup;
@synthesize registeredCompaniesBox;
@synthesize companiesListTableView;
@synthesize currentCompany1,moc;

-(void) updateScrollerForTablewView:(NSTableView *)tableview;
{
    NSRect frame = [[tableview cornerView] frame];
    [tableview setCornerView:nil];
    AVGradientBackgroundView *newView = [[[AVGradientBackgroundView alloc] initWithFrame:frame] autorelease];
    [tableview setCornerView:newView];
    
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
        
        [newHeader setControlSize:NSRegularControlSize];
        [newHeader setAlignment:NSCenterTextAlignment];
        
        //[column set
        [column setHeaderCell:newHeader];
        
    }
    [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    //[tableView setBackgroundColor:[NSColor colorWithDeviceRed:0.52 green:0.54 blue:0.70 alpha:1]];
    [self updateScrollerForTablewView:tableView];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        [moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setPersistentStoreCoordinator:delegate.persistentStoreCoordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];

    }
    
    return self;
}

- (void)importerDidSave:(NSNotification *)saveNotification {
    //NSLog(@"MERGE in First authorization controller");
    if ([NSThread isMainThread]) {
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        [[delegate managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
    } else {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}

#pragma mark -
#pragma mark NSTAbleView delegate block
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row;
{
    CurrentCompany *selectedCompany = [[firstAuthorizationSetup.currentCompany arrangedObjects] objectAtIndex:row];
    if (selectedCompany) {
        firstAuthorizationSetup.company.stringValue = [NSString stringWithFormat:@"%@ (join request)",selectedCompany.name];
        firstAuthorizationSetup.isCompanyListWasSelected = YES;
        return YES;
    } else return NO;
    
}

-(void)test;
{
    //NSLog(@"all companies:%@",[firstAuthorizationSetup.currentCompany arrangedObjects]);

}

@end
