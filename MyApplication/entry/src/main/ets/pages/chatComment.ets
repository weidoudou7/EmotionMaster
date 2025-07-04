import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { ApiService } from '../service/apiservice';
import { CommentItem } from '../common/types';
import { globalUserData } from '../models/userdata';

// 路由参数接口
interface CommentPageParams {
  aiRoleId?: number;
  aiRoleName?: string;
  aiRoleAvatar?: string;
  aiRoleType?: string;
  aiRoleDescription?: string;
  currentUserId?: number;
}

@Entry
@Component
export struct ChatCommentPage {
  @State private comments: CommentItem[] = [];
  @State private likedComments: Set<number> = new Set(); // 已点赞评论id集合
  @State private likeCounts: Record<number, number> = {};
  @State private heartScales: Record<number, number> = {}; // 爱心缩放状态
  @State private commentText: string = ''; // 输入框文本
  @State private aiRoleId: number = 1; // AI角色ID，从路由参数获取
  @State private currentUserId: number = 1; // 当前用户ID，从路由参数获取
  
  // AI角色信息
  @State private aiRoleName: string = 'AI角色';
  @State private aiRoleAvatar: string = '';
  @State private aiRoleType: string = 'default';
  @State private aiRoleDescription: string = '';

  @State private replyToComment: CommentItem | null = null; // 当前正在回复的评论
  @State private isActive: boolean = true; // 页面活跃标记
  @State private refreshKey: number = 0; // 强制刷新键
  @State private pendingDeleteCommentId: number | null = null; // 待删除的评论ID
  @State private deleteConfirmTimeout: number | null = null; // 删除确认超时定时器

  @State totalCount:number = 0;

  aboutToAppear() {
    this.isActive = true;
    // 获取路由参数
    const params = router.getParams() as CommentPageParams;
    if (params) {
      // 修正：aiRoleId必须用路由参数，不能写死
      if (typeof params.aiRoleId === 'number') {
        this.aiRoleId = params.aiRoleId;
      } else if (typeof params.aiRoleId === 'string' && params.aiRoleId !== '') {
        this.aiRoleId = parseInt(params.aiRoleId);
      }
      if (typeof params.currentUserId === 'number') {
        this.currentUserId = params.currentUserId;
      } else if (typeof params.currentUserId === 'string' && params.currentUserId !== '') {
        this.currentUserId = parseInt(params.currentUserId);
      }
      this.aiRoleName = params.aiRoleName || 'AI角色';
      this.aiRoleAvatar = params.aiRoleAvatar || '';
      this.aiRoleType = params.aiRoleType || 'default';
      this.aiRoleDescription = params.aiRoleDescription || '';
      console.info(`[评论] 路由参数 aiRoleId=${this.aiRoleId}, currentUserId=${this.currentUserId}`);
    }
    this.loadAllComments();
  }

  aboutToDisappear() {
    this.isActive = false;
    // 清理删除确认定时器
    if (this.deleteConfirmTimeout !== null) {
      clearTimeout(this.deleteConfirmTimeout);
      this.deleteConfirmTimeout = null;
    }
  }

