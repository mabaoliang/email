//
//  ViewController.m
//  e-mail
//
//  Created by mac on 2018/4/27.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"
#import <MailCore/MailCore.h>
@interface ViewController ()
@property(strong,nonatomic)MCOSMTPSession *smtpSession;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

//获取邮件
- (IBAction)mailGet:(id)sender {
    
    MCOPOPSession *session = [[MCOPOPSession alloc] init];
    
    session.hostname = @"pop.qq.com";
    
    session.port = 995;
    
    [session setUsername:@"1032440206@qq.com"];
    
    [session setPassword:@"bfyurcqnzyrwbdhe"];
    
    [session setConnectionType:MCOConnectionTypeTLS];
    session.checkCertificateEnabled=NO;
    MCOPOPOperation * checkOp = [session checkAccountOperation];
    
    //开启异步请求，检查目前该配置是否能正确登录邮箱
    
    [checkOp start:^(NSError *error) {
        
        NSLog(@"finished checking account.");
        
        if (error == nil) {
            
            //正确登录邮箱
            
            /*在这里获取邮件头，通过邮件头可以获得邮件内容，详情看下面*/
            MCOPOPFetchMessagesOperation * op = [session fetchMessagesOperation];
            //异步获取邮件头MCOPOPMessageInfo，保存在messages里
            [op start:^(NSError * error,NSArray * messages) {
                if (error==nil) {
                    MCOPOPMessageInfo *messageinfo=messages[0];//拿到邮件头
                    int index=messageinfo.index;
                    MCOPOPFetchMessageOperation *messageOperation=[session fetchMessageOperationWithIndex: index];
                    //开启异步请求, messageData为邮件内容
                    [messageOperation start:^(NSError * _Nullable error, NSData * _Nullable messageData) {
                        MCOMessageParser * msgPaser =[MCOMessageParser messageParserWithData:messageData]; //  //由data转换为MCOMessageParser
                        NSLog(@"%@",[msgPaser plainTextBodyRendering]);//获取邮箱里的消息再要内容
                        //NSLog(@"%@",[msgPaser htmlBodyRendering]); //获取邮件正文
                    }];
                    //通过messages中的邮件头信息，可以进一步请求获得最终的邮件内容,获取方法见下面4
                }
            }];
            
        } else {
            
            NSLog(@"登录邮箱失败，请检查网络重试,error loading account: %@", error);
            
            
            
        }
        
        //checkOp = nil;
        
    }];

}



//发送邮件
- (IBAction)mialSend:(id)sender {
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.qq.com";
    smtpSession.port = 587;
    smtpSession.username = @"1032440206@qq.com";
    smtpSession.password =@"bfyurcqnzyrwbdhe";   //@"sxocxhdfopwqbcea";
    smtpSession.connectionType =MCOConnectionTypeStartTLS;  // MCOConnectionTypeStartTLS;
    smtpSession.authType=MCOAuthTypeSASLNone;
    //smtpSession.checkCertificateEnabled=NO;// 关闭证书
    self.smtpSession=smtpSession;
    
    MCOSMTPOperation *smtpOperation = [self.smtpSession loginOperation];
    [smtpOperation start:^(NSError * error) {
        if (error == nil) {
            NSLog(@"login account successed");
            
        } else {
            NSLog(@"login account failure: %@", error);
        }
    }];
    // 构建邮件体的发送内容
    MCOMessageBuilder *messageBuilder = [[MCOMessageBuilder alloc] init];
    
    messageBuilder.header.from = [MCOAddress addressWithDisplayName:@"1032440206" mailbox:@"1032440206@qq.com"];   // 发送人
    messageBuilder.header.to = @[[MCOAddress addressWithMailbox:@"@3046216570@qq.com"]];       // 收件人（多人）
    //   //messageBuilder.header.cc = @[[MCOAddress addressWithMailbox:@"@333333qq.com"]];      // 抄送（多人）
    //  //  messageBuilder.header.bcc = @[[MCOAddress addressWithMailbox:@"444444@qq.com"]];    // 密送（多人）
    //vvcv
    messageBuilder.header.subject = @"12333333";    // 邮件标题
    messageBuilder.textBody = @"hello world";           // 邮件正文
    // 发送邮件
    NSData * rfc822Data =[messageBuilder data];
    //    MCOSMTPSendOperation *sendOperation = [self.smtpSession sendOperationWithData:rfc822Data];
    MCOSMTPSendOperation *sendOperation =[self.smtpSession sendOperationWithData:rfc822Data from:messageBuilder.header.from recipients:nil];
    [sendOperation start:^(NSError *error) {
        if (error == nil) {
            NSLog(@"send message successed");
        } else {
            NSLog(@"send message failure: %@", error);
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
