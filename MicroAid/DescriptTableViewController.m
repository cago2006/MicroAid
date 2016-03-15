//
//  DescriptTableViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 16/3/15.
//  Copyright © 2016年 Strikingly. All rights reserved.
//

#import "DescriptTableViewController.h"
#import "AddTagViewController.h"

@interface DescriptTableViewController ()

@end

@implementation DescriptTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    
    //可编辑
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
    
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
    [self getAllFacilities];
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
    return cell;
}

-(void)getAllFacilities{
    self.dataArray = [NSMutableArray new];
    self.allFacilities = @"无障碍厕所;无障碍坡道;无障碍电梯;无障碍停车场";
    self.allFacilities = [self.allFacilities substringToIndex:[self.allFacilities length]];
    NSArray *list = [self.allFacilities componentsSeparatedByString:@";"];
    [self.dataArray addObjectsFromArray:list];
    
    list = [self.hasFacilities componentsSeparatedByString:@";"];
    for(int i = 0; i< list.count; i++){
        for(int j = 0; j<self.dataArray.count; j++){
            if([[list objectAtIndex:i] isEqualToString:[self.dataArray objectAtIndex:j]]){
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:j inSection:0];
                [self.tableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
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
            choosed = [choosed stringByAppendingString:@";"];
        }
        
        NSLog(@"AddTagchoice:%@",choosed);
        
        AddTagViewController *addTagVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        addTagVC.descriptString = choosed;
        
        [self.navigationController popToViewController:addTagVC animated:YES];
        
    }
    else
    {
        [ProgressHUD showError:@"请至少选择一项"];
    }
}


@end
