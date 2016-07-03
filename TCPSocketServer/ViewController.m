//
//  ViewController.m
//  TCPSocketServer
//
//  Created by 郭艾超 on 16/7/2.
//  Copyright © 2016年 Steven. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#import "SocketManager.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextView *sendTextView;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UIButton *listenPortBtn;

@property (weak, nonatomic) IBOutlet UITextView *recieveTextView;
@property (strong, nonatomic)GCDAsyncSocket * serverSocket;
@property (strong, nonatomic)GCDAsyncSocket * clientSocket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)listenPortAction:(UIButton *)sender {
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError * error = nil;
    [self.serverSocket acceptOnPort:[self.portTextField.text integerValue] error:&error];
}

- (IBAction)sendMessageAction:(UIButton *)sender {
    [self.clientSocket writeData:[self.sendTextView.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    SocketManager * socketManager = [SocketManager sharedSocketManager];
    [socketManager.mySocket readDataWithTimeout:-1 tag:0];
}

- (IBAction)recieveMessageAction:(UIButton *)sender {
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //连接成功，可查看newSocket.connectedHost和newSocket.connectedPort等参数

    self.listenPortBtn.enabled = NO;
    self.clientSocket = newSocket;
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString * receive = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    self.recieveTextView.text = [NSString stringWithFormat:@"%@\n%@",self.recieveTextView.text,receive];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
{
    NSLog(@"连接失败");
    self.listenPortBtn.enabled = NO;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"%ld",tag);
}
@end
