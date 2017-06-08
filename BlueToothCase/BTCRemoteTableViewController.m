//
//  BTCRemoteTableViewController.m
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/5/5.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import "BTCRemoteTableViewController.h"
#import "PureLayout.h"
#import "BTCSwitchTableViewCell.h"
#import "BTCInfoTableViewCell.h"
#import "UIImage+ZBAdd.h"
#import "XMNetworking.h"
#import "BTCStateObject.h"
#import "BTCMapViewController.h"

static NSInteger const SECTION_SWITCH = 1;

static NSInteger const ROW_SWITCH = 0;
static NSInteger const ROW_ALERT = 1;

@interface BTCRemoteTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BTCStateObject *stateObject;
@end

@implementation BTCRemoteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"远程控制"];
    self.view.backgroundColor = [UIColor whiteColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Package"] wzb_imageByResizeToSize:CGSizeMake(160, 200)]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    [_imageView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [_imageView autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [_imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    // 界面
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    //    self.tableView.alpha = 0;
    [self.tableView registerClass:[BTCSwitchTableViewCell class] forCellReuseIdentifier:@"switch"];
    [self.tableView registerClass:[BTCInfoTableViewCell class] forCellReuseIdentifier:@"info"];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"地图" style:UIBarButtonItemStylePlain target:self action:@selector(showMap)];
}

- (void)showMap {
    if (self.stateObject == nil) return;
    BTCMapViewController *vc = [[BTCMapViewController alloc] initWithObject:self.stateObject];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
        request.api = @"app/getlaststate/";
        request.httpMethod = kXMHTTPMethodGET;
        request.parameters = @{@"device":@"047863A004A2"};
    } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"获取最后一条消息: %@", responseObject);
        self.stateObject = [BTCStateObject mj_objectWithKeyValues:[responseObject objectForKey:@"data"]];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == SECTION_SWITCH ? 1 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_SWITCH) {
        BTCSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"switch"];
        cell.type = indexPath.row == 0 ? SwitchTypeStatus : SwitchTypeProtect;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell configureSwitchMode:[self.stateObject.latch_switch isEqualToString:@"1"] ? YES: NO];
        [cell addSwitchHandler:^(UISwitch *theSwitch) {
            if (indexPath.row == ROW_SWITCH) {
                [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
                    request.api = @"app/sendcommand/";
                    request.httpMethod = kXMHTTPMethodPOST;
                    request.parameters = @{@"device":@"047863A004A2",
                                           @"latch_switch": theSwitch.isOn != YES ? @"false": @"true"};
                } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
                    NSLog(@"发送指令:%@", responseObject);
                    NSLog(@"发送指令失败: %@", error.localizedDescription);
                }];
            }
        }];
        return cell;
    } else {
        BTCInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"info"];
        if (indexPath.row == 1) {
            cell.leftString = @"设备ID";
            cell.rightString = @"047863A004A2";
            
        } else if (indexPath.row == 2) {
            cell.leftString = @"经度";
            cell.rightString = self.stateObject.longitude;
        } else  if (indexPath.row == 3){
            cell.leftString = @"纬度";
            cell.rightString = self.stateObject.latitude;
        } else {
            cell.leftString = @"设备状态";
            cell.rightString = [self.stateObject.case_lost isEqualToString:@"1"] ? @"丢失" : @"正常";
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
