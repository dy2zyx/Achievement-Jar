# Achievement Retrieval Implementation
# 成就提取实现

This feature implements a system for randomly pulling past achievements for review, with both automatic and manual retrieval options and delightful animations.
此功能实现了一个系统，用于随机提取过去的成就进行回顾，具有自动和手动提取选项以及愉悦的动画。

## Completed Tasks
## 已完成任务

- [x] Design feature concept and user flow
- [x] Design retrieval algorithm requirements
- [x] Create UI mockup for retrieved achievement display (basic view created)
- [x] Implement random selection algorithm (weighted, non-repeating within session)
- [x] Build retrieved achievement detail view
- [x] Add manual retrieval trigger gesture (button added)

- [x] 设计功能概念和用户流程
- [x] 设计提取算法需求
- [x] 创建已提取成就显示的UI模型 (已创建基本视图)
- [x] 实现随机选择算法 (加权, 会话内不重复)
- [x] 构建已提取成就详情视图
- [x] 添加手动提取触发手势 (已添加按钮)

## In Progress Tasks
## 进行中任务

- [ ] Define retrieval frequency options
- [ ] Implement retrieval animation (basic feedback added)
- [ ] Create retrieval history tracking

- [ ] 定义提取频率选项
- [ ] 实现提取动画 (已添加基本反馈)
- [ ] 创建提取历史跟踪

## Future Tasks
## 未来任务

- [ ] Create daily retrieval scheduler
- [ ] Implement notification for daily retrieval
- [ ] Add reflection/note option for retrieved achievements
- [ ] Create unit tests for retrieval algorithm
- [ ] Add UI tests for retrieval interaction
- [ ] Persist recently retrieved IDs across sessions (using UserDefaults)

- [ ] 创建每日提取调度程序
- [ ] 实现每日提取通知
- [ ] 为已提取成就添加反思/笔记选项
- [ ] 创建提取算法的单元测试
- [ ] 添加提取交互的UI测试
- [ ] 跨会话持久化最近提取的ID (使用 UserDefaults)

## Implementation Plan
## 实施计划

The Achievement Retrieval feature will provide users with a delightful way to rediscover their past achievements:
成就提取功能将为用户提供一种愉悦的方式来重新发现他们过去的成就：

1. **Retrieval Algorithm**: Implement weighted random selection with recency bias
2. **Scheduling**: Create a configurable schedule for automatic retrievals
3. **Notification**: Implement notifications for scheduled retrievals
4. **Animation**: Design beautiful animation for retrieving from jar
5. **Presentation**: Create engaging UI for displaying retrieved achievements

1. **提取算法**：实现带有近期偏好的加权随机选择
2. **调度**：为自动提取创建可配置的计划
3. **通知**：为计划提取实现通知
4. **动画**：为从罐子中提取设计精美的动画
5. **展示**：创建吸引人的UI来显示已提取的成就

### Retrieval Algorithm Requirements
### 提取算法需求

- Truly random selection but with non-repetition guarantees
- Configurable weighting based on achievement age (optional)
- Category-based retrieval options (future enhancement)
- Tracking of previously retrieved items
- Automatic reset of "viewed" status after certain period

- 真正的随机选择但保证不重复
- 基于成就年龄的可配置权重（可选）
- 基于类别的提取选项（未来增强）
- 跟踪先前提取的项目
- 一定时期后自动重置"已查看"状态

### User Flow
### 用户流程

1. User receives notification that an achievement was retrieved (if scheduled)
2. User opens app to see highlighted retrieved achievement
3. Achievement is displayed with original date and any categories/tags
4. User can add a reflection on how they feel about this achievement now
5. User can manually trigger another retrieval if desired

1. 用户收到成就已被提取的通知（如果已计划）
2. 用户打开应用查看高亮显示的已提取成就
3. 成就显示原始日期和任何类别/标签
4. 用户可以添加有关他们现在对这一成就的感受的反思
5. 如果需要，用户可以手动触发另一次提取

### Relevant Files
### 相关文件

