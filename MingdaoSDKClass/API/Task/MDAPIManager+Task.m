//
//  MDAPIManager+Task.m
//  MingdaoV2
//
//  Created by WeeTom on 14-5-26.
//  Copyright (c) 2014年 Mingdao. All rights reserved.
//

#import "MDAPIManager+Task.h"
#import <UIKit/UIKit.h>

@implementation MDAPIManager (Task)
#pragma mark -
- (MDURLConnection *)loadProjectsWithKeywords:(NSString *)keywords handler:(MDAPINSArrayHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/project?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    if (keywords && keywords.length > 0)
        [urlString appendFormat:@"&keywords=%@", keywords];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSArray *projectDics = [dic objectForKey:@"projects"];
        NSMutableArray *projects = [NSMutableArray array];
        for (NSDictionary *projectDic in projectDics) {
            if (![projectDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTaskFolder *task = [[MDTaskFolder alloc] init];
            task.objectID = projectDic[@"guid"];
            task.objectName = projectDic[@"title"];
            [projects addObject:task];
        }
        handler(projects, error);
    }];
    return connection;
}

#pragma mark -
- (MDURLConnection *)loadTaskReplymentsWithTaskID:(NSString *)tID
                                         onlyFile:(BOOL)onlyFile
                                            maxID:(NSString *)maxTID
                                         pageSize:(NSInteger)size
                                          handler:(MDAPINSArrayHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v3/getTopicListByTaskID?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    if (maxTID)
        [urlString appendFormat:@"&max_id=%@", maxTID];
    if (size > 0)
        [urlString appendFormat:@"&pagesize=%ld", (long)size];
    if (onlyFile) {
        [urlString appendFormat:@"&is_onlyFile=%d", 1];
    }
    
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }

        NSArray *replyDics = [dic objectForKey:@"replyments"];
        NSMutableArray *replies = [NSMutableArray array];
        for (NSDictionary *replyDic in replyDics) {
            if (![replyDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTaskReplyment *reply = [[MDTaskReplyment alloc] initWithDictionary:replyDic];
            [replies addObject:reply];
        }
        handler(replies, error);
    }];
    return connection;
}

#pragma mark -
- (MDURLConnection *)createTaskWithTaskName:(NSString *)name
                                description:(NSString *)des
                              endDateString:(NSString *)endDateString
                                  chargerID:(NSString *)chargerID
                                  memberIDs:(NSArray *)memberIDs
                                  projectID:(NSString *)projectID
                                   parentID:(NSString *)parentID
                                    handler:(MDAPINSStringHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/create?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_title=%@", name];
    
    if (endDateString && endDateString.length > 0)
        [urlString appendFormat:@"&t_ed=%@", endDateString];
    if (memberIDs && memberIDs.count > 0)
        [urlString appendFormat:@"&t_mids=%@", [memberIDs componentsJoinedByString:@","]];
    if (chargerID && chargerID.length > 0)
        [urlString appendFormat:@"&u_id=%@", chargerID];
    if (projectID && projectID.length > 0)
        [urlString appendFormat:@"&t_pid=%@", projectID];
    if (parentID && parentID.length > 0) {
        [urlString appendFormat:@"&t_parentID=%@", parentID];
    }
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    if (des && des.length > 0) {
        NSString *str = [NSString stringWithFormat:@"t_des=%@", des];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [req setHTTPBody:data];
    }
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSString *taskID = [dic objectForKey:@"task"];
        handler(taskID, nil);
    }];
    return connection;
}

#pragma mark -
- (MDURLConnection *)createProjectWithName:(NSString *)name handler:(MDAPINSStringHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/add_project?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&title=%@", name];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSString *projectID = [dic objectForKey:@"project"];
        handler(projectID, nil);
    }];
    return connection;
}

