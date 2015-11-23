//
//  SearchTableViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/11/22.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import "SearchTableViewController.h"

@interface SearchTableViewController ()

@end

@implementation SearchTableViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
- (id)initWithStyle:(UITableViewStyle)style superView:(UIViewController *)home
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.superView = home;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [[UIColor blackColor] CGColor];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.recordArray = [userDefaults arrayForKey:@"recordArray"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 返回列表框的下拉列表的数量
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.recordArray = [userDefaults arrayForKey:@"recordArray"];
    return self.recordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [self.recordArray objectAtIndex:row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//点击显示具体信息，首先进行判断
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    //改变array中的顺序，保存
    self.passValueDelegate = _superView;
    [self.passValueDelegate passItemValue:[self.recordArray objectAtIndex:row]];
}


@end
