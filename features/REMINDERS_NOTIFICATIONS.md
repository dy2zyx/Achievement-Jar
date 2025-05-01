# Reminders & Notifications Implementation
# 提醒与通知实现

This feature implements gentle prompts to encourage regular achievement recording and notify users of retrieved achievements, with customizable settings and positive messaging.
此功能实现温和的提示，以鼓励定期记录成就并通知用户已提取的成就，具有可自定义的设置和积极的消息传递。

## Completed Tasks
## 已完成任务

- [x] Define notification requirements and types
- [x] 定义通知需求和类型

## In Progress Tasks
## 进行中任务

- [ ] Research iOS notification best practices
- [ ] Design notification settings UI
- [ ] Draft notification message templates

- [ ] 研究iOS通知最佳实践
- [ ] 设计通知设置UI
- [ ] 起草通知消息模板

## Future Tasks
## 未来任务

- [ ] Implement notification permission handling
- [ ] Create reminder scheduling system
- [ ] Build notification settings UI
- [ ] Implement custom notification frequency
- [ ] Create positive, encouraging notification copy
- [ ] Add achievement retrieval notifications
- [ ] Implement streak milestone notifications
- [ ] Design non-intrusive notification style
- [ ] Add notification action buttons
- [ ] Create unit tests for notification scheduling
- [ ] Add UI tests for notification settings

- [ ] 实现通知权限处理
- [ ] 创建提醒调度系统
- [ ] 构建通知设置UI
- [ ] 实现自定义通知频率
- [ ] 创建积极、鼓励性的通知文案
- [ ] 添加成就提取通知
- [ ] 实现连续记录里程碑通知
- [ ] 设计非侵入式通知样式
- [ ] 添加通知操作按钮
- [ ] 创建通知调度的单元测试
- [ ] 添加通知设置的UI测试

## Implementation Plan
## 实施计划

The Reminders & Notifications feature will provide gentle, customizable prompts to engage with the app:
提醒与通知功能将提供温和、可自定义的提示，以促进与应用程序的互动：

1. **Permission Handling**: Gracefully request and handle notification permissions
2. **Reminder System**: Implement customizable schedule for achievement reminders
3. **Settings UI**: Create user-friendly notification preference controls
4. **Content Creation**: Design positive, encouraging notification messages
5. **Action Buttons**: Add quick-action buttons to notifications where appropriate

1. **权限处理**：优雅地请求和处理通知权限
2. **提醒系统**：为成就提醒实现可自定义的计划
3. **设置UI**：创建用户友好的通知偏好控制
4. **内容创建**：设计积极、鼓励性的通知消息
5. **操作按钮**：在适当的地方为通知添加快速操作按钮

### Notification Types
### 通知类型

#### Achievement Reminders
#### 成就提醒

- Customizable frequency (daily, every few days, weekly)
- Customizable time of day
- Varied, positive messaging
- Quick-add action button

- 可自定义频率（每日、每隔几天、每周）
- 可自定义的每日时间
- 多样化、积极的消息传递
- 快速添加操作按钮

#### Retrieval Notifications
#### 提取通知

- Alert when a random achievement is retrieved
- Preview of the achievement (if permitted by OS)
- View action button

- 当随机提取成就时发出提醒
- 成就预览（如果操作系统允许）
- 查看操作按钮

#### Milestone Notifications
#### 里程碑通知

- Streak achievements
- Count milestones (10th, 50th, 100th achievement)
- Monthly/yearly summaries

- 连续记录成就
- 计数里程碑（第10、50、100个成就）
- 每月/每年总结

### User Preferences
### 用户偏好

- Ability to toggle each notification type
- Time of day preferences
- Frequency control
- Option to disable all notifications
- Notification style preferences

- 切换每种通知类型的能力
- 每日时间偏好
- 频率控制
- 禁用所有通知的选项
- 通知样式偏好

### Technical Implementation
### 技术实现

- Use UNUserNotificationCenter for scheduling
- Implement notification categories and actions
- Create a notification content generator for varied messaging
- Build a robust scheduling system that respects user preferences

- 使用UNUserNotificationCenter进行调度
- 实现通知类别和操作
- 创建用于多样化消息的通知内容生成器
- 构建尊重用户偏好的健壮调度系统

### Relevant Files
### 相关文件