#pragma mark -
- (MDURLConnection *)createTaskReplymentOnTaskWithTaskID:(NSString *)tID
                                                 message:(NSString *)message
                                 replyToReplymentWithRID:(NSString *)rID
                                                  images:(NSArray *)images
                                                 handler:(MDAPINSStringHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/addreply?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    if (rID && rID.length > 0)
        [urlString appendFormat:@"&r_id=%@", rID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSMutableArray *parameters = [NSMutableArray array];
    if (message) {
        [parameters addObject:@{@"key":@"r_msg", @"object":message}];
    }
    if (images.count > 0) {
        for (int i = 0; i < images.count; i++) {
            UIImage *image = images[i];
            NSString *fileName = [NSString stringWithFormat:@"photo%d.jpg", i+1];
            NSMutableString *parameter = [NSMutableString string];
            [parameter appendString:@"r_img"];
            if (i > 0) {
                [parameter appendFormat:@"%d", i];
            }
            [parameters addObject:@{@"key":parameter, @"object":image, @"fileName":fileName}];
        }
    }
    [self postWithParameters:parameters withRequest:req];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSString *replementID = [dic objectForKey:@"replyment"];
        handler(replementID, nil);
    }];
    connection.timeOut = 30 + 30*images.count;
    return connection;
}

#pragma mark -
- (MDURLConnection *)finishTaskWithTaskID:(NSString *)tID handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/finish?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)unfinishTaskWithTaskID:(NSString *)tID handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/unfinish?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)deleteTaskWithTaskID:(NSString *)tID handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/delete?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveTaskWithTaskID:(NSString *)tID
                                  title:(NSString *)title
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/edit_title?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&t_title=%@", title];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlStr handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveTaskWithTaskID:(NSString *)tID
                                    des:(NSString *)des
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/edit_des?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    if (des && des.length > 0) {
        NSString *str = [NSString stringWithFormat:@"des=%@", des];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [req setHTTPBody:data];
    }
    
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveTaskWithTaskID:(NSString *)tID
                              chargerID:(NSString *)chargerID
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/edit_charge?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&u_id=%@", chargerID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveTaskWithTaskID:(NSString *)tID
                          endDateString:(NSString *)endDateString
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/edit_expiredate?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&expiredate=%@", endDateString];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveTaskWithTaskID:(NSString *)tID
                              projectID:(NSString *)projectID
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/edit_project?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    if (projectID && projectID.length > 0) {
        [urlString appendFormat:@"&p_id=%@", projectID];
    }
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)addMemberToTaskWithTaskID:(NSString *)tID
                                      memberID:(NSString *)memberID
                                       handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/add_member?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&u_id=%@", memberID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)deleteMemberFromeTaskWithTaskID:(NSString *)tID
                                            memberID:(NSString *)memberID
                                             handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/delete_member?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&u_id=%@", memberID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)applyTaskMemberWithTaskID:(NSString *)tID
                                       handler:(MDAPIBoolHandler)handler
{
    
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/applyTaskMember?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
   
}

- (MDURLConnection *)applyJoinInTaskWithTaskID:(NSString *)tID
                                        memberID:(NSString *)memberID
                                         isAgree:(BOOL)agree
                                         handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/isAgreeMember?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&u_id=%@", memberID];
    [urlString appendFormat:@"&is_agree=%d",agree?1:0];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)agreeToTaskWithTaskID:(NSString *)tID
                                  memberID:(NSString *)memberID
                                   handler:(MDAPIBoolHandler)handler
{
    return [self applyJoinInTaskWithTaskID:tID memberID:memberID isAgree:YES handler:handler];
}

- (MDURLConnection *)refuseToTaskWithTaskID:(NSString *)tID
                                   memberID:(NSString *)memberID
                                    handler:(MDAPIBoolHandler)handler
{
    return [self applyJoinInTaskWithTaskID:tID memberID:memberID isAgree:NO handler:handler];
}

