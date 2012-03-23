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

@interface DestinationsHeaderView : UIView
{
    UIView *view;

}
@property (nonatomic, retain) IBOutlet UIView *view;

@property (nonatomic, retain) UILabel *country;
@property (nonatomic, retain) UILabel *specific;
@property (nonatomic, retain) UILabel *rate;
@property (nonatomic, retain) UILabel *lastUsedMinutesLenght;
@property (nonatomic, retain) UILabel *lastUsedACD;



@property (nonatomic, retain) UIButton *disclosureButton;
@property (nonatomic, retain) UIButton *testingButton;

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
-(void) sectionOpenTodgeStatus;

-(UITableView *)currentTableView;

@end
