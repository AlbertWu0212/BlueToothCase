//
//  BTCSwitchTableViewCell.m
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/4/14.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import "BTCSwitchTableViewCell.h"
#import "PureLayout.h"
#import <objc/runtime.h>

static const void *switchCellBlockKey = &switchCellBlockKey;

@interface BTCSwitchTableViewCell ()
@property (nonatomic, strong) UISwitch *s;
//@property (nonatomic, strong) UILabel *label;
@end

@implementation BTCSwitchTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.s = [UISwitch newAutoLayoutView];
        [self.contentView addSubview:self.s];
        
        [_s autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_s autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:15.0f];

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setType:(SwitchType)type {
    switch (type) {
        case SwitchTypeStatus:
            self.textLabel.text = @"箱包开关";
            break;
        case SwitchTypeProtect:
            self.textLabel.text = @"设备布防";
            break;
    }
}

- (void)addSwitchHandler:(CellSwitchBlock)handler {
    objc_setAssociatedObject(self, switchCellBlockKey, handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self.s addTarget:self action:@selector(blockActionValueChanged:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)blockActionValueChanged:(UISwitch *)s {
    CellSwitchBlock block = objc_getAssociatedObject(self, switchCellBlockKey);
    if (block) {
        block(s);
    }
}

- (void)configureSwitchMode:(BOOL)isOn {
    [self.s setOn:isOn animated:YES];
}

- (void)configureSwitchEnabled:(BOOL)isOn {
    [self.s setUserInteractionEnabled:isOn];
}
@end
