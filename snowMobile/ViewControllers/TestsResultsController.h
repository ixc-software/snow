//
//  TestsResultsController.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestingResultsTableViewCell.h"

@interface TestsResultsController : UIViewController
@property (nonatomic, retain) NSManagedObject *destination;

@property (nonatomic, retain) IBOutlet TestingResultsTableViewCell *resultCell;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
