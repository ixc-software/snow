//
//  CarrierListConroller.h
//  snow
//
//  Created by Oleksii Vynogradov on 14.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarrierListTableViewCell.h"

@interface CarrierListConroller : UITableViewController <NSFetchedResultsControllerDelegate,CarrierListTableViewDelegate,UITableViewDataSource,UITableViewDataSource,UISearchBarDelegate>
{
    IBOutlet CarrierListTableViewCell *cell;
}
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet CarrierListTableViewCell *cell;


@end
