//
//  ViewController.m
//  D5大生活
//
//  Created by June801 on 15/12/21.
//  Copyright © 2015年 June801. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "TFHpple.h"
#import "HomeCell.h"
#import "DetailViewController.h"
#import "MJRefresh.h"
#import "SlideNavigationController.h"
#import "public.h"
#import "UIScrollView+EmptyDataSet.h"

#import "AFWebViewController.h"
#import "AFModalWebViewController.h"

static const CGFloat MJDuration = 6.0;

static NSString *CellTableIdentifier = @"CellTableIdentifier";

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,NSURLConnectionDataDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSMutableArray *titleImageUrlArray;
@property (strong, nonatomic) NSMutableData *backData;
@property (strong, nonatomic) NSArray *sectionNames;
@property (assign, nonatomic) NSInteger leftMenuSelectIndex;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSURL *url = [NSURL URLWithString:@"http://www.d5yuansu.com/category/talk/"];
//    /** request */
////    ASIHTTPRequest *request =[ASIHTTPRequest requestWithURL:url];
//    NSURL *URL = [NSURL URLWithString:@"http://www.d5yuansu.com/category/talk/"];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:URL.absoluteString parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    //    [self test3];
    [self initLeftMenu];
    [self initConfig];
    [self initTableView];
    [self initMJRefreshExample01];
    
    [self AnalyseChildUrl:@"http://www.d5yuansu.com/2015/12/20/100760.html"];
}

#pragma mark - init

- (void)initLeftMenu{
    [SlideNavigationController sharedInstance].portraitSlideOffset = [UIScreen mainScreen].bounds.size.width - 130;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LeftMenuSelectNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSInteger selectIndex = [note.userInfo[@"LeftMenuSelectIndex"] integerValue];
        NSLog(@"selectIndex %ld", (long)selectIndex);
        self.leftMenuSelectIndex = selectIndex;
        self.title = [@"D5大生活-" stringByAppendingString:self.sectionNames[self.leftMenuSelectIndex]];
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
        // 马上进入刷新状态
        [self.tableView.mj_header beginRefreshing];
    }];
}

- (void)initMJRefreshExample01{
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf loadNewData];
        [self overtimeAction];
        [self testReq];
    }];
    
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}

- (void)initConfig{
//    self.title = @"D5大生活";
    
    self.dataArray = [@[] mutableCopy];
    self.titleImageUrlArray = [@[] mutableCopy];
    self.backData = [[NSMutableData alloc] init];
    self.sectionNames = @[@"最新文章",@"话说",@"挖图",@"轻生活",@"光影",@"影讯",@"NULL"];
    self.leftMenuSelectIndex = 1;
    
    self.title = [@"D5大生活-" stringByAppendingString:self.sectionNames[self.leftMenuSelectIndex]];
    
    NSString *urlStr = @"http://www.d5yuansu.com";
    
    //备用
    //    [self AnalyseUrl:urlStr];
    //测试
//    [self testReq];
    
    //    if (self.dataArray.count != 0) {
    //        for (NSDictionary *item in self.dataArray) {
    //            NSString *urlString = [item objectForKey:@"href"];
    //            NSString *lastImageUrlString = [self AnalyseChildUrl:urlString];
    //            [self.titleImageUrlArray addObject:lastImageUrlString];
    //        }
    //    }
}

