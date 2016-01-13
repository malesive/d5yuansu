//
//  HomeCell.h
//  D5大生活
//
//  Created by daizhouliang@mac on 15/12/21.
//  Copyright (c) 2015年 June801. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (strong, nonatomic) NSString *urlString;
@property (assign, nonatomic) NSInteger leftMenuSelectIndex;
@end
