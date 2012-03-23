//
//  DestinationsHeaderView.h
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DestinationsListPushList.h"

@protocol DestinationsHeaderViewDelegate;

@interface DestinationsHeaderView : UIView <UIGestureRecognizerDelegate>
{
    UIView *view;

}
@property (nonatomic, retain) IBOutlet UIView *view;

@property (nonatomic, retain) IBOutlet UILabel *country;
@property (nonatomic, retain) IBOutlet UILabel *specific;
@property (nonatomic, retain) IBOutlet UILabel *rate;
@property (nonatomic, retain) IBOutlet UILabel *lastUsedMinutesLenght;
@property (nonatomic, retain) IBOutlet UILabel *lastUsedACD;



@property (nonatomic, retain) IBOutlet UIButton *disclosureButton;
@property (nonatomic, retain) IBOutlet UIButton *testingButton;
@property (retain, nonatomic) IBOutlet UILabel *testingResults;
@property (retain, nonatomic) IBOutlet UILabel *testingTitle;

//@property (nonatomic, assign) DestinationsListPushList *object;
@property (nonatomic, retain) NSManagedObjectID *objectID;

@property (nonatomic, assign) NSUInteger section;
@property (nonatomic, assign) BOOL isOpened;
@property (nonatomic, assign) id <DestinationsHeaderViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame 
       withCountry:(NSString *)countryForHeader 
      withSpecific:(NSString *)specificForHeader 
         withPrice:(NSNumber *)price 
       withMinutes:(NSNumber *)minutes 
           withACD:(NSNumber *)acd 
      withObjectID:(NSManagedObjectID *)objectIDexternal 
           section:(NSUInteger)sectionNumber 
          isOpened:(BOOL)isOpenedForHeader
          delegate:(id <DestinationsHeaderViewDelegate>)aDelegate
isDestinationsPushList:(BOOL)isDestinationsPushListEntity
           testing:(NSUInteger)testingFlow; 

-(void)toggleOpenWithUserAction:(BOOL)userAction;
//withLocation:(CGPoint)location;


@end

@protocol DestinationsHeaderViewDelegate <NSObject>

@optional
-(void)sectionHeaderView:(DestinationsHeaderView *)sectionHeaderView 
           sectionOpened:(NSUInteger)sectionOpened;
-(void)sectionHeaderView:(DestinationsHeaderView *)sectionHeaderView 
           sectionClosed:(NSUInteger)sectionClosed;
-(void)sectionHeaderView:(DestinationsHeaderView *)sectionHeaderView 
      openTestingResults:(NSUInteger)sectionTestingResults;

-(void) sectionOpenTodgeStatus;

-(UITableView *)currentTableView;

@end
