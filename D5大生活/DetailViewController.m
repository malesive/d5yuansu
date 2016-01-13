//
//  DetailViewController.m
//  D5大生活
//
//  Created by daizhouliang@mac on 15/12/21.
//  Copyright (c) 2015年 June801. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.titleString;
    [self openWebWithUrlString:self.urlString];
}

- (void)openWebWithUrlString:(NSString *)urlStr{
    
//    NSString *addressText = @"tian an men,bei jing,China";
//    
//    addressText = [ addressText stringByAddingpercentEscapesUsingEncoding:NSASCIIStringEncoding];
//    
//    NSString *urlText = [ NSString stringWithFormat:@"http://maps.google.com/maps?q = %@",addressText];
    
    self.webView.userInteractionEnabled = true;
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
    
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

@end
