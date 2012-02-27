//
//  CompanyAddController.h
//  snow
//
//  Created by Oleksii Vynogradov on 04.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CompanyInfoDetailCell.h"
//#import "UserDataController.h"
#import "CompanyAndUserConfiguration.h"

@class CompanyInfoDetailCell;
@class CompanyStuff;

@interface CompanyAddController : UITableViewController <NSFetchedResultsControllerDelegate,UISearchDisplayDelegate,CompanyInfoDetailCellDelegate> {
    IBOutlet CompanyInfoDetailCell *cellInfo;
    CompanyStuff *stuff;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) CompanyInfoDetailCell *cellInfo;
@property (nonatomic, retain) NSManagedObjectID *stuffID;
//@property (nonatomic, retain) UserDataController *userController;
@property (nonatomic, retain) CompanyAndUserConfiguration *companyAndUserConfiguration;

//-(void) reloadLocalDataFromUserDataController;

@end

