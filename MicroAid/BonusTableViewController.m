//
//  BonusTableViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/31.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "BonusTableViewController.h"

@interface BonusTableViewController ()

@end

@implementation BonusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,500,40,40)];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(returnToCreate) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationItem setTitle:@"悬赏金额"];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
}
-(void) passTypeValues:(NSMutableArray *)array choiceString:(NSString *)string{
    
}
-(void) passLocationValues:(NSString *)location latitude:(double)latitude longitude:(double)longitude{
    
}
-(void) passGroupValues:(NSMutableArray *)array choiceString:(NSString *)string{
    
}

-(void) passBonusValues:(NSString *)string{
    //初始化项目
    self.dataArray = [NSMutableArray new];
    self.dataArray = [NSMutableArray arrayWithObjects:@"0分",@"1分",@"2分",@"3分",@"4分",@"5分", nil];
    
    //初始化选中的项目
    for(int j = 0; j<self.dataArray.count; j++){
        if([string isEqualToString:[self.dataArray objectAtIndex:j]]){
            self.choosedIndex = [NSIndexPath indexPathForRow:j inSection:0];
        }
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.dataArray = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure a cell to show the corresponding string from the array.
    static NSString *kCellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
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


- (void)returnToCreate
{
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
            choosed = [self.dataArray objectAtIndex:selectionIndex.row];
        }
        
        
        CreateMissionViewController *cmVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        cmVC.isEditMission = NO;
        self.returnBonusDelegate = cmVC;
        [self.returnBonusDelegate passChoiceBonusValues:choosed];
        
        [self.navigationController popToViewController:cmVC animated:YES];
        
    }
    else if(self.choosedIndex == nil || [self.choosedIndex isEqual:@""])
    {
        [ProgressHUD showError:@"请选择一项"];
    }else{
        NSString *choosed = [[NSString alloc]init];
        choosed = [self.dataArray objectAtIndex:self.choosedIndex.row];
        CreateMissionViewController *cmVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        cmVC.isEditMission = NO;
        
        self.returnBonusDelegate = cmVC;
        [self.returnBonusDelegate passChoiceBonusValues:choosed];
        
        [self.navigationController popToViewController:cmVC animated:YES];
    }
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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
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