- (MDURLConnection *)saveTaskWitTaskID:(NSString *)tID colorType:(int)colorType handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/editTaskColor?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&color=%d", colorType];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveTaskWithTaskID:(NSString *)tID
                              lockState:(BOOL)lockedOrNot
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/editTaskLockState?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&stateLock=%d", lockedOrNot?1:0];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveTaskWithTaskID:(NSString *)tID
                               parentID:(NSString *)parentID
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/editTaskParent?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    if (parentID && parentID.length > 0) {
        [urlString appendFormat:@"&t_parentID=%@", parentID];
    }
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveTaskWithTaskID:(NSString *)tID
                            noticeState:(BOOL)noticeState
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/editUserNotice?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&notice=%d", noticeState?1:0];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)copyTaskWithTaskID:(NSString *)tID
                              chargerID:(NSString *)chargerID
                                  title:(NSString *)title
                                options:(NSArray *)options
                                handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/duplicate_task?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", tID];
    [urlString appendFormat:@"&u_id=%@", chargerID];
    [urlString appendFormat:@"&title=%@", title];
    if (options.count == 6) {
        [urlString appendFormat:@"&is_taskdesc=%d", [options[0] boolValue]?1:0];
        [urlString appendFormat:@"&is_folderID=%d", [options[1] boolValue]?1:0];
        [urlString appendFormat:@"&is_members=%d", [options[2] boolValue]?1:0];
        [urlString appendFormat:@"&is_observers=%d", [options[3] boolValue]?1:0];
        [urlString appendFormat:@"&is_deadline=%d", [options[4] boolValue]?1:0];
        [urlString appendFormat:@"&is_subtask=%d", [options[5] boolValue]?1:0];
    }
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

#pragma mark -
- (MDURLConnection *)loadFoldersWithKeywords:(NSString *)keywords
                                  filterType:(int)type
                                   colorType:(int)colorType
                                   orderType:(int)orderType
                           isShowEmptyFolder:(BOOL)isShowEmptyFolder
                       isShowCompletedFolder:(BOOL)isShowCompletedFolder
                                    pageSize:(int)pageSize
                                   pageIndex:(int)pageIndex
                                     handler:(void(^)(NSArray *folders, MDTaskFolder *noFolderTaskInfo, NSError *error))handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/getFolders?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    if (keywords && keywords.length > 0){
        [urlString appendFormat:@"&keywords=%@", keywords];
    }
    if (type == 2 || type == 3) {
        [urlString appendFormat:@"&filter_type=%d", type];
    }
    if (colorType >= 0 && colorType <= 5) {
        [urlString appendFormat:@"&color=%d", colorType];
    }

    [urlString appendFormat:@"&sort=%d", orderType];
    if (pageSize > 0) {
        [urlString appendFormat:@"&pagesize=%d", pageSize];
    }
    if (pageIndex > 0) {
        [urlString appendFormat:@"&pageindex=%d", pageIndex];
    }
    [urlString appendFormat:@"&is_showEmptyFolder=%d", isShowEmptyFolder?1:0];
    [urlString appendFormat:@"&is_showCompletedFolder=%d", isShowCompletedFolder?1:0];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, nil, error);
            return ;
        }
        
        NSArray *projectDics = [dic objectForKey:@"folders"];
        NSMutableArray *projects = [NSMutableArray array];
        for (NSDictionary *projectDic in projectDics) {
            if (![projectDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTaskFolder *task = [[MDTaskFolder alloc] initWithDictionary:projectDic];
            [projects addObject:task];
        }
        
        if ([[dic objectForKey:@"nullFolder_notificationCount"] intValue] == -1 || [[dic objectForKey:@"nullFolder_unCompleteCount"] intValue] == -1 || [[dic objectForKey:@"nullFolder_completedCount"] intValue] == -1) {
            handler(projects, nil, error);
        } else {
            MDTaskFolder *noFolderTaskInfo = [[MDTaskFolder alloc] init];
            noFolderTaskInfo.unreadDiscussCount = [[dic objectForKey:@"nullFolder_notificationCount"] intValue];
            noFolderTaskInfo.taskInProgressCount = [[dic objectForKey:@"nullFolder_unCompleteCount"] intValue];
            noFolderTaskInfo.taskCompletedCount = [[dic objectForKey:@"nullFolder_completedCount"] intValue];
            handler(projects, noFolderTaskInfo, error);
        }
    }];
    return connection;
}

