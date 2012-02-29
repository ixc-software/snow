//
//  DestinationsListViewController.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/28/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DestinationPushListHeaderView.h"
#import "AddRoutesTableViewController.h"
#import <MessageUI/MessageUI.h>

#import "DestinationsPushListCell.h"


@class AddRoutesTableViewController;

@interface DestinationsListViewController : UIViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate, UISearchBarDelegate,  DestinationPushListHeaderViewDelegate,UIActionSheetDelegate,DestinationsPushListTableViewDelegate>
{
    NSMutableArray *changedDestinationsIDs;

}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSManagedObjectID *selectedCarrierID;

@property (retain) NSMutableIndexSet *sections;

@property (nonatomic, retain) IBOutlet UIToolbar *deleteAlert;

@property (nonatomic, retain) IBOutlet UIView *deleteAlertView;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

@property (nonatomic) BOOL isControllerStartedFromOutsideTabbar;

//@property (nonatomic, retain) UserDataController *userController;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *bar;
@property (nonatomic, retain) IBOutlet DestinationsPushListCell *destinationCell;
@property (nonatomic, retain) UIButton *home;
@property (nonatomic, retain) UISegmentedControl *addRoutes;
@property (nonatomic, retain) UISegmentedControl *selectRoutes;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchedResultsController *fetchResultControllerSearch;
@property (readwrite) BOOL searchIsActive;
@property (readwrite) BOOL isDeleteOperation;
@property (nonatomic, retain) AddRoutesTableViewController *addRoutesView;
@property (nonatomic, retain) UINavigationController *addRoutesNavigationView;
@property (nonatomic, retain) NSIndexSet *forDeleteOperation;
@property (readwrite) BOOL isOpenCloseSection;

@property (nonatomic, retain) UIBarButtonItem *item;
//@property (nonatomic, retain) UISegmentedControl *alert;
//@property (retain, nonatomic) IBOutlet UITableView *tableViewMain;
@property (retain, nonatomic) UIActivityIndicatorView *desinationsUpdateProgress;

// update progress view:
@property (retain, nonatomic) IBOutlet UIView *progressView;
@property (retain, nonatomic) IBOutlet UIProgressView *carriersProgress;
@property (retain, nonatomic) IBOutlet UILabel *carriersProgressTitle;
@property (retain, nonatomic) IBOutlet UILabel *operationTitle;
@property (retain, nonatomic) IBOutlet UIProgressView *operationProgress;


@property (readwrite) BOOL isRoutesWeBuyListUpdated;
@property (readwrite) BOOL isRoutesForSaleListUpdated;
@property (readwrite) BOOL isRoutesPushlistListUpdated;
@property (retain, nonatomic) IBOutlet UIButton *cancelAllUpdatesButton;

@end