- (void)initTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = 88;
    UINib *nib = [UINib nibWithNibName:@"HomeCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellTableIdentifier];
    
    //
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
//                             SimpleTableIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]
//                initWithStyle:UITableViewCellStyleDefault
//                reuseIdentifier:SimpleTableIdentifier];
//    }
//    NSDictionary *item = self.dataArray[indexPath.row];
//    NSString *itemTitle = [item objectForKey:@"title"];
//    cell.textLabel.text = itemTitle;
//    return cell;
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellTableIdentifier-%ld-%ld",self.leftMenuSelectIndex,indexPath.row];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([HomeCell class]) bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"CellTableIdentifier-%ld-%ld",self.leftMenuSelectIndex,indexPath.row]];
//    if (!cell) {
//        
//        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([HomeCell class])
//                                              owner:self
//                                            options:nil] objectAtIndex:0];
//    }
    NSDictionary *item = self.dataArray[indexPath.row];
    NSString *itemTitle = [item objectForKey:@"title"];
    NSString *urlString = [item objectForKey:@"href"];
    cell.titleLabel.text = itemTitle;
//    cell.titleImageView.image = [UIImage imageNamed:@"IMG_0599"];
    cell.urlString = [urlString copy];
    cell.leftMenuSelectIndex = self.leftMenuSelectIndex;
//
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //    DetailViewController *dvc = [story instantiateViewControllerWithIdentifier:@"DetailViewController"];
    NSDictionary *item = self.dataArray[indexPath.row];
    NSString *itemTitle = [item objectForKey:@"title"];
    NSString *urlString = [item objectForKey:@"href"];
    //    dvc.titleString = itemTitle;
    //    dvc.urlString = urlString;
    //    [self.navigationController pushViewController:dvc animated:YES];
    //
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AFWebViewController *webViewController = [AFWebViewController webViewControllerWithAddress:urlString];
    webViewController.toolbarTintColor = [UIColor orangeColor]; // Does not work on iPad
    [self.navigationController pushViewController:webViewController animated:YES];
    
//    AFModalWebViewController *webViewController = [AFModalWebViewController webViewControllerWithAddress:urlString];
//    webViewController.toolbarTintColor = [UIColor orangeColor]; // Does not work on iPad
//    webViewController.barsTintColor = [UIColor redColor];
//    [self presentViewController:webViewController animated:YES completion:NULL];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - NSURLConnectionDataDelegate

//接受到数据时调用，完整的数据可能拆分为多个包发送，每次接受到数据片段都会调用这个方法，所以需要一个全局的NSData对象，用来把每次的数据拼接在一起
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.backData appendData:data];
}

//数据接受结束时调用这个方法，这时的数据就是获得的完整数据了，可以使用数据做之后的处理了
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *resultString = [[NSString alloc]initWithData:self.backData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",resultString);
//    self.
    [self analyseResultString:resultString withIndex:self.leftMenuSelectIndex];
    
    
    
}

//这是请求出错是调用，错误处理不可忽视
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (error.code == NSURLErrorTimedOut) {
        NSLog(@"请求超时");
    }
    NSLog(@"%@",[error localizedDescription]);
}

//NSURLRequest * request = [[NSURLRequest alloc]initWithURL:URL cachePolicy:0 timeoutInterval:8.0];
//或者：
//NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:URL];
//[request setTimeoutInterval:8.0];
//请求时间超过所设置的超时时间，会自动调用
//-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
//
//}
//但是有个问题是怎么把判断是超时导致的请求失败，上面的例子里已经写了，可以根据返回的error的code进行判断。了解不同情况的请求失败，可以更好的给用户提示。
#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - test

- (void)testReq{
    NSString * URLString = @"http://www.d5yuansu.com/";//http://www.d5yuansu.com/
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:URL cachePolicy:0 timeoutInterval:8.0];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
}

- (void)test{
    NSURL *url =[NSURL URLWithString:@"http://www.d5yuansu.com/category/talk/"] ;
    NSError *err = nil;
    NSString *str =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    if (err == nil)
    {
        NSLog(@"%@",str);
    }
    else
    {
        NSLog(@"读取失败");
        NSLog(@"%@",err.localizedDescription);
    }
}

- (void)test2{
    NSURL *url =[NSURL URLWithString:@"http://www.d5yuansu.com/category/talk/"] ;
    NSURL *url2 =[NSURL URLWithString:@"http://www.d5yuansu.com"] ;

    NSError *err = nil;
//    NSString *str =   [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    NSData *data = [NSData dataWithContentsOfURL:url2];
    if (err == nil)
    {
        NSLog(@"%@",data);
    }
    else
    {
        NSLog(@"读取失败");
        NSLog(@"%@",err.localizedDescription);
    }
    
    
    
//    // Create parser
//    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
//    //Get all the cells of the 2nd row of the 3rd table
//    NSArray *elements  = [xpathParser search:@"//table[3]/tr[2]/td"];
//    // Access the first cell
//    TFHppleElement *element = [elements objectAtIndex:0];
//    // Get the text within the cell tag
//    NSString *content = [element content];
}

