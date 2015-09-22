//
//  MyMissionsViewController.m
//  MicroAid
//
//  Created by jiahuaxu on 15/9/21.
//  Copyright (c) 2015年 Strikingly. All rights reserved.
//

#import "MyMissionsViewController.h"
#import "FinishedMissionsViewController.h"
#import "StartedMissionsViewController.h"
#import "ClaimedMissionsViewController.h"

@interface MyMissionsViewController ()

@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) NSArray *controllers;

@property (nonatomic, strong) NSMutableArray *tabs;

@property (nonatomic) float statusHeight;

@property (nonatomic, strong) UIView *indicatorView;

@end

@implementation MyMissionsViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        FinishedMissionsViewController *finishedMissionsVC = [[FinishedMissionsViewController alloc] initWithNibName:@"FinishedMissionsViewController" bundle:nil];
        [finishedMissionsVC setTitle:@"已完成"];
        
        StartedMissionsViewController *startedMissionsVC = [[StartedMissionsViewController alloc] initWithNibName:@"StartedMissionsViewController" bundle:nil];
        [startedMissionsVC setTitle:@"已发起"];
        
        ClaimedMissionsViewController *claimedMissionsVC = [[ClaimedMissionsViewController alloc] initWithNibName:@"ClaimedMissionsViewController" bundle:nil];
        [claimedMissionsVC setTitle:@"已认领"];
        
        _controllers =[[NSArray alloc]initWithObjects:startedMissionsVC, claimedMissionsVC,finishedMissionsVC,  nil];
    
        selectedTab = NSIntegerMax;
        _delegate = nil;
        _indicatorView = [[UIView alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
    [self.navigationItem setTitle:@"我的任务"];
    
    self.view.backgroundColor = [UIColor whiteColor];//tab颜色
    _indicatorView.backgroundColor= [UIColor orangeColor];//游标的颜色
    _statusHeight = 0.0;
    if (_controllers != nil)
    {
        [self loadUI];
    }
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillLayoutSubviews
{
    
    _contentScrollView.frame = CGRectMake(0.0,
                                          _menuHeight + _statusHeight,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height-_menuHeight);
    
    for (int i=0; i < [_controllers count]; i++)
    {
        // Create content view
        UIViewController *controller = [_controllers objectAtIndex:i];
        
        [[controller view] setFrame:CGRectMake(i * _contentScrollView.frame.size.width,
                                               0.0,
                                               _contentScrollView.frame.size.width,
                                               _contentScrollView.frame.size.height)];
    }
    
    [_contentScrollView setContentSize:CGSizeMake(self.view.frame.size.width * [_controllers count], self.view.frame.size.height - _menuHeight - _statusHeight)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)loadUI
{
    _menuHeight = 40.0;
    
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0,_menuHeight + _statusHeight,
                                                                        self.view.frame.size.width,
                                                                        self.view.frame.size.height - _menuHeight -_statusHeight)];
    [_contentScrollView setShowsHorizontalScrollIndicator:NO];
    [_contentScrollView setShowsVerticalScrollIndicator:NO];
    [_contentScrollView setPagingEnabled:YES];
    [_contentScrollView setDelegate:self];
    _contentScrollView.bounces = NO;
    
    float tabWidth = self.view.frame.size.width / [_controllers count];
    
    _tabs = [[NSMutableArray alloc] init];
    for (int i=0; i < [_controllers count]; i++)
    {
        // Create content view
        UIViewController *controller = [_controllers objectAtIndex:i];
        
        [[controller view] setFrame:CGRectMake(i * _contentScrollView.frame.size.width,
                                               0.0,
                                               _contentScrollView.frame.size.width,
                                               _contentScrollView.frame.size.height)];
        [_contentScrollView addSubview:[controller view]];
        
        // Create button
        UIButton *tab = [[UIButton alloc] initWithFrame:CGRectMake(i * tabWidth, _statusHeight, tabWidth, _menuHeight)];
        [tab setTitle:controller.title forState:UIControlStateNormal];
        [tab setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tab addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:tab];
        [_tabs addObject:tab];
        
        // Add separator
        if( i>0 )
        {
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(i*tabWidth,
                                                                   10 + _statusHeight,
                                                                   1,
                                                                   20)];
            [sep setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1.0]];
            [self.view addSubview:sep];
        }
    }
    
    UIButton *tab = [_tabs objectAtIndex:0];
    [tab setSelected:YES];
    selectedTab = 0;
    _indicatorView.frame = CGRectMake(0.0, _menuHeight + _statusHeight - 5.0, tabWidth, 5.0);
    [self.view addSubview:_indicatorView];
    
    UIView *bottomHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0.0, _menuHeight + _statusHeight - 1.0, self.view.frame.size.width, 1.0)];
    bottomHeaderView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:bottomHeaderView];
    
    [self.view addSubview:_contentScrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = scrollView.frame.size.width;
    int page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    float tabWidth = _indicatorView.frame.size.width;
    _indicatorView.frame = CGRectMake(page * tabWidth, _menuHeight + _statusHeight - 5.0, tabWidth, 5.0);
    [self deselectAllTabs];
    UIButton *tab = [_tabs objectAtIndex:page];
    [tab setSelected:YES];
}

- (void)selectTab:(id)sender
{
    selectedTab = [_tabs indexOfObject:sender];
    CGRect rect = CGRectMake(self.view.frame.size.width * selectedTab,
                             0.0,
                             self.view.frame.size.width,
                             10.0);
                             //_contentScrollView.contentSize.height);
    [_contentScrollView scrollRectToVisible:rect animated:YES];
    [self deselectAllTabs];
    [sender setSelected:YES];
    
    if(_delegate && [_delegate respondsToSelector:@selector(currentTabHasChanged:)] )
    {
        [_delegate currentTabHasChanged:selectedTab];
    }
}

- (void)deselectAllTabs
{
    for (UIButton *tab in _tabs)
    {
        [tab setSelected:NO];
        [tab setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)selectTabNum:(NSInteger)index
{
    if(index<0 || index>=[_tabs count])
    {
        return;
    }
    UIButton *tab = [_tabs objectAtIndex:index];
    [self selectTab:tab];
}

- (NSInteger)selectedTab
{
    return selectedTab;
}

@end