#pragma mark -
- (MDURLConnection *)loadTasksWithKeywords:(NSString *)keywords
                                  folderID:(NSString *)folderID
                                   stageID:(NSString *)stageID
                                filterType:(int)filterType
                                 colorType:(int)colorType
                                 orderType:(int)orderType
                                  finished:(BOOL)finished
                               categortIDs:(NSString *)categortIDs
                                    userID:(NSString *)userID
                                 pageIndex:(int)pageIndex
                                  pageSize:(int)pageSize
                                   handler:(MDAPINSArrayHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/getTaskList?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    if (keywords && keywords.length > 0){
        [urlString appendFormat:@"&keywords=%@", keywords];
    }
    if (folderID) {
        [urlString appendFormat:@"&t_folderID=%@", folderID];
        if (stageID) {
            [urlString appendFormat:@"&t_sid=%@", stageID];
        }
    }
    [urlString appendFormat:@"&filter_type=%d", filterType];
    if (colorType >= 0 && colorType <= 5) {
        [urlString appendFormat:@"&color=%d", colorType];
    }
    [urlString appendFormat:@"&status=%d", finished?1:0];
    if (categortIDs) {
        [urlString appendFormat:@"&categoryIDs=%@", categortIDs];
    }
    if (userID) {
        [urlString appendFormat:@"&u_id=%@", userID];
    }
    if (pageSize > 0)
        [urlString appendFormat:@"&pagesize=%d", pageSize];
    if (pageIndex > 0)
        [urlString appendFormat:@"&pageindex=%d", pageIndex];

    [urlString appendFormat:@"&sort=%d", orderType];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        if (orderType == 4) {
            NSArray *folderDics = dic[@"tasks"];
            NSMutableArray *folders = [NSMutableArray array];
            for (NSDictionary *folderDic in folderDics) {
                NSArray *taskDics = [folderDic objectForKey:@"tasks"];
                NSMutableArray *tasks = [NSMutableArray array];
                for (NSDictionary *taskDic in taskDics) {
                    if (![taskDic isKindOfClass:[NSDictionary class]])
                        continue;
                    MDTask *task = [[MDTask alloc] initWithDictionary:taskDic];
                    [tasks addObject:task];
                }
                
                NSDictionary *tempDic = @{[folderDic[@"folderName"] isEqualToString:@""]?@"未关联项目":folderDic[@"folderName"]:tasks};
                [folders addObject:tempDic];
            }
            handler(folders,error);
        } else {
            NSArray *taskDics = [dic objectForKey:@"tasks"];
            NSMutableArray *tasks = [NSMutableArray array];
            for (NSDictionary *taskDic in taskDics) {
                if (![taskDic isKindOfClass:[NSDictionary class]])
                    continue;
                MDTask *task = [[MDTask alloc] initWithDictionary:taskDic];
                [tasks addObject:task];
            }
            handler(tasks, error);

        }
        
    }];
    return connection;
}

- (MDURLConnection *)loadSubTasksWithParentID:(NSString *)parentID
                                    pageIndex:(int)pageIndex
                                     pageSize:(int)pageSize
                                      handler:(MDAPINSArrayHandler)handler
{
    
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/getSubTasks?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_parentID=%@", parentID];
    if (pageSize > 0)
        [urlString appendFormat:@"&pagesize=%d", pageSize];
    if (pageIndex > 0)
        [urlString appendFormat:@"&pageindex=%d", pageIndex];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSArray *taskDics = [dic objectForKey:@"tasks"];
        NSMutableArray *tasks = [NSMutableArray array];
        for (NSDictionary *taskDic in taskDics) {
            if (![taskDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTask *task = [[MDTask alloc] initWithDictionary:taskDic];
            [tasks addObject:task];
        }
        handler(tasks, error);
    }];
    return connection;
}

- (MDURLConnection *)loadParentTasksWithTaskID:(NSString *)taskID
                                       handler:(MDAPINSArrayHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/getTaskParentsAndSubs?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", taskID];

    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSArray *taskDics = [dic objectForKey:@"parentTasks"];
        NSMutableArray *tasks = [NSMutableArray array];
        for (NSDictionary *taskDic in taskDics) {
            if (![taskDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTask *task = [[MDTask alloc] initWithDictionary:taskDic];
            [tasks addObject:task];
        }
        handler(tasks, error);
    }];
    return connection;

}


