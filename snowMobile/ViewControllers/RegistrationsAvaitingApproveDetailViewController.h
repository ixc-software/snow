//
//  RegistrationsAvaitingApproveDetailViewController.h
//  snow
//
//  Created by Oleksii Vynogradov on 28.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegistrationsDetailTableViewCell.h"
//#import "UserDataController.h"
#import "CompanyAndUserConfiguration.h"


@interface RegistrationsAvaitingApproveDetailViewController : UITableViewController {
    IBOutlet RegistrationsDetailTableViewCell *cellInfo;

}

@property (nonatomic,retain) NSDictionary *stackRecord;
@property (nonatomic, retain) RegistrationsDetailTableViewCell *cellInfo;
@property (nonatomic, retain) CompanyStuff *stuff;
//@property (nonatomic, retain) UserDataController *userController;
@property (nonatomic, retain) CompanyAndUserConfiguration *companyAndUsedConfiguration;
@property (nonatomic, retain) NSManagedObjectID *operationObjectID;


@end
