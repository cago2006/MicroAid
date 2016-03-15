//
//  FreeTypeTableViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import "FreeTypeTableViewController.h"
#import "AddTagViewController.h"

@interface FreeTypeTableViewController ()

@end

@implementation FreeTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    //可编辑
    //self.tableView.allowsMultipleSelectionDuringEditing = YES;
    //[self.tableView setEditing:YES animated:YES];
    
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,500,40,40)];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(returnToAddTag) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationItem setTitle:@"能提供的帮助"];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //处理self.hasFacilities;
    [self getAllTypes];
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
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure a cell to show the corresponding string from the array.
    static NSString *kCellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
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

-(void)getAllTypes{
    self.dataArray = [NSMutableArray new];
    self.allTypes = @"餐厅;医院;酒店;厕所;学校;地铁站;办公楼;公交站;机场;火车站;其他;";
    self.allTypes = [self.allTypes substringToIndex:[self.allTypes length]];
    NSArray *list = [self.allTypes componentsSeparatedByString:@";"];
    [self.dataArray addObjectsFromArray:list];
    
    for(int j = 0; j<self.dataArray.count; j++){
        if([self.typeString isEqualToString:[self.dataArray objectAtIndex:j]]){
            self.choosedIndex = [NSIndexPath indexPathForRow:j inSection:0];
            break;
        }
    }
}

-(void)returnToAddTag{
    // Delete what the user selected.
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
            choosed = [choosed stringByAppendingString:[self.dataArray objectAtIndex:selectionIndex.row]];
        }
        
        NSLog(@"AddTagchoice:%@",choosed);
        
        AddTagViewController *addTagVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        addTagVC.typeString = choosed;
        
        [self.navigationController popToViewController:addTagVC animated:YES];
        
    }
    else
    {
        [ProgressHUD showError:@"请选择一项"];
    }
}



@end