- (MDURLConnection *)loadCanBeRelatedTasksWithTaskID:(NSString *)taskID
                                            keywords:(NSString *)keywords
                                             handler:(MDAPINSArrayHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/getTasksByKeywordsAndID?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@", taskID];
    if (keywords && keywords.length> 0){
        [urlString appendFormat:@"&keywords=%@", keywords];
    }
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }

        NSArray *taskDics = [dic objectForKey:@"tasks"];
        NSMutableArray *tasks = [NSMutableArray array];
        for (NSDictionary *taskDic in taskDics) {
            if (![taskDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTask *task = [[MDTask alloc] initWithDictionary:taskDic];
            [tasks addObject:task];
        }
        handler(tasks, error);
    }];
    return connection;
}

#pragma mark -
- (MDURLConnection *)loadTaskDetailWithTaskID:(NSString *)taskID
                                       handler:(MDAPIObjectHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/getTaskDetail?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@",taskID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSDictionary *taskDics = [dic objectForKey:@"task"];
        
        MDTask *task = [[MDTask alloc] initWithDictionary:taskDics];
        handler(task, error);
    }];
    return connection;
}

- (MDURLConnection *)loadTaskActivityWithTaskID:(NSString *)taskID
                                        handler:(MDAPINSArrayHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/getTaskActivityByTaskID?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_id=%@",taskID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSArray *taskActArr = [dic objectForKey:@"taskActList"];
        NSMutableArray *taskActArray = [NSMutableArray array];
        for (NSDictionary *dic in taskActArr) {
            MDTaskActivity *taskAct = [[MDTaskActivity alloc] initWithDictionary:dic];
            [taskActArray addObject:taskAct];
        }
        handler(taskActArray, error);
    }];
    return connection;

}

#pragma mark -
- (MDURLConnection *)loadAllTaskMessagesWithKeyWords:(NSString *)keywords
                                         messageType:(int)messageType
                                          isFavorite:(BOOL)isFavorite
                                            isUnread:(BOOL)isUnread
                                           pageIndex:(int)pageIndex
                                            pageSize:(int)pageSize
                                             handler:(MDAPINSArrayHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v3/getAllTaskMessage?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    if (keywords && keywords.length > 0) {
        [urlString appendFormat:@"&keywords=%@",keywords];
    }
    [urlString appendFormat:@"&msg_type=%d",messageType];
    
    [urlString appendFormat:@"&is_favorite=%d",isFavorite?1:0];
    [urlString appendFormat:@"&is_unread=%d",isUnread?1:0];
    if (pageIndex > 0) {
        [urlString appendFormat:@"&pageindex=%d",pageIndex];
    }
    if (pageSize > 0) {
        [urlString appendFormat:@"&pagesize=%d",pageSize];
    }
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSArray *msgDics = [dic objectForKey:@"taskMessages"];
        NSMutableArray *messages = [NSMutableArray array];
        for (NSDictionary *msgDic in msgDics) {
            if (![msgDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTaskMessage *message = [[MDTaskMessage alloc] initWithDictionary:msgDic];
            [messages addObject:message];
        }
        handler(messages, error);
    }];
    
    return connection;
}

#pragma mark -
- (MDURLConnection *)validateFolderWithName:(NSString *)folderName
                                    handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/validateFolder?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    
    NSMutableData *postBody = [NSMutableData data];
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    NSString *boundary = @"--------MINGDAO";
    NSString *boundaryPrefix = @"--";
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"name"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", folderName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundaryPrefix] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField:@"Content-type"];
    [req setHTTPBody:postBody];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    
    return connection;
}

- (MDURLConnection *)createFolderWithName:(NSString *)folderName
                             chargeUserID:(NSString *)userID
                                 deadLine:(NSString *)deadLine
                               isFavorite:(NSInteger)isFavorite
                                  members:(NSString *)members
                                  handler:(MDAPINSStringHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/addFolder?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    
    NSMutableData *postBody = [NSMutableData data];
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    NSString *boundary = @"--------MINGDAO";
    NSString *boundaryPrefix = @"--";
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"name"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", folderName] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"chargeUserID"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", userID] dataUsingEncoding:NSUTF8StringEncoding]];

    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"isFavorite"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%ld\r\n", (long)isFavorite] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"members"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", members] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (deadLine && deadLine.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"deadline"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", deadLine] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [postBody appendData:[[NSString stringWithFormat:@"%@", boundaryPrefix] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField:@"Content-type"];
    [req setHTTPBody:postBody];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSString *folderID = [dic objectForKey:@"folderId"];
        handler(folderID, error);
    }];    return connection;
}