- `Features/Notifications/Services/NotificationManager.swift` - Core notification handling 核心通知处理
- `Features/Notifications/Services/NotificationScheduler.swift` - Scheduling logic 调度逻辑
- `Features/Notifications/Services/NotificationContentGenerator.swift` - Message creation 消息创建
- `Features/Notifications/ViewModels/NotificationSettingsViewModel.swift` - Settings logic 设置逻辑
- `Features/Notifications/Views/NotificationSettingsView.swift` - Settings UI 设置UI
- `Core/Helpers/UserDefaultsManager.swift` - Preference storage 偏好存储
- `Core/Extensions/UNNotificationContent+Achievement.swift` - Notification utilities 通知工具

### Sample Notification Settings UI
### 示例通知设置UI

```swift
import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: NotificationSettingsViewModel
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Allow Notifications", isOn: $viewModel.notificationsEnabled)
                    .onChange(of: viewModel.notificationsEnabled) { _, enabled in
                        if enabled {
                            viewModel.requestNotificationPermissions { granted in
                                if !granted {
                                    showingPermissionAlert = true
                                    viewModel.notificationsEnabled = false
                                }
                            }
                        }
                    }
            } header: {
                Text("General")
            } footer: {
                Text("Enable notifications to receive reminders and updates")
            }
            
            if viewModel.notificationsEnabled {
                Section {
                    Toggle("Daily Reminders", isOn: $viewModel.dailyRemindersEnabled)
                    
                    if viewModel.dailyRemindersEnabled {
                        DatePicker(
                            "Remind me at",
                            selection: $viewModel.reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        
                        Picker("Frequency", selection: $viewModel.reminderFrequency) {
                            Text("Daily").tag(NotificationFrequency.daily)
                            Text("Every 3 days").tag(NotificationFrequency.threeDays)
                            Text("Weekly").tag(NotificationFrequency.weekly)
                        }
                    }
                } header: {
                    Text("Achievement Reminders")
                } footer: {
                    Text("Get gentle reminders to record your achievements")
                }
                
                Section {
                    Toggle("Retrieval Notifications", isOn: $viewModel.retrievalNotificationsEnabled)
                    
                    if viewModel.retrievalNotificationsEnabled {
                        Toggle("Include Achievement Preview", isOn: $viewModel.includeAchievementPreview)
                    }
                } header: {
                    Text("Retrieval Notifications")
                } footer: {
                    Text("Get notified when the app retrieves a past achievement for you to revisit")
                }
                
                Section {
                    Toggle("Milestone Celebrations", isOn: $viewModel.milestoneNotificationsEnabled)
                    
                    if viewModel.milestoneNotificationsEnabled {
                        Toggle("Streak Milestones", isOn: $viewModel.streakMilestonesEnabled)
                        Toggle("Count Milestones", isOn: $viewModel.countMilestonesEnabled)
                        Toggle("Monthly Summaries", isOn: $viewModel.monthlySummariesEnabled)
                    }
                } header: {
                    Text("Milestone Notifications")
                } footer: {
                    Text("Celebrate your progress with milestone notifications")
                }
                
                Section {
                    Picker("Notification Style", selection: $viewModel.notificationStyle) {
                        Text("Cheerful").tag(NotificationStyle.cheerful)
                        Text("Gentle").tag(NotificationStyle.gentle)
                        Text("Minimal").tag(NotificationStyle.minimal)
                    }
                    
                    Button("Preview Notification") {
                        viewModel.sendPreviewNotification()
                    }
                    .foregroundColor(.blue)
                } header: {
                    Text("Appearance")
                }
            }
        }
        .navigationTitle("Notifications")
        .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
            Button("Open Settings", role: .none) {
                viewModel.openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications for this app in your device settings to receive reminders.")
        }
        .onAppear {
            viewModel.checkNotificationStatus()
        }
    }
}

enum NotificationFrequency: String, CaseIterable, Identifiable {
    case daily = "daily"
    case threeDays = "three_days"
    case weekly = "weekly"
    
    var id: String { self.rawValue }
}

enum NotificationStyle: String, CaseIterable, Identifiable {
    case cheerful = "cheerful"
    case gentle = "gentle"
    case minimal = "minimal"
    
    var id: String { self.rawValue }
}
``` 