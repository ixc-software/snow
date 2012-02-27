//
//  SectionHeaderView.h
//  snow
//
//  Created by Oleksii Vynogradov on 14.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CountrySpecificCodeList.h"


@protocol SectionHeaderViewDelegate;


@interface AddRoutesHeaderView : UIView {
@private
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIButton *disclosureButton;
@property (nonatomic, retain) NSManagedObjectID *objectID;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSString *sectionName;

@property (nonatomic) BOOL opened;

@property (nonatomic, assign) id <SectionHeaderViewDelegate> delegate;


-(id)initWithFrame:(CGRect)frame
          objectID:(NSManagedObjectID *)_objectID 
           section:(NSInteger)sectionNumber
       sectionName:(NSString *)_sectionName
            opened:(BOOL)_opened
          delegate:(id <SectionHeaderViewDelegate>)aDelegate ;

-(void)toggleOpenWithUserAction:(BOOL)userAction;


@end

/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
@protocol SectionHeaderViewDelegate <NSObject>

@optional
-(void)sectionHeaderView:(AddRoutesHeaderView*)sectionHeaderView 
           sectionOpened:(NSInteger)section;
-(void)sectionHeaderView:(AddRoutesHeaderView*)sectionHeaderView 
           sectionClosed:(NSInteger)section;

@end