#pragma mark -
- (MDURLConnection *)createTaskV2WithTaskName:(NSString *)title
                                 description:(NSString *)description
                               endDateString:(NSString *)endDateString
                                   chargerID:(NSString *)chargerID
                                   memberIDs:(NSArray *)memberIDs
                                   projectID:(NSString *)projectID
                                      stageID:(NSString *)stageID
                                    parentID:(NSString *)parentID
                                   colorType:(int)colorType
                                       postID:(NSString *)postID
                                handler:(MDAPINSStringHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/addTask?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    
    NSMutableData *postBody = [NSMutableData data];
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    NSString *boundary = @"--------MINGDAO";
    NSString *boundaryPrefix = @"--";
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_title"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", title] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (description && description.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_des"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", description] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (endDateString && endDateString.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_ed"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", endDateString] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"u_id"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", chargerID] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (memberIDs && memberIDs.count > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_mids"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", [memberIDs componentsJoinedByString:@","]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (projectID && projectID.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_folderID"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", projectID] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (stageID.length > 0) {
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_sid"]dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", stageID] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    if (parentID && parentID.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_parentID"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", parentID] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (colorType >= 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"color"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%d\r\n", colorType] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (postID && postID.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"p_id"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", postID] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundaryPrefix] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField:@"Content-type"];
    [req setHTTPBody:postBody];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSString *postID = [dic objectForKey:@"task"];
        handler(postID, error);
    }];
    return connection;
}

- (MDURLConnection *)saveFolderWithFolderID:(NSString *)folderID
                                 folderName:(NSString *)folderName
                                 chargeUser:(NSString *)chargeUser
                                   deadLine:(NSString *)deadLine
                                 isFavorite:(NSInteger)isFavorite
                                    members:(NSString *)members
                                    handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/editFolderInfo?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    
    NSMutableData *postBody = [NSMutableData data];
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    NSString *boundary = @"--------MINGDAO";
    NSString *boundaryPrefix = @"--";
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_folderID"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", folderID] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (folderName.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"name"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", folderName] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    if (chargeUser.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"chargeUserID"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", chargeUser] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"isFavorite"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%ld\r\n", (long)isFavorite] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"members"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", members] dataUsingEncoding:NSUTF8StringEncoding]];

    if (deadLine && deadLine.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"deadline"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", deadLine] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundaryPrefix] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField:@"Content-type"];
    [req setHTTPBody:postBody];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlStr handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveFolderWithFolderID:(NSString *)folderID
                                  colorType:(int)colorType
                                    handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/editFolderColor?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    [urlString appendFormat:@"&color=%d", colorType];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)deleteFolderWithFolderID:(NSString *)folderID
                                isDeleteTasks:(BOOL)isDeleteTasks
                                      handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v2/deleteFolder?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    
    [urlString appendFormat:@"&is_deleteTask=%d",isDeleteTasks?1:0];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)saveStagesSeqWithFolderID:(NSString *)folderID
                                     newStages:(NSArray *)stages
                                       handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/editFolderStage.aspx?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    if (stages.count > 0) {
        NSMutableArray *stageDics = [NSMutableArray array];
        for (MDTaskFolderStage *stage in stages) {
            if ([stage isKindOfClass:[MDTaskFolderStage class]]) {
                if (stage.objectID) {
                    NSMutableDictionary *stageDic = [NSMutableDictionary dictionary];
                    [stageDic setObject:stage.objectID forKey:@"stageID"];
                    [stageDics addObject:stageDic];
                }
            }
        }
        
        NSString *jsonString = nil;
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:stageDics
                                                           options:0
                                                             error:&error];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *boundary = @"----------MINGDAO";
        NSString *boundaryPrefix = @"--";
        
        NSMutableData *postBody = [NSMutableData data];
        
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"newstages"] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", jsonString] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postBody appendData:[[NSString stringWithFormat:@"%@", boundaryPrefix] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
        [req setValue:contentType forHTTPHeaderField:@"Content-type"];
        
        [req setHTTPBody:postBody];
    }
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)loadFolderStagesWithFolderID:(NSString *)folderID
                                          handler:(MDAPIObjectHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/getFolderStage.aspx?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSMutableDictionary *mDic = [dic mutableCopy];
        NSArray *msgDics = [dic objectForKey:@"stages"];
        NSMutableArray *messages = [NSMutableArray array];
        for (NSDictionary *msgDic in msgDics) {
            if (![msgDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTaskFolderStage *message = [[MDTaskFolderStage alloc] initWithDictionary:msgDic];
            [messages addObject:message];
        }
        [mDic setObject:messages forKey:@"stages"];
        handler(mDic, error);
    }];
    
    return connection;
}

