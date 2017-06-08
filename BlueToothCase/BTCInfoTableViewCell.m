//
//  BTCInfoTableViewCell.m
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/4/24.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import "BTCInfoTableViewCell.h"
#import "PureLayout.h"

@interface BTCInfoTableViewCell ()
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@end

@implementation BTCInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.leftLabel = [UILabel newAutoLayoutView];
        [self.contentView addSubview:self.leftLabel];
        
        self.leftLabel.text = @"设备ID";
        [self.leftLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20.0];
        [self.leftLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        self.rightLabel = [UILabel newAutoLayoutView];
        [self.contentView addSubview:self.rightLabel];
        self.rightLabel.text = @"正在获取...";
        [self.rightLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10.0f];
        [self.rightLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        self.rightLabel.font = [UIFont systemFontOfSize:14];
        self.rightLabel.textColor = [UIColor darkGrayColor];
        
    }
    return self;
}

- (void)setLeftString:(NSString *)leftString {
    self.leftLabel.text = leftString;
}

- (void)setRightString:(NSString *)rightString {
    _rightString = rightString;
    self.rightLabel.text = rightString;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
