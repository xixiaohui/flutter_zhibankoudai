import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json());

app.post("/ai", async (req, res) => {
  const { query } = req.body;

  // 👉 模拟AI（先跑通）
  const result = `你问的是：${query}

分析结果：
1. 当前市场趋势上升
2. 建议关注原材料价格
3. 可考虑提前采购`;

  res.json({ result });
});

app.listen(3000, () => {
  console.log("AI server running on http://localhost:3000");
});