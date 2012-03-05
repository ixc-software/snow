//
//  DestinationPushListHeaderView.h
//  snow
//
//  Created by Oleksii Vynogradov on 30.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DestinationsListPushList.h"

@protocol DestinationPushListHeaderViewDelegate;


@interface DestinationPushListHeaderView : UIView {
    
    
}

@property (nonatomic, retain) UILabel *country;
@property (nonatomic, retain) UILabel *specific;
@property (nonatomic, retain) UILabel *rate;
@property (nonatomic, retain) UILabel *lastUsedMinutesLenght;
@property (nonatomic, retain) UILabel *lastUsedACD;



@property (nonatomic, retain) UIButton *disclosureButton;
//@property (nonatomic, assign) DestinationsListPushList *object;
@property (nonatomic, retain) NSManagedObjectID *objectID;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) BOOL isOpened;
@property (nonatomic, assign) id <DestinationPushListHeaderViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame 
       withCountry:(NSString *)countryForHeader 
      withSpecific:(NSString *)specificForHeader 
         withPrice:(NSNumber *)price 
       withMinutes:(NSNumber *)minutes 
           withACD:(NSNumber *)acd 
      withObjectID:(NSManagedObjectID *)objectIDexternal 
           section:(NSInteger)sectionNumber 
          isOpened:(NSNumber *)isOpenedForHeader 
          delegate:(id <DestinationPushListHeaderViewDelegate>)aDelegate ;

-(void)toggleOpenWithUserAction:(BOOL)userAction;
                   //withLocation:(CGPoint)location;


@end

@protocol DestinationPushListHeaderViewDelegate <NSObject>

@optional
-(void)sectionHeaderView:(DestinationPushListHeaderView*)sectionHeaderView 
           sectionOpened:(NSInteger)sectionOpened;
-(void)sectionHeaderView:(DestinationPushListHeaderView*)sectionHeaderView 
           sectionClosed:(NSInteger)sectionClosed;
-(void) sectionOpenTodgeStatus;

-(UITableView *)currentTableView;

@end