- (void)test3{
    NSString *urlStr = @"http://www.d5yuansu.com";
    
    NSArray *arr = [self AnalyseUrl:urlStr];
    NSLog(@"arr.count = %ld",arr.count);
    
    TFHppleElement *element = arr[4];
    
    NSDictionary *elementContent =[element attributes];
    
    NSLog(@"elementContent = %@",elementContent);
    
    NSLog(@"href = %@",[elementContent objectForKey:@"href"]);
    NSLog(@"title = %@",[elementContent objectForKey:@"title"]);
}

-(NSArray *)AnalyseUrl:(NSString *)htmlString;{
    
    NSString *subHTMLStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:htmlString] encoding:NSUTF8StringEncoding error:nil];
    
    NSRange rang1=[subHTMLStr rangeOfString:@"title=\"话说\">话说</a>"];
    NSMutableString *subHTMLStr2=[[NSMutableString alloc]initWithString:[subHTMLStr substringFromIndex:rang1.location+rang1.length]];
    
    NSRange rang2=[subHTMLStr2 rangeOfString:@"title=\"挖图\">挖图</a>"];
    NSMutableString *subHTMLStr3=[[NSMutableString alloc]initWithString:[subHTMLStr2 substringToIndex:rang2.location]];
    //        NSLog(@"subHTMLStr3 = %@",subHTMLStr3);
    
    NSRange rang3 = [subHTMLStr3 rangeOfString:@"<ul>"];
    //    NSMutableString *subHTMLStr4 = [[NSMutableString alloc] initWithString:[subHTMLStr3 substringFromIndex:rang3.location+rang3.length]];
    NSMutableString *subHTMLStr4 = [[NSMutableString alloc] initWithString:[subHTMLStr3 substringFromIndex:rang3.location]];
    
    //
    NSRange rang4=[subHTMLStr4 rangeOfString:@"</ul>"];
    NSMutableString *subHTMLStr5=[[NSMutableString alloc]initWithString:[subHTMLStr4 substringToIndex:rang4.location+rang4.length]];
    //    NSLog(@"subHTMLStr5 = %@",subHTMLStr5);
    
    
    NSData *dataTitle=[subHTMLStr5 dataUsingEncoding:NSUTF8StringEncoding];
    //    NSLog(@"dataTitle = %@",dataTitle);
    
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    
    NSArray *elements=[xpathParser searchWithXPathQuery:@"//a"];
    NSLog(@"elements = %@",elements);
    
    //    _imageArray=[[NSMutableArray alloc]init];
    
    
    for (TFHppleElement *element in elements) {
        NSLog(@"element = %@",element);
        //        NSLog(@"element.children = %@",element.children);
        //        NSArray *array = element.children;
        NSDictionary *elementContent =[element attributes];
        
        NSLog(@"elementContent = %@",elementContent);
        
        NSLog(@"href = %@",[elementContent objectForKey:@"href"]);
        NSLog(@"title = %@",[elementContent objectForKey:@"title"]);
        
        //        [_imageArray addObject:[elementContent objectForKey:@"src"]];
        [self.dataArray addObject:elementContent];
    }
    
    //    return _imageArray;
    return elements;
}

