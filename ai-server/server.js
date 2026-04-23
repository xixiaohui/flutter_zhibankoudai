import express from "express";
import cors from "cors";

import { genkit } from "genkit";
import { googleAI } from "@genkit-ai/googleai";

// 初始化 Genkit
const ai = genkit({
  plugins: [googleAI()],
  model: "googleai/gemini-2.0-flash",
});

const app = express();
app.use(cors());
app.use(express.json());

// 👇 定义 AI 流程（重点）
const analyzeFlow = ai.defineFlow(
  {
    name: "analyzeFlow",
    inputSchema: z.object({
      query: z.string(),
    }),
    outputSchema: z.string(),
  },
  async ({ query }) => {
    const response = await ai.generate({
      prompt: `你是一个材料行业专家，请分析：

问题：${query}

要求：
1. 给出专业分析
2. 提供建议
3. 结构清晰`,
    });

    return response.text;
  }
);

// API 接口
app.post("/ai", async (req, res) => {
  const { query } = req.body;

  const result = await analyzeFlow({ query });

  res.json({ result });
});

app.listen(3000, () => {
  console.log("✅ Genkit AI server running: http://localhost:3000");
});