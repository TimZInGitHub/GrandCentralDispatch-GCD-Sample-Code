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

    //dispatch_queue_priority_t priority, // 队列的优先级!


    //使用dispatch_barrier_async
- (IBAction)barrier:(id)sender
{
        //1.创建队列(并发队列)
    dispatch_queue_t queue = dispatch_queue_create("com.downloadqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"%zd-download1--%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"%zd-download2--%@",i,[NSThread currentThread]);
        }
    });
    
        //栅栏函数
    dispatch_barrier_async(queue, ^{
        NSLog(@"我是一个栅栏函数");
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"%zd-download3--%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        
        for (NSInteger i = 0; i<10; i++) {
            NSLog(@"%zd-download4--%@",i,[NSThread currentThread]);
        }
    });
}

    //使用dispatch_after延时执行
- (IBAction)after:(id)sender
{
    NSLog(@"----");
        //表名2秒钟之后调用run
        //    [self performSelector:@selector(run) withObject:nil afterDelay:2.0];
    
        //    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    
    /*
     第一个参数:延迟时间
     第二个参数:要执行的代码
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        NSLog(@"---%@",[NSThread currentThread]);
    });
}

    //使用dispatch_once函数能保证某段代码在程序运行过程中只被执行1次
- (IBAction)once:(id)sender
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"+++++++++");
    });
}

    //使用dispatch_apply函数能进行快速迭代遍历
- (IBAction)apply:(id)sender
{
        //    for (NSInteger i=0; i<10; i++) {
        //        NSLog(@"%zd--%@",i,[NSThread currentThread]);
        //    }

        //创建队列(并发队列)
    dispatch_queue_t queue = dispatch_queue_create("com.downloadqueue", DISPATCH_QUEUE_CONCURRENT);
    /*
     第一个参数:迭代的次数
     第二个参数:在哪个队列中执行
     第三个参数:block要执行的任务
     */
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zd--%@",index,[NSThread currentThread]);
    });
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
