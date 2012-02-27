//
//  CompanyAndUserConfiguration.h
//  snow
//
//  Created by Oleksii Vynogradov on 02.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "CompanyAndUserInfoCell.h"

@class InfoViewController;
@class CompanyAndUserInfoCell;
@class CompanyStuff;


@interface CompanyAndUserConfiguration : UITableViewController <CompanyAndUserInfoCellDelegate,NSFetchedResultsControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate> {
    InfoViewController *infoController;
    IBOutlet CompanyAndUserInfoCell *cellInfo;
    //CompanyStuff *stuff;
    NSManagedObjectID *stuffID;
    
}
@property (readwrite)  BOOL isEditedCarriers;
@property (readwrite)  BOOL isUpdatingCarriers;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) InfoViewController *infoController;
@property (nonatomic, retain) CompanyAndUserInfoCell *cellInfo;
//@property (nonatomic, retain) CompanyStuff *stuff;
@property (nonatomic, retain) NSManagedObjectID *stuffID;

//@property (nonatomic, retain) UserDataController *userController;
@property (readwrite) BOOL isEditingNow;



@end