- (MDURLConnection *)loadFolderDetailWithFolderID:(NSString *)folderID
                                          handler:(MDAPIObjectHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/getFolderDetail?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        MDTaskFolder *folder = [[MDTaskFolder alloc] initWithDictionary:dic];
        handler(folder, error);
    }];
    
    return connection;

}


- (MDURLConnection *)addStageToFolder:(NSString *)folderID
                            stageName:(NSString *)stageName
                                 sort:(NSInteger)sort
                              handler:(MDAPINSStringHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/addFolderV4?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    [urlString appendFormat:@"&stageName=%@", stageName];
    [urlString appendFormat:@"&sort=%ld", (long)sort];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];

    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSString *postID = [dic objectForKey:@"stageID"];
        handler(postID, error);
    }];
    return connection;
}

- (MDURLConnection *)saveStageNameWithFolderID:(NSString *)folderID
                                       stageID:(NSString *)stageID
                                  newStageName:(NSString *)stageName
                                       handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/editStageName.aspx?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    [urlString appendFormat:@"&t_sid=%@", stageID];
    [urlString appendFormat:@"&stageName=%@", stageName];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)validateStageNeedToTransferTasksBeforeDelete:(NSString *)folderID
                                                          stageID:(NSString *)stageID
                                                          handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/validateStageHasTask.aspx?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    [urlString appendFormat:@"&t_sid=%@", stageID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(NO, error);
            return ;
        }
        
        if ([[dic objectForKey:@"isHas"] boolValue]) {
            handler(YES, error);
        } else {
            handler(NO, error);
        }
    }];
    return connection;
}

- (MDURLConnection *)deleteStageWithFolderID:(NSString *)folderID
                                     stageID:(NSString *)stageID
                                     handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/deleteFolderStage?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    [urlString appendFormat:@"&t_sid=%@", stageID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)editTaskToStageTaskID:(NSString *)taskID
                                  folderID:(NSString *)folderID
                             stageID:(NSString *)stageID
                             handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/editTaskStage?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@",folderID];
    [urlString appendFormat:@"&t_id=%@", taskID];
    [urlString appendFormat:@"&t_sid=%@", stageID];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;
}

- (MDURLConnection *)editFolderStageWithFolderID:(NSString *)folderID
                                         stageID:(NSString *)stageID
                                       stageName:(NSString *)stageName
                                            sort:(NSInteger)sort
                                         handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/editFolderStage?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    [urlString appendFormat:@"&t_folderID=%@", folderID];
    [urlString appendFormat:@"&t_sid=%@", stageID];
    if (stageName) {
        [urlString appendFormat:@"&stageName=%@", stageName];
    }
    [urlString appendFormat:@"&sort=%ld", (long)sort];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;

}


- (MDURLConnection *)editFolderOrTaskFavoriteWithFolderID:(NSString *)folderID taskID:(NSString *)taskID favorite:(NSInteger)favorite handler:(MDAPIBoolHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/editFolderOrTaskFavorite?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
    if (taskID) {
        [urlString appendFormat:@"&t_id=%@", taskID];
    }
    if (folderID) {
        [urlString appendFormat:@"&t_folderID=%@", folderID];
    }
    
    [urlString appendFormat:@"&isFavorite=%ld",(long)favorite];
    
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        [self handleBoolData:dic error:error URLString:urlString handler:handler];
    }];
    return connection;

}

