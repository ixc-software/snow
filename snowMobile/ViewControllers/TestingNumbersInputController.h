//
//  TestingNumbersInputController.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/26/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestingNumbersInputController : UIViewController
@property (nonatomic, retain) NSManagedObject *destination;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMoc:(NSManagedObjectContext *)moc withDestinationMain:(NSManagedObject *)destinationMain;
@property (retain, nonatomic) IBOutlet UILabel *countrySpecific;
@property (retain, nonatomic) IBOutlet UITextView *codes;
@property (retain, nonatomic) IBOutlet UISegmentedControl *addNumber;
@property (retain, nonatomic) IBOutlet UITextField *phoneNumber;
@property (retain, nonatomic) NSMutableArray *allNumbers;

@end
