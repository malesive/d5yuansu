//
//  HomeCell.m
//  D5大生活
//
//  Created by daizhouliang@mac on 15/12/21.
//  Copyright (c) 2015年 June801. All rights reserved.
//

#import "HomeCell.h"
#import "TFHpple.h"
#import "UIImageView+WebCache.h"


@interface HomeCell () <NSURLConnectionDataDelegate>
@property (strong, nonatomic) NSMutableData *backData;
@end


@implementation HomeCell

- (void)setUrlString:(NSString *)urlString{
    _urlString = urlString;
    
    [self analyseReqwithUrlString:urlString];//原来的
//    [self analyseReqwithUrlString:@"http://www.d5yuansu.com/2015/12/23/100969.html"];
    
}

- (void)awakeFromNib {
    // Initialization code
//    self.titleImageView.image = [UIImage imageNamed:@"IMG_0599"];//blackD5
    self.titleImageView.image = [UIImage imageNamed:@"cellLogo"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSData *)backData{
    if (_backData == nil) {
        _backData = [[NSMutableData alloc] init];
    }
    return _backData;
}

#pragma mark - NSURLConnectionDataDelegate

//接受到数据时调用，完整的数据可能拆分为多个包发送，每次接受到数据片段都会调用这个方法，所以需要一个全局的NSData对象，用来把每次的数据拼接在一起
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.backData appendData:data];
}

//数据接受结束时调用这个方法，这时的数据就是获得的完整数据了，可以使用数据做之后的处理了
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *resultString = [[NSString alloc]initWithData:self.backData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",resultString);
    if(self.leftMenuSelectIndex != 1){
        [self analyseChildUrlResultString:resultString];//原来的，取话说最后一张图片
    }
    else{
        [self analyseMoreImginChildUrlResultString:resultString];//多图尝试
    }
    
//    NSString *lastImageSrc = [self analyseChildUrlResultString:resultString];
//    NSURL *lastImageUrl = [NSURL URLWithString:lastImageSrc];
//    if (lastImageUrl != nil) {
//        //给一张默认图片，先使用默认图片，当图片加载完成后再替换
//            [self.titleImageView sd_setImageWithURL:lastImageUrl placeholderImage:[UIImage imageNamed:@"IMG_0599"]];
//    }
    
    
}

//这是请求出错是调用，错误处理不可忽视
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if (error.code == NSURLErrorTimedOut) {
        NSLog(@"请求超时");
    }
    NSLog(@"%@",[error localizedDescription]);
}

#pragma mark - 

- (void)analyseReqwithUrlString:(NSString *)string{
    NSString * URLString = string;//@"http://www.d5yuansu.com";
    NSURL * URL = [NSURL URLWithString:[URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:URL cachePolicy:0 timeoutInterval:8.0];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
}

-(NSString *)analyseChildUrlResultString:(NSString *)resultString{
//    NSString *subHTMLStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:htmlString] encoding:NSUTF8StringEncoding error:nil];
    NSString *subHTMLStr=[resultString copy];
    
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
//    NSLog(@"subHTMLStr3 = %@",subHTMLStr3);
    
    NSData *dataTitle=[subHTMLStr3 dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *dataTitle=[subHTMLStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"dataTitle = %@",dataTitle);
    
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    
    NSArray *elements=[xpathParser searchWithXPathQuery:@"//img"];
//    NSLog(@"elements = %@",elements);
    
    //返回每页最后一张图的url地址
    TFHppleElement *element = elements.lastObject;
    NSDictionary *elementContent =[element attributes];
//    NSLog(@"elementContent = %@",elementContent);
//    NSLog(@"href = %@",[elementContent objectForKey:@"src"]);
    
    NSString *lastImageSrc = [elementContent objectForKey:@"src"];
    NSURL *lastImageUrl = [NSURL URLWithString:lastImageSrc];
    if (lastImageUrl != nil) {
        //给一张默认图片，先使用默认图片，当图片加载完成后再替换
    [self.titleImageView sd_setImageWithURL:lastImageUrl placeholderImage:[UIImage imageNamed:@"cellLogo"]];
    }
    
    

    
    return [elementContent objectForKey:@"src"];
}

-(NSString *)analyseMoreImginChildUrlResultString:(NSString *)resultString{
    //    NSString *subHTMLStr=[NSString stringWithContentsOfURL:[NSURL URLWithString:htmlString] encoding:NSUTF8StringEncoding error:nil];
    NSString *subHTMLStr=[resultString copy];
    
    if (subHTMLStr == nil) {
        return nil;
    }
    
//    NSData *dataTitle=[subHTMLStr3 dataUsingEncoding:NSUTF8StringEncoding];
        NSData *dataTitle=[subHTMLStr dataUsingEncoding:NSUTF8StringEncoding];
    //    NSLog(@"dataTitle = %@",dataTitle);
    
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:dataTitle];
    
    NSArray *elements=[xpathParser searchWithXPathQuery:@"//img"];
    //    NSLog(@"elements = %@",elements);
//    NSInteger i;
//    TFHppleElement *element;
//    if (elements.count > 5) {
//        i = 5;
//        element = elements[i];
//    }
    NSDictionary *elementContent;
    NSString *lastImageSrc;
    for (TFHppleElement *element in elements) {
        elementContent =[element attributes];
        lastImageSrc = [elementContent objectForKey:@"src"];
        if (!([lastImageSrc isEqualToString:@"http://ww1.sinaimg.cn/mw690/7d1c8e96gw1eyk5bks35rj208i038mxl.jpg"] || [lastImageSrc isEqualToString:@"http://d5yuansu.com/wp-content/uploads/2015/11/ogoright.png"] || [lastImageSrc isEqualToString:@"http://ww2.sinaimg.cn/large/7d1c8e96gw1ez09e5x2jfj20tj03pwfw.jpg"])) {
            break;
        }
    }
    
    //返回每页最后一张图的url地址
//    TFHppleElement *element = elements[i];
//    NSDictionary *elementContent =[element attributes];
    //    NSLog(@"elementContent = %@",elementContent);
    //    NSLog(@"href = %@",[elementContent objectForKey:@"src"]);
    
//    NSString *lastImageSrc = [elementContent objectForKey:@"src"];
    NSURL *lastImageUrl = [NSURL URLWithString:lastImageSrc];
    if (lastImageUrl != nil) {
        //给一张默认图片，先使用默认图片，当图片加载完成后再替换
        [self.titleImageView sd_setImageWithURL:lastImageUrl placeholderImage:[UIImage imageNamed:@"IMG_0599"]];
    }
    
    
    
    
    return [elementContent objectForKey:@"src"];
}



@end
