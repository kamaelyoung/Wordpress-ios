//
//  WPPostCell.h
//  Wordpress
//
//  Created by Evgeniy Yurtaev on 03/01/15.
//  Copyright (c) 2015 Evgeniy Yurtaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WPPostsItemViewModel;

@interface WPPostCell : UITableViewCell

+ (CGFloat)cellHeightWithVewModel:(WPPostsItemViewModel *)viewModel tableView:(UITableView *)tableView;

@property (strong, nonatomic) WPPostsItemViewModel *viewModel;

@end
