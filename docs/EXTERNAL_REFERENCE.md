# Historical ratings and observed data

Checked 2026-10-26. Ratings below are the publishers' opinions, not verified weapon statistics or ground-truth labels.

| Publisher / S24-labelled article | R-301 | Flatline | CAR | Version caveat |
|---|---|---|---|---|
| esports.gg | C | B | B | Explicitly includes a mid-season patch; exact snapshot date not established |
| bo3.gg | A | A | C | Exact patch alignment not established; some mechanics/stat claims require independent checking |

Sources:
- https://esports.gg/news/apex-legends/apex-weapon-tier-list/
- https://bo3.gg/games/articles/ranking-the-best-weapons-season-24-in-apex-legends

## 对模型的参考意义

R-301 的评价强调稳定、易用和低后坐力：提示实际 p 随武器改变，支持本项目不做同 p 的全武器排名。Flatline 的相对评价受到竞争武器增强影响：自身效率改善不保证相对等级上升。CAR 的评价涉及弹匣及激光瞄准器：不能把其评价变化全部解释成身体伤害 +1 的效果。

两个网站分级不同，也可能对应不同补丁时点、受众和评价尺度。没有配对 S23/S24 历史快照，不能计算可靠的“评级变化”，不进行等级数值化回归、Spearman 相关或拟合权重。项目只作机制解释与遗漏因素的案例讨论。

排除依据理想命中 TTK 自动生成的榜单作为独立实战验证：它们与本模型可能共享输入与数学机制。

## ALGS 可用性审计（背景参考）

此前保存的 Y5 Split1 Americas Day1 A vs B 六局记录中，各武器均有一条 hits='-'。只汇总 shots/hits 都为有效数字的五局：

| Weapon | Shots | Hits | Pooled hits/shots |
|---|---:|---:|---:|
| R-301 | 1181 | 101 | 8.55% |
| Flatline | 792 | 103 | 13.01% |
| CAR | 703 | 80 | 11.38% |

这些统计由之前缓存的记录得到，本项目只保留摘要，不提供完整原始记录，因而此部分不是随包独立复现的采集结果。它不参与任何模型拟合。若将 '-' 假设为 0，则六局汇总分别为 8.21%、12.73%、10.87%；该解释未确认，不能默认采用。

源站页面：
https://apexlegendsstatus.com/algs/Y5-Split1/Pro-League/NA/Day1/AvB/9cbe79c431f5f70100f4724826592c42

源站说明 hits 按子弹或适用的弹丸计数；FWR=knockdowns/(knockdowns+times knocked)，并非本项目的一梭子完成概率。整局比例混合玩家、距离、目标与射击目的，不能直接视为固定交战 p；没有交战内顺序和分组，也无法估计本项目的 rho。

开发者关于后台事件数据的说明：https://hde.gg/posts/2026-01-20-algs-stats-backend-on-als/

后台保存事件不等于原始日志公开可下载。本次进一步读取前端脚本遇到 HTTP 403，未取得新玩家级或交战级数据，未绕过访问限制。