- `Features/AchievementRetrieval/ViewModels/RetrievalViewModel.swift` - Retrieval business logic 提取业务逻辑
- `Features/AchievementRetrieval/Views/RetrievedAchievementView.swift` - Achievement display 成就显示
- `Features/AchievementRetrieval/Services/RetrievalScheduler.swift` - Scheduling logic 调度逻辑
- `Features/AchievementRetrieval/Services/RetrievalAlgorithm.swift` - Selection algorithm 选择算法
- `UI/Animations/JarRetrievalAnimation.swift` - Animation for retrieving from jar 从罐子中提取的动画
- `Core/Helpers/NotificationManager.swift` - Notification handling 通知处理
- `Data/Repositories/RetrievalHistoryRepository.swift` - History tracking 历史跟踪

### Retrieval Algorithm Implementation
### 提取算法实现

```swift
import Foundation
import SwiftData

class RetrievalAlgorithm {
    // Weights for different time periods to balance recency with diversity
    private let weights = [
        0...7: 0.5,      // Last week: 50% lower chance
        8...30: 0.8,     // Last month: 20% lower chance
        31...90: 1.0,    // Last 3 months: Normal chance
        91...180: 1.2,   // Last 6 months: 20% higher chance
        181...365: 1.5,  // Last year: 50% higher chance
        366...Int.max: 2.0 // Older than a year: Double chance
    ]
    
    // Blacklist of recently retrieved IDs to avoid repetition
    private var recentlyRetrievedIDs: [String] = []
    private let maxRecentIDs = 10 // Don't repeat the last 10 retrieved items
    
    // Gets a weighted random achievement, favoring older and less recently viewed items
    func retrieveRandomAchievement(from achievements: [Achievement]) -> Achievement? {
        guard !achievements.isEmpty else { return nil }
        
        // Filter out recently retrieved achievements if possible
        var eligibleAchievements = achievements
        if eligibleAchievements.count > maxRecentIDs {
            eligibleAchievements = eligibleAchievements.filter { 
                !recentlyRetrievedIDs.contains($0.id.uuidString)
            }
        }
        
        // Apply weights based on age and recency
        let weightedAchievements = eligibleAchievements.map { achievement -> (Achievement, Double) in
            let daysOld = Calendar.current.dateComponents([.day], 
                         from: achievement.timestamp, 
                         to: Date()).day ?? 0
            
            let ageWeight = getWeightForAge(daysOld)
            let recencyWeight = achievement.lastRetrievedDate == nil ? 
                                1.5 : // Bonus for never retrieved
                                getWeightForLastRetrieved(achievement.lastRetrievedDate!)
            
            return (achievement, ageWeight * recencyWeight)
        }
        
        // Select a random achievement based on weights
        let totalWeight = weightedAchievements.reduce(0) { $0 + $1.1 }
        let randomValue = Double.random(in: 0..<totalWeight)
        
        var cumulativeWeight = 0.0
        for (achievement, weight) in weightedAchievements {
            cumulativeWeight += weight
            if randomValue < cumulativeWeight {
                // Update tracking
                updateRecentlyRetrievedList(achievement.id.uuidString)
                return achievement
            }
        }
        
        // Fallback to ensure something is returned
        return achievements.randomElement()
    }
    
    private func getWeightForAge(_ daysOld: Int) -> Double {
        for (range, weight) in weights {
            if range.contains(daysOld) {
                return weight
            }
        }
        return 1.0 // Default weight
    }
    
    private func getWeightForLastRetrieved(_ date: Date) -> Double {
        let daysSinceLastRetrieved = Calendar.current.dateComponents([.day], 
                                    from: date, 
                                    to: Date()).day ?? 0
        return min(2.0, Double(daysSinceLastRetrieved) / 30.0 + 0.5)
    }
    
    private func updateRecentlyRetrievedList(_ id: String) {
        recentlyRetrievedIDs.append(id)
        if recentlyRetrievedIDs.count > maxRecentIDs {
            recentlyRetrievedIDs.removeFirst()
        }
    }
}
``` 