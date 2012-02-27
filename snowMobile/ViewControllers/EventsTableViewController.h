//
//  EventsViewController.h
//  snow
//
//  Created by Alex Vinogradov on 20.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadExternalData.h"

@interface EventsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,UISearchDisplayDelegate, UISearchBarDelegate,DownloadExternalDataDelegate> 
{
@private
    NSFetchedResultsController *fetchedResultsController_;
    NSFetchedResultsController *searchFetchedResultsController_;
    NSString        *savedSearchTerm_;
    //NSInteger       savedScopeButtonIndex_;
    //BOOL            searchWasActive_;
    
    //NSManagedObjectContext *managedObjectContext_;
    UITableViewCell *eventCell;
    UISearchBar *search;
    UISearchDisplayController *mySearchDisplayController;
    IBOutlet UINavigationController*  myNavigationController;
    UISegmentedControl *segmented;
    
    BOOL downloadExternalDataWasUnsucceseful;
    int downloadAttempts;

    UILabel *updateResult;
    UITextView *updateResultText;

    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    DownloadExternalData *download;

}

@property (nonatomic, assign) IBOutlet UITableViewCell *eventCell;
@property (nonatomic, retain) IBOutlet UISearchBar *search;
@property (nonatomic, retain) IBOutlet UISearchDisplayController *mySearchDisplayController;

@property (nonatomic, retain) UILabel *updateResult;
@property (nonatomic, retain) UITextView *updateResultText;

@property (nonatomic, retain) UISegmentedControl *segmented;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;
//@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (readwrite) BOOL downloadExternalDataWasUnsucceseful;
@property (readwrite) int downloadAttempts;

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) DownloadExternalData *download;


- (void)showEvent:(NSManagedObject *)event animated:(BOOL)animated;
//- (void)configureCell:(EventsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;
- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;
- (void)fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath forTableView:(UITableView *)tableView;
- (void) updateExternalData;

@end

@interface EventsTableViewController ()
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *searchFetchedResultsController;
//@property (nonatomic, retain) UISearchDisplayController *mySearchDisplayController;

@end