  // 加载所有评论（包括主评论和回复）
  private async loadAllComments() {
    if (!this.isActive) return;
    try {
      console.info(`[评论] 开始加载所有评论，aiRoleId=${this.aiRoleId}`);
      const result = await ApiService.getCommentsByAiRoleId(this.aiRoleId, 1, 1000); // 一次性加载所有主评论
      const mainComments = result.comments;
      console.info(`[评论] 加载主评论完成，数量=${mainComments.length}`);

              // 为每个主评论加载所有回复
        for (const mainComment of mainComments) {
          try {
            const replyResult = await ApiService.getRepliesByRootCommentId(mainComment.id, 1, 1000); // 一次性加载所有回复
            mainComment.replies = replyResult.replies || [];
            mainComment.replyTotal = replyResult.totalCount || 0;
            console.info(`[评论] 主评论${mainComment.id}加载回复完成，数量=${mainComment.replies.length}`);
            // 调试：打印回复详情
            if (mainComment.replies && mainComment.replies.length > 0) {
              mainComment.replies.forEach((reply, index) => {
                console.info(`[评论] 回复${index + 1}: ID=${reply.id}, 内容=${reply.content}`);
              });
            }
          } catch (error) {
            console.error(`[评论] 加载主评论${mainComment.id}的回复失败:`, error);
            mainComment.replies = [];
            mainComment.replyTotal = 0;
          }
        }
      
      // 立即更新UI状态，确保数据能及时显示
      if (this.isActive) {
        // 先清空数组，然后重新赋值，确保UI能检测到变化
        this.comments = [];
        // 使用setTimeout确保UI能检测到数组变化
        setTimeout(() => {
          if (!this.isActive) return;
          this.comments = mainComments;
          this.comments.forEach(item => {
            this.likeCounts[item.id] = item.likeCount;
            this.heartScales[item.id] = 1;
            this.checkUserLikedStatus(item.id);
            // 为回复也设置点赞状态
            if (item.replies && Array.isArray(item.replies)) {
              item.replies.forEach(reply => {
                this.likeCounts[reply.id] = reply.likeCount;
                this.heartScales[reply.id] = 1;
                this.checkUserLikedStatus(reply.id);
              });
            }
          });
          console.info(`[评论] UI状态更新完成，主评论数量=${this.comments.length}`);
          // 打印每个主评论的回复数量，用于调试
          this.comments.forEach(item => {
            console.info(`[评论] 主评论${item.id}有${item.replies ? item.replies.length : 0}条回复`);
          });
          // 强制触发UI重新渲染
          this.refreshKey++;
        }, 10);
      }
    } catch (error) {
      setTimeout(() => {
        if (!this.isActive) return;
        console.error('[评论] 加载评论失败:', error);
        try {
          if (this.isActive) {
            promptAction.showToast({ message: '加载评论失败，请重试' });
          }
        } catch (error) {
          console.error('显示Toast失败:', error);
        }
      }, 100);
    }
  }

  // 检查用户点赞状态
  private async checkUserLikedStatus(commentId: number) {
    try {
      const result = await ApiService.checkUserLikedComment(commentId, this.currentUserId);
      if (result.isLiked) {
        setTimeout(() => {
          if (!this.isActive) return;
          this.likedComments.add(commentId);
        }, 100);
      }
    } catch (error) {
      setTimeout(() => {
        if (!this.isActive) return;
        console.error('检查点赞状态失败:', error);
      }, 100);
    }
  }

  // 发布评论方法
  private async publishComment() {
    if (!this.isActive || !this.commentText.trim()) {
      setTimeout(() => {
        if (!this.isActive) return;
        try {
          if (this.isActive) {
            promptAction.showToast({ message: '请输入评论内容' });
          }
        } catch (error) {
          console.error('显示Toast失败:', error);
        }
      }, 100);
      return;
    }
    try {
      const result = await ApiService.publishComment(this.aiRoleId, this.currentUserId, this.commentText.trim());
      // 立即清理输入状态
      if (this.isActive) {
        this.commentText = '';
      }
      // 发布成功后刷新整个评论列表
      await this.loadAllComments();
      setTimeout(() => {
        if (!this.isActive) return;
        try {
          if (this.isActive) {
            promptAction.showToast({ message: result.message });
          }
        } catch (error) {
          console.error('显示Toast失败:', error);
        }
      }, 100);
    } catch (error) {
      setTimeout(() => {
        if (!this.isActive) return;
        console.error('发布评论失败:', error);
        try {
          if (this.isActive) {
            promptAction.showToast({ message: '发布评论失败，请重试' });
          }
        } catch (toastError) {
          console.error('显示Toast失败:', toastError);
        }
      }, 100);
    }
  }

