//
//  RoutesTableViewController.h
//  snow
//
//  Created by Oleksii Vynogradov on 14.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRoutesHeaderView.h"
#import <MessageUI/MessageUI.h>
#import "DestinationsListViewController.h"
#import "CompanyStuff.h"
//#import "UserDataController.h"

@class DestinationsListViewController;
@class SpecificCodesCell;

@interface AddRoutesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, MFMailComposeViewControllerDelegate,UISearchDisplayDelegate,UISearchBarDelegate,SectionHeaderViewDelegate> {
@private
    //UISearchDisplayController *mySearchDisplayController;
    UISearchBar *bar;
    //NSFetchedResultsController *fetchResultController;
    NSFetchedResultsController *fetchResultControllerSearch;
    //BOOL searchIsActive;
    //BOOL routeAddIsActive;
    DestinationsListViewController *destinationsPushListView;
    //UIButton *home;
    //CompanyStuff *stuff;
}

//@property (nonatomic, retain) NSMutableArray *countriesForSections;
//@property (nonatomic, retain) NSMutableString *previousSearchString;


@property (nonatomic, retain) DestinationsListViewController *destinationsPushListView;
//@property (nonatomic, retain) UserDataController *userController;
@property (nonatomic, retain) UISegmentedControl *routesList;


@property (nonatomic, assign) IBOutlet SpecificCodesCell *quoteCell;
//@property (nonatomic, retain) IBOutlet UISearchDisplayController *mySearchDisplayController;
@property (nonatomic, retain) IBOutlet UISearchBar *bar;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, retain) NSFetchedResultsController *fetchResultControllerSearch;
//@property (readwrite) BOOL searchIsActive;
//@property (readwrite) BOOL routeAddIsActive;
//@property (nonatomic, retain) UIButton *home;
//@property (nonatomic, retain) CompanyStuff *stuff;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView;

@end
