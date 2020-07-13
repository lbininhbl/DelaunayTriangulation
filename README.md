# DelaunayTriangulation
Delaunay三角剖分的逐点插入实现的swift版

算法参考 http://paulbourke.net/papers/triangulate/ 中的 c 语言版实现

思路分析参考 https://www.cnblogs.com/zhiyishou/p/4430017.html ，这里对比原版，进行了坐标x排序优化。实际使用中，可能不希望原坐标点顺序被改动，所以按实际需要，在三角形遍历中选择性的注释掉`跳过当前已判定为 Delaunay 三角形`的逻辑。因为如果在坐标点没有排序的情况下，依然保留跳过逻辑的话，会过早地判定三角形为 Delaunay 三角形，从而导致误判且最终会出现离散点的情况。