  // 点赞评论
  private async likeComment(commentId: number) {
    try {
      if (this.likedComments.has(commentId)) {
        const result = await ApiService.unlikeComment(commentId, this.currentUserId);
        if (result.success) {
                setTimeout(() => {
        if (!this.isActive) return;
        this.likedComments.delete(commentId);
        this.likeCounts[commentId] = Math.max(this.likeCounts[commentId] - 1, 0);
      }, 100);
        }
      } else {
        const result = await ApiService.likeComment(commentId, this.currentUserId);
        if (result.success) {
                  setTimeout(() => {
          if (!this.isActive) return;
          this.likedComments.add(commentId);
          this.likeCounts[commentId] = (this.likeCounts[commentId] || 0) + 1;
        }, 100);
        }
      }
      setTimeout(() => {
        if (!this.isActive) return;
        this.heartScales[commentId] = 1.3;
        setTimeout(() => {
          if (!this.isActive) return;
          this.heartScales[commentId] = 1;
        }, 200);
      }, 100);
    } catch (error) {
      setTimeout(() => {
        if (!this.isActive) return;
        console.error('点赞操作失败:', error);
        try {
          if (this.isActive) {
            promptAction.showToast({ message: '操作失败，请重试' });
          }
        } catch (error) {
          console.error('显示Toast失败:', error);
        }
      }, 100);
    }
  }

  // 删除评论（双击确认）
  private async deleteComment(commentId: number) {
    // 如果已经有待删除的评论，且是同一个评论，则执行删除
    if (this.pendingDeleteCommentId === commentId) {
      // 清理定时器
      if (this.deleteConfirmTimeout !== null) {
        clearTimeout(this.deleteConfirmTimeout);
        this.deleteConfirmTimeout = null;
      }
      
      // 重置待删除状态
      this.pendingDeleteCommentId = null;
      
      // 执行删除操作
      try {
        console.info(`[删除] 开始删除评论ID=${commentId}`);
        const result = await ApiService.deleteComment(commentId, this.currentUserId);
        console.info(`[删除] 删除结果:`, result);
        if (result.success) {
          // 立即清理相关状态
          this.likedComments.delete(commentId);
          this.likeCounts[commentId] = 0;
          this.heartScales[commentId] = 1;
          console.info(`[删除] 清理状态完成，开始刷新评论列表`);
          
          // 立即清空评论数组，强制UI更新
          this.comments = [];
          
          // 立即刷新评论列表
          await this.loadAllComments();
          console.info(`[删除] 评论列表刷新完成`);
          
          // 强制触发UI重新渲染
          this.refreshKey++;
          
          // 显示成功提示
          setTimeout(() => {
            if (!this.isActive) return;
            try {
              if (this.isActive) {
                promptAction.showToast({ message: '删除成功' });
              }
            } catch (error) {
              console.error('显示Toast失败:', error);
            }
          }, 100);
        } else {
          setTimeout(() => {
            if (!this.isActive) return;
            try {
              if (this.isActive) {
                promptAction.showToast({ message: result.message || '删除失败' });
              }
            } catch (error) {
              console.error('显示Toast失败:', error);
            }
          }, 100);
        }
      } catch (error) {
        setTimeout(() => {
          if (!this.isActive) return;
          console.error('删除评论失败:', error);
          try {
            if (this.isActive) {
              promptAction.showToast({ message: '删除失败，请重试' });
            }
          } catch (error) {
            console.error('显示Toast失败:', error);
          }
        }, 100);
      }
      return;
    }
    
    // 第一次点击删除，设置待删除状态
    this.pendingDeleteCommentId = commentId;
    
    // 显示确认提示
    try {
      if (this.isActive) {
        promptAction.showToast({ message: '再按一次删除' });
      }
    } catch (error) {
      console.error('显示确认提示失败:', error);
    }
    
    // 设置3秒超时，超时后重置状态
    this.deleteConfirmTimeout = setTimeout(() => {
      if (this.isActive) {
        this.pendingDeleteCommentId = null;
        this.deleteConfirmTimeout = null;
      }
    }, 3000);
  }