- (MDURLConnection *)getFolderTaskListWithFolderID:(NSString *)folderID
                                           stageID:(NSString *)stageID
                                            status:(NSInteger)status
                                         pageindex:(NSInteger)pageindex
                                          pagesize:(NSInteger)pagesize
                                              sort:(NSInteger)sort
                                          keywords:(NSString *)keywords
                                       filterType:(NSInteger)filterType
                                           handler:(MDAPINSArrayHandler)handler
{
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/getFolderTaskList?format=json"];
    [urlString appendFormat:@"&access_token=%@", self.accessToken];
  
    
    if (folderID) {
        [urlString appendFormat:@"&t_folderID=%@", folderID];
    }

    if (stageID) {
        [urlString appendFormat:@"&t_sid=%@", stageID];
    } 

    
    [urlString appendFormat:@"&status=%ld",(long)status];
    [urlString appendFormat:@"&pageindex=%ld",(long)pageindex];

    [urlString appendFormat:@"&pagesize=%ld",(long)pagesize];

    if (keywords) {
        [urlString appendFormat:@"&keywords=%@",keywords];
    }
    [urlString appendFormat:@"&filter_type=%ld",(long)filterType];

    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSArray *tasks = [dic objectForKey:@"tasks"];
        NSMutableArray *stageArray = [NSMutableArray array];
        for (NSDictionary *stageDic in tasks) {
            NSMutableArray *tempArray = [[NSMutableArray alloc]init];
            if (![stageDic isKindOfClass:[NSDictionary class]])
                continue;
            MDTaskFolderStage *stage = [[MDTaskFolderStage alloc] initWithDictionary:stageDic];
            NSArray *taskArr = stageDic[@"tasks"];
            for (NSDictionary *taskDic in taskArr) {
                MDTask *task = [[MDTask alloc] initWithDictionary:taskDic];
                NSMutableDictionary *dic = [@{@"level":@0,@"open":@NO,@"task":task} mutableCopy];
                [tempArray addObject:dic];
            }
            [stageArray addObject:[@{@"stage":stage,@"tasks":tempArray} mutableCopy]];
        }
        handler(stageArray, error);
    }];
    
    return connection;
}


- (MDURLConnection *)createTaskV4AtFolderStageWithName:(NSString *)name
                                              parentID:(NSString *)parentID
                                                   des:(NSString *)des
                                               endDate:(NSString *)endDate
                                             chargerID:(NSString *)chargerID
                                               members:(NSString *)members
                                              folderID:(NSString *)folderID
                                                 color:(NSInteger)color
                                                postID:(NSString *)postID
                                               stageID:(NSString *)stageID
                                            isFavorite:(NSInteger)isFavorite
                                               handler:(MDAPINSStringHandler)handler
{
    
    NSMutableString *urlString = [self.serverAddress mutableCopy];
    [urlString appendString:@"/task/v4/addTask?format=json"];
    [urlString appendFormat:@"&access_token=%@",self.accessToken];
    
    NSMutableData *postBody = [NSMutableData data];
    NSString *urlStr = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [req setHTTPMethod:@"POST"];
    
    NSString *boundary = @"--------MINGDAO";
    NSString *boundaryPrefix = @"--";
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_title"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (des && des.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_des"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", des] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (endDate && endDate.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_ed"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", endDate] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"u_id"]dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", chargerID] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (members && members.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_mids"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", members] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (folderID && folderID.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_folderID"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", folderID] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (stageID.length > 0) {
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_sid"]dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", stageID] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    if (parentID && parentID.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"t_parentID"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", parentID] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (color >= 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"color"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%ld\r\n", (long)color] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (postID && postID.length > 0) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",@"p_id"]dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@\r\n", postID] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundaryPrefix] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"%@", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"--" dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
    [req setValue:contentType forHTTPHeaderField:@"Content-type"];
    [req setHTTPBody:postBody];
    
    MDURLConnection *connection = [[MDURLConnection alloc] initWithRequest:req handler:^(MDURLConnection *theConnection, NSDictionary *dic, NSError *error) {
        if (error) {
            handler(nil, error);
            return ;
        }
        
        NSString *taskID = [dic objectForKey:@"task"];
        handler(taskID, error);
    }];
    return connection;
}

@end