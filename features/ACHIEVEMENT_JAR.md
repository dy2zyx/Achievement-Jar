# Achievement Jar Storage Implementation
# 成就罐存储实现

This feature provides a visually appealing jar that stores all achievements, with animations and visual feedback as the jar fills up with achievements over time.
此功能提供一个视觉上吸引人的罐子，用于存储所有成就，随着时间的推移，当罐子中的成就增加时，会有动画和视觉反馈。

## Completed Tasks
## 已完成任务

- [x] Research jar visualization techniques and animation approaches
- [x] Design jar visualization concept with Ghibli-inspired aesthetic
- [x] Create basic jar UI component
- [x] Implement jar filling visualization logic
- [x] Implement achievement counter display
- [x] Connect storage with SwiftData (via @Query)

- [x] 研究罐子可视化技术和动画方法
- [x] 设计具有吉卜力风格美学的罐子可视化概念
- [x] 创建基本罐子UI组件
- [x] 实现罐子填充可视化逻辑
- [x] 实现成就计数器显示
- [x] 将存储与SwiftData连接 (通过 @Query)

## In Progress Tasks
## 进行中任务

- [ ] Implement jar interaction gestures (tap stats, shake, long press retrieval)
- [ ] 实现罐子交互手势（点击统计、摇晃、长按提取）

## Future Tasks
## 未来任务

- [ ] Create smooth animations for jar interactions
- [ ] Design visual indicators for jar fullness
- [ ] Create particle effects for jar glow/highlighting
- [ ] Design achievement density visualization
- [ ] Add jar customization options (Phase 3)
- [ ] Create unit tests for jar visualization logic
- [ ] Add UI tests for jar interactions

- [ ] 创建罐子交互的流畅动画
- [ ] 设计罐子满度的视觉指示器
- [ ] 创建罐子发光/高亮的粒子效果
- [ ] 设计成就密度可视化
- [ ] 添加罐子自定义选项（第3阶段）
- [ ] 创建罐子可视化逻辑的单元测试
- [ ] 添加罐子交互的UI测试

## Implementation Plan
## 实施计划

The Achievement Jar Storage feature will be the visual centerpiece of the app, implemented with a focus on delightful animations and visual feedback:
成就罐存储功能将是应用程序的视觉中心，实现重点是愉悦的动画和视觉反馈：

1. **Jar Visualization**: Create a beautiful, Ghibli-inspired jar design with transparency to show contents
2. **Fill Mechanics**: Implement dynamic fill level based on achievement count
3. **Achievement Representation**: Design how individual achievements appear within the jar
4. **Animations**: Create smooth animations for adding to and retrieving from the jar
5. **Interaction**: Implement gesture recognizers for jar interaction

1. **罐子可视化**：创建美丽的、受吉卜力启发的罐子设计，带有透明度以显示内容
2. **填充机制**：基于成就数量实现动态填充水平
3. **成就表示**：设计单个成就在罐子内的显示方式
4. **动画**：为添加到罐子和从罐子中提取创建流畅的动画
5. **交互**：实现罐子交互的手势识别器

### Technical Approach
### 技术方法

- Use SwiftUI animations for smooth, performant animations
- Implement custom shape views for the jar design
- Use Canvas API for particle effects if needed
- Create reusable animation components for jar interactions
- Optimize rendering for performance

- 使用SwiftUI动画实现流畅、高性能的动画
- 为罐子设计实现自定义形状视图
- 如有需要，使用Canvas API实现粒子效果
- 为罐子交互创建可重用的动画组件
- 优化渲染以提高性能

### User Interactions
### 用户交互

- Tap jar to see brief stats about achievements
- Long press to manually retrieve a random achievement
- Shake phone to "stir" achievements (visual effect)
- Pinch to zoom in and see achievement details

- 点击罐子查看成就的简要统计信息
- 长按手动提取随机成就
- 摇晃手机"搅动"成就（视觉效果）
- 捏合缩放以查看成就详情

### Relevant Files
### 相关文件

- `Features/AchievementJar/Views/JarView.swift` - Main jar visualization 主要罐子可视化
- `Features/AchievementJar/ViewModels/JarViewModel.swift` - Jar state and logic 罐子状态和逻辑
- `UI/Components/JarShapeView.swift` - Custom jar shape drawing 自定义罐子形状绘制
- `UI/Animations/JarFillingAnimation.swift` - Animations for jar filling 罐子填充动画
- `UI/Animations/JarRetrievalAnimation.swift` - Animations for taking from jar 从罐子中提取的动画
- `Core/Extensions/Animation+Custom.swift` - Animation utilities 动画工具
- `Core/Helpers/AchievementVisualizer.swift` - Helpers for visualizing achievements in jar 在罐子中可视化成就的辅助工具

### Sample Jar Component Design
### 示例罐子组件设计

```swift
import SwiftUI

struct JarView: View {
    @ObservedObject var viewModel: JarViewModel
    @State private var isShaking = false
    
    var body: some View {
        ZStack {
            // Jar background and shape
            JarShapeView(fillPercentage: viewModel.fillPercentage)
                .shadow(radius: 5)
            
            // Achievement particles inside jar
            AchievementParticlesView(achievements: viewModel.visibleAchievements)
                .clipShape(JarShapeView(fillPercentage: 1.0).scale(0.95))
                .rotationEffect(isShaking ? Angle(degrees: 2) : Angle(degrees: -2))
                .animation(
                    isShaking ? 
                        .easeInOut(duration: 0.1).repeatForever(autoreverses: true) : 
                        .default, 
                    value: isShaking
                )
            
            // Jar lid
            JarLidView()
                .offset(y: -viewModel.jarHeight / 2)
        }
        .frame(width: viewModel.jarWidth, height: viewModel.jarHeight)
        .onTapGesture {
            viewModel.showStats()
        }
        .onLongPressGesture {
            viewModel.retrieveRandomAchievement()
        }
        .gesture(MagnificationGesture()
            .onChanged { value in
                viewModel.handleZoom(scale: value)
            }
        )
        .onShake {
            withAnimation {
                isShaking = true
            }
            
            // Stop shaking after a short duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    isShaking = false
                }
            }
        }
    }
}
``` 