  // 格式化时间
  private formatTime(dateString: string): string {
    try {
      const date = new Date(dateString);
      const now = new Date();
      const diff = now.getTime() - date.getTime();
      
      const minutes = Math.floor(diff / (1000 * 60));
      const hours = Math.floor(diff / (1000 * 60 * 60));
      const days = Math.floor(diff / (1000 * 60 * 60 * 24));
      
      if (minutes < 1) return '刚刚';
      if (minutes < 60) return `${minutes}分钟前`;
      if (hours < 24) return `${hours}小时前`;
      if (days < 30) return `${days}天前`;
      
      return date.toLocaleDateString();
    } catch (error) {
      return '未知时间';
    }
  }

  // 发布回复方法
  private async publishReply() {
    if (!this.isActive || !this.replyToComment) return;
    try {
      const rootId = this.replyToComment.rootCommentId || this.replyToComment.id;
      const toId = this.replyToComment.id;
      const res = await ApiService.replyComment(
        this.aiRoleId,
        this.currentUserId,
        this.commentText.trim(),
        rootId,
        toId
      );
      // 立即清理输入状态
      if (this.isActive) {
        this.commentText = '';
        this.replyToComment = null;
      }
      // 回复成功后刷新整个评论列表
      await this.loadAllComments();
      // 使用setTimeout确保UI上下文存在
      setTimeout(() => {
        if (!this.isActive) return;
        // 使用try-catch包裹showToast调用
        try {
          if (this.isActive) {
            promptAction.showToast({ message: '回复成功' });
          }
        } catch (error) {
          console.error('显示Toast失败:', error);
        }
      }, 100);
    } catch (error) {
      setTimeout(() => {
        if (!this.isActive) return;
        console.error('回复评论失败:', error);
        // 使用try-catch包裹showToast调用
        try {
          if (this.isActive) {
            promptAction.showToast({ message: '回复评论失败，请重试' });
          }
        } catch (toastError) {
          console.error('显示Toast失败:', toastError);
        }
      }, 100);
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部栏
        Row() {
          Button('‹')
            .backgroundColor('transparent')
            .fontColor('#fff')
            .fontSize(24)
            .onClick(() => {
              router.back();
            })
          Blank().width(8)
          Text(`${this.aiRoleName}的评论区`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#fff')
            .layoutWeight(1)
        }
        .padding({ left: 12, right: 12, top: 12, bottom: 8 })
        .alignItems(VerticalAlign.Center)

        // 滚动内容区（包含用户信息和评论列表）
        List() {
          // AI角色信息卡片
          ListItem() {
            Row() {
              Image(this.aiRoleAvatar || 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg')
                .width(64).height(64)
                .borderRadius(32)
                .objectFit(ImageFit.Cover)
              Column() {
                Text(this.aiRoleName)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#fff')
                  .margin({ bottom: 2 })
                Text(`${this.aiRoleType}风格角色`)
                  .fontSize(14)
                  .fontColor('rgba(255,255,255,0.7)')
                  .margin({ bottom: 2 })
                Row() {
                  Text('类型：')
                    .fontSize(14)
                    .fontColor('rgba(255,255,255,0.7)')
                  Text(this.aiRoleType)
                    .fontSize(14)
                    .fontColor('#FFD700')
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 2 })
                }
              }
              .margin({ left: 12, right: 8 })
              .alignItems(HorizontalAlign.Start)
              Blank().layoutWeight(1)
              Column() {
                Button('返回聊天')
                  .fontColor('#FFD700')
                  .fontSize(16)
                  .border({ width: 1, color: '#FFD700' })
                  .borderRadius(20)
                  .backgroundColor('transparent')
                  .width(80)
                  .height(36)
                  .onClick(() => {
                    router.back();
                  })
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          }
          
          // 评论总数
          ListItem() {
            Text(`全部评论 ${this.comments.length}`)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#fff')
              .margin({ left: 5, top: 8, bottom: 8 })
          }
          
          // 评论列表
          if (this.comments.length === 0) {
            ListItem() {
              Row() {
                Text('暂无评论，快来抢沙发吧~')
                  .fontSize(16)
                  .fontColor('rgba(255,255,255,0.6)')
                  .margin({ top: 24, bottom: 24 })
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
          }
          ForEach(this.comments, (item: CommentItem, idx: number) => {
            ListItem() {
              Column() {
                // 主评论
                Row() {
                  Image(item.profileImage || 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg')
                    .width(44).height(44)
                    .borderRadius(22)
                  Column() {
                    Row() {
                      Text(item.username || '未知用户')
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#fff')
                      if (item.isAuthor) {
                        Text('作者')
                          .fontSize(12)
                          .fontColor('#FFD700')
                          .margin({ left: 4 })
                      }
                      if (item.isTop) {
                        Text('置顶')
                          .fontSize(12)
                          .fontColor('#fff')
                          .backgroundColor('#333')
                          .borderRadius(8)
                          .margin({ left: 4 })
                      }
                    }
                    Text(item.content)
                      .fontSize(15)
                      .fontColor('#fff')
                      .margin({ top: 2, bottom: 2, right: 16 })
                      .textOverflow({ overflow: TextOverflow.Clip })
                      .width('100%')
                    Row() {
                      Text(this.formatTime(item.createdAt))
                        .fontSize(12)
                        .fontColor('rgba(255,255,255,0.5)')
                      Text('回复')
                        .fontSize(12)
                        .fontColor('rgba(255,255,255,0.5)')
                        .margin({ left: 8 })
                        .onClick(() => {
                          this.replyToComment = item;
                          this.commentText = '';
                        })
                      // 删除主评论按钮（只有评论作者可以删除）
                      if (item.userId === this.currentUserId) {
                        Text('删除')
                          .fontSize(12)
                          .fontColor(this.pendingDeleteCommentId === item.id ? '#FF6B6B' : 'rgba(255,255,255,0.5)')
                          .fontWeight(this.pendingDeleteCommentId === item.id ? FontWeight.Bold : FontWeight.Normal)
                          .margin({ left: 8 })
                          .onClick(() => this.deleteComment(item.id))
                      }
                      Blank().layoutWeight(1)
                      // 爱心点赞
                      Text(this.likedComments.has(item.id) ? '❤️' : '🤍')
                        .fontSize(18)
                        .margin({ right: 2 })
                        .scale({ x: this.heartScales[item.id] || 1, y: this.heartScales[item.id] || 1 })
                        .animation({
                          duration: 200,
                          curve: Curve.EaseInOut
                        })
                        .onClick(() => this.likeComment(item.id))
                      Text(this.likeCounts[item.id] !== undefined ? this.likeCounts[item.id].toString() : item.likeCount.toString())
                        .fontSize(12)
                        .fontColor('rgba(255,255,255,0.5)')
                        .margin({ right: 16 })
                    }
                  }
                  .margin({ left: 10, right: 0 })
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .width('100%')
                }
                .width('100%')
                .padding({ top: 10, bottom: 10, left: 16, right: 0 })
                
                                // 渲染所有回复
                if (item.replies && Array.isArray(item.replies) && item.replies.length > 0) {
                  ForEach(item.replies, (reply: CommentItem, ridx: number) => {
                    Row() {
                      Image(reply.profileImage || 'https://img.zcool.cn/community/01b6c95d5b2e2fa801216518a8e3e2.jpg')
                        .width(32).height(32)
                        .borderRadius(16)
                      Column() {
                        Row() {
                          Text(reply.username || '未知用户')
                            .fontSize(14)
                            .fontColor('#FFD700')
                          if (reply.isAuthor) {
                            Text('作者')
                              .fontSize(11)
                              .fontColor('#FFD700')
                              .margin({ left: 4 })
                          }
                        }
                        Text(reply.content)
                          .fontSize(14)
                          .fontColor('#fff')
                          .margin({ top: 2, bottom: 2, right: 16 })
                          .textOverflow({ overflow: TextOverflow.Clip })
                          .width('100%')
                        Row() {
                          Text(this.formatTime(reply.createdAt))
                            .fontSize(11)
                            .fontColor('rgba(255,255,255,0.5)')
                          Text('回复')
                            .fontSize(11)
                            .fontColor('rgba(255,255,255,0.5)')
                            .margin({ left: 8 })
                            .onClick(() => {
                              this.replyToComment = reply;
                              this.commentText = '';
                            })
                          // 删除回复按钮（只有回复作者可以删除）
                          if (reply.userId === this.currentUserId) {
                            Text('删除')
                              .fontSize(11)
                              .fontColor(this.pendingDeleteCommentId === reply.id ? '#FF6B6B' : 'rgba(255,255,255,0.5)')
                              .fontWeight(this.pendingDeleteCommentId === reply.id ? FontWeight.Bold : FontWeight.Normal)
                              .margin({ left: 8 })
                              .onClick(() => this.deleteComment(reply.id))
                          }
                          Blank().layoutWeight(1)
                          Text(this.likedComments.has(reply.id) ? '❤️' : '🤍')
                            .fontSize(15)
                            .margin({ right: 2 })
                            .scale({ x: this.heartScales[reply.id] || 1, y: this.heartScales[reply.id] || 1 })
                            .animation({
                              duration: 200,
                              curve: Curve.EaseInOut
                            })
                            .onClick(() => this.likeComment(reply.id))
                          Text(this.likeCounts[reply.id] !== undefined ? this.likeCounts[reply.id].toString() : reply.likeCount.toString())
                            .fontSize(11)
                            .fontColor('rgba(255,255,255,0.5)')
                            .margin({ right: 16 })
                        }
                      }
                      .margin({ left: 10, right: 0 })
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      .width('100%')
                    }
                    .width('100%')
                    .padding({ top: 6, bottom: 6, left: 60, right: 0 }) // 缩进显示
                  }, (reply: CommentItem) => reply.id.toString())
                }
              }
            }
          }, (item: CommentItem) => item.id.toString())
        }
        .width('100%')
        .layoutWeight(1)

        // 发送框上方显示"正在回复"
        if (this.replyToComment) {
          Row() {
            Text(`正在回复 @${this.replyToComment.username}：`)
              .fontSize(13)
              .fontColor('#FFD700')
            Button('取消')
              .fontSize(12)
              .fontColor('#fff')
              .backgroundColor('transparent')
              .onClick(() => {
                this.replyToComment = null;
                this.commentText = '';
              })
          }
          .margin({ bottom: 4 })
        }
        // 发送框
        Row() {
          TextInput({ 
            placeholder: this.replyToComment ? `回复 @${this.replyToComment.username}` : '发送善意的评论',
            text: this.commentText
          })
            .height(40)
            .backgroundColor('rgba(255, 254, 254, 0.05)')
            .fontColor('#fffcfcfc')
            .borderRadius(20)
            .padding({ left: 20 })
            .onChange((value: string) => {
              this.commentText = value;
            })
            .layoutWeight(1)

          Blank().width(8)

          Button('发送')
            .backgroundColor(this.commentText.trim() ? '#FFD700' : 'rgba(255,255,255,0.3)')
            .fontColor(this.commentText.trim() ? '#000' : 'rgba(255,255,255,0.5)')
            .borderRadius(20)
            .width(50)
            .height(40)
            .onClick(() => {
              if (this.commentText.trim()) {
                if (this.replyToComment) {
                  this.publishReply();
                } else {
                  this.publishComment();
                }
              }
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
        .zIndex(10)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#181818')
  }
} 