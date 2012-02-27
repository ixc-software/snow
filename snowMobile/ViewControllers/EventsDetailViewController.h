//
//  EventsDetailViewController.h
//  snow
//
//  Created by Alex Vinogradov on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <MessageUI/MessageUI.h>

@interface EventsDetailViewController : UITableViewController <UIActionSheetDelegate,MFMailComposeViewControllerDelegate > {
@private
    NSManagedObject *event;
    NSString *country;
    NSArray *specifics;
    NSArray *specificsStates;
   // RCSwitch *switchState;
    UILabel *switchLabel;
    
    UITableViewCell *resolvedCell;
    //UIButton *resolv;
    //UIButton *addToLocalCalendar;
    UIView *popoverView;
    EKEventStore *eventStore;
    NSDateFormatter *formatter;
}


@property (nonatomic, retain) NSManagedObject *event;
@property (nonatomic, retain) NSArray *specifics;
@property (nonatomic, retain) NSArray *specificsStates;
@property (nonatomic, retain) NSDateFormatter *formatter;

@property (readwrite) BOOL isErrorStillShowing;


@property (nonatomic, retain) NSString *country;
@property (nonatomic, assign) IBOutlet UITableViewCell *resolvedCell;
//@property (nonatomic, assign) IBOutlet RCSwitch *switchState;
@property (nonatomic, assign) IBOutlet UIView *popoverView;
@property (nonatomic, assign) IBOutlet UILabel *switchLabel;


/*@property (nonatomic, retain) UILabel *date;
@property (nonatomic, retain) UILabel *dateAlarm;
@property (nonatomic, retain) UILabel *name;*/
-(IBAction) changeResolveState:(id)sender;


@end
