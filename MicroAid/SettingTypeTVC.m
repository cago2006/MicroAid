//
//  SettingTypeTVC.m
//  MicroAid
//
//  Created by jiahuaxu on 15/12/3.
//  Copyright © 2015年 Strikingly. All rights reserved.
//

#import "SettingTypeTVC.h"
#import "MySettingViewController.h"

@interface SettingTypeTVC ()

@end

@implementation SettingTypeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,500,40,40)];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(returnToSetting) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:Localized(@"确定") forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationItem setTitle:Localized(@"设置默认类型")];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //初始化选中的项目
    for(int j = 0; j<self.dataArray.count; j++){
        if([self.typeString isEqualToString:Localized([self.dataArray objectAtIndex:j])]){
            self.choosedIndex = [NSIndexPath indexPathForRow:j inSection:0];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.dataArray = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataArray.count;;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure a cell to show the corresponding string from the array.
    static NSString *kCellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    cell.textLabel.text = Localized([self.dataArray objectAtIndex:indexPath.row]);
    if([indexPath isEqual: self.choosedIndex])cell.accessoryType = UITableViewCellAccessoryCheckmark;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    self.choosedIndex = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    //将其它cell的勾取消
    for(int j = 0; j<self.dataArray.count; j++){
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:j inSection:0];
        if(![self.choosedIndex isEqual:indexpath]){
            UITableViewCell *cell2 = [tableView cellForRowAtIndexPath:indexpath];
            cell2.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

-(void) returnToSetting{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    BOOL deleteSpecificRows = selectedRows.count > 0;
    if (deleteSpecificRows)
    {
        // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
        NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
        for (NSIndexPath *selectionIndex in selectedRows)
        {
            [indicesOfItemsToDelete addIndex:selectionIndex.row];
        }
        
        
        NSString *choosed = [[NSString alloc]init];
        for (NSIndexPath *selectionIndex in selectedRows){
            choosed = [self.dataArray objectAtIndex:selectionIndex.row];
        }
        
        
        MySettingViewController *mySettingVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        mySettingVC.missionType = Localized(choosed);
        
        [self.navigationController popToViewController:mySettingVC animated:YES];
        
    }
    else if(self.choosedIndex == nil || [self.choosedIndex isEqual:@""])
    {
        [ProgressHUD showError:Localized(@"请选择一项")];
    }else{
        NSString *choosed = [self.dataArray objectAtIndex:self.choosedIndex.row];
        MySettingViewController *mySettingVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        mySettingVC.missionType = Localized(choosed);
        
        [self.navigationController popToViewController:mySettingVC animated:YES];
    }
}

@end
