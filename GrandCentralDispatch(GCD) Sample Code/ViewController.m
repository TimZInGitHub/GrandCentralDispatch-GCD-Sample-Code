//
//  ViewController.m
//  GrandCentralDispatch(GCD) Sample Code
//
//  Created by Tim.Z on 11/24/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage  *image1; /**< 图片1 */
@property (nonatomic, strong) UIImage  *image2; /**< 图片2 */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

    //等2个异步操作都执行完毕后,再回到主线程执行操作
- (IBAction)groupNotify:(id)sender
{
        //记得设置App Transport Security Settings!!!!
        //下载图片1
    
        //创建队列组
    dispatch_group_t group =  dispatch_group_create();
    
        //1.开子线程下载图片
        //创建队列(并发)
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_async(group, queue, ^{
            //1.获取url地址
        NSURL *url = [NSURL URLWithString:@"http://img2.duitang.com/uploads/item/201207/28/20120728122854_8sekE.jpeg"];
        
            //2.下载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        
            //3.把二进制数据转换成图片
        self.image1 = [UIImage imageWithData:data];
        
        NSLog(@"1---%@",self.image1);
    });
    
        //下载图片2
    dispatch_group_async(group, queue, ^{
            //1.获取url地址
        NSURL *url = [NSURL URLWithString:@"http://img4.duitang.com/uploads/item/201206/11/20120611174846_JtvFd.thumb.600_0.png"];
        
            //2.下载图片
        NSData *data = [NSData dataWithContentsOfURL:url];
        
            //3.把二进制数据转换成图片
        self.image2 = [UIImage imageWithData:data];
        NSLog(@"2---%@",self.image2);
        
    });
    
        //合成
    dispatch_group_notify(group, queue, ^{
        
            //开启图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(200, 200));
        
            //画1
        [self.image1 drawInRect:CGRectMake(0, 0, 200, 100)];
        
            //画2
        [self.image2 drawInRect:CGRectMake(0, 100, 200, 100)];
        
            //根据图形上下文拿到图片
        UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
        
            //关闭上下文
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            NSLog(@"%@--刷新UI",[NSThread currentThread]);
        });
    });

}


#pragma mark -
//同步函数+主队列:死锁
- (IBAction)syncMain:(id)sender
{
    NSLog(@"----");
        //1.获得主队列
    dispatch_queue_t queue =  dispatch_get_main_queue();
    
        //2.同步函数
    dispatch_sync(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
}

//异步函数+主队列:不会开线程,任务串行执行
- (IBAction)asyncMain:(id)sender
{
        //1.获得主队列
    dispatch_queue_t queue =  dispatch_get_main_queue();
    
        //2.异步函数
    dispatch_async(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
}

//同步函数+串行队列:不会开线程,任务串行执行
- (IBAction)syncSerial:(id)sender
{
        //创建串行队列
    /*
     第一个参数:C语言字符串,标签
     第二个参数:
     DISPATCH_QUEUE_CONCURRENT:并发队列
     DISPATCH_QUEUE_SERIAL:串行队列
     */
    dispatch_queue_t queue =  dispatch_queue_create("TZ.download", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
}

//同步函数+并发队列:不会开线程,任务串行执行
- (IBAction)syncConcurrent:(id)sender
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    NSLog(@"--syncConcurrent--start-");
    
    dispatch_sync(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_sync(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
    
    NSLog(@"--syncConcurrent--end-");
}

//异步函数+串行队列:会开启一条线程,任务串行执行
- (IBAction)asyncSerial:(id)sender
{
        //创建串行队列
    /*
     第一个参数:C语言字符串,标签
     第二个参数:
     DISPATCH_QUEUE_CONCURRENT:并发队列
     DISPATCH_QUEUE_SERIAL:串行队列
     */
    dispatch_queue_t queue =  dispatch_queue_create("TZ.download", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
}

//异步函数+并发队列:会开启新的线程,并发执行
- (IBAction)asyncCONCURRENT:(id)sender
{
        //创建并发队列
    /*
     第一个参数:C语言字符串,标签
     第二个参数:
     DISPATCH_QUEUE_CONCURRENT:并发队列
     DISPATCH_QUEUE_SERIAL:串行队列
     */
        //    dispatch_queue_t queue =  dispatch_queue_create("com.520it.download", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"--asyncCONCURRENT--start-");
        //获得全局并发队列
    /*
     第一个参数:队列的优先级DISPATCH_QUEUE_PRIORITY_DEFAULT
     第二个参数:永远传0
     */
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        //异步函数
    /*
     第一个参数:队列
     第二个参数:block,在里面封装任务
     */
    dispatch_async(queue, ^{
        NSLog(@"---download1---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download2---%@",[NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"---download3---%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"---download4---%@",[NSThread currentThread]);
    });
    
    NSLog(@"--asyncCONCURRENT--end-");
}






@end
