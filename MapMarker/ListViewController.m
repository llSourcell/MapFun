//
//  ListViewController.m
//  MapMarker
//
//  Created by Siraj Raval on 5/15/15.
//  Copyright (c) 2015 Siraj Raval. All rights reserved.
//

#import "AppConstants.h"
#import "MapViewController.h"
#import "ListViewController.h"
#import "PointTableViewCell.h"
#import "DDPointList.h"


@interface ListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *customNavBar;
@property (nonatomic, strong) DDPointList *pointList;

@end


@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    // custom NavigationBar
    self.customNavBar.layer.borderWidth = 0.5;
    self.customNavBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pointList = [DDPointList sharedPointList];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pointList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:POINT_CELL_ID];
    [cell setupWithPoint:self.pointList.array[indexPath.row]];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tabBarController.selectedIndex = 0;
    MapViewController *mapVC = self.tabBarController.viewControllers[0];
    [mapVC selectAnnotation: self.pointList.array[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.pointList deletePointAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:YES];
    }
}


#pragma mark - Button Actions

- (IBAction)btnClearPressed:(id)sender {
    if (self.pointList.count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pressed"
                                                                       message:@"ВCleared!"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"1" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"2" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self.pointList deleteAllPoints];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                          withRowAnimation:UITableViewRowAnimationFade];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


@end
