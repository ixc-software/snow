//
//  DestinationsListPushListTableViewController.h
//  snow
//
//  Created by Oleksii Vynogradov on 26.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AddRoutesTableViewController.h"
#import "DestinationPushListHeaderView.h"
//#import "UserDataController.h"
//#import "DestinationsPushListCell.h"
#import "DestinationsPushListCell.h"
//#import "AVSearchBar.h"

@class AddRoutesTableViewController;
//@class DestinationsPushListCell;


@interface DestinationsListPushListTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate,UISearchDisplayDelegate,UISearchBarDelegate,DestinationPushListHeaderViewDelegate,UIActionSheetDelegate,DestinationsPushListTableViewDelegate> 
{
@private
    UISearchDisplayController *mySearchDisplayController;
    UISearchBar *bar;
    //NSFetchedResultsController *fetchResultController;
    NSFetchedResultsController *fetchResultControllerSearch;
    BOOL searchIsActive;
    BOOL isDeleteOperation;
    NSIndexSet *forDeleteOperation;
    AddRoutesTableViewController *addRoutesView;
    DestinationsPushListCell *destinationCell;
    UINavigationController *addRoutesNavigationView;
    UIButton *home;
    NSString        *savedSearchTerm;
    BOOL            searchWasActive;
    NSMutableArray *changedDestinationsIDs;
    NSMutableIndexSet *sections;
    
}
@property (nonatomic, retain) NSManagedObjectID *selectedCarrierID;

@property (retain) NSMutableIndexSet *sections;

@property (nonatomic, retain) IBOutlet UIToolbar *deleteAlert;

@property (nonatomic, retain) IBOutlet UIView *deleteAlertView;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

@property (nonatomic) BOOL isControllerStartedFromOutsideTabbar;

//@property (nonatomic, retain) UserDataController *userController;

@property (nonatomic, retain) IBOutlet UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *bar;
@property (nonatomic, retain) IBOutlet DestinationsPushListCell *destinationCell;
@property (nonatomic, retain) UIButton *home;
@property (nonatomic, retain) UISegmentedControl *addRoutes;
@property (nonatomic, retain) UISegmentedControl *selectRoutes;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *fetchResultControllerSearch;
@property (readwrite) BOOL searchIsActive;
@property (readwrite) BOOL isDeleteOperation;
@property (nonatomic, retain) AddRoutesTableViewController *addRoutesView;
@property (nonatomic, retain) UINavigationController *addRoutesNavigationView;
@property (nonatomic, retain) NSIndexSet *forDeleteOperation;
@property (readwrite) BOOL isOpenCloseSection;

@property (nonatomic, retain) UIBarButtonItem *item;
@property (nonatomic, retain) UISegmentedControl *alert;
//@property (retain, nonatomic) IBOutlet UITableView *tableViewMain;
@property (retain, nonatomic) UIActivityIndicatorView *desinationsUpdateProgress;


@end