- (void)analyseResultString:(NSString *)string withIndex:(NSInteger)index{
    NSString *subHTMLStr= [string copy];
//    NSRange rang1=[subHTMLStr rangeOfString:@"title=\"话说\">话说</a>"];
    NSRange rang1=[subHTMLStr rangeOfString:[NSString stringWithFormat:@"title=\"%@\">%@</a>",self.sectionNames[index],self.sectionNames[index]]];
    if (rang1.length == 0) {
        return ;
    }
    NSMutableString *subHTMLStr2=[[NSMutableString alloc]initWithString:[subHTMLStr substringFromIndex:rang1.location+rang1.length]];
    
//    NSRange rang2=[subHTMLStr2 rangeOfString:@"title=\"挖图\">挖图</a>"];
    NSRange rang2;
    if (index != 5) {
        rang2=[subHTMLStr2 rangeOfString:[NSString stringWithFormat:@"title=\"%@\">%@</a>",self.sectionNames[index+1],self.sectionNames[index+1]]];
    }else{
        rang2=[subHTMLStr2 rangeOfString:@"<!-- 异步468*60 -->"];
    }
    if (rang2.length == 0) {
        return ;
    }
    NSMutableString *subHTMLStr3=[[NSMutableString alloc]initWithString:[subHTMLStr2 substringToIndex:rang2.location]];
    //        NSLog(@"subHTMLStr3 = %@",subHTMLStr3);
    
    NSRange rang3 = [subHTMLStr3 rangeOfString:@"<ul>"];
    //    NSMutableString *subHTMLStr4 = [[NSMutableString alloc] initWithString:[subHTMLStr3 substringFromIndex:rang3.location+rang3.length]];
    NSMutableString *subHTMLStr4 = [[NSMutableString alloc] initWithString:[subHTMLStr3 substringFromIndex:rang3.location]];
    
    //
    NSRange rang4=[subHTMLStr4 rangeOfString:@"</ul>"];
    NSMutableString *subHTMLStr5=[[NSMutableString alloc]initWithString:[subHTMLStr4 substringToIndex:rang4.location+rang4.length]];
    //    NSLog(@"subHTMLStr5 = %@",subHTMLStr5);
    
    
    NSData *dataTitle=[subHTMLStr5 dataUsingEncoding:NSUTF8StringEncoding];
    //    NSLog(@"dataTitle = %@",dataTitle);
    
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    
    NSArray *elements=[xpathParser searchWithXPathQuery:@"//a"];
    NSLog(@"elements = %@",elements);
    if (elements.count != 0) {
        [self.dataArray removeAllObjects];
    }
    
    //    _imageArray=[[NSMutableArray alloc]init];
    
    
    for (TFHppleElement *element in elements) {
        NSLog(@"element = %@",element);
        //        NSLog(@"element.children = %@",element.children);
        //        NSArray *array = element.children;
        NSDictionary *elementContent =[element attributes];
        
        NSLog(@"elementContent = %@",elementContent);
        
        NSLog(@"href = %@",[elementContent objectForKey:@"href"]);
        NSLog(@"title = %@",[elementContent objectForKey:@"title"]);
        
        //        [_imageArray addObject:[elementContent objectForKey:@"src"]];
        [self.dataArray addObject:elementContent];
    }
    // 拿到当前的下拉刷新控件，结束刷新状态
    [self.tableView.mj_header endRefreshing];
    [self.tableView reloadData];
    
}

-(NSString *)AnalyseChildUrl:(NSString *)htmlString{
    NSString *subHTMLStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:htmlString] encoding:NSUTF8StringEncoding error:nil];
    
    if (subHTMLStr == nil) {
        return nil;
    }
    
    NSRange rang1=[subHTMLStr rangeOfString:@"<p><span style=\"color: #ff6628;\">"];
    if (rang1.length == 0) {
        return nil;
    }
    NSMutableString *subHTMLStr2=[[NSMutableString alloc]initWithString:[subHTMLStr substringFromIndex:rang1.location]];
    
    NSRange rang2=[subHTMLStr2 rangeOfString:@"<p><span style=\"color: #993300;\">"];
    if (rang2.length == 0) {
        return nil;
    }
    NSMutableString *subHTMLStr3=[[NSMutableString alloc]initWithString:[subHTMLStr2 substringToIndex:rang2.location]];
    NSLog(@"subHTMLStr3 = %@",subHTMLStr3);
    
    NSData *dataTitle=[subHTMLStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"dataTitle = %@",dataTitle);
    
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    
    NSArray *elements=[xpathParser searchWithXPathQuery:@"//img"];
    NSLog(@"elements = %@",elements);
    
    //返回每页最后一张图的url地址
    TFHppleElement *element = elements.lastObject;
    NSDictionary *elementContent =[element attributes];
    NSLog(@"elementContent = %@",elementContent);
    NSLog(@"href = %@",[elementContent objectForKey:@"src"]);
    
    return [elementContent objectForKey:@"src"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 下拉刷新数据
- (void)overtimeAction{
    // 1.添加假数据
//    for (int i = 0; i<5; i++) {
//        [self.data insertObject:MJRandomData atIndex:0];
//    }
    
    // 2.模拟2秒后刷新表格UI（真实开发中，可以移除这段gcd代码）
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MJDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
//        [self.tableView reloadData];
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
    });
}

#pragma mark - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"下拉刷新试试";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"D5的网站可能挂掉了，也可能是APP没有及时更新，抱歉。。";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

//- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
//{
//    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f]};
//    
//    return [[NSAttributedString alloc] initWithString:@"Continue" attributes:attributes];
//}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}


@end
