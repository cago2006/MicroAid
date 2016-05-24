//
//  ChoiceViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/8/27.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "ChoiceViewController.h"
#import "RegisterViewController.h"

@interface ChoiceViewController ()

@end

@implementation ChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,500,65,65)];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(returnToRegister) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:Localized(@"确定") forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationItem setTitle:Localized(@"能提供的帮助")];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.dataArray = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)passAllChoiceValues:(NSMutableArray *)array choiceStrings:(NSString *)strings{
    //初始化项目
    self.dataArray = [NSMutableArray new];
    self.dataArray = array;
    
    //可编辑
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
    
    //初始化选中的项目
    NSArray *list = [strings componentsSeparatedByString:@","];
    for(int i = 0; i< list.count; i++){
        for(int j = 0; j<self.dataArray.count; j++){
            if([[list objectAtIndex:i] isEqualToString:[self.dataArray objectAtIndex:j]]){
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:j inSection:0];
                [self.tableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)returnToRegister
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
            choosed = [choosed stringByAppendingString:[self.dataArray objectAtIndex:selectionIndex.row]];
            choosed = [choosed stringByAppendingString:@","];
        }
        
        NSLog(@"choice:%@",choosed);
        
        RegisterViewController *registVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        
        self.returnValueDelegate = registVC;
        [self.returnValueDelegate passChoiceValues:choosed];
        
        [self.navigationController popToViewController:registVC animated:YES];
        
    }
    else
    {
        [ProgressHUD showError:Localized(@"请至少选择一项")];
    }
}


@end
