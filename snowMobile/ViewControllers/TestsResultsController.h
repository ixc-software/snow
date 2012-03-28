//
//  TestsResultsController.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestingResultsTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface TestsResultsController : UIViewController <NSFetchedResultsControllerDelegate,AVAudioPlayerDelegate>
@property (nonatomic, retain) NSManagedObject *destination;
@property (nonatomic, retain) AVAudioPlayer *player;

@property (nonatomic, retain) IBOutlet TestingResultsTableViewCell *resultCell;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withMoc:(NSManagedObjectContext *)moc withDestinationMain:(NSManagedObject *)destinationMain;

- (IBAction)playRingForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)stopPlayRingForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)playCallForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)stopPlayCallForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)unmarkAsFasForIndexPath:(NSIndexPath *)indexPath;
- (IBAction)markAsFasForIndexPath:(NSIndexPath *)indexPath;

@end
