//
//  DestinationsHeaderView.m
//  snow
//
//  Created by Oleksii Vynogradov on 3/23/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "DestinationsHeaderView.h"
#import "mobileAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation DestinationsHeaderView
@synthesize view;
@synthesize country,specific,rate,delegate,section,disclosureButton,isOpened,objectID,lastUsedACD,lastUsedMinutesLenght,testingButton;
+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

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
{
    self = [super initWithFrame:frame];
    if (self) {
        // testing flow:
        // 0 - no tests
        // 1 - processed
        // 3 - result failed no success calls
        // 4 - result faile FAS
        // >> 4 - result success, mean ASR 

        // Initialization code
        mobileAppDelegate *delegateMain = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
        if ([delegateMain isPad]) [[NSBundle mainBundle] loadNibNamed:@"DestinationsHeaderViewIPad" owner:self options:nil];
        else [[NSBundle mainBundle] loadNibNamed:@"DestinationsHeaderView" owner:self options:nil];       
        [self addSubview:self.view];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void) awakeFromNib
{
    [super awakeFromNib];
    
    mobileAppDelegate *delegateMain = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegateMain isPad]) [[NSBundle mainBundle] loadNibNamed:@"DestinationsHeaderViewIPad" owner:self options:nil];
    else [[NSBundle mainBundle] loadNibNamed:@"DestinationsHeaderView" owner:self options:nil];       
    [self addSubview:self.view];
}

- (void)dealloc {
    [view release];

    [super dealloc];
}
@end
