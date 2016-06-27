//
//  ContinueButtonExampleViewController.m
//  ORKTest
//
//  Created by Shannon Young on 6/27/16.
//  Copyright © 2016 ResearchKit. All rights reserved.
//

#import "ContinueButtonExampleViewController.h"
#import "FooterView.h"

@interface ContinueButtonExampleViewController ()

@property (weak, nonatomic) IBOutlet FooterView *footerView;

@end

@implementation ContinueButtonExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.footerView.continueButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)continueButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
